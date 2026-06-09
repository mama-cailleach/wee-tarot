local pd <const> = playdate
local gfx <const> = playdate.graphics

class('HowToMenuScene').extends(gfx.sprite)

function HowToMenuScene:init()
    HowToMenuScene.super.init(self)

    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

    self.bgSprite = gfx.sprite.new(gfx.image.new("images/bg/darkcloth"))
    self.bgSprite:moveTo(200, 120)
    self.bgSprite:add()

    local selectorImage = gfx.image.new("images/bg/icon_tri_smol")
    self.selectorSprite = gfx.sprite.new(selectorImage)
    self.selectorSprite:moveTo(128, 86)
    self.selectorSprite:add()

    self.titleText = gfx.sprite.spriteWithText("HOW TO", 400, 200, nil, nil, nil, kTextAlignment.center)
    self.titleText:moveTo(200, 30)
    self.titleText:add()

    self.topicOptions = {
        { label = "Spreads", key = "spreads" },
        { label = "Diary", key = "diary" },
        { label = "Table Manners", key = "table_manners" },
        { label = "Bits & Bobs", key = "bits_and_bobs" },
        { label = "Back", key = "back" }
    }

    self.optionSprites = {}
    self.selectedIndex = 1
    self.topY = 68
    self.step = 34

    self:createOptionSprites()
    self:updateSelectorPosition()

    self:add()
end

function HowToMenuScene:createOptionSprites()
    for _, sprite in ipairs(self.optionSprites) do
        sprite:remove()
    end
    self.optionSprites = {}

    for index, option in ipairs(self.topicOptions) do
        local y = self.topY + (index - 1) * self.step
        local optionSprite = gfx.sprite.spriteWithText(option.label, 290, 40, nil, nil, nil, kTextAlignment.center)
        optionSprite:moveTo(200, y)
        optionSprite:add()
        table.insert(self.optionSprites, optionSprite)
    end
end

function HowToMenuScene:updateSelectorPosition()
    local option = self.topicOptions[self.selectedIndex]
    local textWidth = gfx.getTextSize(option.label)
    local offset = 22
    local y = self.topY + (self.selectedIndex - 1) * self.step
    self.selectorSprite:moveTo(200 - textWidth / 2 - offset, y)
end

function HowToMenuScene:confirmSelection()
    local option = self.topicOptions[self.selectedIndex]

    if option.key == "table_manners" then
        Sound.playSFX("cards_fast2")
        SCENE_MANAGER:switchScene(HowToTableMannersScene)
        return
    end

    if option.key == "bits_and_bobs" then
        Sound.playSFX("cards_fast2")
        SCENE_MANAGER:switchScene(HowToBitsAndBobsScene)
        return
    end

    if option.key == "spreads" then
        Sound.playSFX("cards_fast2")
        SCENE_MANAGER:switchScene(HowToSpreadsMenuScene)
        return
    end

    if option.key == "diary" then
        Sound.playSFX("cards_fast2")
        SCENE_MANAGER:switchScene(HowToDiaryScene)
        return
    end

    if option.key == "back" then
        Sound.playSFX("cards_fast2")
        SCENE_MANAGER:switchScene(SettingsScene)
        return
    end
end

function HowToMenuScene:update()
    if pd.buttonJustPressed(pd.kButtonDown) then
        Sound.playABut()
        self.selectedIndex = self.selectedIndex + 1
        if self.selectedIndex > #self.topicOptions then
            self.selectedIndex = 1
        end
        self:updateSelectorPosition()
    elseif pd.buttonJustPressed(pd.kButtonUp) then
        Sound.playABut()
        self.selectedIndex = self.selectedIndex - 1
        if self.selectedIndex < 1 then
            self.selectedIndex = #self.topicOptions
        end
        self:updateSelectorPosition()
    end

    if pd.buttonJustPressed(pd.kButtonA) then
        Sound.playABut()
        self:confirmSelection()
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        Sound.playSFX("b_button")
        SCENE_MANAGER:switchScene(SettingsScene)
    end
end

function HowToMenuScene:deinit()
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    if self.bgSprite then self.bgSprite:remove() self.bgSprite = nil end
    if self.selectorSprite then self.selectorSprite:remove() self.selectorSprite = nil end
    if self.titleText then self.titleText:remove() self.titleText = nil end

    for _, sprite in ipairs(self.optionSprites or {}) do
        sprite:remove()
    end
    self.optionSprites = nil
end
