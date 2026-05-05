local pd <const> = playdate
local gfx <const> = playdate.graphics

class('HowToSpreadsMenuScene').extends(gfx.sprite)

function HowToSpreadsMenuScene:init()
    HowToSpreadsMenuScene.super.init(self)

    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

    self.bgSprite = gfx.sprite.new(gfx.image.new("images/bg/darkcloth"))
    self.bgSprite:moveTo(200, 120)
    self.bgSprite:add()

    local selectorImage = gfx.image.new("images/bg/icon_tri_smol")
    self.selectorSprite = gfx.sprite.new(selectorImage)
    self.selectorSprite:moveTo(128, 86)
    self.selectorSprite:add()

    self.titleText = gfx.sprite.spriteWithText("Spreads", 400, 200, nil, nil, nil, kTextAlignment.center)
    self.titleText:moveTo(210, 30)
    self.titleText:add()

    self.topicOptions = {
        { label = "1-bit Fortune", key = "one_card" },
        { label = "Pentagram", key = "pentagram" },
        { label = "Root-Trunk-Branch", key = "three_card" },
        { label = "Celtic Cross", key = "celtic_cross" },
        { label = "Horoscope", key = "horoscope" },
        { label = "Back", key = "back" }
    }

    self.optionSprites = {}
    self.selectedIndex = 1
    self.topY = 68
    self.step = 28

    self:createOptionSprites()
    self:updateSelectorPosition()

    self:add()
end

function HowToSpreadsMenuScene:createOptionSprites()
    for _, sprite in ipairs(self.optionSprites) do
        sprite:remove()
    end
    self.optionSprites = {}

    for index, option in ipairs(self.topicOptions) do
        local y = self.topY + (index - 1) * self.step
        local optionSprite = gfx.sprite.spriteWithText(option.label, 290, 40, nil, nil, nil, kTextAlignment.center)
        optionSprite:moveTo(210, y)
        optionSprite:add()
        table.insert(self.optionSprites, optionSprite)
    end
end

function HowToSpreadsMenuScene:updateSelectorPosition()
    local option = self.topicOptions[self.selectedIndex]
    local textWidth = gfx.getTextSize(option.label)
    local offset = 18
    local y = self.topY + (self.selectedIndex - 1) * self.step
    self.selectorSprite:moveTo(210 - textWidth / 2 - offset, y)
end

function HowToSpreadsMenuScene:confirmSelection()
    local option = self.topicOptions[self.selectedIndex]

    if option.key == "one_card" then
        Sound.playSFX("cards_fast2")
        SCENE_MANAGER:switchScene(HowToScene)
        return
    end

    if option.key == "three_card" then
        Sound.playSFX("cards_fast2")
        SCENE_MANAGER:switchScene(HowToThreeCardScene)
        return
    end

    if option.key == "pentagram" then
        Sound.playSFX("cards_fast2")
        SCENE_MANAGER:switchScene(HowToPentagramScene)
        return
    end

    if option.key == "celtic_cross" then
        Sound.playSFX("cards_fast2")
        SCENE_MANAGER:switchScene(HowToCelticCrossScene)
        return
    end

    if option.key == "horoscope" then
        Sound.playSFX("cards_fast2")
        SCENE_MANAGER:switchScene(HowToHoroscopeScene)
        return
    end

    if option.key == "back" then
        Sound.playSFX("cards_fast2")
        SCENE_MANAGER:switchScene(HowToMenuScene)
        return
    end
end

function HowToSpreadsMenuScene:update()
    if pd.buttonJustPressed(pd.kButtonDown) then
        self.selectedIndex = self.selectedIndex + 1
        if self.selectedIndex > #self.topicOptions then
            self.selectedIndex = 1
        end
        self:updateSelectorPosition()
    elseif pd.buttonJustPressed(pd.kButtonUp) then
        self.selectedIndex = self.selectedIndex - 1
        if self.selectedIndex < 1 then
            self.selectedIndex = #self.topicOptions
        end
        self:updateSelectorPosition()
    end

    if pd.buttonJustPressed(pd.kButtonA) then
        self:confirmSelection()
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        Sound.playSFX("cards_slow")
        SCENE_MANAGER:switchScene(HowToMenuScene)
    end
end

function HowToSpreadsMenuScene:deinit()
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    if self.bgSprite then self.bgSprite:remove() self.bgSprite = nil end
    if self.selectorSprite then self.selectorSprite:remove() self.selectorSprite = nil end
    if self.titleText then self.titleText:remove() self.titleText = nil end

    for _, sprite in ipairs(self.optionSprites or {}) do
        sprite:remove()
    end
    self.optionSprites = nil
end
