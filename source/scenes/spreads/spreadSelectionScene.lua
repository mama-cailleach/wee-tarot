local pd <const> = playdate
local gfx <const> = playdate.graphics

class('SpreadSelectionScene').extends(gfx.sprite)

local deckKeys = {"full", "major", "minor", "cups", "pentacles", "swords", "wands"}
local deckLabels = {"Full Deck", "Major Arcana", "Minor Arcana", "Cups", "Pentacles", "Swords", "Wands"}

function SpreadSelectionScene:init()
    SpreadSelectionScene.super.init(self)

    self.bgSprite = gfx.sprite.new(gfx.image.new("images/bg/darkcloth"))
    self.bgSprite:moveTo(200, 120)
    self.bgSprite:add()

    local selectorImage = gfx.image.new("images/bg/icon_tri_smol")
    self.selectorSprite = gfx.sprite.new(selectorImage)
    self.selectorSprite:moveTo(120, 92)
    self.selectorSprite:add()

    self.selectorSpriteRight = gfx.sprite.new(selectorImage)
    self.selectorSpriteRight:setImageFlip(gfx.kImageFlippedX)
    self.selectorSpriteRight:moveTo(280, 92)
    self.selectorSpriteRight:add()

    self.titleText = gfx.sprite.spriteWithText("READING", 400, 200, nil, nil, nil, kTextAlignment.center)
    self.titleText:moveTo(200, 30)
    self.titleText:add()

    self.spreadOptions = {
        { label = "1-bit Fortune", key = "one_card", implemented = true },
        { label = "Root-Trunk-Branch", key = "three_card", implemented = true },
        { label = "Pentagram", key = "pentagram", implemented = true },
        { label = "Celtic Cross", key = "celtic_cross", implemented = true },
        { label = "Horoscope", key = "horoscope", implemented = true }
    }

    self.spreadOptionIndex = 1
    self.deckOptionIndex = 1
    for index, key in ipairs(deckKeys) do
        if key == (selectedDeck or "full") then
            self.deckOptionIndex = index
            break
        end
    end

    selectedDeck = deckKeys[self.deckOptionIndex]

    self.rowLabels = {"SPREAD", "DECK", "SEEK"}
    self.rowY = {70, 138, 212}
    self.selectedRow = 1

    self.spreadHeaderSprite = nil
    self.spreadValueSprite = nil
    self.deckHeaderSprite = nil
    self.deckValueSprite = nil
    self.goSprite = nil

    self.noticeSprite = nil
    self.noticeTimer = nil

    self:createLayoutSprites()
    self:updateSelectorPosition()

    self:add()
end

function SpreadSelectionScene:createLayoutSprites()
    self.spreadHeaderSprite = gfx.sprite.spriteWithText("SPREAD", 400, 40, nil, nil, nil, kTextAlignment.center)
    self.spreadHeaderSprite:moveTo(200, self.rowY[1])
    self.spreadHeaderSprite:add()

    self.spreadValueSprite = gfx.sprite.spriteWithText(self.spreadOptions[self.spreadOptionIndex].label, 400, 40, nil, nil, nil, kTextAlignment.center)
    self.spreadValueSprite:moveTo(200, self.rowY[1] + 28)
    self.spreadValueSprite:add()

    self.deckHeaderSprite = gfx.sprite.spriteWithText("DECK", 400, 40, nil, nil, nil, kTextAlignment.center)
    self.deckHeaderSprite:moveTo(200, self.rowY[2])
    self.deckHeaderSprite:add()

    self.deckValueSprite = gfx.sprite.spriteWithText(deckLabels[self.deckOptionIndex], 400, 40, nil, nil, nil, kTextAlignment.center)
    self.deckValueSprite:moveTo(200, self.rowY[2] + 28)
    self.deckValueSprite:add()

    self.goSprite = gfx.sprite.spriteWithText("SEEK", 400, 40, nil, nil, nil, kTextAlignment.center)
    self.goSprite:moveTo(200, self.rowY[3])
    self.goSprite:add()
end

function SpreadSelectionScene:updateSelectorPosition()
    local rowLabel = self.rowLabels[self.selectedRow]
    local textWidth = gfx.getTextSize(rowLabel)
    local offset = 18
    local y = self.rowY[self.selectedRow] - 2
    self.selectorSprite:moveTo(200 - textWidth / 2 - offset, y)
    self.selectorSpriteRight:moveTo(200 + textWidth / 2 + offset, y)
end

function SpreadSelectionScene:updateSpreadValueSprite()
    if self.spreadValueSprite then
        self.spreadValueSprite:remove()
    end
    self.spreadValueSprite = gfx.sprite.spriteWithText(self.spreadOptions[self.spreadOptionIndex].label, 400, 40, nil, nil, nil, kTextAlignment.center)
    self.spreadValueSprite:moveTo(200, self.rowY[1] + 28)
    self.spreadValueSprite:add()
end

function SpreadSelectionScene:updateDeckValueSprite()
    if self.deckValueSprite then
        self.deckValueSprite:remove()
    end
    self.deckValueSprite = gfx.sprite.spriteWithText(deckLabels[self.deckOptionIndex], 400, 40, nil, nil, nil, kTextAlignment.center)
    self.deckValueSprite:moveTo(200, self.rowY[2] + 28)
    self.deckValueSprite:add()
end

function SpreadSelectionScene:showNotice(text)
    if self.noticeSprite then
        self.noticeSprite:remove()
        self.noticeSprite = nil
    end
    if self.noticeTimer then
        self.noticeTimer:remove()
        self.noticeTimer = nil
    end

    self.noticeSprite = gfx.sprite.spriteWithText(text, 400, 40, nil, nil, nil, kTextAlignment.center)
    self.noticeSprite:moveTo(200, 222)
    self.noticeSprite:add()

    self.noticeTimer = pd.timer.performAfterDelay(1200, function()
        if self.noticeSprite then
            self.noticeSprite:remove()
            self.noticeSprite = nil
        end
        self.noticeTimer = nil
    end)
end

function SpreadSelectionScene:confirmSelection()
    local option = self.spreadOptions[self.spreadOptionIndex]
    selectedDeck = deckKeys[self.deckOptionIndex]

    if not option.implemented then
        cards_slow2:play(1)
        self:showNotice("This spread is coming soon")
        return
    end

    if option.key == "one_card" then
        cards_fast2:play(1)
        SCENE_MANAGER:switchScene(GameScene)
        return
    elseif option.key == "three_card" then
        cards_fast2:play(1)
        SCENE_MANAGER:switchScene(ThreeCardGameScene)
        return
    elseif option.key == "pentagram" then
        cards_fast2:play(1)
        SCENE_MANAGER:switchScene(PentagramGameScene)
        return
    elseif option.key == "celtic_cross" then
        cards_fast2:play(1)
        SCENE_MANAGER:switchScene(CelticCrossGameScene)
        return
    elseif option.key == "horoscope" then
        cards_fast2:play(1)
        SCENE_MANAGER:switchScene(HoroscopeGameScene)
        return
    end
end

function SpreadSelectionScene:update()
    if pd.buttonJustPressed(pd.kButtonDown) then
        self.selectedRow = self.selectedRow + 1
        if self.selectedRow > #self.rowLabels then
            self.selectedRow = 1
        end
        self:updateSelectorPosition()
    elseif pd.buttonJustPressed(pd.kButtonUp) then
        self.selectedRow = self.selectedRow - 1
        if self.selectedRow < 1 then
            self.selectedRow = #self.rowLabels
        end
        self:updateSelectorPosition()
    end

    if pd.buttonJustPressed(pd.kButtonA) then
        if self.selectedRow == 1 then
            self.spreadOptionIndex = self.spreadOptionIndex % #self.spreadOptions + 1
            cards_slow2:play(1)
            self:updateSpreadValueSprite()
        elseif self.selectedRow == 2 then
            self.deckOptionIndex = self.deckOptionIndex % #deckLabels + 1
            selectedDeck = deckKeys[self.deckOptionIndex]
            cards_slow2:play(1)
            self:updateDeckValueSprite()
        else
            self:confirmSelection()
        end
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        cards_slow:play(1)
        SCENE_MANAGER:switchScene(AfterDialogueScene)
    end
end

function SpreadSelectionScene:deinit()
    if self.bgSprite then self.bgSprite:remove() self.bgSprite = nil end
    if self.selectorSprite then self.selectorSprite:remove() self.selectorSprite = nil end
    if self.selectorSpriteRight then self.selectorSpriteRight:remove() self.selectorSpriteRight = nil end
    if self.titleText then self.titleText:remove() self.titleText = nil end
    if self.spreadHeaderSprite then self.spreadHeaderSprite:remove() self.spreadHeaderSprite = nil end
    if self.spreadValueSprite then self.spreadValueSprite:remove() self.spreadValueSprite = nil end
    if self.deckHeaderSprite then self.deckHeaderSprite:remove() self.deckHeaderSprite = nil end
    if self.deckValueSprite then self.deckValueSprite:remove() self.deckValueSprite = nil end
    if self.goSprite then self.goSprite:remove() self.goSprite = nil end
    if self.noticeSprite then self.noticeSprite:remove() self.noticeSprite = nil end
    if self.noticeTimer then self.noticeTimer:remove() self.noticeTimer = nil end
end
