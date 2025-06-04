--import "libraries/AnimatedSprite"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('MenuScene').extends(gfx.sprite)


function MenuScene:init()
    MenuScene.super.init(self)

    -- scene variables
    self.imagetable = gfx.imagetable.new("images/bg/dinahBG-table-400-266")
    self.dinahSprite = AnimatedSprite.new(self.imagetable)
    self.scrollBoxImg = gfx.image.new("images/textScroll/scroll1b")
    self.scrollBoxSprite = gfx.sprite.new(self.scrollBoxImg)
    self.dinahText = {}
    self.currentIndex = 1
    self.dinahScrollText = nil
    self.bButton = nil
    self.deleteB = false
    self.lastText = false
    self.scrollBoxAnimatorIn = nil 
    self.scrollBoxY = nil
    self.scrollBoxLoad = false
    self.interaction = false
    self.optionsTextOn = false

    -- --- TEXT ANIMATION LOOP PARAMETERS ---
    self.scrollBaseY = 170 -- scroll img base
    self.textBaseY = 182    -- The original, center Y position of the text
    self.textAmplitude = 3.7 -- How many pixels the text will move up and down from titleBaseY
    self.textSpeed = 2.5 -- Controls the speed/frequency of the oscillation.
    

    -- scene set up methods
    self:dinahSpriteLoad()
    self:dinahTexts()
    self:scrollBoxCreate()
    self:buttonBBlink()
    self:buttonABlink()

    self:add()
    
end


function MenuScene:dinahTexts()
    self.dinahText[1] = "..."
    self.dinahText[2] = "Yes, yes... I can see... Your future is bright. Care for a reading, darling?"
    self.dinahText[3] = "Please...                           \nHave a seat...         \n       Don't be scared..."
    self.dinahText[4] = "I speak only what I see, but to find more meaning on the cards is up to you."
end



function MenuScene:showTextAtIndex(index)
    if self.dinahScrollText then
        self.dinahScrollText:remove()
    end

    -- Check if index is valid, otherwise handle end of text or placeholder
    if index > #self.dinahText then
        self.lastText = true
        self.bButton:remove()
        self.scrollBoxSprite:remove()
        self.scrollBoxLoad = false
        self:optionsText()
        -- Add a short delay before enabling options input
        pd.timer.performAfterDelay(500, function()
            self.optionsTextOn = true
        end)
        return
    end

    self.dinahScrollText = gfx.sprite.spriteWithText(self.dinahText[index], 310, 200, nil, nil, nil, kTextAlignment.center)
    self.dinahScrollText:moveTo(190, 182) 
    self.dinahScrollText:add()
end

function MenuScene:nextTextLogic()
    self.currentIndex = self.currentIndex + 1
    self:showTextAtIndex(self.currentIndex)
end


function MenuScene:loadGameAnimation()
    self.dinahSprite.states["transition"].onAnimationEndEvent = function ()
        SCENE_MANAGER:switchScene(GameScene)
    end
end


function MenuScene:dinahSpriteLoad()
    self.dinahSprite:addState("idle", 1, 6, {tickStep = 4, yoyo = true})
    self.dinahSprite:addState("transition", 1, 20, {tickStep = 1, loop = false})
    self.dinahSprite:moveTo(200,120)
    self.dinahSprite:add()
    self.dinahSprite:playAnimation()
end


function MenuScene:scrollBoxCreate()
    self.scrollBoxAnimatorIn = gfx.animator.new(3000, 300, 170, pd.easingFunctions.outBack)
    self.scrollBoxSprite:moveTo(202, 300)
    self.scrollBoxSprite:add()

    pd.timer.performAfterDelay(3200, function ()
        self:onScrollBoxAnimationFinished()
       
    end)
    
end

function MenuScene:onScrollBoxAnimationFinished()
    self.bButton:add() -- Add B button once animation is done
    self:showTextAtIndex(self.currentIndex)
    self.scrollBoxLoad = true -- Show the first text
end

function MenuScene:buttonBBlink()
    gfx.setImageDrawMode(gfx.kDrawModeInverted)
    self.bButton = gfx.sprite.spriteWithText("B", 400, 40, nil, nil, nil, kTextAlignment.center)
    self.bButton:moveTo(360, 220)
    -- self.bButton:add() -- Don't add initially, add after anim
    
    local blinkerTimer = pd.timer.new(800, function()
        if self.bButton then self.bButton:setVisible(not self.bButton:isVisible()) end
    end)
    blinkerTimer.repeats = true
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    
end

function MenuScene:buttonABlink()
    gfx.setImageDrawMode(gfx.kDrawModeInverted)
    self.aButton = gfx.sprite.spriteWithText("A", 400, 40, nil, nil, nil, kTextAlignment.center)
    self.aButton:moveTo(360, 220)
    -- self.aButton:add() -- Don't add initially
    
    local blinkerTimer = pd.timer.new(800, function()
        if self.aButton then self.aButton:setVisible(not self.aButton:isVisible()) end
    end)
    blinkerTimer.repeats = true
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    

end


function MenuScene:optionsText()
    -- for settings B, for reading A
    -- on the bottom in white. maybe blinking?
    -- create a settings scene


    gfx.setImageDrawMode(gfx.kDrawModeInverted)
    self.settingsText = gfx.sprite.spriteWithText("settings: B", 400, 120, nil, nil, nil, kTextAlignment.left)
    self.settingsText:moveTo(65, 220)
    self.settingsText:add()
    
    self.interactText = gfx.sprite.spriteWithText("reading: A", 400, 120, nil, nil, nil, kTextAlignment.right)
    self.interactText:moveTo(340, 220)
    self.interactText:add()



    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
end



function MenuScene:update()
        self.scrollBoxY = self.scrollBoxAnimatorIn:currentValue()
        self.scrollBoxSprite:moveTo(202, self.scrollBoxY)



    local textAnimTimer = pd.getElapsedTime()
    local oscillationOffset = self.textAmplitude * math.sin(textAnimTimer * self.textSpeed)
    local textNewY = self.textBaseY + oscillationOffset + 0.2
    local scrollNewY = self.scrollBaseY + oscillationOffset
    if self.scrollBoxLoad then
        self.dinahScrollText:moveTo(self.dinahScrollText.x, textNewY)
        self.scrollBoxSprite:moveTo(self.scrollBoxSprite.x, scrollNewY)
    end

    if pd.buttonJustPressed(pd.kButtonB) and self.scrollBoxLoad then
        if not self.lastText then
            self:nextTextLogic()
        end
    end

    if pd.buttonJustPressed(pd.kButtonB) and self.optionsTextOn then
        --[[if self.settingsText then
            self.settingsText:remove()
        end
        if self.interactText then
            self.interactText:remove()
        end
        self.optionsTexton = false]]
        print("hello")
        SCENE_MANAGER:switchScene(SettingsScene)
    end

    
    if pd.buttonJustPressed(pd.kButtonA) then
        if self.dinahScrollText then
            self.dinahScrollText:remove()
        end
        self.bButton:remove()
        self.scrollBoxSprite:remove()
        self:loadGameAnimation()
        self.dinahSprite:changeState("transition")
        if self.lastText then
            self.aButton:remove()
        end
    end
end



