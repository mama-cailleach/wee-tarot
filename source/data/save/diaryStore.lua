local pd <const> = playdate

import "data/spreadReadingData"

DiaryStore = {}

local DATASTORE_PATH <const> = "data/save/diaryEntries"
local BUNDLED_FALLBACK_PATH <const> = "data/save/diaryEntries.json"

local function sanitizeEntry(raw)
    if type(raw) ~= "table" then
        return nil
    end

    local date = raw.date or "00-00-0000"
    local time = raw.time or "00.00"
    local spreadType = raw.spreadType or "unknown"

    if type(time) == "string" then
        -- Backward compatibility for entries saved as HH:MM.
        time = string.gsub(time, ":", ".")
    end

    if type(time) ~= "string" or not string.match(time, "^%d%d%.%d%d$") then
        time = "00.00"
    end

    local cards = {}
    if type(raw.cards) == "table" then
        for _, card in ipairs(raw.cards) do
            if type(card) == "table" then
                table.insert(cards, {
                    name = card.name,
                    number = card.number,
                    suit = card.suit,
                    inverted = card.inverted == true,
                    position = card.position
                })
            end
        end
    end

    local fortuneLines = {}
    if type(raw.fortuneLines) == "table" then
        for _, line in ipairs(raw.fortuneLines) do
            if type(line) == "string" then
                table.insert(fortuneLines, line)
            end
        end
    end

    local fortuneText = raw.fortuneText
    if type(fortuneText) ~= "string" then
        fortuneText = table.concat(fortuneLines, "\n")
    end

    local cardDetails = {}
    if type(raw.cardDetails) == "table" then
        for _, detail in ipairs(raw.cardDetails) do
            if type(detail) == "table" then
                local position = tonumber(detail.position)
                local positionLabel = detail.positionLabel
                local config = SpreadReadingData.getConfig(spreadType)
                if config and position and position > 0 then
                    positionLabel = SpreadReadingData.getPositionName(spreadType, position)
                end

                local themes = {}
                if type(detail.themes) == "table" then
                    for _, theme in ipairs(detail.themes) do
                        if type(theme) == "string" then
                            table.insert(themes, theme)
                        end
                    end
                end

                local readingLines = {}
                if type(detail.readingLines) == "table" then
                    for _, line in ipairs(detail.readingLines) do
                        if type(line) == "string" then
                            table.insert(readingLines, line)
                        end
                    end
                end

                local readingText = detail.readingText
                if type(readingText) ~= "string" and #readingLines > 0 then
                    readingText = table.concat(readingLines, "\n")
                end

                table.insert(cardDetails, {
                    position = position or detail.position,
                    positionLabel = positionLabel,
                    cardName = detail.cardName,
                    inverted = detail.inverted == true,
                    themes = themes,
                    readingLines = readingLines,
                    readingText = readingText
                })
            end
        end
    end

    return {
        date = date,
        time = time,
        spreadType = spreadType,
        cards = cards,
        cardDetails = cardDetails,
        fortuneLines = fortuneLines,
        fortuneText = fortuneText,
        createdAtEpoch = raw.createdAtEpoch
    }
end

local function sanitizeEntries(rawEntries)
    local entries = {}
    if type(rawEntries) ~= "table" then
        return entries
    end

    for _, entry in ipairs(rawEntries) do
        local sanitized = sanitizeEntry(entry)
        if sanitized then
            table.insert(entries, sanitized)
        end
    end

    return entries
end

local function readBundledFallback()
    local fallback = json.decodeFile(BUNDLED_FALLBACK_PATH)
    if type(fallback) ~= "table" then
        return {}
    end

    return sanitizeEntries(fallback.entries)
end

function DiaryStore.getEntries()
    local stored = pd.datastore.read(DATASTORE_PATH)
    if type(stored) ~= "table" then
        return readBundledFallback()
    end

    local storedEntries = sanitizeEntries(stored.entries)
    if #storedEntries == 0 then
        return readBundledFallback()
    end

    return storedEntries
end

function DiaryStore.formatDateFromSystem()
    local now = pd.getTime and pd.getTime()
    if not now or not now.day or not now.month or not now.year then
        return "00-00-0000"
    end

    return string.format("%02d-%02d-%04d", now.day, now.month, now.year)
end

function DiaryStore.formatTimeFromSystem()
    local now = pd.getTime and pd.getTime()
    if not now or now.hour == nil or now.minute == nil then
        return "00.00"
    end

    return string.format("%02d.%02d", now.hour, now.minute)
end

function DiaryStore.appendEntry(entry)
    local sanitized = sanitizeEntry(entry)
    if not sanitized then
        return false
    end

    local entries = DiaryStore.getEntries()
    table.insert(entries, 1, sanitized)

    local savePayload = {
        schemaVersion = 1,
        entries = entries
    }

    pd.datastore.write(savePayload, DATASTORE_PATH, true)
    return true
end

return DiaryStore
