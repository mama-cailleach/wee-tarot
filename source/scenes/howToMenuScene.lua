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

    self.titleText = gfx.sprite.spriteWithText("How To", 400, 200, nil, nil, nil, kTextAlignment.center)
    self.titleText:moveTo(210, 30)
    self.titleText:add()

    self.topicOptions = {
        { label = "Table Manners", key = "general", implemented = true },
        { label = "1-bit Fortune", key = "one_card", implemented = true },
        { label = "Root-Trunk-Branch", key = "three_card", implemented = true },
        { label = "Pentagram", key = "pentagram", implemented = true },
        { label = "Celtic Cross", key = "celtic_cross", implemented = true },
        { label = "Horoscope", key = "horoscope", implemented = true }
    }

    self.optionSprites = {}
    self.selectedIndex = 1
    self.topY = 68
    self.step = 28

    self.noticeSprite = nil
    self.noticeTimer = nil

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
        optionSprite:moveTo(210, y)
        optionSprite:add()
        table.insert(self.optionSprites, optionSprite)
    end
end

function HowToMenuScene:updateSelectorPosition()
    local option = self.topicOptions[self.selectedIndex]
    local textWidth = gfx.getTextSize(option.label)
    local offset = 18
    local y = self.topY + (self.selectedIndex - 1) * self.step
    self.selectorSprite:moveTo(210 - textWidth / 2 - offset, y)
end

function HowToMenuScene:showNotice(text)
    if self.noticeSprite then
        self.noticeSprite:remove()
        self.noticeSprite = nil
    end
    if self.noticeTimer then
        self.noticeTimer:remove()
        self.noticeTimer = nil
    end

    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
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

function HowToMenuScene:confirmSelection()
    local option = self.topicOptions[self.selectedIndex]

    if option.key == "one_card" then
        cards_fast2:play(1)
        SCENE_MANAGER:switchScene(HowToScene)
        return
    end

    if option.key == "three_card" then
        cards_fast2:play(1)
        SCENE_MANAGER:switchScene(HowToThreeCardScene)
        return
    end

    if option.key == "pentagram" then
        cards_fast2:play(1)
        SCENE_MANAGER:switchScene(HowToPentagramScene)
        return
    end

    if option.key == "celtic_cross" then
        cards_fast2:play(1)
        SCENE_MANAGER:switchScene(HowToCelticCrossScene)
        return
    end

    if option.key == "horoscope" then
        cards_fast2:play(1)
        SCENE_MANAGER:switchScene(HowToHoroscopeScene)
        return
    end

    cards_slow2:play(1)
    self:showNotice("Scene not implemented yet!")
end

function HowToMenuScene:update()
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
        cards_slow:play(1)
        SCENE_MANAGER:switchScene(SettingsScene)
    end
end

function HowToMenuScene:deinit()
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
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
