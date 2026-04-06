local pd <const> = playdate
local gfx <const> = pd.graphics

import "data/save/diaryStore"
import "data/save/playerProfileStore"

class('DiaryEntriesListScene').extends(gfx.sprite)

function DiaryEntriesListScene:init(restoreIndex)
    DiaryEntriesListScene.super.init(self)

    self.bgImage = gfx.image.new("images/bg/journal1")
    self.bgSprite = gfx.sprite.new(self.bgImage)
    self.bgSprite:moveTo(200, 120)
    self.bgSprite:add()

    self.entries = DiaryStore.getEntries()
    self.entrySprites = {}
    self.previewSprite = nil
    self.listLeft = 35
    self.listTop = 10
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
    self.selectedIndex = restoreIndex or 1
    self.listStartIndex = 1
    self.selectorSprite = nil

    local selectorImage = gfx.image.new("images/bg/icon_knot1_smol")
    if selectorImage then
        self.selectorSprite = gfx.sprite.new(selectorImage)
        self.selectorSprite:add()
    end

    if #self.entries == 0 then
        self.selectedIndex = 0
    elseif self.selectedIndex > #self.entries then
        self.selectedIndex = #self.entries
    elseif self.selectedIndex < 1 then
        self.selectedIndex = 1
    end

    self:renderEntries()

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

function DiaryEntriesListScene:formatEntry(entry)
    local date = entry and entry.date or "00-00-0000"
    return PlayerProfileStore.formatDiaryDate(date)
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
        return "??? - ?? - ????"
    end

    local monthNames = {
        "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
        "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
    }

    local monthIndex = tonumber(month) or 0
    local monthText = monthNames[monthIndex] or "???"
    local dayText = self:toOrdinal(tonumber(day) or 0)

    return monthText .. " - " .. dayText .. " - " .. year
end

function DiaryEntriesListScene:formatSpreadLabel(spreadType)
    local spread = spreadType or "unknown"
    spread = string.gsub(spread, "[_%-]", " ")
    spread = string.gsub(spread, "(%a)([%w_']*)", function(first, rest)
        return string.upper(first) .. string.lower(rest)
    end)
    return spread
end

function DiaryEntriesListScene:buildPreviewText()
    local previewText = "No diary entries yet."
    if self.selectedIndex > 0 and self.entries[self.selectedIndex] then
        local entry = self.entries[self.selectedIndex]
        local lines = {
            self:formatSpreadLabel(entry.spreadType),
            "\n\n"
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

        previewText = table.concat(lines, "")
    end

    return previewText
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
        gfx.drawTextInRect(previewText, 0, -self.previewScrollY, self.previewWidth, fullHeight, nil, nil, kTextAlignment.left)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
    gfx.popContext()

    self.previewSprite = gfx.sprite.new(previewImage)
    if self.previewSprite then
        self.previewSprite:setCenter(0, 0)
        self.previewSprite:moveTo(self.previewLeft, self.previewTop)
        self.previewSprite:add()
    end
end

function DiaryEntriesListScene:clampSelectionAndWindow()
    local total = #self.entries
    if total == 0 then
        self.selectedIndex = 0
        self.listStartIndex = 1
        return
    end

    if self.selectedIndex < 1 then
        self.selectedIndex = 1
    elseif self.selectedIndex > total then
        self.selectedIndex = total
    end

    local maxStart = math.max(1, (total - self.visibleEntryCount) + 1)
    if self.listStartIndex > maxStart then
        self.listStartIndex = maxStart
    end

    if self.selectedIndex < self.listStartIndex then
        self.listStartIndex = self.selectedIndex
    end

    local lastVisible = self.listStartIndex + self.visibleEntryCount - 1
    if self.selectedIndex > lastVisible then
        self.listStartIndex = self.selectedIndex - self.visibleEntryCount + 1
    end
end

function DiaryEntriesListScene:updateSelectorPosition()
    if not self.selectorSprite then
        return
    end

    if self.selectedIndex == 0 then
        self.selectorSprite:setVisible(false)
        return
    end

    self.selectorSprite:setVisible(true)
    local row = self.selectedIndex - self.listStartIndex + 1
    local y = self.listTop + ((row - 1) * self.rowHeight) + 12
    self.selectorSprite:moveTo(self.listLeft - 18, y + 6)
end

function DiaryEntriesListScene:renderEntries()
    self:clearEntrySprites()
    self:clampSelectionAndWindow()
    self:renderPreview(true)

    for row = 1, self.visibleEntryCount do
        local index = self.listStartIndex + row - 1
        local entry = self.entries[index]
        if not entry then
            break
        end

        local text = self:formatEntry(entry)
        local sprite = gfx.sprite.spriteWithText(text, 150, 40, nil, nil, nil, kTextAlignment.left)
        if not sprite then
            self.diaryLine1 = gfx.sprite.spriteWithText(text, 150, 40, nil, nil, nil, kTextAlignment.left)
            self.diaryLine1:setCenter(0, 0)
            self.diaryLine1:moveTo(self.listLeft, self.listTop + ((row - 1) * self.rowHeight))
            self.diaryLine1:add()
            break
        end

        sprite:setCenter(0, 0)
        sprite:moveTo(self.listLeft, self.listTop + ((row - 1) * self.rowHeight))
        sprite:add()
        table.insert(self.entrySprites, sprite)
    end

    self:updateSelectorPosition()
end

function DiaryEntriesListScene:update()
    local total = #self.entries
    local crankTicks = pd.getCrankTicks(self.previewTicksPerRevolution)

    if crankTicks ~= 0 and self.previewMaxScroll > 0 then
        local nextScroll = self.previewScrollY + (crankTicks * self.previewScrollStep)
        local clampedScroll = math.max(0, math.min(nextScroll, self.previewMaxScroll))
        if clampedScroll ~= self.previewScrollY then
            self.previewScrollY = clampedScroll
            self:renderPreview(false)
        end
    end

    if pd.buttonJustPressed(pd.kButtonDown) then
        if total > 0 and self.selectedIndex < total then
            self.selectedIndex = self.selectedIndex + 1
            self:renderEntries()
        end
    end

    if pd.buttonJustPressed(pd.kButtonUp) then
        if total > 0 and self.selectedIndex > 1 then
            self.selectedIndex = self.selectedIndex - 1
            self:renderEntries()
        end
    end

    if pd.buttonJustPressed(pd.kButtonA) then
        if total > 0 and self.selectedIndex > 0 then
            cards_fast2:play(1)
            SCENE_MANAGER:switchScene(DiaryEntryScene, self.entries[self.selectedIndex], self.selectedIndex)
        end
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        cards_slow2:play(1)
        SCENE_MANAGER:switchScene(DiaryScene)
    end
end

function DiaryEntriesListScene:deinit()
    if self.bgSprite then self.bgSprite:remove() self.bgSprite = nil end
    if self.diaryLabel then self.diaryLabel:remove() self.diaryLabel = nil end
    if self.diaryLine then self.diaryLine:remove() self.diaryLine = nil end
    if self.selectorSprite then self.selectorSprite:remove() self.selectorSprite = nil end
    if self.previewSprite then self.previewSprite:remove() self.previewSprite = nil end

    self:clearEntrySprites()
end