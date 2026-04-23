local pd <const> = playdate
local gfx <const> = pd.graphics

import "data/save/diaryStore"
import "data/save/playerProfileStore"

class('DiaryEntriesListScene').extends(gfx.sprite)

local MONTH_NAMES = {
    "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
    "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
}

local MONTH_NAMES_FULL = {
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
}

local SPREAD_LABELS = {
    one_card = "1-bit Fortune",
    three_card = "Root-Trunk- Branch",
    pentagram = "Pentagram",
    celtic_cross = "Celtic Cross",
    horoscope = "Horoscope"
}

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

function DiaryEntriesListScene:init(restoreState)
    DiaryEntriesListScene.super.init(self)

    self.bgImage = gfx.image.new("images/bg/journal1")
    self.bgSprite = gfx.sprite.new(self.bgImage)
    self.bgSprite:moveTo(200, 120)
    self.bgSprite:add()

    self.entries = DiaryStore.getEntries()
    self.browserData = {
        years = {}
    }
    self.browserMode = "year"
    self.selectedYearIndex = 1
    self.selectedMonthIndex = 1
    self.selectedDayIndex = 1
    self.yearListStartIndex = 1
    self.dayListStartIndex = 1
    self.entrySprites = {}
    self.previewSprite = nil
    self.titleSprite = nil
    self.leftArrowSprite = nil
    self.rightArrowSprite = nil
    self.listLeftOffset = 20
    self.listLeft = 40
    self.listTop = 40
    self.listWidth = 182
    self.rowHeight = 32
    self.previewLeft = 220
    self.previewTop = 0
    self.previewWidth = 170
    self.previewHeight = 240
    self.previewScrollY = 0
    self.previewMaxScroll = 0
    self.previewScrollStep = 10
    self.previewTicksPerRevolution = 30
    local screenHeight = 240
    self.visibleEntryCount = math.max(1, math.floor((screenHeight - self.listTop) / self.rowHeight))
    self.selectorSprite = nil

    local selectorImage = gfx.image.new("images/bg/icon_knot1_smol")
    if selectorImage then
        self.selectorSprite = gfx.sprite.new(selectorImage)
        self.selectorSprite:add()
    end

    self:buildBrowserData()
    self:applyRestoreState(restoreState)

    self:renderCurrentMode(true)

    self:add()
end

function DiaryEntriesListScene:clearEntrySprites()
    for _, sprite in ipairs(self.entrySprites) do
        if sprite then
            sprite:remove()
        end
    end
    self.entrySprites = {}
end

function DiaryEntriesListScene:clearHeaderSprites()
    if self.titleSprite then self.titleSprite:remove() self.titleSprite = nil end
    if self.leftArrowSprite then self.leftArrowSprite:remove() self.leftArrowSprite = nil end
    if self.rightArrowSprite then self.rightArrowSprite:remove() self.rightArrowSprite = nil end
end

function DiaryEntriesListScene:createTextSprite(text, width, height, alignment)
    return gfx.sprite.spriteWithText(text, width, height, nil, nil, nil, alignment or kTextAlignment.left)
end

function DiaryEntriesListScene:buildBrowserData()
    local yearLookup = {}
    local years = {}

    for entryIndex, entry in ipairs(self.entries) do
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
                    return left.sortOrder < right.sortOrder
                end

                return left.day < right.day
            end)
        end
    end

    self.browserData.years = years
end

function DiaryEntriesListScene:applyRestoreState(restoreState)
    if type(restoreState) ~= "table" then
        if type(restoreState) == "number" then
            self.selectedYearIndex = restoreState
        end
        self:clampSelectionForMode()
        return
    end

    if type(restoreState.browserMode) == "string" then
        if restoreState.browserMode == "dayEntries" then
            self.browserMode = "monthDay"
        else
            self.browserMode = restoreState.browserMode
        end
    end

    if type(restoreState.selectedYearIndex) == "number" then
        self.selectedYearIndex = restoreState.selectedYearIndex
    end

    if type(restoreState.selectedMonthIndex) == "number" then
        self.selectedMonthIndex = restoreState.selectedMonthIndex
    end

    if type(restoreState.selectedDayIndex) == "number" then
        self.selectedDayIndex = restoreState.selectedDayIndex
    end

    if type(restoreState.yearListStartIndex) == "number" then
        self.yearListStartIndex = restoreState.yearListStartIndex
    end

    if type(restoreState.dayListStartIndex) == "number" then
        self.dayListStartIndex = restoreState.dayListStartIndex
    end

    self:clampSelectionForMode()
end

function DiaryEntriesListScene:getCurrentYearBucket()
    return self.browserData.years[self.selectedYearIndex]
end

function DiaryEntriesListScene:getCurrentMonthBucket()
    local yearBucket = self:getCurrentYearBucket()
    if not yearBucket then
        return nil
    end

    return yearBucket.months[self.selectedMonthIndex]
end

function DiaryEntriesListScene:getCurrentMonthEntries()
    local monthBucket = self:getCurrentMonthBucket()
    if not monthBucket then
        return {}
    end

    return monthBucket.entries or {}
end

function DiaryEntriesListScene:clampListState(selectedIndex, listStartIndex, total)
    if total == 0 then
        return 0, 1
    end

    if selectedIndex < 1 then
        selectedIndex = 1
    elseif selectedIndex > total then
        selectedIndex = total
    end

    local maxStart = math.max(1, (total - self.visibleEntryCount) + 1)
    if listStartIndex > maxStart then
        listStartIndex = maxStart
    end

    if selectedIndex < listStartIndex then
        listStartIndex = selectedIndex
    end

    local lastVisible = listStartIndex + self.visibleEntryCount - 1
    if selectedIndex > lastVisible then
        listStartIndex = selectedIndex - self.visibleEntryCount + 1
    end

    return selectedIndex, listStartIndex
end

function DiaryEntriesListScene:clampSelectionForMode()
    local years = self.browserData.years
    local totalYears = #years

    if totalYears == 0 then
        self.browserMode = "year"
        self.selectedYearIndex = 0
        self.selectedMonthIndex = 0
        self.selectedDayIndex = 0
        self.yearListStartIndex = 1
        self.dayListStartIndex = 1
        return
    end

    self.selectedYearIndex, self.yearListStartIndex = self:clampListState(self.selectedYearIndex, self.yearListStartIndex, totalYears)

    local yearBucket = self:getCurrentYearBucket()
    if not yearBucket or #yearBucket.months == 0 then
        self.selectedMonthIndex = 0
        self.selectedDayIndex = 0
        self.dayListStartIndex = 1
        return
    end

    if self.selectedMonthIndex < 1 then
        self.selectedMonthIndex = 1
    elseif self.selectedMonthIndex > #yearBucket.months then
        self.selectedMonthIndex = #yearBucket.months
    end

    local monthEntries = self:getCurrentMonthEntries()
    if #monthEntries == 0 then
        self.selectedDayIndex = 0
        self.dayListStartIndex = 1
        return
    end

    self.selectedDayIndex, self.dayListStartIndex = self:clampListState(self.selectedDayIndex, self.dayListStartIndex, #monthEntries)
end

function DiaryEntriesListScene:toOrdinal(day)
    local suffix = "th"
    local mod100 = day % 100
    if mod100 < 11 or mod100 > 13 then
        local mod10 = day % 10
        if mod10 == 1 then
            suffix = "st"
        elseif mod10 == 2 then
            suffix = "nd"
        elseif mod10 == 3 then
            suffix = "rd"
        end
    end
    return tostring(day) .. suffix
end

function DiaryEntriesListScene:formatPreviewDate(date)
    local day, month, year = string.match(date or "", "^(%d%d)%-(%d%d)%-(%d%d%d%d)$")
    if not day or not month or not year then
        return "Erstwhile"
    end

    local monthIndex = tonumber(month) or 0
    local monthText = MONTH_NAMES_FULL[monthIndex] or "???"
    local dayText = self:toOrdinal(tonumber(day) or 0)

    local dateString = dayText .. " of \n" .. monthText .. "\n" .. year

    return dateString
end

function DiaryEntriesListScene:formatSpreadLabel(spreadType)
    local spread = spreadType or "unknown"
    local lowered = string.lower(spread)
    local normalized = string.gsub(lowered, "%-", "_")

    if SPREAD_LABELS[lowered] then
        return SPREAD_LABELS[lowered]
    end

    if SPREAD_LABELS[normalized] then
        return SPREAD_LABELS[normalized]
    end

    spread = string.gsub(spread, "[_%-]", " ")
    spread = string.gsub(spread, "(%a)([%w_']*)", function(first, rest)
        return string.upper(first) .. string.lower(rest)
    end)
    return spread
end

function DiaryEntriesListScene:buildEntrySummaryText(entry)
    if not entry then
        return "No diary entries yet."
    end

    local lines = {
        self:formatSpreadLabel(entry.spreadType),
        "\n---------------------\n"
    }

    if type(entry.cards) == "table" and #entry.cards > 0 then
        for _, card in ipairs(entry.cards) do
            local cardName = card.name or "Unknown Card"
            table.insert(lines, cardName)
            table.insert(lines, "\n---------------------\n")
        end
    else
        table.insert(lines, "No cards recorded")
    end

    return table.concat(lines, "")
end

function DiaryEntriesListScene:buildYearPreviewText()
    local yearBucket = self:getCurrentYearBucket()
    if not yearBucket then
        return "No diary entries yet."
    end

    local totalReadings = 0
    local totalCardsPulled = 0
    local cardCounts = {}
    local spreadCounts = {}

    for _, monthBucket in ipairs(yearBucket.months) do
        for _, item in ipairs(monthBucket.entries or {}) do
            local entry = item.entry
            totalReadings = totalReadings + 1

            if entry then
                local spreadKey = string.lower(entry.spreadType or "unknown")
                spreadCounts[spreadKey] = (spreadCounts[spreadKey] or 0) + 1

                if type(entry.cards) == "table" then
                    totalCardsPulled = totalCardsPulled + #entry.cards

                    for _, card in ipairs(entry.cards) do
                        local cardName = card.name or "Unknown Card"
                        cardCounts[cardName] = (cardCounts[cardName] or 0) + 1
                    end
                end
            end
        end
    end

    local mostSeenCard = "N/A"
    local mostSeenCardCount = 0
    for cardName, count in pairs(cardCounts) do
        if count > mostSeenCardCount then
            mostSeenCard = cardName
            mostSeenCardCount = count
        end
    end

    local favoriteSpreadKey = nil
    local favoriteSpreadCount = 0
    for spreadKey, count in pairs(spreadCounts) do
        if count > favoriteSpreadCount then
            favoriteSpreadKey = spreadKey
            favoriteSpreadCount = count
        end
    end

    local favoriteSpread = "N/A"
    if favoriteSpreadKey then
        favoriteSpread = self:formatSpreadLabel(favoriteSpreadKey)
    end

    local lines = {
        tostring(yearBucket.year),
        "\n---------------------\n",
        "Total Readings: ", tostring(totalReadings),
        "\n---------------------\n",
        "Total Cards Pulled: ", tostring(totalCardsPulled),
        "\n---------------------\n",
        "Card Most Seen: ", mostSeenCard,
        "\n---------------------\n",
        "Favorite Spread: ", favoriteSpread,
        "\n---------------------\n"
    }

    return table.concat(lines, "")
end

function DiaryEntriesListScene:buildMonthDayPreviewText()
    local monthEntries = self:getCurrentMonthEntries()
    local selectedItem = monthEntries[self.selectedDayIndex]
    if not selectedItem then
        return "No diary entries yet."
    end

    local lines = {
        self:formatPreviewDate(selectedItem.date),
        "\n---------------------\n"
    }

    table.insert(lines, self:buildEntrySummaryText(selectedItem.entry))
    return table.concat(lines, "")
end

function DiaryEntriesListScene:buildPreviewText()
    if self.browserMode == "year" then
        return self:buildYearPreviewText()
    end

    return self:buildMonthDayPreviewText()
end

function DiaryEntriesListScene:renderPreview(resetScroll)
    if self.previewSprite then
        self.previewSprite:remove()
        self.previewSprite = nil
    end

    if resetScroll then
        self.previewScrollY = 0
    end

    local previewText = self:buildPreviewText()
    local _, textHeight = gfx.getTextSizeForMaxWidth(previewText, self.previewWidth)
    local fullHeight = math.max(self.previewHeight, textHeight + 8)
    self.previewMaxScroll = math.max(0, fullHeight - self.previewHeight)
    self.previewScrollY = math.max(0, math.min(self.previewScrollY, self.previewMaxScroll))

    local previewImage = gfx.image.new(self.previewWidth, self.previewHeight)
    if not previewImage then
        return
    end

    gfx.pushContext(previewImage)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        if self.browserMode == "monthDay" then
            gfx.drawTextInRect(previewText, 0, -self.previewScrollY, self.previewWidth, fullHeight, nil, nil, kTextAlignment.center)
        else
            gfx.drawTextInRect(previewText, 0, -self.previewScrollY, self.previewWidth, fullHeight, nil, nil, kTextAlignment.center)
        end
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
    gfx.popContext()

    self.previewSprite = gfx.sprite.new(previewImage)
    if self.previewSprite then
        self.previewSprite:setCenter(0, 0)
        self.previewSprite:moveTo(self.previewLeft, self.previewTop)
        self.previewSprite:add()
    end
end

function DiaryEntriesListScene:updateSelectorPosition()
    if not self.selectorSprite then
        return
    end

    local selectedIndex = 0
    local listStartIndex = 1
    local total = 0

    if self.browserMode == "year" then
        selectedIndex = self.selectedYearIndex
        listStartIndex = self.yearListStartIndex
        total = #self.browserData.years
    else
        selectedIndex = self.selectedDayIndex
        listStartIndex = self.dayListStartIndex
        total = #self:getCurrentMonthEntries()
    end

    if total == 0 or selectedIndex == 0 then
        self.selectorSprite:setVisible(false)
        return
    end

    self.selectorSprite:setVisible(true)
    local row = selectedIndex - listStartIndex + 1
    local y = self.listTop + ((row - 1) * self.rowHeight) + 12
    self.selectorSprite:moveTo(self.listLeft - 18, y + 6)
end

function DiaryEntriesListScene:renderModeTitle()
    self:clearHeaderSprites()

    local titleText = "YEAR"
    local showArrows = false

    if self.browserMode == "monthDay" then
        local monthBucket = self:getCurrentMonthBucket()
        titleText = MONTH_NAMES[monthBucket and monthBucket.month or 1] or "???"
        showArrows = true
    end
    
    self.titleSprite = self:createTextSprite(titleText, 160, 60, kTextAlignment.center)
    if self.titleSprite then
        self.titleSprite:setCenter(0.5, 0)
        self.titleSprite:moveTo(self.listLeft + 48, 4)
        self.titleSprite:add()
    end

    if showArrows then
        self.leftArrowSprite = self:createTextSprite("®", 60, 60, kTextAlignment.center)
        if self.leftArrowSprite then
            self.leftArrowSprite:setRotation(270)
            self.leftArrowSprite:setCenter(0.5, 0.5)
            self.leftArrowSprite:moveTo(self.listLeft, 21)
            self.leftArrowSprite:add()
        end

        self.rightArrowSprite = self:createTextSprite("®", 60, 60, kTextAlignment.center)
        if self.rightArrowSprite then
            self.rightArrowSprite:setRotation(90)
            self.rightArrowSprite:setCenter(0.5, 0.5)
            self.rightArrowSprite:moveTo(self.listLeft + 96, 21)
            self.rightArrowSprite:add()
        end
    end
end

function DiaryEntriesListScene:animateMonthArrowLeft()
    if not self.leftArrowSprite then
        return
    end

    local point1 = playdate.geometry.point.new(self.listLeft, self.leftArrowSprite.y)
    local point2 = playdate.geometry.point.new(self.listLeft - 10, self.leftArrowSprite.y)
    local animator = gfx.animator.new(250, point2, point1, playdate.easingFunctions.outCubic)
    self.leftArrowSprite:setAnimator(animator)
end

function DiaryEntriesListScene:animateMonthArrowRight()
    if not self.rightArrowSprite then
        return
    end

    local point1 = playdate.geometry.point.new(self.listLeft + 96, self.rightArrowSprite.y)
    local point2 = playdate.geometry.point.new(self.listLeft + 106, self.rightArrowSprite.y)
    local animator = gfx.animator.new(250, point2, point1, playdate.easingFunctions.outCubic)
    self.rightArrowSprite:setAnimator(animator)
end

function DiaryEntriesListScene:renderListRows(items, selectedIndex, listStartIndex, itemFormatter)
    for row = 1, self.visibleEntryCount do
        local index = listStartIndex + row - 1
        local item = items[index]
        if not item then
            break
        end

        local text = itemFormatter(item, index)
        local sprite = self:createTextSprite(text, 150, 40, kTextAlignment.left)
        if sprite then
            sprite:setCenter(0, 0)
            sprite:moveTo(self.listLeft + self.listLeftOffset, self.listTop + ((row - 1) * self.rowHeight))
            sprite:add()
            table.insert(self.entrySprites, sprite)
        end
    end

    if selectedIndex == 0 then
        self.selectorSprite:setVisible(false)
    else
        self.selectorSprite:setVisible(true)
        local row = selectedIndex - listStartIndex + 1
        local y = self.listTop + ((row - 1) * self.rowHeight) + 12
        self.selectorSprite:moveTo(self.listLeft - 4, y + 6)
    end
end

function DiaryEntriesListScene:renderCurrentMode(resetScroll)
    self:clearEntrySprites()
    self:renderModeTitle()

    if self.browserMode == "year" then
        self.selectedYearIndex, self.yearListStartIndex = self:clampListState(self.selectedYearIndex, self.yearListStartIndex, #self.browserData.years)
        self:renderPreview(resetScroll)
        self:renderListRows(self.browserData.years, self.selectedYearIndex, self.yearListStartIndex, function(item)
            return tostring(item.year)
        end)
    else
        local monthEntries = self:getCurrentMonthEntries()
        self.selectedDayIndex, self.dayListStartIndex = self:clampListState(self.selectedDayIndex, self.dayListStartIndex, #monthEntries)
        self:renderPreview(resetScroll)
        self:renderListRows(monthEntries, self.selectedDayIndex, self.dayListStartIndex, function(item)
            return self:toOrdinal(item.day)
        end)
    end
end

function DiaryEntriesListScene:enterMonthDayMode()
    local yearBucket = self:getCurrentYearBucket()
    if not yearBucket or #yearBucket.months == 0 then
        return
    end

    self.browserMode = "monthDay"
    self.selectedMonthIndex = math.max(1, math.min(self.selectedMonthIndex, #yearBucket.months))
    self.selectedDayIndex = 1
    self.dayListStartIndex = 1
    self:renderCurrentMode(true)
end

function DiaryEntriesListScene:cycleMonth(step)
    local yearBucket = self:getCurrentYearBucket()
    if not yearBucket or #yearBucket.months == 0 then
        return
    end

    local monthCount = #yearBucket.months
    local nextIndex = self.selectedMonthIndex + step
    if nextIndex < 1 then
        nextIndex = monthCount
    elseif nextIndex > monthCount then
        nextIndex = 1
    end

    if nextIndex ~= self.selectedMonthIndex then
        self.selectedMonthIndex = nextIndex
        self.selectedDayIndex = 1
        self.dayListStartIndex = 1
        self:renderCurrentMode(true)

        if step < 0 then
            self:animateMonthArrowLeft()
        elseif step > 0 then
            self:animateMonthArrowRight()
        end
    end
end

function DiaryEntriesListScene:buildReturnState()
    return {
        browserMode = self.browserMode,
        selectedYearIndex = self.selectedYearIndex,
        selectedMonthIndex = self.selectedMonthIndex,
        selectedDayIndex = self.selectedDayIndex,
        yearListStartIndex = self.yearListStartIndex,
        dayListStartIndex = self.dayListStartIndex
    }
end

function DiaryEntriesListScene:openCurrentEntry()
    local monthEntries = self:getCurrentMonthEntries()
    local selectedItem = monthEntries[self.selectedDayIndex]
    if not selectedItem or not selectedItem.entry then
        return
    end

    cards_fast2:play(1)
    SCENE_MANAGER:switchScene(DiaryEntryScene, selectedItem.entry, self:buildReturnState())
end

function DiaryEntriesListScene:update()
    local crankTicks = pd.getCrankTicks(self.previewTicksPerRevolution)

    if crankTicks ~= 0 and self.previewMaxScroll > 0 then
        local nextScroll = self.previewScrollY + (crankTicks * self.previewScrollStep)
        local clampedScroll = math.max(0, math.min(nextScroll, self.previewMaxScroll))
        if clampedScroll ~= self.previewScrollY then
            self.previewScrollY = clampedScroll
            self:renderPreview(false)
        end
    end

    if self.browserMode == "year" then
        local totalYears = #self.browserData.years

        if pd.buttonJustPressed(pd.kButtonDown) then
            if totalYears > 0 and self.selectedYearIndex < totalYears then
                self.selectedYearIndex = self.selectedYearIndex + 1
                self:renderCurrentMode(true)
            end
        end

        if pd.buttonJustPressed(pd.kButtonUp) then
            if totalYears > 0 and self.selectedYearIndex > 1 then
                self.selectedYearIndex = self.selectedYearIndex - 1
                self:renderCurrentMode(true)
            end
        end

        if pd.buttonJustPressed(pd.kButtonA) then
            if totalYears > 0 then
                cards_fast2:play(1)
                self:enterMonthDayMode()
            end
        end

        if pd.buttonJustPressed(pd.kButtonB) then
            cards_slow2:play(1)
            SCENE_MANAGER:switchScene(DiaryScene)
        end
        return
    end

    if self.browserMode == "monthDay" then
        local yearBucket = self:getCurrentYearBucket()
        local monthEntries = self:getCurrentMonthEntries()

        if pd.buttonJustPressed(pd.kButtonLeft) and yearBucket and #yearBucket.months > 0 then
            self:cycleMonth(-1)
        end

        if pd.buttonJustPressed(pd.kButtonRight) and yearBucket and #yearBucket.months > 0 then
            self:cycleMonth(1)
        end

        if pd.buttonJustPressed(pd.kButtonDown) and #monthEntries > 0 then
            if self.selectedDayIndex < #monthEntries then
                self.selectedDayIndex = self.selectedDayIndex + 1
                self:renderCurrentMode(true)
            end
        end

        if pd.buttonJustPressed(pd.kButtonUp) and #monthEntries > 0 then
            if self.selectedDayIndex > 1 then
                self.selectedDayIndex = self.selectedDayIndex - 1
                self:renderCurrentMode(true)
            end
        end

        if pd.buttonJustPressed(pd.kButtonA) then
            if #monthEntries > 0 then
                self:openCurrentEntry()
            end
        end

        if pd.buttonJustPressed(pd.kButtonB) then
            cards_slow2:play(1)
            self.browserMode = "year"
            self:renderCurrentMode(true)
        end

        return
    end
end

function DiaryEntriesListScene:deinit()
    if self.bgSprite then self.bgSprite:remove() self.bgSprite = nil end
    self:clearHeaderSprites()
    if self.selectorSprite then self.selectorSprite:remove() self.selectorSprite = nil end
    if self.previewSprite then self.previewSprite:remove() self.previewSprite = nil end

    self:clearEntrySprites()
end