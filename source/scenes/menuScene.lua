--import "libraries/AnimatedSprite"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('MenuScene').extends(gfx.sprite)

local MAX_VISIBLE_LINES = 1
local SCROLL_SPEED_DIVISOR = 90

function MenuScene:init()
    MenuScene.super.init(self)

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
    self.optionsTextOn = false

    -- --- TEXT ANIMATION LOOP PARAMETERS ---
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

function MenuScene:dinahTexts()
    -- Store all lines in a flat array
    local texts = {
        "...",
        "Welcome to my humble abode, I've been expecting you.",
        "Yes, yes... I can see... Your future is bright.\nCare for a reading, darling?",
        "Please...\nHave a seat...\nDon't be scared...",
        "I speak only what I see, but to find more meaning on the cards is up to you."
    }
    for _, t in ipairs(texts) do
        for line in t:gmatch("[^\n]+") do
            table.insert(self.dinahLines, line)
        end
    end
    self.scrollOffset = 0 -- float, for smooth scrolling
    self.maxScroll = math.max(0, #self.dinahLines - MAX_VISIBLE_LINES)
end

function MenuScene:showTextWindow()
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

function MenuScene:buttonABlink()
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

function MenuScene:removeAButton()
    if self.aButton then
        self.aButton:remove()
        self.aButton = nil
    end
    if self.aButtonBlinkTimer then
        self.aButtonBlinkTimer:remove()
        self.aButtonBlinkTimer = nil
    end
end

function MenuScene:dinahSpriteLoad()
    self.dinahSprite:addState("idle", 1, 6, {tickStep = 4, yoyo = true})
    self.dinahSprite:addState("transition", 1, 17, {tickStep = 1, loop = false})
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
    self:showTextWindow()
    self.scrollBoxLoad = true -- Show the first text
    self.oscillationStartTime = pd.getElapsedTime()
    -- Set the oscillation base to the final animator Y position for smooth transition
    if self.scrollBoxAnimatorIn then
        self.scrollBaseY = self.scrollBoxAnimatorIn:currentValue()
    end
end

function MenuScene:optionsText()
    gfx.setImageDrawMode(gfx.kDrawModeInverted)
    self.settingsText = gfx.sprite.spriteWithText("first time? B", 400, 120, nil, nil, nil, kTextAlignment.left)
    self.settingsText:moveTo(75, 220)
    self.settingsText:add()
    self.interactText = gfx.sprite.spriteWithText("reading? A", 400, 120, nil, nil, nil, kTextAlignment.right)
    self.interactText:moveTo(333, 220)
    self.interactText:add()
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
end

function MenuScene:loadGameAnimation()
    self.dinahSprite.states["transition"].onAnimationEndEvent = function ()
        SCENE_MANAGER:switchScene(GameScene)
    end
end

function MenuScene:update()
    -- Animate scroll box in
    if self.scrollBoxAnimatorIn and not self.scrollBoxAnimatorIn:ended() then
        self.scrollBoxY = self.scrollBoxAnimatorIn:currentValue()
        self.scrollBoxSprite:moveTo(202, self.scrollBoxY)
    end

    local elapsed = pd.getElapsedTime()
    local oscillationOffset = self.textAmplitude * math.sin((elapsed - (self.oscillationStartTime or 0)) * self.textSpeed)
    local textNewY = self.textBaseY + oscillationOffset + 0.2
    local scrollNewY = 170 + oscillationOffset + 0.2
    if self.scrollBoxLoad then
        if self.dinahScrollText then
            self.dinahScrollText:moveTo(self.dinahScrollText.x, textNewY)
        end
        if self.scrollBoxSprite then
            self.scrollBoxSprite:moveTo(self.scrollBoxSprite.x, scrollNewY)
        end
    end

    -- Only allow crank scrolling if options are not shown
    if self.scrollBoxLoad and not self.optionsTextOn then
        local crankChange = pd.getCrankChange() / SCROLL_SPEED_DIVISOR
        if crankChange ~= 0 then
            local prevOffset = self.scrollOffset
            self.scrollOffset = math.max(0, math.min(self.scrollOffset + crankChange, self.maxScroll))
            if math.floor(self.scrollOffset) ~= math.floor(prevOffset) then
                self:showTextWindow()
            end
        end
        -- Show A blink only if at end
        if math.floor(self.scrollOffset + 0.5) >= self.maxScroll then
            if not self.aButton then self:buttonABlink() end
        else
            self:removeAButton()
        end
        -- Only allow A to proceed if at end
        if pd.buttonJustPressed(pd.kButtonA) and math.floor(self.scrollOffset + 0.5) >= self.maxScroll then
            if self.dinahScrollText then self.dinahScrollText:remove() self.dinahScrollText = nil end
            if self.scrollBoxSprite then self.scrollBoxSprite:remove() end
            self:removeAButton()
            self:optionsText()
            self.optionsTextOn = true
        end
    elseif self.optionsTextOn then
        -- Only allow A/B for options after text is gone
        if pd.buttonJustPressed(pd.kButtonB) then
            SCENE_MANAGER:switchScene(SettingsScene)
        end
        if pd.buttonJustPressed(pd.kButtonA) then
            self:loadGameAnimation()
            self.dinahSprite:changeState("transition")
            self:removeAButton()
        end
    end
end



