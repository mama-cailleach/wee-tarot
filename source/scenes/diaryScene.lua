local pd <const> = playdate
local gfx <const> = pd.graphics

import "data/save/diaryStore"

class('DiaryScene').extends(gfx.sprite)

function DiaryScene:init(restoreIndex)
    DiaryScene.super.init(self)

    self.bgImage = gfx.image.new("images/bg/journal1")
    self.bgSprite = gfx.sprite.new(self.bgImage)
    self.bgSprite:moveTo(200, 120)
    self.bgSprite:add()

    self.diaryLabel = gfx.sprite.spriteWithText("Diary of", 320, 40, nil, nil, nil, kTextAlignment.left)
    self.diaryLabel:setCenter(0, 0)
    self.diaryLabel:moveTo(40, 80)
    self.diaryLabel:add()

    self.diaryLine = gfx.sprite.spriteWithText("________________", 320, 40, nil, nil, nil, kTextAlignment.left)
    self.diaryLine:setCenter(0, 0)
    self.diaryLine:moveTo(40, 120)
    self.diaryLine:add()

    self.entries = DiaryStore.getEntries()
    self.entrySprites = {}
    self.visibleEntryCount = 8
    self.listLeft = 240
    self.listTop = 10
    self.listWidth = 182
    self.rowHeight = 28
    self.selectedIndex = restoreIndex or 1
    self.listStartIndex = 1
    self.selectorSprite = nil

    local selectorImage = gfx.image.new("images/bg/icon_tri_smol")
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

function DiaryScene:clearEntrySprites()
    for _, sprite in ipairs(self.entrySprites) do
        if sprite then
            sprite:remove()
        end
    end
    self.entrySprites = {}
end

function DiaryScene:formatEntry(entry)
    local date = entry and entry.date or "00-00-0000"
    local spread = entry and entry.spreadType or "unknown"
    return date -- .. " - " .. spread
end

function DiaryScene:clampSelectionAndWindow()
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

function DiaryScene:updateSelectorPosition()
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
    self.selectorSprite:moveTo(self.listLeft - 12, y)
end

function DiaryScene:renderEntries()
    self:clearEntrySprites()
    self:clampSelectionAndWindow()

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
            self.diaryLine1:moveTo(240, 110)
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

function DiaryScene:update()
    local total = #self.entries

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
        SCENE_MANAGER:switchScene(AfterDialogueScene)
    end

end

function DiaryScene:deinit()
    if self.bgSprite then self.bgSprite:remove() self.bgSprite = nil end
    if self.diaryLabel then self.diaryLabel:remove() self.diaryLabel = nil end
    if self.diaryLine then self.diaryLine:remove() self.diaryLine = nil end
    if self.selectorSprite then self.selectorSprite:remove() self.selectorSprite = nil end

    self:clearEntrySprites()
end
