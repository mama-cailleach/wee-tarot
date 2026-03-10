import "../../scripts/deck"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('BaseSpreadGameScene').extends(gfx.sprite)

local explodeImagetable = gfx.imagetable.new("images/shuffleAnimation/explode_finale-table-400-240")
local scaleTable = gfx.imagetable.new("images/shuffleAnimation/scaled_card-table-400-240")
local imagetableShuffle = gfx.imagetable.new("images/shuffleAnimation/1_card_shuffle-table-400-240")

function BaseSpreadGameScene:init(config)
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

    self.crankSoundPlaying = false
    self.crankInactivityTimer = nil

    self.promptSprite = gfx.sprite.spriteWithText(config.promptText, 220, 80, nil, nil, nil, kTextAlignment.center)
    self.promptSprite:moveTo(100, 180)
    self.promptSprite:add()

    self:setup16CardShuffleAnimation()
    self:add()
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
        self.cardPlacementSprite:add()
    end
    if self.shuffleAnimSprite then
        self.shuffleAnimSprite:remove()
        self.shuffleAnimSprite = nil
    end
    if self.promptSprite then
        self.promptSprite:remove()
        self.promptSprite = nil
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

    self:revealCardsSequentially()
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
        self.state = "fortune"
        tuin:play(1)
    end)
end

function BaseSpreadGameScene:zoomInOutCards()
    if pd.buttonJustPressed(pd.kButtonUp) then
        for _, visual in ipairs(self.drawnCardVisuals) do
            visual:setScale(self.config.zoomScale)
        end
    end
    if pd.buttonJustPressed(pd.kButtonDown) then
        for _, visual in ipairs(self.drawnCardVisuals) do
            visual:setScale(self.config.defaultScale)
        end
    end
end

function BaseSpreadGameScene:update()
    gfx.sprite.update()

    if pd.buttonJustPressed(pd.kButtonA) then
        if self.state == "shuffle" and self.shuffleAnimSprite and not self.shuffleFinishTimer then
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
            SCENE_MANAGER:switchScene(self.config.postSceneClass, self.playerCards, self.playerCardNumbers, self.playerCardSuits, self.playerCardsInverted)
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
    if self.promptSprite then self.promptSprite:remove() self.promptSprite = nil end
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

    self:clearDrawnCards()
end
