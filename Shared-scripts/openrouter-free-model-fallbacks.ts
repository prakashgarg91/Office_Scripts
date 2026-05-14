export const OPENROUTER_POPULARITY_WINDOWS = [
    { id: 'week', days: 7 },
    { id: 'month', days: 30 },
    { id: 'threeMonths', days: 90 },
] as const

export type OpenRouterPopularityWindow = typeof OPENROUTER_POPULARITY_WINDOWS[number]['id']

export interface OpenRouterCatalogModel {
    id: string;
    canonical_slug?: string;
    name?: string;
    created?: number;
    pricing?: {
        prompt?: string;
        completion?: string;
    };
    architecture?: {
        modality?: string;
        input_modalities?: string[];
        output_modalities?: string[];
    };
}

export interface OpenRouterFreeModel {
    id: string;
    name: string;
    created: number;
    canonicalSlug?: string;
}

export interface OpenRouterRankingPoint {
    x: string;
    ys: Record<string, number>;
}

export interface OpenRouterPopularityFallback {
    window: OpenRouterPopularityWindow;
    model: OpenRouterFreeModel;
    tokens: number;
}

export function isOpenRouterFreeTextModel(model: OpenRouterCatalogModel): boolean {
    const promptPrice = Number.parseFloat(model.pricing?.prompt ?? Number.NaN)
    const completionPrice = Number.parseFloat(model.pricing?.completion ?? Number.NaN)
    const isFree = model.id.endsWith(':free') || (
        Number.isFinite(promptPrice) &&
        Number.isFinite(completionPrice) &&
        promptPrice === 0 &&
        completionPrice === 0
    )

    if (!isFree) {
        return false
    }

    if (!model.architecture) {
        return true
    }

    const inputModalities = model.architecture.input_modalities ?? []
    const outputModalities = model.architecture.output_modalities ?? []

    if (outputModalities.length > 0 && !outputModalities.includes('text')) {
        return false
    }

    return inputModalities.length === 0 || inputModalities.every((modality) => modality === 'text')
}

export function getOpenRouterModelAliases(model: OpenRouterFreeModel): Set<string> {
    const aliases = new Set<string>()
    const baseId = model.id.replace(/:free$/, '')

    aliases.add(model.id)
    aliases.add(baseId)

    if (model.canonicalSlug) {
        aliases.add(model.canonicalSlug)
        aliases.add(`${model.canonicalSlug}:free`)
        aliases.add(model.canonicalSlug.replace(/:free$/, ''))
    }

    return aliases
}

export function matchOpenRouterRankedModelId(
    rankedModelId: string,
    liveModels: OpenRouterFreeModel[],
): OpenRouterFreeModel | null {
    const normalizedRankedId = rankedModelId.replace(/^openrouter\//, '')
    const rankedBaseId = normalizedRankedId.replace(/:free$/, '')

    return liveModels.find((model) => {
        const aliases = getOpenRouterModelAliases(model)
        return aliases.has(normalizedRankedId) || aliases.has(rankedBaseId) || aliases.has(`${rankedBaseId}:free`)
    }) ?? null
}

export function parseOpenRouterWeeklyLeaderboard(html: string): string[] {
    const sectionMatch = html.match(/<div class="flex flex-col gap-5">.*?Show more/si)
    if (!sectionMatch) {
        return []
    }

    const rows = [...sectionMatch[0].matchAll(/col-span-1 text-left">(\d+)<!-- -->\.<\/div>.*?href="\/([^"]+)"[^>]*>[^<]+<\/a>.*?<div>([\d.]+[KMBT])<!-- --> tokens<\/div>/gsi)]

    return rows
        .sort((left, right) => Number.parseInt(left[1], 10) - Number.parseInt(right[1], 10))
        .map((match) => match[2])
}

export function parseOpenRouterRankingHistory(html: string): OpenRouterRankingPoint[] {
    const matches = [...html.matchAll(/\\?"data\\?":\[(.*?)\],\\?"forecast\\?":\\?"forecast-1w\\?",\\?"forecastFromTimestamp\\?":\d+/gs)]

    for (const match of matches) {
        try {
            const history = JSON.parse(`[${match[1].replace(/\\"/g, '"')}]`) as OpenRouterRankingPoint[]
            if (history.some((point) => Object.keys(point.ys ?? {}).some((key) => key.includes('/')))) {
                return history
            }
        } catch {
            continue
        }
    }

    return []
}

export function getMostPopularOpenRouterFreeModel(
    rankingPoints: OpenRouterRankingPoint[],
    liveModels: OpenRouterFreeModel[],
): { model: OpenRouterFreeModel; tokens: number } | null {
    const totals = new Map<string, { model: OpenRouterFreeModel; tokens: number }>()

    for (const point of rankingPoints) {
        for (const [rankedModelId, tokens] of Object.entries(point.ys ?? {})) {
            const liveModel = matchOpenRouterRankedModelId(rankedModelId, liveModels)
            if (!liveModel) {
                continue
            }

            const current = totals.get(liveModel.id)
            totals.set(liveModel.id, {
                model: liveModel,
                tokens: (current?.tokens ?? 0) + tokens,
            })
        }
    }

    return [...totals.values()].sort((left, right) => right.tokens - left.tokens)[0] ?? null
}

export function buildOpenRouterPopularityFallbacks(
    html: string,
    liveModels: OpenRouterFreeModel[],
): OpenRouterPopularityFallback[] {
    const history = parseOpenRouterRankingHistory(html)
    const latestHistoryPoint = history.at(-1)
    const latestHistoryDate = latestHistoryPoint ? new Date(`${latestHistoryPoint.x}T00:00:00Z`) : null
    const fallbackModels: OpenRouterPopularityFallback[] = []
    const seen = new Set<string>()

    const weeklyLeaderboardIds = parseOpenRouterWeeklyLeaderboard(html)
    for (const rankedModelId of weeklyLeaderboardIds) {
        const liveModel = matchOpenRouterRankedModelId(rankedModelId, liveModels)
        if (!liveModel || seen.has(liveModel.id)) {
            continue
        }

        seen.add(liveModel.id)
        fallbackModels.push({
            window: 'week',
            model: liveModel,
            tokens: 0,
        })
        break
    }

    if (latestHistoryDate) {
        for (const window of OPENROUTER_POPULARITY_WINDOWS.filter((candidate) => candidate.id !== 'week')) {
            const fromTimestamp = latestHistoryDate.getTime() - (window.days * 24 * 60 * 60 * 1000)
            const windowPoints = history.filter((point) => {
                const pointTimestamp = new Date(`${point.x}T00:00:00Z`).getTime()
                return pointTimestamp >= fromTimestamp
            })
            const winner = getMostPopularOpenRouterFreeModel(windowPoints, liveModels)

            if (!winner || seen.has(winner.model.id)) {
                continue
            }

            seen.add(winner.model.id)
            fallbackModels.push({
                window: window.id,
                model: winner.model,
                tokens: winner.tokens,
            })
        }
    }

    if (fallbackModels.length === 0 && latestHistoryPoint) {
        const winner = getMostPopularOpenRouterFreeModel([latestHistoryPoint], liveModels)
        if (winner) {
            fallbackModels.push({
                window: 'week',
                model: winner.model,
                tokens: winner.tokens,
            })
        }
    }

    return fallbackModels
}