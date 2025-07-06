local pd <const> = playdate
local gfx <const> = playdate.graphics

class('SettingsScene').extends(gfx.sprite)


function SettingsScene:init()
    self.bgImage = gfx.image.new("images/bg/darkcloth")
    self.bgSprite = gfx.sprite.new(self.bgImage)
    self.bgSprite:moveTo(200,120)
    self.bgSprite:add()


    local img = gfx.image.new("images/bg/Wands_test2")
    self.spritewands = gfx.sprite.new(img)
    self.spritewands:moveTo(150, 70)
    self.spritewands:add()

    -- Add selector button sprite (e.g., ">" or "●")
    self.selectorSprite = self.spritewands
    --self:makeButtonSprite("A", 150, 70, 13)
    
    gfx.setImageDrawMode(gfx.kDrawModeNXOR) -- for text color

    self.titleText = gfx.sprite.spriteWithText("MENU", 400, 200, nil, nil, nil, kTextAlignment.center)  
    self.titleText:moveTo(200, 30)
    self.titleText:setScale(1)
    self.titleText:add()

    -- default options
    self.howTo = false

    self.deckText = {"Full Deck", "Major Arcana"}
    self.deckTextIndex = onlyMajor and 2 or 1

    self.soundText = {"Music&Rain", "Just Music", "Just Rain"}
    self.soundTextIndex = 1


    self.topY = 70
    self.step = 35
    self.bottomY = self.topY + 4 * self.step 

    -- Add buttons
    self:addButton("How To", 200, self.topY)
    self.deckButton = self:addButton(self.deckText[self.deckTextIndex], 200, self.topY + self.step)
    self.soundButton = self:addButton(self.soundText[self.soundTextIndex], 200, self.topY + self.step*2)
    self:addButton("Credits", 200, self.bottomY - self.step)
    self:addButton("Back", 200, self.bottomY)

    self.options = {
    {text = "How To", y = self.topY},
    {text = self.deckText[self.deckTextIndex], y = self.topY + self.step},
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
        thunder:play(1)
        SCENE_MANAGER:switchScene(AfterDialogueScene)
    --HOW TO OPTION
    elseif pd.buttonJustPressed(pd.kButtonA) and self.selectorSprite.y == self.topY then
        thunder:play(1)
        SCENE_MANAGER:switchScene(HowToScene)
    -- CREDITS OPTION
    elseif pd.buttonJustPressed(pd.kButtonA) and self.selectorSprite.y == self.bottomY - self.step then
        thunder:play(1)
        SCENE_MANAGER:switchScene(CreditsScene)
    --DECK OPtion
    elseif pd.buttonJustPressed(pd.kButtonA) and self.selectorSprite.y == self.topY + self.step then
        self.howTo = true
        self.deckTextIndex = self.deckTextIndex % #self.deckText + 1
        -- Update the button text
        if self.deckButton then
            self.deckButton:remove()
        end
        self.deckButton = self:addButton(self.deckText[self.deckTextIndex], 200, self.topY + self.step)

        -- Update the options table so selector uses the new text
        self.options[2].text = self.deckText[self.deckTextIndex]

        -- Set global onlyMajor
        if self.deckTextIndex == 1 then
            onlyMajor = false
            print(onlyMajor)
        else
            onlyMajor = true
            print(onlyMajor)
        end
    -- SOUND OPTION
    elseif pd.buttonJustPressed(pd.kButtonA) and self.selectorSprite.y == self.topY + self.step*2 then
        -- Toggle soundTextIndex
        self.soundTextIndex = self.soundTextIndex % #self.soundText + 1
        -- Update the button text
        if self.soundButton then
            self.soundButton:remove()
        end
        self.soundButton = self:addButton(self.soundText[self.soundTextIndex], 200, self.topY + self.step*2)
        -- Update the options table so selector uses the new text
        self.options[3].text = self.soundText[self.soundTextIndex]
        -- (Optional) Set a global or do something with the sound mode here  
        if self.soundTextIndex == 1 then
            -- Music&Ambience
            if bgMusic:getVolume() == 0 then
                bgMusic:setVolume(0.7)
            end
            if not ambience:isPlaying() then
                ambience:setVolume(0.3)
                ambience:play(0)
            end
        elseif self.soundTextIndex == 2 then
            -- Play only music
            if bgMusic:getVolume() == 0 then
                bgMusic:setVolume(0.7)
            end
            if ambience:isPlaying() then
                ambience:stop()
            end
        elseif self.soundTextIndex == 3 then
            -- Play only ambience
            if bgMusic:getVolume() ~= 0 then
                bgMusic:setVolume(0)
            end
            if not ambience:isPlaying() then
                ambience:setVolume(0.3)
                ambience:play(0)
            end
        end
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        SCENE_MANAGER:switchScene(AfterDialogueScene)
    end


    if pd.buttonJustPressed(pd.kButtonDown) then
        self.selectorSprite:moveBy(0, self.step)
    elseif pd.buttonJustPressed(pd.kButtonUp) then  
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
