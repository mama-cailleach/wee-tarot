local pd <const> = playdate
local gfx <const> = playdate.graphics

class('SettingsScene').extends(gfx.sprite)


function SettingsScene:init()
    self.bgImage = gfx.image.new("images/bg/darkcloth")
    self.bgSprite = gfx.sprite.new(self.bgImage)
    self.bgSprite:moveTo(200,120)
    self.bgSprite:add()


    local img = gfx.image.new("images/bg/icon_tri_smol")
    self.spritewands = gfx.sprite.new(img)
    self.selectorX = 200
    self.spritewands:moveTo(self.selectorX, 70)
    self.spritewands:add()

    self.selectorSprite = self.spritewands
    
    gfx.setImageDrawMode(gfx.kDrawModeNXOR)

    self.titleText = gfx.sprite.spriteWithText("MENU", 400, 200, nil, nil, nil, kTextAlignment.center)  
    self.titleText:moveTo(200, 30)
    self.titleText:setScale(1)
    self.titleText:add()

    self.buttonX = 200
    self.topY = 70
    self.step = 35
    self.bottomY = self.topY + 3 * self.step

    self:addButton("How To", self.buttonX, self.topY)
    self:addButton("Sound", self.buttonX, self.topY + self.step)
    self:addButton("Credits", self.buttonX, self.bottomY - self.step)
    self:addButton("Back", self.buttonX, self.bottomY)

    self.options = {
        {text = "How To", y = self.topY},
        {text = "Sound", y = self.topY + self.step},
        {text = "Credits", y = self.bottomY - self.step},
        {text = "Back", y = self.bottomY}
    }
    self.selectedIndex = 1

    self:add()
end


function SettingsScene:update()
    if pd.buttonJustPressed(pd.kButtonA) and self.selectorSprite.y == self.bottomY then
        Sound.playABut()
        Sound.playSFX("cards_slow2")
        SCENE_MANAGER:switchScene(AfterDialogueScene)
    elseif pd.buttonJustPressed(pd.kButtonA) and self.selectorSprite.y == self.topY then
        Sound.playABut()
        Sound.playSFX("cards_slow2")
        SCENE_MANAGER:switchScene(HowToMenuScene)
    elseif pd.buttonJustPressed(pd.kButtonA) and self.selectorSprite.y == self.bottomY - self.step then
        Sound.playABut()
        Sound.playSFX("cards_slow2")
        SCENE_MANAGER:switchScene(CreditsScene)
    elseif pd.buttonJustPressed(pd.kButtonA) and self.selectorSprite.y == self.topY + self.step then
        Sound.playABut()
        Sound.playSFX("cards_slow2")
        SCENE_MANAGER:switchScene(SoundSettingsScene)
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        Sound.playSFX("b_button")
        Sound.playSFX("cards_slow")
        SCENE_MANAGER:switchScene(AfterDialogueScene)
    end


    if pd.buttonJustPressed(pd.kButtonDown) then
        Sound.playABut()
        self.selectorSprite:moveBy(0, self.step)
    elseif pd.buttonJustPressed(pd.kButtonUp) then  
        Sound.playABut()
        self.selectorSprite:moveBy(0, -self.step)
        if self.selectorSprite.y < self.topY then
            self.selectorSprite:moveTo(self.selectorX, self.bottomY)
        end

    end

    local yToIndex = {
        [self.topY] = 1,
        [self.topY + self.step] = 2,
        [self.bottomY - self.step] = 3,
        [self.bottomY] = 4
    }
    self.selectedIndex = yToIndex[self.selectorSprite.y] or 1
    local font = gfx.getSystemFont()
    local currentOption = self.options[self.selectedIndex]
    local textWidth = gfx.getTextSize(currentOption.text, font)
    local offset = 18
    self.selectorSprite:moveTo(self.selectorX - textWidth/2 - offset, currentOption.y)
end

function SettingsScene:textOut()
    self.titleText:remove()
end

function SettingsScene:addButton(text, x, y)
    local buttonText = gfx.sprite.spriteWithText(text, 400, 200, nil, nil, nil, kTextAlignment.center)
    buttonText:moveTo(x, y)
    buttonText:add()
    self:add(buttonText)
    return buttonText
end
