local pd <const> = playdate
local gfx <const> = playdate.graphics

class('HowToScene').extends(gfx.sprite)
-- local HowToScene = HowToScene | fixing the squigly line?

local MAX_VISIBLE_LINES = 1
local SCROLL_SPEED_DIVISOR = 90

function HowToScene:init()
    HowToScene.super.init(self)

    -- scene variables
    self.imagetable = gfx.imagetable.new("images/bg/dinahBG-table-400-266")
    self.dinahSprite = AnimatedSprite.new(self.imagetable)
    self.scrollBoxImg = gfx.image.new("images/textScroll/scroll1b")
    self.scrollBoxSprite = gfx.sprite.new(self.scrollBoxImg)
    self.dinahLines = {}
    self.scrollOffset = 0
    self.maxScroll = 0
    self.dinahScrollText = nil
    self.aButton = nil
    self.aButtonBlinkTimer = nil
    self.scrollBoxAnimatorIn = nil 
    self.scrollBoxY = nil
    self.scrollBoxLoad = false
    self.allowAButton = true

    -- --- TEXT ANIMATION LOOP PARAMETERS ---
    self.aButtonY = 220
    self.scrollBaseY = 170 -- scroll img base
    self.textBaseY = 182    -- The original, center Y position of the text
    self.textAmplitude = 3.7 -- How many pixels the text will move up and down from titleBaseY
    self.textSpeed = 2.5 -- Controls the speed/frequency of the oscillation.
    self.oscillationStartTime = nil -- Used to track the start time of the oscillation

    -- scene set up methods
    self:dinahTexts()
    self:dinahSpriteLoad()
    self:scrollBoxCreate()

    self:add()
end

function HowToScene:dinahTexts()
    -- Store all lines in a flat array
    local texts = {
        "Ah yes, curious one... I felt your energy long before you stepped in.",
        "First time? Don't fret. I'll hold the veil open for you.",
        "One card. One glimpse beyond what most dare to seek.", 
        "Shuffle the deck. Let fate crack its knuckles.",
        "Use the crank to stir your fate. The stars lean in when no one's looking.",
        "A card may fall on its own... or press A to return the deck to me.",
        "(Haste has its own magic, if you trust it.",
        "This is a single-card reading. Simple, but never shallow.",
        "Full deck or Major Arcana only? Depends how much truth you can handle.",
        "Once the card reveals itself...",
        "I listen. The whispers don't speak to just anyone.",
        "Your fortune will rise like mist, or smoke, or something you forgot to name",
        "When the spirits go quiet, you may seek another reading.",
        "I won't judge. Curiosity is practically holy.",
        "But remember, darling... the cards don't lie. Even when you do."

    }
    for _, t in ipairs(texts) do
        for line in t:gmatch("[^\n]+") do
            table.insert(self.dinahLines, line)
        end
    end
    self.scrollOffset = 0 -- float, for smooth scrolling
    self.maxScroll = math.max(0, #self.dinahLines - MAX_VISIBLE_LINES)
end

function HowToScene:showTextWindow()
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    if self.dinahScrollText then
        self.dinahScrollText:remove()
        self.dinahScrollText = nil
    end
    local startLine = math.floor(self.scrollOffset) + 1
    local lines = {}
    for i = 0, MAX_VISIBLE_LINES - 1 do
        local idx = startLine + i
        if self.dinahLines[idx] then
            table.insert(lines, self.dinahLines[idx])
        end
    end
    local text = table.concat(lines, "\n")
    self.dinahScrollText = gfx.sprite.spriteWithText(text, 310, 200, nil, nil, nil, kTextAlignment.center)
    self.dinahScrollText:moveTo(190, self.textBaseY)
    self.dinahScrollText:add()
end

function HowToScene:buttonABlink()
    print(self.allowAButton)
    if self.aButton then return end
    gfx.setImageDrawMode(gfx.kDrawModeInverted)
    self.aButton = gfx.sprite.spriteWithText("A", 40, 40, nil, nil, nil, kTextAlignment.center)
    self.aButton:moveTo(360, 220)
    self.aButton:add()
    self.aButtonBlinkTimer = pd.timer.new(800, function()
        if self.aButton then self.aButton:setVisible(not self.aButton:isVisible()) end
    end)
    self.aButtonBlinkTimer.repeats = true
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
end

function HowToScene:removeAButton()
    if self.aButton then
        self.aButton:remove()
        self.aButton = nil
    end
    if self.aButtonBlinkTimer then
        self.aButtonBlinkTimer:remove()
        self.aButtonBlinkTimer = nil
    end
end

function HowToScene:dinahSpriteLoad()
    self.dinahSprite:addState("idle", 1, 6, {tickStep = 4, yoyo = true})
    self.dinahSprite:addState("transition", 1, 17, {tickStep = 1, loop = false})
    self.dinahSprite:moveTo(200,120)
    self.dinahSprite:add()
    self.dinahSprite:playAnimation()
end

function HowToScene:scrollBoxCreate()
    self.scrollBoxAnimatorIn = gfx.animator.new(3000, 300, 170, pd.easingFunctions.outBack)
    self.scrollBoxSprite:moveTo(202, 300)
    self.scrollBoxSprite:add()
    pd.timer.performAfterDelay(3200, function ()
        self:onScrollBoxAnimationFinished()
    end)
end

function HowToScene:onScrollBoxAnimationFinished()
    self.scrollOffset = 0
    self:showTextWindow()
    self.scrollBoxLoad = true -- Show the first text
    self.oscillationStartTime = pd.getElapsedTime()
    -- Set the oscillation base to the final animator Y position for smooth transition
    if self.scrollBoxAnimatorIn then
        self.scrollBaseY = self.scrollBoxAnimatorIn:currentValue()
    end
end

function HowToScene:loadGameAnimation()
    self.dinahSprite.states["transition"].onAnimationEndEvent = function ()
        SCENE_MANAGER:switchScene(SettingsScene)
    end
end

function HowToScene:update()
    -- Animate scroll box in
    if self.scrollBoxAnimatorIn and not self.scrollBoxAnimatorIn:ended() then
        self.scrollBoxY = self.scrollBoxAnimatorIn:currentValue()
        self.scrollBoxSprite:moveTo(202, self.scrollBoxY)
    end

    local elapsed = pd.getElapsedTime()
    local oscillationOffset = self.textAmplitude * math.sin((elapsed - (self.oscillationStartTime or 0)) * self.textSpeed)
    local textNewY = self.textBaseY + oscillationOffset + 0.2
    local scrollNewY = 170 + oscillationOffset + 0.2
    local abuttonNewY = self.aButtonY + oscillationOffset + 0.2
    if self.scrollBoxLoad then
        if self.dinahScrollText then
            self.dinahScrollText:moveTo(self.dinahScrollText.x, textNewY)
        end
        if self.scrollBoxSprite then
            self.scrollBoxSprite:moveTo(self.scrollBoxSprite.x, scrollNewY)
        end
        if self.aButton then
            self.aButton:moveTo(self.aButton.x, abuttonNewY)
        end
    end

      -- Only allow A to advance text (crank logic commented out)
    if self.scrollBoxLoad then
        --[[
        local crankChange = pd.getCrankChange() / SCROLL_SPEED_DIVISOR
        if crankChange ~= 0 then
            local prevOffset = self.scrollOffset
            self.scrollOffset = math.max(0, math.min(self.scrollOffset + crankChange, self.maxScroll))
            if math.floor(self.scrollOffset) ~= math.floor(prevOffset) then
                self:showTextWindow()
            end
        end
        --]]
        -- Always show A button
        if self.allowAButton and not self.aButton then 
            self:buttonABlink() 
        end

        -- Allow A to proceed to next text
        if pd.buttonJustPressed(pd.kButtonA) then
            if self.scrollOffset < self.maxScroll then
                self.scrollOffset = self.scrollOffset + 1
                self:showTextWindow()
            else
                -- At end, proceed to options
                self.allowAButton = false
                self:removeAButton()
                if self.dinahScrollText then self.dinahScrollText:remove() self.dinahScrollText = nil end
                if self.scrollBoxSprite then self.scrollBoxSprite:remove() end
                pd.timer.performAfterDelay(100, function()
                    self:loadGameAnimation()
                    self.dinahSprite:changeState("transition")
                    
                end)
                
                

            end
        end
    end
end



