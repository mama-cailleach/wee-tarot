import "../../scripts/deck"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('BaseSpreadGameScene').extends(gfx.sprite)

local explodeImagetable = gfx.imagetable.new("images/shuffleAnimation/explode_finale-table-400-240")
local scaleTable = gfx.imagetable.new("images/shuffleAnimation/scaled_card-table-400-240")
local imagetableShuffle = gfx.imagetable.new("images/shuffleAnimation/1_card_shuffle-table-400-240")

local DEFAULT_FIRST_PROMPTS = {
    "Set your intentions, let the cards\nhear your silent whispers.",
    "Let your energy flow... \nand the answers will find you.",
    "Clear your mind, focus your heart,\nand allow the truth to unfold.",
    "Shuffle with purpose. Your\nquestion shapes the path ahead.",
    "Breathe deep, steady your spirit,\nand invite clarity into the cards.",
    "The deck awaits your touch,\nguide it with your thoughts.",
    "With each shuffle, your destiny\nstirs. Trust the journey."
}

function BaseSpreadGameScene:init(config, restoreState)
    BaseSpreadGameScene.super.init(self)

    self.config = config
    self.deck = Deck()
    self.selectedDeck = selectedDeck or "full"

    self.bgSprite = gfx.sprite.new(gfx.image.new("images/bg/tarot_playspace"))
    self.bgSprite:moveTo(200, 120)
    self.bgSprite:add()

    self.state = "shuffle"
    self.shuffleAnimSprite = nil
    self.shuffleFinishTimer = nil
    self.shuffleFrame = 1
    self.shuffleFrameCount = 1

    self.playerCards = {}
    self.playerCardNumbers = {}
    self.playerCardSuits = {}
    self.playerCardsInverted = {}
    self.drawnCardVisuals = {}

    self.cardPositions = config.cardPositions
    self.revealTimers = {}
    self.revealedTimersStarted = false

    self.selectedCardIndex = config.initialSelectedIndex or math.ceil((config.cardCount or 1) / 2)
    self.selectedScale = config.selectedScale or config.defaultScale
    self.selectedCardZoomed = false

    self.crankSoundPlaying = false
    self.crankInactivityTimer = nil

    self.firstPrompts = config.firstPrompts or DEFAULT_FIRST_PROMPTS
    self.firstPromptX = config.firstPromptX or 20
    self.firstPromptY = config.firstPromptY or 4
    self.firstPromptDelayPerChar = config.firstPromptDelayPerChar or 40
    self.firstPromptVisibleTime = config.firstPromptVisibleTime or 1500
    self.firstPromptFadeOutTime = config.firstPromptFadeOutTime or 40
    self.firstPromptRepeatMin = config.firstPromptRepeatMin or 20000
    self.firstPromptRepeatMax = config.firstPromptRepeatMax or 25000

    self.firstPromptSprite = nil
    self.firstPromptTimer = nil
    self.promptTypeTimers = {}
    self.confirmToMenu = restoreState and restoreState.confirmToMenu or false

    if restoreState then
        self:showPlacementSprite()
        self.state = "fortune"
        self:restoreSpreadState(restoreState)
    else
        self:showFirstPrompt()
        self:setup16CardShuffleAnimation()
    end

    self:add()
end

function BaseSpreadGameScene:restoreSpreadState(restoreState)
    if not restoreState then return end

    self:clearDrawnCards()

    local cardNames = restoreState.cardNames or {}
    local cardNumbers = restoreState.cardNumbers or {}
    local cardSuits = restoreState.cardSuits or {}
    local cardInverted = restoreState.cardInverted or {}

    for index = 1, self.config.cardCount do
        local cardNumber = cardNumbers[index]
        local cardSuit = cardSuits[index]
        if cardNumber and cardSuit then
            local visual = Card(cardNumber, cardSuit)
            visual:moveTo(self.cardPositions[index].x, self.cardPositions[index].y)
            visual:setVisible(true)

            local isInverted = cardInverted[index] or false
            visual.inverted = isInverted
            visual:setRotation(isInverted and 180 or 0)

            table.insert(self.drawnCardVisuals, visual)
            table.insert(self.playerCards, cardNames[index])
            table.insert(self.playerCardNumbers, cardNumber)
            table.insert(self.playerCardSuits, cardSuit)
            table.insert(self.playerCardsInverted, isInverted)
        end
    end

    self.selectedCardZoomed = false
    self:selectCard(restoreState.selectedCardIndex or self.selectedCardIndex)
end

function BaseSpreadGameScene:showPromptTextTypewriter(text, x, y, delayPerChar, visibleTime, fadeOutTime)
    local width, height = gfx.getTextSize(text)
    if width == 0 or height == 0 then width, height = 10, 10 end

    local promptSprite = gfx.sprite.new()
    promptSprite:setCenter(0, 0)
    promptSprite:moveTo(x or 8, y or 8)
    promptSprite:add()

    local currentLength = 0
    local function updateText()
        currentLength += 1
        local shownText = string.sub(text, 1, currentLength)
        local textImage = gfx.image.new(width, height)
        gfx.pushContext(textImage)
            gfx.setColor(gfx.kColorWhite)
            gfx.drawTextAligned(shownText, 0, 0, kTextAlignment.left)
        gfx.popContext()
        promptSprite:setImage(textImage)
    end

    local function trackTimer(timer)
        table.insert(self.promptTypeTimers, timer)
        return timer
    end

    local typeTimer
    typeTimer = trackTimer(pd.timer.keyRepeatTimerWithDelay(delayPerChar or 40, delayPerChar or 40, function()
        if currentLength < #text then
            updateText()
        else
            typeTimer:remove()
            trackTimer(pd.timer.performAfterDelay(visibleTime or 1200, function()
                local removeLength = #text
                local function updateRemoveText()
                    removeLength -= 1
                    local shownText = string.sub(text, 1, removeLength)
                    local textImage = gfx.image.new(width, height)
                    gfx.pushContext(textImage)
                        gfx.setColor(gfx.kColorWhite)
                        gfx.drawTextAligned(shownText, 0, 0, kTextAlignment.left)
                    gfx.popContext()
                    promptSprite:setImage(textImage)
                end

                local removeTimer
                removeTimer = trackTimer(pd.timer.keyRepeatTimerWithDelay(fadeOutTime or delayPerChar or 40, fadeOutTime or delayPerChar or 40, function()
                    if removeLength > 0 then
                        updateRemoveText()
                    else
                        removeTimer:remove()
                        promptSprite:remove()
                    end
                end))
            end))
        end
    end))

    updateText()
    return promptSprite
end

function BaseSpreadGameScene:showFirstPrompt()
    if self.firstPromptSprite then
        self.firstPromptSprite:remove()
        self.firstPromptSprite = nil
    end

    local prompt = self.firstPrompts[math.random(#self.firstPrompts)]
    self.firstPromptSprite = self:showPromptTextTypewriter(
        prompt,
        self.firstPromptX,
        self.firstPromptY,
        self.firstPromptDelayPerChar,
        self.firstPromptVisibleTime,
        self.firstPromptFadeOutTime
    )

    if self.firstPromptTimer then
        self.firstPromptTimer:remove()
        self.firstPromptTimer = nil
    end

    self.firstPromptTimer = pd.timer.performAfterDelay(math.random(self.firstPromptRepeatMin, self.firstPromptRepeatMax), function()
        if self.state == "shuffle" and not pd.buttonIsPressed(pd.kButtonA) then
            self:showFirstPrompt()
        end
    end)
end

function BaseSpreadGameScene:clearShufflePrompts()
    if self.firstPromptSprite then
        self.firstPromptSprite:remove()
        self.firstPromptSprite = nil
    end

    if self.firstPromptTimer then
        self.firstPromptTimer:remove()
        self.firstPromptTimer = nil
    end

    for _, timer in ipairs(self.promptTypeTimers) do
        if timer then timer:remove() end
    end
    self.promptTypeTimers = {}
end

function BaseSpreadGameScene:setup16CardShuffleAnimation()
    if self.shuffleAnimSprite then self.shuffleAnimSprite:remove() self.shuffleAnimSprite = nil end
    self.shuffleAnimSprite = AnimatedSprite.new(imagetableShuffle)
    self.shuffleAnimSprite:addState("idle", 1, 1)
    self.shuffleAnimSprite:addState("shuffle", 1, 60, { tickStep = 1 })
    self.shuffleAnimSprite:moveTo(220, 135)
    self.shuffleAnimSprite:add()
    self.shuffleAnimSprite:playAnimation()
    self.shuffleFrameCount = self.shuffleAnimSprite.imagetable:getLength()
end

function BaseSpreadGameScene:setupCardExplodeAnimation()
    if self.explodeAnimSprite then self.explodeAnimSprite:remove() self.explodeAnimSprite = nil end
    self.explodeAnimSprite = AnimatedSprite.new(explodeImagetable)
    self.explodeAnimSprite:addState("explode", 1, 100, {
        tickStep = 1,
        loop = false,
        onAnimationEndEvent = function()
            if self.explodeAnimSprite then
                self.explodeAnimSprite:remove()
                self.explodeAnimSprite = nil
            end
        end
    }, true)
    self.explodeAnimSprite:moveTo(208, 125)
    self.explodeAnimSprite:add()
    self.explodeAnimSprite:playAnimation()
end

function BaseSpreadGameScene:scaleAnimation(x, y)
    if self.scaleSprite then self.scaleSprite:remove() self.scaleSprite = nil end
    self.scaleSprite = AnimatedSprite.new(scaleTable)
    self.scaleSprite:addState("scale", 1, 60, {
        tickStep = 1,
        loop = false,
        onAnimationEndEvent = function()
            if self.scaleSprite then
                self.scaleSprite:remove()
                self.scaleSprite = nil
            end
            self:showPlacementSprite()
            self.state = "revealed"
        end
    }, true)
    self.scaleSprite:moveTo(x or 180, y or 120)
    self.scaleSprite:add()
    self.scaleSprite:changeState("scale", true)
    self.scaleSprite:playAnimation()
end

function BaseSpreadGameScene:showPlacementSprite(x, y)
    if self.bgSprite then
        local newBgImage = gfx.image.new("images/bg/darkcloth")
        self.bgSprite:setImage(newBgImage)
    end
    if not self.cardPlacementSprite then
        self.cardPlacementSprite = gfx.sprite.new(gfx.image.new("images/decknback/placementzone_diamond"))
        self.cardPlacementSprite:setScale(1)
        self.cardPlacementSprite:moveTo(x or 200, y or 120)
        pd.timer.performAfterDelay(self.config.revealDelay + 3000, function()
            if self.cardPlacementSprite then
                self.cardPlacementSprite:add()
            end
        end)
    end
    if self.shuffleAnimSprite then
        self.shuffleAnimSprite:remove()
        self.shuffleAnimSprite = nil
    end
end

function BaseSpreadGameScene:drawCardByDeckSelection()
    self.selectedDeck = selectedDeck or "full"

    if self.selectedDeck == "major" then
        return self.deck:drawMajor()
    elseif self.selectedDeck == "minor" then
        return self.deck:drawMinorArcana()
    elseif self.selectedDeck == "cups" or self.selectedDeck == "wands" or self.selectedDeck == "swords" or self.selectedDeck == "pentacles" then
        return self.deck:drawFromSuit(self.selectedDeck)
    end

    return self.deck:drawFullDeck()
end

function BaseSpreadGameScene:clearDrawnCards()
    for _, sprite in ipairs(self.drawnCardVisuals) do
        sprite:remove()
    end
    self.drawnCardVisuals = {}
    self.playerCards = {}
    self.playerCardNumbers = {}
    self.playerCardSuits = {}
    self.playerCardsInverted = {}
end

function BaseSpreadGameScene:drawCardsLogic()
    self:clearDrawnCards()

    for index = 1, self.config.cardCount do
        local cardDrawed, cardNumber, cardSuit = self:drawCardByDeckSelection()
        if cardNumber and cardSuit then
            local visual = Card(cardNumber, cardSuit)
            visual:moveTo(self.cardPositions[index].x, self.cardPositions[index].y)
            visual:setScale(self.config.defaultScale)
            visual:setVisible(false)
            table.insert(self.drawnCardVisuals, visual)

            table.insert(self.playerCards, cardDrawed)
            table.insert(self.playerCardNumbers, cardNumber)
            table.insert(self.playerCardSuits, cardSuit)
            table.insert(self.playerCardsInverted, visual.inverted or false)
        end
    end

    self:selectCard(self.selectedCardIndex)

    self:revealCardsSequentially()
end

function BaseSpreadGameScene:selectCard(index)
    if #self.drawnCardVisuals == 0 then return end

    local total = #self.drawnCardVisuals
    local wrappedIndex = ((index - 1) % total) + 1
    self.selectedCardIndex = wrappedIndex

    local baseZ = self.config.cardBaseZIndex or 100
    local selectedZ = self.config.selectedCardZIndex or (baseZ + 50)
    local zoomedSelectedZ = self.config.zoomedSelectedCardZIndex or (baseZ + 100)

    for i, visual in ipairs(self.drawnCardVisuals) do
        local targetScale = self.config.defaultScale
        local targetZ = baseZ + i
        if i == self.selectedCardIndex then
            targetScale = self.selectedCardZoomed and self.config.zoomScale or self.selectedScale
            targetZ = self.selectedCardZoomed and zoomedSelectedZ or selectedZ
        end
        visual:setScale(targetScale)
        visual:setZIndex(targetZ)
    end

    if self.cardPlacementSprite then
        local selectedCard = self.drawnCardVisuals[self.selectedCardIndex]
        if selectedCard then
            self.cardPlacementSprite:moveTo(selectedCard.x, selectedCard.y)
        end
    end
end

function BaseSpreadGameScene:cycleSelectedCard(direction)
    if #self.drawnCardVisuals == 0 then return end
    self.selectedCardZoomed = false
    self:selectCard(self.selectedCardIndex + direction)
end

function BaseSpreadGameScene:revealCardsSequentially()
    local revealDelay = self.config.revealDelay
    for i, visual in ipairs(self.drawnCardVisuals) do
        local timer = pd.timer.performAfterDelay((i - 1) * revealDelay, function()
            if visual then
                visual:setVisible(true)
                cards_fast3:play(1)
            end
        end)
        table.insert(self.revealTimers, timer)
    end

    pd.timer.performAfterDelay((#self.drawnCardVisuals * revealDelay) + 200, function()
        self.selectedCardZoomed = false
        self:selectCard(self.selectedCardIndex)
        self.state = "fortune"
        tuin:play(1)
    end)
end

function BaseSpreadGameScene:zoomInOutCards()
    if #self.drawnCardVisuals == 0 then return end

    if pd.buttonJustPressed(pd.kButtonLeft) then
        self:cycleSelectedCard(-1)
    end

    if pd.buttonJustPressed(pd.kButtonRight) then
        self:cycleSelectedCard(1)
    end

    if pd.buttonJustPressed(pd.kButtonUp) then
        self.selectedCardZoomed = true
        self:selectCard(self.selectedCardIndex)
    end

    if pd.buttonJustPressed(pd.kButtonDown) then
        self.selectedCardZoomed = false
        self:selectCard(self.selectedCardIndex)
    end
end

function BaseSpreadGameScene:update()
    gfx.sprite.update()

    if pd.buttonJustPressed(pd.kButtonA) then
        if self.state == "shuffle" and self.shuffleAnimSprite and not self.shuffleFinishTimer then
            self:clearShufflePrompts()
            local finishFrame = self.shuffleAnimSprite.frameCount or self.shuffleFrameCount or 90
            local function advanceFrame()
                local currentFrame = self.shuffleAnimSprite._currentFrame
                if currentFrame < finishFrame then
                    cards2_fast2:play(1)
                    self.shuffleAnimSprite:setFrame(currentFrame + 1)
                else
                    if self.shuffleFinishTimer then
                        self.shuffleFinishTimer:remove()
                        self.shuffleFinishTimer = nil
                    end
                    self.shuffleAnimSprite:changeState("idle")
                    cards2_fast2:stop()
                    pd.timer.performAfterDelay(100, function()
                        if self.shuffleAnimSprite then
                            self.shuffleAnimSprite:remove()
                            self.shuffleAnimSprite = nil
                        end
                        self:setupCardExplodeAnimation()
                        cards2_slow:play(1)
                        pd.timer.performAfterDelay(2500, function()
                            cards_fast3:play(1)
                            pd.timer.performAfterDelay(300, function()
                                self:scaleAnimation(200, 110)
                            end)
                        end)
                    end)
                end
            end
            self.shuffleFinishTimer = pd.timer.keyRepeatTimerWithDelay(1000 / 500, 1000 / 500, advanceFrame)
        elseif self.state == "fortune" and #self.playerCards == self.config.cardCount then
            cards_fast2:play(1)
            if self.confirmToMenu then
                SCENE_MANAGER:switchScene(AfterDialogueScene)
            else
                SCENE_MANAGER:switchScene(self.config.postSceneClass, self.playerCards, self.playerCardNumbers, self.playerCardSuits, self.playerCardsInverted, self.selectedCardIndex)
            end
        end
    end

    if self.state == "revealed" and not self.revealedTimersStarted then
        self.revealedTimersStarted = true
        pd.timer.performAfterDelay(800, function()
            self:drawCardsLogic()
        end)
    end

    if self.state == "shuffle" and self.shuffleAnimSprite and not self.shuffleFinishTimer then
        local crankChange = pd.getCrankChange()
        if crankChange ~= 0 then
            self.shuffleFrame = ((self.shuffleFrame - 1 + math.floor(crankChange / 7)) % self.shuffleFrameCount) + 1
            self.shuffleAnimSprite:setFrame(self.shuffleFrame)

            if not self.crankSoundPlaying then
                crank5:play(0)
                self.crankSoundPlaying = true
            end

            if self.crankInactivityTimer then
                self.crankInactivityTimer:remove()
                self.crankInactivityTimer = nil
            end

            local scene = self
            self.crankInactivityTimer = pd.timer.performAfterDelay(100, function()
                if scene.crankSoundPlaying and crank5 then
                    crank5:stop()
                    scene.crankSoundPlaying = false
                end
                scene.crankInactivityTimer = nil
            end)
        end
    end

    if self.state == "fortune" then
        self:zoomInOutCards()
    end
end

function BaseSpreadGameScene:deinit()
    if self.bgSprite then self.bgSprite:remove() self.bgSprite = nil end
    if self.cardPlacementSprite then self.cardPlacementSprite:remove() self.cardPlacementSprite = nil end
    if self.shuffleAnimSprite then self.shuffleAnimSprite:remove() self.shuffleAnimSprite = nil end
    if self.explodeAnimSprite then self.explodeAnimSprite:remove() self.explodeAnimSprite = nil end
    if self.scaleSprite then self.scaleSprite:remove() self.scaleSprite = nil end

    for _, timer in ipairs(self.revealTimers or {}) do
        if timer then timer:remove() end
    end
    self.revealTimers = nil

    if self.shuffleFinishTimer then self.shuffleFinishTimer:remove() self.shuffleFinishTimer = nil end
    if self.crankInactivityTimer then self.crankInactivityTimer:remove() self.crankInactivityTimer = nil end

    if self.crankSoundPlaying then
        crank5:stop()
        self.crankSoundPlaying = false
    end

    self:clearShufflePrompts()

    self:clearDrawnCards()
end
