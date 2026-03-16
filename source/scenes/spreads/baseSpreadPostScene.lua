import "../../data/spreadReadingData"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('BaseSpreadPostScene').extends(gfx.sprite)

function BaseSpreadPostScene:init(config, cardNames, cardNumbers, cardSuits, cardInverted, selectedCardIndex)
    BaseSpreadPostScene.super.init(self)

    self.config = config or {}
    self.cardNames = cardNames or {}
    self.cardNumbers = cardNumbers or {}
    self.cardSuits = cardSuits or {}
    self.cardInverted = cardInverted or {}
    self.selectedCardIndex = selectedCardIndex or math.ceil((#self.cardNumbers or 1) / 2)
    self.cardSprites = {}

    self.imagetable = gfx.imagetable.new("images/bg/dinahBG-table-400-266")
    self.dinahSprite = AnimatedSprite.new(self.imagetable)
    self.scrollBoxImg = gfx.image.new("images/textScroll/scroll1b")
    self.scrollBoxSprite = gfx.sprite.new(self.scrollBoxImg)

    self.textLines = SpreadReadingData.buildPlaceholderReadingText(self.config.spreadKey, self.cardNames, self.cardInverted)
    self.textIndex = 1
    self.textSprite = nil
    self.aButton = nil
    self.aButtonBlinkTimer = nil
    self.canButton = false

    self.aButtonY = 220
    self.textBaseY = 182
    self.textAmplitude = 3.7
    self.textSpeed = 2.5
    self.oscillationStartTime = nil

    self:dinahSpriteLoad()

    self.scrollBoxAnimatorIn = gfx.animator.new(2600, 300, 170, pd.easingFunctions.outBack)
    self.scrollBoxSprite:moveTo(202, 300)
    self.scrollBoxSprite:add()

    self.scrollBoxTimer = pd.timer.performAfterDelay(2800, function()
        self:onScrollBoxAnimationFinished()
    end)

    self:add()
end

function BaseSpreadPostScene:dinahSpriteLoad()
    self.dinahSprite:addState("idle", 1, 6, { tickStep = 4, yoyo = true })
    self.dinahSprite:addState("transition", 1, 20, { tickStep = 1, loop = false })
    self.dinahSprite:moveTo(200, 120)
    self.dinahSprite:add()
    self.dinahSprite:playAnimation()
end

function BaseSpreadPostScene:createCardPreviewSprites()
    local previewPositions = self.config.previewPositions or {}
    local previewScale = self.config.previewScale or 0.35

    for index, position in ipairs(previewPositions) do
        if self.cardNumbers[index] and self.cardSuits[index] then
            local cardSprite = Card(self.cardNumbers[index], self.cardSuits[index])
            cardSprite:moveTo(position.x, position.y)
            cardSprite:setScale(previewScale)
            cardSprite:setRotation(self.cardInverted[index] and 180 or 0)
            table.insert(self.cardSprites, cardSprite)
        end
    end
end

function BaseSpreadPostScene:buttonABlink()
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
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
end

function BaseSpreadPostScene:removeAButton()
    if self.aButton then
        self.aButton:remove()
        self.aButton = nil
    end
    if self.aButtonBlinkTimer then
        self.aButtonBlinkTimer:remove()
        self.aButtonBlinkTimer = nil
    end
end

function BaseSpreadPostScene:showCurrentLine()
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    if self.textSprite then
        self.textSprite:remove()
        self.textSprite = nil
    end

    local line = self.textLines[self.textIndex] or ""
    self.textSprite = gfx.sprite.spriteWithText(line, 310, 200, nil, nil, nil, kTextAlignment.center)
    self.textSprite:moveTo(190, self.textBaseY)
    self.textSprite:add()
end

function BaseSpreadPostScene:onScrollBoxAnimationFinished()
    self:showCurrentLine()
    self.canButton = true
    self.oscillationStartTime = pd.getElapsedTime()
end

function BaseSpreadPostScene:finishReading()
    self.canButton = false
    self:removeAButton()
    SCENE_MANAGER:switchScene(AfterDialogueScene)
end

function BaseSpreadPostScene:getSpreadGameSceneClass()
    local spreadKey = self.config.spreadKey
    if spreadKey == "three_card" then
        return ThreeCardGameScene
    elseif spreadKey == "pentagram" then
        return PentagramGameScene
    elseif spreadKey == "celtic_cross" then
        return CelticCrossGameScene
    elseif spreadKey == "horoscope" then
        return HoroscopeGameScene
    end
    return nil
end

function BaseSpreadPostScene:goBackToSpreadView()
    local gameSceneClass = self:getSpreadGameSceneClass()
    if not gameSceneClass then
        self:finishReading()
        return
    end

    self.canButton = false
    self:removeAButton()

    SCENE_MANAGER:switchScene(gameSceneClass, {
        cardNames = self.cardNames,
        cardNumbers = self.cardNumbers,
        cardSuits = self.cardSuits,
        cardInverted = self.cardInverted,
        selectedCardIndex = self.selectedCardIndex,
        confirmToMenu = true
    })
end

function BaseSpreadPostScene:update()
    if self.scrollBoxAnimatorIn and not self.scrollBoxAnimatorIn:ended() then
        local y = self.scrollBoxAnimatorIn:currentValue()
        self.scrollBoxSprite:moveTo(202, y)
    end

    if self.canButton and not self.aButton then
        self:buttonABlink()
    end

    local elapsed = pd.getElapsedTime()
    local offset = self.textAmplitude * math.sin((elapsed - (self.oscillationStartTime or 0)) * self.textSpeed)

    if self.textSprite then
        self.textSprite:moveTo(self.textSprite.x, self.textBaseY + offset)
    end
    if self.scrollBoxSprite then
        self.scrollBoxSprite:moveTo(self.scrollBoxSprite.x, 170 + offset)
    end
    if self.aButton then
        self.aButton:moveTo(self.aButton.x, self.aButtonY + offset)
    end

    if self.canButton and pd.buttonJustPressed(pd.kButtonA) then
        if self.textIndex < #self.textLines then
            self.textIndex = self.textIndex + 1
            self:showCurrentLine()
        else
            self:finishReading()
        end
    end

    if self.canButton and pd.buttonJustPressed(pd.kButtonB) then
        self:goBackToSpreadView()
    end
end

function BaseSpreadPostScene:deinit()
    if self.dinahSprite then self.dinahSprite:remove() self.dinahSprite = nil end
    if self.scrollBoxSprite then self.scrollBoxSprite:remove() self.scrollBoxSprite = nil end
    if self.textSprite then self.textSprite:remove() self.textSprite = nil end
    if self.scrollBoxTimer then self.scrollBoxTimer:remove() self.scrollBoxTimer = nil end

    self:removeAButton()

    for _, cardSprite in ipairs(self.cardSprites or {}) do
        cardSprite:remove()
    end
    self.cardSprites = nil
end
