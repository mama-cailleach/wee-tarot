import "data/cardDescriptions"

local FALLBACK_KEYWORDS = { "mystery", "uncertain path", "hidden lesson" }

local SPREAD_CONFIGS = {
    three_card = {
        openingLines = {
            "Three cards... Past, Present, and Future.",
            "Let us see what your path is trying to reveal."
        },
        positionNames = { "Past", "Present", "Future" },
        closingLine = "Press A to continue, or B to choose another spread."
    },
    pentagram = {
        openingLines = {
            "Five cards now stand in your spread.",
            "Let us read each position one by one."
        },
        positionNames = { "Air", "Fire", "Water", "Earth", "Soul" },
        closingLine = "Press A to continue, or B to choose another spread."
    },
    celtic_cross = {
        openingLines = {
            "Ten cards form the Celtic Cross before us.",
            "We will read each position in order."
        },
        positionNames = {
            "Present Situation", "Problem", "Past", "Future", "Conscious",
            "Unconscious", "Your Influence", "External Influence", "Hopes and Fears", "Outcome"
        },
        closingLine = "Press A to continue, or B to choose another spread."
    },
    horoscope = {
        openingLines = {
            "Twelve cards circle the horoscope spread.",
            "Let each sign speak in turn."
        },
        positionNames = {
            "Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
            "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"
        },
        closingLine = "Press A to continue, or B to choose another spread."
    }
}

local function shuffledCopy(tbl)
    local copy = {}
    for index = 1, #tbl do
        copy[index] = tbl[index]
    end
    for index = #copy, 2, -1 do
        local swapIndex = math.random(index)
        copy[index], copy[swapIndex] = copy[swapIndex], copy[index]
    end
    return copy
end

SpreadReadingData = {}

function SpreadReadingData.getConfig(spreadKey)
    return SPREAD_CONFIGS[spreadKey]
end

function SpreadReadingData.pickKeywords(cardName, inverted, keywordCount)
    local count = keywordCount or 3
    local cardInfo = cardName and CARD_DATA[cardName] or nil
    if not cardInfo then
        return FALLBACK_KEYWORDS
    end

    local sourceKeywords = cardInfo.upright_keywords or {}
    if inverted and cardInfo.reversed_keywords and #cardInfo.reversed_keywords > 0 then
        sourceKeywords = cardInfo.reversed_keywords
    end

    if #sourceKeywords == 0 then
        return FALLBACK_KEYWORDS
    end

    if #sourceKeywords <= count then
        return sourceKeywords
    end

    local shuffled = shuffledCopy(sourceKeywords)
    local selectedKeywords = {}
    for index = 1, count do
        selectedKeywords[index] = shuffled[index]
    end

    return selectedKeywords
end

function SpreadReadingData.getPositionName(spreadKey, index)
    local config = SPREAD_CONFIGS[spreadKey]
    if not config then
        return "Card " .. tostring(index)
    end

    return config.positionNames and config.positionNames[index] or ("Card " .. tostring(index))
end

function SpreadReadingData.buildCardDetails(spreadKey, cardNames, cardInverted)
    local details = {}
    local config = SPREAD_CONFIGS[spreadKey]
    local count = math.max(#(cardNames or {}), #(cardInverted or {}))

    for index = 1, count do
        local cardName = cardNames and cardNames[index] or "Unknown Card"
        local inverted = cardInverted and cardInverted[index] == true or false
        local positionName = SpreadReadingData.getPositionName(spreadKey, index)
        local themes = SpreadReadingData.pickKeywords(cardName, inverted, 3)
        local readingLines = {
            positionName .. ": " .. cardName .. (inverted and " (Reversed)" or ""),
            "Themes: " .. table.concat(themes, ", ") .. "."
        }

        table.insert(details, {
            position = index,
            positionLabel = positionName,
            cardName = cardName,
            inverted = inverted,
            themes = themes,
            readingLines = readingLines,
            readingText = table.concat(readingLines, "\n")
        })
    end

    return details
end

function SpreadReadingData.buildPlaceholderReadingText(spreadKey, cardNames, cardInverted)
    local config = SPREAD_CONFIGS[spreadKey]
    if not config then
        return { "This spread has no reading data yet." }
    end

    local lines = {}
    for _, openingLine in ipairs(config.openingLines) do
        table.insert(lines, openingLine)
    end

    for index, positionName in ipairs(config.positionNames) do
        local cardName = cardNames[index] or "Unknown Card"
        local inverted = cardInverted[index] and " (Reversed)" or ""
        local keywords = SpreadReadingData.pickKeywords(cardName, cardInverted[index], 3)

        table.insert(lines, positionName .. ": " .. cardName .. inverted)
        table.insert(lines, "Themes: " .. table.concat(keywords, ", ") .. ".")
    end

    table.insert(lines, config.closingLine)
    return lines
end
