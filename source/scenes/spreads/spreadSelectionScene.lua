local pd <const> = playdate
local gfx <const> = playdate.graphics

class('SpreadSelectionScene').extends(gfx.sprite)

function SpreadSelectionScene:init()
    SpreadSelectionScene.super.init(self)

    self.bgSprite = gfx.sprite.new(gfx.image.new("images/bg/darkcloth"))
    self.bgSprite:moveTo(200, 120)
    self.bgSprite:add()

    local selectorImage = gfx.image.new("images/bg/menu_icon")
    self.selectorSprite = gfx.sprite.new(selectorImage)
    self.selectorSprite:moveTo(120, 86)
    self.selectorSprite:add()

    self.titleText = gfx.sprite.spriteWithText("SPREAD", 400, 200, nil, nil, nil, kTextAlignment.center)
    self.titleText:moveTo(200, 30)
    self.titleText:add()

    self.spreadOptions = {
        { label = "1 Card Fortune", key = "one_card", implemented = true },
        { label = "3 Card Spread", key = "three_card", implemented = true },
        { label = "Pentagram (5)", key = "pentagram", implemented = true },
        { label = "Celtic Cross (10)", key = "celtic_cross", implemented = true },
        { label = "Horoscope (12)", key = "horoscope", implemented = true }
    }

    self.optionSprites = {}
    self.selectedIndex = 1
    self.topY = 70
    self.step = 26

    self.noticeSprite = nil
    self.noticeTimer = nil

    self:createOptionSprites()
    self:updateSelectorPosition()

    self:add()
end

function SpreadSelectionScene:createOptionSprites()
    for _, sprite in ipairs(self.optionSprites) do
        sprite:remove()
    end
    self.optionSprites = {}

    for index, option in ipairs(self.spreadOptions) do
        local y = self.topY + (index - 1) * self.step
        local optionSprite = gfx.sprite.spriteWithText(option.label, 280, 40, nil, nil, nil, kTextAlignment.center)
        optionSprite:moveTo(210, y)
        optionSprite:add()
        table.insert(self.optionSprites, optionSprite)
    end
end

function SpreadSelectionScene:updateSelectorPosition()
    local option = self.spreadOptions[self.selectedIndex]
    local textWidth = gfx.getTextSize(option.label)
    local offset = 18
    local y = self.topY + (self.selectedIndex - 1) * self.step
    self.selectorSprite:moveTo(210 - textWidth / 2 - offset, y)
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
    local option = self.spreadOptions[self.selectedIndex]

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

    cards_slow2:play(1)
    self:showNotice("This spread is coming soon")
end

function SpreadSelectionScene:update()
    if pd.buttonJustPressed(pd.kButtonDown) then
        self.selectedIndex = self.selectedIndex + 1
        if self.selectedIndex > #self.spreadOptions then
            self.selectedIndex = 1
        end
        self:updateSelectorPosition()
    elseif pd.buttonJustPressed(pd.kButtonUp) then
        self.selectedIndex = self.selectedIndex - 1
        if self.selectedIndex < 1 then
            self.selectedIndex = #self.spreadOptions
        end
        self:updateSelectorPosition()
    end

    if pd.buttonJustPressed(pd.kButtonA) then
        self:confirmSelection()
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        cards_slow:play(1)
        SCENE_MANAGER:switchScene(AfterDialogueScene)
    end
end

function SpreadSelectionScene:deinit()
    if self.bgSprite then self.bgSprite:remove() self.bgSprite = nil end
    if self.selectorSprite then self.selectorSprite:remove() self.selectorSprite = nil end
    if self.titleText then self.titleText:remove() self.titleText = nil end
    if self.noticeSprite then self.noticeSprite:remove() self.noticeSprite = nil end
    if self.noticeTimer then self.noticeTimer:remove() self.noticeTimer = nil end

    for _, sprite in ipairs(self.optionSprites or {}) do
        sprite:remove()
    end
    self.optionSprites = nil
end
