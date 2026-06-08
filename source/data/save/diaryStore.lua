local pd <const> = playdate

import "data/spreadReadingData"

DiaryStore = {}

local DATASTORE_PATH <const> = "data/save/diaryEntries"
local BUNDLED_FALLBACK_PATH <const> = "data/save/diaryEntries.json"

local entriesCache = nil
local pendingDiskWrite = false
local framesUntilFlush = 0
local browserCacheByDescending = {}

-- Idle backup: flush JSON to disk if the player stays on the hub a while.
local FLUSH_IDLE_FRAMES <const> = 180

local function sanitizeEntry(raw)
    if type(raw) ~= "table" then
        return nil
    end

    local date = raw.date or "00-00-0000"
    local time = raw.time or "00.00"
    local spreadType = SpreadReadingData.normalizeSpreadKey(raw.spreadType or "unknown")

    if type(time) == "string" then
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

    return {
        date = date,
        time = time,
        spreadType = spreadType,
        cards = cards
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

local function loadEntriesFromStorage()
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

local function writeCacheToDisk()
    if not entriesCache then
        return false
    end

    local savePayload = {
        schemaVersion = 1,
        entries = entriesCache
    }

    pd.datastore.write(savePayload, DATASTORE_PATH, true)
    return true
end

function DiaryStore.getEntries()
    if entriesCache then
        return entriesCache
    end

    entriesCache = loadEntriesFromStorage()
    return entriesCache
end

function DiaryStore.invalidateCache()
    entriesCache = nil
    browserCacheByDescending = {}
end

function DiaryStore.invalidateBrowserCache()
    browserCacheByDescending = {}
end

local function formatPreviewTime(timeText)
    if type(timeText) ~= "string" then
        return "00.00"
    end

    timeText = string.gsub(timeText, ":", ".")

    if not string.match(timeText, "^%d%d%.%d%d$") then
        return "00.00"
    end

    return timeText
end

local function parseDiaryDate(dateText)
    local dayText, monthText, yearText = string.match(dateText or "", "^(%d%d)%-(%d%d)%-(%d%d%d%d)$")
    if not dayText or not monthText or not yearText then
        return nil
    end

    local day = tonumber(dayText)
    local month = tonumber(monthText)
    local year = tonumber(yearText)
    if not day or not month or not year then
        return nil
    end

    return {
        day = day,
        month = month,
        year = year,
        date = dateText
    }
end

local function buildBrowserData(entries, entriesListDescending)
    local yearLookup = {}
    local years = {}

    for entryIndex, entry in ipairs(entries or {}) do
        local parsed = parseDiaryDate(entry.date)
        if parsed then
            local yearBucket = yearLookup[parsed.year]
            if not yearBucket then
                yearBucket = {
                    year = parsed.year,
                    months = {},
                    monthLookup = {}
                }
                yearLookup[parsed.year] = yearBucket
                table.insert(years, yearBucket)
            end

            local monthBucket = yearBucket.monthLookup[parsed.month]
            if not monthBucket then
                monthBucket = {
                    month = parsed.month,
                    days = {},
                    dayLookup = {},
                    entries = {}
                }
                yearBucket.monthLookup[parsed.month] = monthBucket
                table.insert(yearBucket.months, monthBucket)
            end

            local dayBucket = monthBucket.dayLookup[parsed.day]
            if not dayBucket then
                dayBucket = {
                    day = parsed.day,
                    date = parsed.date,
                    entries = {}
                }
                monthBucket.dayLookup[parsed.day] = dayBucket
                table.insert(monthBucket.days, dayBucket)
            end

            table.insert(dayBucket.entries, entry)
            table.insert(monthBucket.entries, {
                entry = entry,
                day = parsed.day,
                date = parsed.date,
                sortOrder = entryIndex
            })
        end
    end

    table.sort(years, function(left, right)
        return left.year > right.year
    end)

    for _, yearBucket in ipairs(years) do
        table.sort(yearBucket.months, function(left, right)
            return left.month < right.month
        end)

        for _, monthBucket in ipairs(yearBucket.months) do
            table.sort(monthBucket.days, function(left, right)
                return left.day < right.day
            end)

            table.sort(monthBucket.entries, function(left, right)
                if left.day == right.day then
                    local leftTime = formatPreviewTime(left.entry and left.entry.time)
                    local rightTime = formatPreviewTime(right.entry and right.entry.time)

                    if leftTime == rightTime then
                        return left.sortOrder < right.sortOrder
                    end

                    if entriesListDescending then
                        return leftTime > rightTime
                    end

                    return leftTime < rightTime
                end

                if entriesListDescending then
                    return left.day > right.day
                end

                return left.day < right.day
            end)
        end
    end

    return { years = years }
end

function DiaryStore.getBrowserData(entriesListDescending)
    local descending = entriesListDescending == true
    if browserCacheByDescending[descending] then
        return browserCacheByDescending[descending]
    end

    local data = buildBrowserData(DiaryStore.getEntries(), descending)
    browserCacheByDescending[descending] = data
    return data
end

--- Prebuild list index + touch list images (no disk write).
function DiaryStore.prewarmDiaryUI()
    DiaryStore.getBrowserData(false)
    DiaryStore.getBrowserData(true)
    if GameAssets and GameAssets.prewarmDiaryListAssets then
        GameAssets.prewarmDiaryListAssets()
    end
end

--- New entry is visible in getEntries() immediately; only the JSON write is deferred.
function DiaryStore.scheduleAppendPresanitized(sanitizedEntry)
    if not sanitizedEntry then
        return false
    end

    local entries = DiaryStore.getEntries()
    table.insert(entries, 1, sanitizedEntry)
    entriesCache = entries

    pendingDiskWrite = true
    framesUntilFlush = FLUSH_IDLE_FRAMES
    DiaryStore.invalidateBrowserCache()
    return true
end

function DiaryStore.scheduleAppend(entry)
    return DiaryStore.scheduleAppendPresanitized(sanitizeEntry(entry))
end

function DiaryStore.queueCompletedReading(spreadType, cards)
    return DiaryStore.scheduleAppend({
        date = DiaryStore.formatDateFromSystem(),
        time = DiaryStore.formatTimeFromSystem(),
        spreadType = spreadType,
        cards = cards
    })
end

function DiaryStore.flushPendingAppend()
    if not pendingDiskWrite then
        return false
    end

    pendingDiskWrite = false
    framesUntilFlush = 0
    return writeCacheToDisk()
end

function DiaryStore.tickFlush(isSceneTransitioning)
    if not pendingDiskWrite then
        framesUntilFlush = 0
        return false
    end

    if isSceneTransitioning then
        framesUntilFlush = FLUSH_IDLE_FRAMES
        return false
    end

    if framesUntilFlush > 0 then
        framesUntilFlush -= 1
        return false
    end

    return DiaryStore.flushPendingAppend()
end

function DiaryStore.hasPendingAppend()
    return pendingDiskWrite
end

function DiaryStore.warmCache()
    DiaryStore.getEntries()
    DiaryStore.getBrowserData(false)
    DiaryStore.getBrowserData(true)
    if GameAssets and GameAssets.prewarmDiaryListAssets then
        GameAssets.prewarmDiaryListAssets()
    end
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

function DiaryStore.appendEntry(entry, alreadySanitized)
    local sanitized = alreadySanitized and entry or sanitizeEntry(entry)
    if not sanitized then
        return false
    end

    local entries = DiaryStore.getEntries()
    table.insert(entries, 1, sanitized)
    entriesCache = entries
    pendingDiskWrite = true
    return writeCacheToDisk()
end

return DiaryStore
