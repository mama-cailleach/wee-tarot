local pd <const> = playdate
local gfx <const> = playdate.graphics

class('BaseHowToScene').extends(gfx.sprite)

local MAX_VISIBLE_LINES = 1

function BaseHowToScene:init(texts)
    BaseHowToScene.super.init(self)

    self.tutorialTexts = texts or {}
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
    self.scrollBoxReadyTimer = nil
    self.transitionDelayTimer = nil
    self.scrollBoxY = nil
    self.scrollBoxLoad = false
    self.allowAButton = true

    self.aButtonY = 220
    self.scrollBaseY = 170
    self.textBaseY = 182
    self.textAmplitude = 3.7
    self.textSpeed = 2.5
    self.oscillationStartTime = nil

    self:buildDinahLines()
    self:dinahSpriteLoad()
    self:scrollBoxCreate()

    self:add()
end

function BaseHowToScene:buildDinahLines()
    for _, text in ipairs(self.tutorialTexts) do
        for line in text:gmatch("[^\n]+") do
            table.insert(self.dinahLines, line)
        end
    end

    self.scrollOffset = 0
    self.maxScroll = math.max(0, #self.dinahLines - MAX_VISIBLE_LINES)
end

function BaseHowToScene:showTextWindow()
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    if self.dinahScrollText then
        self.dinahScrollText:remove()
        self.dinahScrollText = nil
    end

    local startLine = math.floor(self.scrollOffset) + 1
    local lines = {}
    for index = 0, MAX_VISIBLE_LINES - 1 do
        local lineIndex = startLine + index
        if self.dinahLines[lineIndex] then
            table.insert(lines, self.dinahLines[lineIndex])
        end
    end

    local text = table.concat(lines, "\n")
    self.dinahScrollText = gfx.sprite.spriteWithText(text, 310, 200, nil, nil, nil, kTextAlignment.center)
    self.dinahScrollText:moveTo(190, self.textBaseY)
    self.dinahScrollText:add()
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
end

function BaseHowToScene:buttonABlink()
    if self.aButton then return end

    gfx.setImageDrawMode(gfx.kDrawModeInverted)
    self.aButton = gfx.sprite.spriteWithText("A", 40, 40, nil, nil, nil, kTextAlignment.center)
    self.aButton:moveTo(360, 220)
    self.aButton:add()
    self.aButtonBlinkTimer = pd.timer.new(800, function()
        if self.aButton then
            self.aButton:setVisible(not self.aButton:isVisible())
        end
    end)
    self.aButtonBlinkTimer.repeats = true
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
end

function BaseHowToScene:removeAButton()
    if self.aButton then
        self.aButton:remove()
        self.aButton = nil
    end
    if self.aButtonBlinkTimer then
        self.aButtonBlinkTimer:remove()
        self.aButtonBlinkTimer = nil
    end
end

function BaseHowToScene:dinahSpriteLoad()
    self.dinahSprite:addState("idle", 1, 6, { tickStep = 4, yoyo = true })
    self.dinahSprite:addState("transition", 1, 17, { tickStep = 1, loop = false })
    self.dinahSprite:moveTo(200, 120)
    self.dinahSprite:add()
    self.dinahSprite:playAnimation()
end

function BaseHowToScene:scrollBoxCreate()
    self.scrollBoxAnimatorIn = gfx.animator.new(3000, 300, 170, pd.easingFunctions.outBack)
    self.scrollBoxSprite:moveTo(202, 300)
    self.scrollBoxSprite:add()
    self.scrollBoxReadyTimer = pd.timer.performAfterDelay(3200, function()
        self:onScrollBoxAnimationFinished()
        self.scrollBoxReadyTimer = nil
    end)
end

function BaseHowToScene:onScrollBoxAnimationFinished()
    self.scrollOffset = 0
    self:showTextWindow()
    self.scrollBoxLoad = true
    self.oscillationStartTime = pd.getElapsedTime()
    if self.scrollBoxAnimatorIn then
        self.scrollBaseY = self.scrollBoxAnimatorIn:currentValue()
    end
end

function BaseHowToScene:loadGameAnimation()
    self.dinahSprite.states["transition"].onAnimationEndEvent = function()
        SCENE_MANAGER:switchScene(HowToMenuScene)
    end
end

function BaseHowToScene:finishTutorial()
    self.allowAButton = false
    self:removeAButton()
    if self.dinahScrollText then
        self.dinahScrollText:remove()
        self.dinahScrollText = nil
    end
    if self.scrollBoxSprite then
        self.scrollBoxSprite:remove()
        self.scrollBoxSprite = nil
    end
    self.transitionDelayTimer = pd.timer.performAfterDelay(100, function()
        self:loadGameAnimation()
        cards_fast2:play(1)
        self.dinahSprite:changeState("transition")
        self.transitionDelayTimer = nil
    end)
end

function BaseHowToScene:update()
    if self.scrollBoxAnimatorIn and not self.scrollBoxAnimatorIn:ended() then
        self.scrollBoxY = self.scrollBoxAnimatorIn:currentValue()
        if type(self.scrollBoxY) == "number" then
            self.scrollBoxSprite:moveTo(202, self.scrollBoxY)
        end
    end

    local elapsed = pd.getElapsedTime()
    local oscillationOffset = self.textAmplitude * math.sin((elapsed - (self.oscillationStartTime or 0)) * self.textSpeed)
    local textNewY = self.textBaseY + oscillationOffset + 0.2
    local scrollNewY = 170 + oscillationOffset + 0.2
    local aButtonNewY = self.aButtonY + oscillationOffset + 0.2

    if self.scrollBoxLoad then
        if self.dinahScrollText then
            self.dinahScrollText:moveTo(self.dinahScrollText.x, textNewY)
        end
        if self.scrollBoxSprite then
            self.scrollBoxSprite:moveTo(self.scrollBoxSprite.x, scrollNewY)
        end
        if self.aButton then
            self.aButton:moveTo(self.aButton.x, aButtonNewY)
        end
    end

    if self.scrollBoxLoad then
        if self.allowAButton and not self.aButton then
            self:buttonABlink()
        end

        if pd.buttonJustPressed(pd.kButtonA) then
            if self.scrollOffset < self.maxScroll then
                self.scrollOffset = self.scrollOffset + 1
                self:showTextWindow()
            else
                self:finishTutorial()
            end
        end
    end
end

function BaseHowToScene:deinit()
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    self:removeAButton()

    if self.scrollBoxReadyTimer then
        self.scrollBoxReadyTimer:remove()
        self.scrollBoxReadyTimer = nil
    end

    if self.transitionDelayTimer then
        self.transitionDelayTimer:remove()
        self.transitionDelayTimer = nil
    end

    if self.dinahScrollText then
        self.dinahScrollText:remove()
        self.dinahScrollText = nil
    end

    if self.scrollBoxSprite then
        self.scrollBoxSprite:remove()
        self.scrollBoxSprite = nil
    end

    if self.dinahSprite then
        self.dinahSprite:remove()
        self.dinahSprite = nil
    end

    self.scrollBoxAnimatorIn = nil
    self.imagetable = nil
    self.scrollBoxImg = nil
    self.tutorialTexts = nil
    self.dinahLines = nil
end