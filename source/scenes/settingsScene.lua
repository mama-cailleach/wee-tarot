local pd <const> = playdate
local gfx <const> = playdate.graphics

class('SettingsScene').extends(gfx.sprite)

local deckKeys = {"full", "major", "minor", "cups", "pentacles", "swords", "wands"}


function SettingsScene:init()
    self.bgImage = gfx.image.new("images/bg/darkcloth")
    self.bgSprite = gfx.sprite.new(self.bgImage)
    self.bgSprite:moveTo(200,120)
    self.bgSprite:add()


    local img = gfx.image.new("images/bg/icon_tri_smol")
    self.spritewands = gfx.sprite.new(img)
    self.spritewands:moveTo(160, 70)
    self.spritewands:add()

    -- Add selector button sprite (e.g., ">" or "●")
    self.selectorSprite = self.spritewands
    --self:makeButtonSprite("A", 150, 70, 13)
    
    gfx.setImageDrawMode(gfx.kDrawModeNXOR) -- for text color

    self.titleText = gfx.sprite.spriteWithText("MENU", 400, 200, nil, nil, nil, kTextAlignment.center)  
    self.titleText:moveTo(210, 30)
    self.titleText:setScale(1)
    self.titleText:add()

    -- default options
    self.howTo = false

    self.soundText = {"Music&Rain", "Just Music", "Just Rain"}
    self.soundTextIndex = Sound.getSoundMode()

    self.buttonX = 210
    self.topY = 70
    self.step = 35
    self.bottomY = self.topY + 4 * self.step 

    -- Add buttons
    self:addButton("How To", self.buttonX, self.topY)
    self:addButton("Diary Mending", self.buttonX, self.topY + self.step)
    self.soundButton = self:addButton(self.soundText[self.soundTextIndex], self.buttonX, self.topY + self.step*2)
    self:addButton("Credits", self.buttonX, self.bottomY - self.step)
    self:addButton("Back", self.buttonX, self.bottomY)

    self.options = {
    {text = "How To", y = self.topY},
    {text = "Diary Mending", y = self.topY + self.step},
    {text = self.soundText[self.soundTextIndex], y = self.topY + self.step*2},
    {text = "Credits", y = self.bottomY - self.step},
    {text = "Back", y = self.bottomY}
    }
    self.selectedIndex = 1 -- Start at the first option

    
 
    self:add()
end


function SettingsScene:makeButtonSprite(letter, x, y, radius)
    local r = radius or 16
    local img = gfx.image.new(r*2, r*2)
    gfx.pushContext(img)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillCircleAtPoint(r, r, r)
        gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
        gfx.setLineWidth(2)
        gfx.drawCircleAtPoint(r, r, r)
        local font = gfx.getSystemFont()
        local w, h = gfx.getTextSize(letter, font)
        gfx.drawTextAligned(letter, r - w/2, r - h/2, kTextAlignment.left)
    gfx.popContext()
    local sprite = gfx.sprite.new(img)
    sprite:moveTo(x, y)
    sprite:add()
    return sprite
end



function SettingsScene:update()
    

    -- BACK OPTION
    if pd.buttonJustPressed(pd.kButtonA) and self.selectorSprite.y == self.bottomY then
        Sound.playABut()
        Sound.playSFX("cards_slow2")
        SCENE_MANAGER:switchScene(AfterDialogueScene)
    --HOW TO OPTION
    elseif pd.buttonJustPressed(pd.kButtonA) and self.selectorSprite.y == self.topY then
        Sound.playABut()
        Sound.playSFX("cards_slow2")
        SCENE_MANAGER:switchScene(HowToMenuScene)
    -- CREDITS OPTION
    elseif pd.buttonJustPressed(pd.kButtonA) and self.selectorSprite.y == self.bottomY - self.step then
        Sound.playABut()
        Sound.playSFX("cards_slow2")
        SCENE_MANAGER:switchScene(CreditsScene)
    --DIARY OPTION
    elseif pd.buttonJustPressed(pd.kButtonA) and self.selectorSprite.y == self.topY + self.step then
        Sound.playABut()
        Sound.playSFX("cards_slow2")
        SCENE_MANAGER:switchScene(DiarySettingsScene)
    -- SOUND OPTION
    elseif pd.buttonJustPressed(pd.kButtonA) and self.selectorSprite.y == self.topY + self.step*2 then
        -- Toggle soundTextIndex
        self.soundTextIndex = self.soundTextIndex % #self.soundText + 1

        Sound.setSoundMode(self.soundTextIndex)

        -- Update the button text
        if self.soundButton then
            self.soundButton:remove()
        end
        self.soundButton = self:addButton(self.soundText[self.soundTextIndex], 200, self.topY + self.step*2)
        -- Update the options table so selector uses the new text
        self.options[3].text = self.soundText[self.soundTextIndex]
        if self.soundTextIndex ~= 2 then
            Sound.setAmbienceVolume(0.3)
            Sound.playAmbience()
        end
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
            self.selectorSprite:moveTo(200, self.bottomY)
        end

    end

    local yToIndex = { [self.topY]=1, [self.topY + self.step]=2, [self.topY + self.step *2 ]=3, [self.bottomY - self.step]=4, [self.bottomY]=5 }
    self.selectedIndex = yToIndex[self.selectorSprite.y] or 1
    local font = gfx.getSystemFont()
    local currentOption = self.options[self.selectedIndex]
    local textWidth = gfx.getTextSize(currentOption.text, font)
    local offset = 18
    self.selectorSprite:moveTo(200 - textWidth/2 - offset, currentOption.y)

    
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
