local pd <const> = playdate
local gfx <const> = pd.graphics

import "data/save/diaryStore"
import "data/save/playerProfileStore"
import "data/spreadReadingData"

class('DiaryEntriesListScene').extends(gfx.sprite)

local MONTH_NAMES = {
    "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
    "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
}

local MONTH_NAMES_FULL = {
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
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


    --[[
    self.bgImage = gfx.image.new("images/bg/journal1")
    self.bgSprite = gfx.sprite.new(self.bgImage)
    self.bgSprite:moveTo(200, 120)
    self.bgSprite:add()
    ]]

    self.bgSprite = gfx.sprite.new(GameAssets.getJournal1Image())
    self.bgSprite:moveTo(200, 120)
    self.bgSprite:add()

    self.entries = DiaryStore.getEntries()
    self.entriesListDescending = PlayerProfileStore.getEntriesListDescending()
    self.browserData = DiaryStore.getBrowserData(self.entriesListDescending)
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

    self.crankSoundPlaying = false
    self.crankInactivityTimer = nil
    self.lastCrankTime = 0
    self.previewImage = nil
    self.lastPreviewRenderTime = 0
    self.previewNeedsRender = false

    local selectorImage = GameAssets.getIconKnotSmolImage()
    if selectorImage then
        self.selectorSprite = gfx.sprite.new(selectorImage)
        self.selectorSprite:add()
    end

    self:applyRestoreState(restoreState)

    self:add()

    -- Defer first list/preview build to the frame after init (keeps scene fade smooth).
    pd.timer.performAfterDelay(0, function()
        self:renderCurrentMode(true)
    end)
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
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    local sprite = gfx.sprite.spriteWithText(text, width, height, nil, nil, nil, alignment or kTextAlignment.left)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    return sprite
end

function DiaryEntriesListScene:buildBrowserData()
    self.browserData = DiaryStore.getBrowserData(self.entriesListDescending)
end

function DiaryEntriesListScene:getYearListCount()
    return #self.browserData.years + 2
end

function DiaryEntriesListScene:getYearBodyVisibleCount()
    return math.max(1, self.visibleEntryCount - 3)
end

function DiaryEntriesListScene:getYearMendIndex()
    return #self.browserData.years + 1
end

function DiaryEntriesListScene:getYearCloseIndex()
    return #self.browserData.years + 2
end

function DiaryEntriesListScene:isLockAndLeaveSelected()
    return self.selectedYearIndex == self:getYearListCount()
end

function DiaryEntriesListScene:getYearListItem(index)
    local totalYears = #self.browserData.years
    if index == totalYears + 1 then
        return {
            isMend = true,
            label = "Alter"
        }
    end

    if index == totalYears + 2 then
        return {
            isLockAndLeave = true,
            label = "Close"
        }
    end

    return self.browserData.years[index]
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

function DiaryEntriesListScene:buildMonthDayRows()
    local rows = {}
    local monthEntries = self:getCurrentMonthEntries()
    local currentDay = nil

    for _, item in ipairs(monthEntries) do
        if currentDay ~= item.day then
            currentDay = item.day
            table.insert(rows, {
                type = "divider",
                day = item.day,
                date = item.date
            })
        end

        table.insert(rows, {
            type = "entry",
            day = item.day,
            date = item.date,
            entry = item.entry,
            time = self:formatPreviewTime(item.entry and item.entry.time)
        })
    end

    return rows
end

function DiaryEntriesListScene:findNextEntryRow(rows, startIndex, step)
    local index = startIndex
    while true do
        index = index + step
        if index < 1 or index > #rows then
            return nil
        end

        if rows[index] and rows[index].type == "entry" then
            return index
        end
    end
end

function DiaryEntriesListScene:moveMonthDaySelection(step)
    local rows = self:buildMonthDayRows()
    if #rows == 0 then
        return false
    end

    local nextIndex = self:findNextEntryRow(rows, self.selectedDayIndex, step)
    if not nextIndex then
        return false
    end

    self.selectedDayIndex = nextIndex

    if step < 0 and rows[nextIndex - 1] and rows[nextIndex - 1].type == "divider" then
        self.dayListStartIndex = math.max(1, nextIndex - 1)
    end

    return true
end

function DiaryEntriesListScene:clampMonthDaySelection(rows)
    if #rows == 0 then
        self.selectedDayIndex = 0
        self.dayListStartIndex = 1
        return
    end

    self.selectedDayIndex, self.dayListStartIndex = self:clampListState(self.selectedDayIndex, self.dayListStartIndex, #rows)

    local selectedRow = rows[self.selectedDayIndex]
    if not (selectedRow and selectedRow.type == "entry") then
        local downIndex = self:findNextEntryRow(rows, self.selectedDayIndex, 1)
        if downIndex then
            self.selectedDayIndex = downIndex
        else
            local upIndex = self:findNextEntryRow(rows, self.selectedDayIndex, -1)
            if upIndex then
                self.selectedDayIndex = upIndex
            else
                self.selectedDayIndex = 0
            end
        end
    end

    if self.selectedDayIndex > 0 then
        self.selectedDayIndex, self.dayListStartIndex = self:clampListState(self.selectedDayIndex, self.dayListStartIndex, #rows)
    end

    -- Keep the day divider visible when the selected entry is the first visible row.
    local dividerIndex = self.selectedDayIndex - 1
    if dividerIndex >= 1 and rows[dividerIndex] and rows[dividerIndex].type == "divider" then
        self.dayListStartIndex = math.min(self.dayListStartIndex, dividerIndex)
    end
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
    local bodyVisibleCount = self:getYearBodyVisibleCount()
    local totalYearEntries = self:getYearListCount()

    if totalYearEntries == 0 then
        self.browserMode = "year"
        self.selectedYearIndex = 1
        self.selectedMonthIndex = 0
        self.selectedDayIndex = 0
        self.yearListStartIndex = 1
        self.dayListStartIndex = 1
        return
    end

    if self.selectedYearIndex <= totalYears then
        self.selectedYearIndex, self.yearListStartIndex = self:clampListState(self.selectedYearIndex, self.yearListStartIndex, totalYears)
    else
        self.yearListStartIndex = math.max(1, (totalYears - bodyVisibleCount) + 1)
    end

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

    local monthRows = self:buildMonthDayRows()
    self:clampMonthDaySelection(monthRows)
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

function DiaryEntriesListScene:formatPreviewTime(timeText)
    if type(timeText) ~= "string" then
        return "00.00"
    end

    timeText = string.gsub(timeText, ":", ".")

    if not string.match(timeText, "^%d%d%.%d%d$") then
        return "00.00"
    end

    return timeText
end

function DiaryEntriesListScene:formatSpreadLabel(spreadType)
    if SpreadReadingData.normalizeSpreadKey(spreadType) == "three_card" then
        return "Root-Trunk-\nBranch"
    end
    return SpreadReadingData.getSpreadDisplayName(spreadType)
end

function DiaryEntriesListScene:buildEntrySummaryText(entry)
    if not entry then
        return "No diary entries yet."
    end

    local lines = {"SPREAD\n",
        self:formatSpreadLabel(entry.spreadType),
        "\nºººººººº\n"
    }

    if type(entry.cards) == "table" and #entry.cards > 0 then
        table.insert(lines, "CARDS\n")
        --table.insert(lines, "\nºººººººº\n")
        for _, card in ipairs(entry.cards) do
            local cardName = card.name or "Unknown Card"
            table.insert(lines, "--\n")
            table.insert(lines, cardName)
            table.insert(lines, "\n")
            --table.insert(lines, "\nºººººººº\n")
        end
    else
        table.insert(lines, "No cards recorded")
    end
    table.insert(lines, "ºººººººº\n")

    return table.concat(lines, "")
end

function DiaryEntriesListScene:buildYearPreviewText()
    if self.selectedYearIndex == self:getYearMendIndex() then
        return table.concat({
            "Alter Diary",
            "\nºººººººº\n",
            "Customise the the fabric of your diary.",
            "\nºººººººº\n",
            "Name:\n", PlayerProfileStore.getName(),
            "\n--\nOrdering:\n", PlayerProfileStore.getEntriesListDescending() and "Newest to Oldest" or "Oldest to Newest"
        }, "")
    end

    if self:isLockAndLeaveSelected() then
        return table.concat({
            "Close",
            "\nºººººººº\n",
            "Close and lock your diary.\n\nProtect your readings from unwanted eyes and keep your secrets safe."
        }, "")
    end

    local yearBucket = self:getCurrentYearBucket()
    if not yearBucket then
        return "No entries for this year."
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
        "\nºººººººº\n",
        "Total Readings:\n", tostring(totalReadings),
        "\nºººººººº\n",
        "Total Cards Pulled:\n", tostring(totalCardsPulled),
        "\nºººººººº\n",
        "Card Most Seen:\n", mostSeenCard,
        "\nºººººººº\n",
        "Favorite Spread:\n", favoriteSpread,
        "\nºººººººº\n"
    }

    return table.concat(lines, "")
end

function DiaryEntriesListScene:renderYearFooter()
    self.yearFooterSeparatorY = 144
    self.yearFooterMendY = 173
    self.yearFooterCloseY = 202

    local separatorSprite = self:createTextSprite("ºººººººº", 160, 40, kTextAlignment.center)
    if separatorSprite then
        separatorSprite:setCenter(0.5, 0)
        separatorSprite:moveTo(self.listLeft + 48, self.yearFooterSeparatorY)
        separatorSprite:add()
        table.insert(self.entrySprites, separatorSprite)
    end

    local mendSprite = self:createTextSprite("Mend", 150, 40, kTextAlignment.left)
    if mendSprite then
        mendSprite:setCenter(0, 0)
        mendSprite:moveTo(self.listLeft + self.listLeftOffset, self.yearFooterMendY)
        mendSprite:add()
        table.insert(self.entrySprites, mendSprite)
    end

    local closeSprite = self:createTextSprite("Close", 150, 40, kTextAlignment.left)
    if closeSprite then
        closeSprite:setCenter(0, 0)
        closeSprite:moveTo(self.listLeft + self.listLeftOffset, self.yearFooterCloseY)
        closeSprite:add()
        table.insert(self.entrySprites, closeSprite)
    end
end

function DiaryEntriesListScene:buildMonthDayPreviewText()
    local monthRows = self:buildMonthDayRows()
    local selectedItem = monthRows[self.selectedDayIndex]
    if not selectedItem or selectedItem.type ~= "entry" then
        return "No diary entries yet."
    end

    local timeText = selectedItem.time or self:formatPreviewTime(selectedItem.entry and selectedItem.entry.time)

    local lines = {
        self:formatPreviewDate(selectedItem.date),
        "\n",
        timeText,
        "\nºººººººº\n"
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
    -- Reuse preview image/sprite to avoid allocations
    if not self.previewImage then
        self.previewImage = gfx.image.new(self.previewWidth, self.previewHeight)
    end

    if resetScroll then
        self.previewScrollY = 0
    end

    local previewText = self:buildPreviewText()
    local _, textHeight = gfx.getTextSizeForMaxWidth(previewText, self.previewWidth)
    local fullHeight = math.max(self.previewHeight, textHeight + 8)
    self.previewMaxScroll = math.max(0, fullHeight - self.previewHeight)
    self.previewScrollY = math.max(0, math.min(self.previewScrollY, self.previewMaxScroll))

    gfx.pushContext(self.previewImage)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(0, 0, self.previewWidth, self.previewHeight)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.drawTextInRect(previewText, 0, -self.previewScrollY, self.previewWidth, fullHeight, nil, nil, kTextAlignment.center)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
    gfx.popContext()

    if not self.previewSprite then
        self.previewSprite = gfx.sprite.new(self.previewImage)
        self.previewSprite:setCenter(0, 0)
        self.previewSprite:moveTo(self.previewLeft, self.previewTop)
        self.previewSprite:add()
    else
        self.previewSprite:setImage(self.previewImage)
        self.previewSprite:markDirty()
    end

    self.lastPreviewRenderTime = pd.getElapsedTime()
    self.previewNeedsRender = false
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
        total = self:getYearListCount()
    else
        local monthRows = self:buildMonthDayRows()
        selectedIndex = self.selectedDayIndex
        listStartIndex = self.dayListStartIndex
        total = #monthRows
    end

    if total == 0 or selectedIndex == 0 then
        self.selectorSprite:setVisible(false)
        return
    end

    self.selectorSprite:setVisible(true)

    local selectorX = self.listLeft - 4
    local y = self.listTop + 12

    if self.browserMode == "year" then
        if selectedIndex == self:getYearMendIndex() then
            selectorX = self.listLeft - 4
            y = (self.yearFooterMendY or 178) + 12
        elseif selectedIndex == self:getYearCloseIndex() then
            selectorX = self.listLeft - 4
            y = (self.yearFooterCloseY or 212) + 12
        else
            local row = selectedIndex - listStartIndex + 1
            y = self.listTop + ((row - 1) * self.rowHeight) + 12
        end
    elseif self.browserMode == "monthDay" then
        local row = selectedIndex - listStartIndex + 1
        y = self.listTop + ((row - 1) * self.rowHeight) + 12
        selectorX = self.listLeft + 25
    end

    self.selectorSprite:moveTo(selectorX, y + 6)
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
    local rowLimit = self.visibleEntryCount
    if self.browserMode == "year" then
        rowLimit = self:getYearBodyVisibleCount()
    end

    for row = 1, rowLimit do
        local index = listStartIndex + row - 1
        local item = items[index]
        if not item then
            break
        end

        local text = itemFormatter(item, index)
        local sprite = self:createTextSprite(text, 150, 40, kTextAlignment.left)
        if sprite then
            sprite:setCenter(0, 0)

            local textX = self.listLeft + self.listLeftOffset
            if self.browserMode == "monthDay" and item.type == "divider" then
                textX = self.listLeft - 20
            end

            sprite:moveTo(textX, self.listTop + ((row - 1) * self.rowHeight))
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

        local selectorX = self.listLeft - 4
        local selectedItem = items[selectedIndex]
        if self.browserMode == "monthDay" and selectedItem and selectedItem.type == "entry" then
            selectorX = self.listLeft + 25
        end

        self.selectorSprite:moveTo(selectorX, y + 6)
    end
end

function DiaryEntriesListScene:renderCurrentMode(resetScroll)
    self:clearEntrySprites()
    self:renderModeTitle()

    if self.browserMode == "year" then
        local yearItems = {}
        for index, yearBucket in ipairs(self.browserData.years) do
            yearItems[index] = yearBucket
        end

        local yearCount = #self.browserData.years
        local bodyVisibleCount = self:getYearBodyVisibleCount()

        if self.selectedYearIndex <= yearCount then
            self.selectedYearIndex, self.yearListStartIndex = self:clampListState(self.selectedYearIndex, self.yearListStartIndex, yearCount)
        else
            self.yearListStartIndex = math.max(1, (yearCount - bodyVisibleCount) + 1)
        end

        self:renderPreview(resetScroll)
        self:renderListRows(yearItems, self.selectedYearIndex, self.yearListStartIndex, function(item)
            return tostring(item.year)
        end)
        self:renderYearFooter()
        self:updateSelectorPosition()
    else
        local monthRows = self:buildMonthDayRows()
        self:clampMonthDaySelection(monthRows)
        self:renderPreview(resetScroll)
        self:renderListRows(monthRows, self.selectedDayIndex, self.dayListStartIndex, function(item)
            if item.type == "divider" then
                return self:toOrdinal(item.day)
            end

            return "  " .. (item.time or self:formatPreviewTime(item.entry and item.entry.time))
        end)
        self:updateSelectorPosition()
    end
end

function DiaryEntriesListScene:enterMonthDayMode()
    local yearBucket = self:getCurrentYearBucket()
    if not yearBucket or #yearBucket.months == 0 then
        return
    end

    self.browserMode = "monthDay"
    self.selectedMonthIndex = math.max(1, math.min(self.selectedMonthIndex, #yearBucket.months))
    self.selectedDayIndex = 0
    self.dayListStartIndex = 1
    self:moveMonthDaySelection(1)
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
        self.selectedDayIndex = 0
        self.dayListStartIndex = 1
        self:moveMonthDaySelection(1)
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

function DiaryEntriesListScene:leaveDiary()
    Sound.playSFX("b_button")
    SCENE_MANAGER:switchScene(DiaryScene)
end

function DiaryEntriesListScene:openCurrentEntry()
    local monthRows = self:buildMonthDayRows()
    local selectedItem = monthRows[self.selectedDayIndex]
    if not selectedItem or selectedItem.type ~= "entry" or not selectedItem.entry then
        return
    end

    Sound.playSFX("cards_fast2")
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

        self.lastCrankTime = pd.getElapsedTime()

        if not self.crankSoundPlaying then
            Sound.startCrankLoop()
            self.crankSoundPlaying = true
        end
    end

    if self.crankSoundPlaying and pd.getElapsedTime() - self.lastCrankTime > 0.1 then
        Sound.stopCrankLoop()
        self.crankSoundPlaying = false
    end

    if self.browserMode == "year" then
        local totalYears = #self.browserData.years
        local yearListCount = self:getYearListCount()

        if pd.buttonJustPressed(pd.kButtonDown) then
            if yearListCount > 0 and self.selectedYearIndex < yearListCount then
                Sound.playABut()
                self.selectedYearIndex = self.selectedYearIndex + 1
                self:renderCurrentMode(true)
            end
        end

        if pd.buttonJustPressed(pd.kButtonUp) then
            if yearListCount > 0 and self.selectedYearIndex > 1 then
                Sound.playABut()
                self.selectedYearIndex = self.selectedYearIndex - 1
                self:renderCurrentMode(true)
            end
        end

        if pd.buttonJustPressed(pd.kButtonA) then
            if self.selectedYearIndex == #self.browserData.years + 1 then
                Sound.playABut()
                SCENE_MANAGER:switchScene(DiarySettingsScene, "diary", self:buildReturnState())
            elseif self:isLockAndLeaveSelected() then
                self:leaveDiary()
            elseif totalYears > 0 then
                Sound.playABut()
                self:enterMonthDayMode()
            end
        end

        if pd.buttonJustPressed(pd.kButtonB) then
            self:leaveDiary()
        end
        return
    end

    if self.browserMode == "monthDay" then
        local yearBucket = self:getCurrentYearBucket()
        local monthRows = self:buildMonthDayRows()

        if pd.buttonJustPressed(pd.kButtonLeft) and yearBucket and #yearBucket.months > 0 then
            Sound.playABut()
            self:cycleMonth(-1)
        end

        if pd.buttonJustPressed(pd.kButtonRight) and yearBucket and #yearBucket.months > 0 then
            Sound.playABut()
            self:cycleMonth(1)
        end

        if pd.buttonJustPressed(pd.kButtonDown) and #monthRows > 0 then
            if self:moveMonthDaySelection(1) then
                Sound.playABut()
                self:renderCurrentMode(true)
            end
        end

        if pd.buttonJustPressed(pd.kButtonUp) and #monthRows > 0 then
            if self:moveMonthDaySelection(-1) then
                Sound.playABut()
                self:renderCurrentMode(true)
            end
        end

        if pd.buttonJustPressed(pd.kButtonA) then
            if #monthRows > 0 then
                Sound.playABut()
                self:openCurrentEntry()
            end
        end

        if pd.buttonJustPressed(pd.kButtonB) then
            Sound.playSFX("b_button")
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

    if self.crankSoundPlaying then
        Sound.stopCrankLoop()
        self.crankSoundPlaying = false
    end
    self.imagetable = nil
    self.bgImage = nil
    self.previewImage = nil
end