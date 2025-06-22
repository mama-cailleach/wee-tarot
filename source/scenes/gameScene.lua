import "scripts/deck"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('GameScene').extends(gfx.sprite)

function GameScene:init()
    self.deck = Deck()


    local bgImage = gfx.image.new("images/bg/tarot_playspace")
    local bgSprite = gfx.sprite.new(bgImage)
    bgSprite:moveTo(200,120)
    bgSprite:add()

    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

    self.state = "shuffle"
    self.onlyMajor = onlyMajor

    self.fortunePromptSprite = gfx.sprite.new()
    self.fortunePromptSprite:setCenter(0, 0)
    self.fortunePromptSprite:moveTo(10, 165)

    self.invertedTextSprite = nil
    self.shuffleAnimSprite = nil


    self:setup16CardShuffleAnimation()
    self.shuffleFrame = 1
    self.shuffleFrameCount = self.shuffleAnimSprite.imagetable:getLength()

    self.ticksPerRevolution = 360 -- Adjust for smoother crank interaction

    self.drawnCardVisual = nil
    self.playerCard = nil
    self.isInverted = false
    self:showFirstPrompt()

    self:add()
end




-- --- UI Methods ---

function GameScene:showPromptText(text, x, y)
    local width, height = gfx.getTextSize(text)
    if width == 0 or height == 0 then width, height = 10, 10 end
    local textImage = gfx.image.new(width, height)
    gfx.pushContext(textImage)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawTextAligned(text, 0, 0, kTextAlignment.left)
    gfx.popContext()
    local promptSprite = gfx.sprite.new(textImage)
    promptSprite:setCenter(0, 0)
    promptSprite:moveTo(x or 8, y or 8)
    promptSprite:add()
    return promptSprite
end

function GameScene:showRevealPrompt()
    if self.currentPromptSprite then self.currentPromptSprite:remove() end
    self.currentPromptSprite = self:showPromptText("Press A to\nreveal a card", 8, 8)
end

function GameScene:showDrawnCard(cardName, isInverted)
    if self.currentPromptSprite then self.currentPromptSprite:remove() end
    local prompt = "Your Card:\n" .. cardName
    if isInverted then
        prompt = prompt .. "\nUpside Down"
    end
    self.currentPromptSprite = self:showPromptText(prompt, 8, 8)
end

function GameScene:showDrawnMajorCard(cardName, isInverted)
    if self.currentPromptSprite then self.currentPromptSprite:remove() end
    local prompt = "Your Card:\n" .. cardName
    if isInverted then
        prompt = prompt .. "\nUpside Down"
    end
    self.currentPromptSprite = self:showPromptText(prompt, 8, 8)
end

function GameScene:showFortunePrompt()
    local width, height = gfx.getTextSize("Are you ready\nfor your fortune?")
    local fortuneTextImage = gfx.image.new(width, height)
    gfx.pushContext(fortuneTextImage)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawTextAligned("Are you ready\nfor your fortune?", 0, 0, kTextAlignment.left)
    gfx.popContext()
    self.fortunePromptSprite:setImage(fortuneTextImage)
    self.fortunePromptSprite:moveTo(10, 165)
    self.fortunePromptSprite:add()
end

function GameScene:showFirstPrompt()
    if self.firstPromptSprite then self.firstPromptSprite:remove() end
    self.firstPromptSprite = self:showPromptText(
        "Let your intentions\n" ..
        "be clear, and the\n" ..
        "answers will find you.",
        8, 8
    )

--[[ TO BE USED LATER as options/switching
- Set your intentions, let the cards hear your silent whispers.
- Let your energy flow... the deck is listening.
- Clear your mind, focus your heart, and allow the truth to unfold.
- Shuffle with purpose. Your question shapes the path ahead.
- Breathe deep, steady your spirit, and invite clarity into the cards.
- The deck awaits your touch, guide it with your thoughts.
- Let your intentions be clear, and the answers will find you.
- With each shuffle, your destiny stirs—trust the journey
]]
end

-- --- Card Drawing Logic ---

function GameScene:drawCardLogic()
    local cardDrawed, cardNumber, cardSuit
    if self.onlyMajor then
        cardDrawed, cardNumber, cardSuit = self.deck:drawMajor()
    else
        cardDrawed, cardNumber, cardSuit = self.deck:drawRandomCard()
    end

    -- Remove previous card visual if it exists
    if self.drawnCardVisual then
        self.drawnCardVisual:remove()
        self.drawnCardVisual = nil
    end

    -- Create and show the card sprite
    if cardNumber and cardSuit then
        self.drawnCardVisual = Card(cardNumber, cardSuit)
    end

    self.playerCard = cardDrawed

    -- is card inverted check
    if self.drawnCardVisual then
        self.isInverted = self.drawnCardVisual.inverted
    end

    -- Show the card name and inverted text in the prompt
    if cardDrawed then
        if self.onlyMajor then
            self:showDrawnMajorCard(cardDrawed, self.isInverted)
        else
            self:showDrawnCard(cardDrawed, self.isInverted)
        end
    end
    self:revealAnimation()
end

-- --- Shuffle Animation Setup (if needed) ---
-- OG ANIMATION
function GameScene:setupShuffleAnimation()
    local imagetableShuffle = gfx.imagetable.new("images/shuffleAnimation/shuffle-table-200-360")
    self.shuffleAnimSprite = AnimatedSprite.new(imagetableShuffle)
    self.shuffleAnimSprite:addState("idle", 1, 1)
    self.shuffleAnimSprite:addState("shuffle", 1, 90, {tickStep = 1})
    self.shuffleAnimSprite:addState("crankShuffle", 1, 90, {tickStep = 1}, false)
    self.shuffleAnimSprite:moveTo(300, 80)
    self.shuffleAnimSprite:add()
    self.shuffleAnimSprite:playAnimation()
end

--OG 16card
function GameScene:setup16CardShuffleAnimation()
    local imagetableShuffle = gfx.imagetable.new("images/shuffleAnimation/16_card_shuffle5-table-300-360")
    self.shuffleAnimSprite = AnimatedSprite.new(imagetableShuffle)
    self.shuffleAnimSprite:addState("idle", 1, 1)
    self.shuffleAnimSprite:addState("shuffle", 1, 90, {tickStep = 1})
    self.shuffleAnimSprite:addState("crankShuffle", 1, 90, {tickStep = 1}, false)
    self.shuffleAnimSprite:moveTo(350, 80)
    self.shuffleAnimSprite:add()
    self.shuffleAnimSprite:playAnimation()
end

function GameScene:showPlacementSprite()
    if not self.cardPlacementSprite then
        self:revealAnimation()
        self.cardPlacementSprite = gfx.sprite.new(gfx.image.new("images/decknback/placementzone_diamond"))
        self.cardPlacementSprite:setScale(1.5)
        self.cardPlacementSprite:moveTo(300, 120)
        self.cardPlacementSprite:add()
    end
    if self.shuffleAnimSprite then
        self.shuffleAnimSprite:remove()
        self.shuffleAnimSprite = nil
    end
end

function GameScene:revealAnimation()
    local revealTable = gfx.imagetable.new("images/shuffleAnimation/reveal-table-236-342")
    self.revealSprite = AnimatedSprite.new(revealTable)
    self.revealSprite:addState(
        "animate", 3, 6,
        {
            tickStep = 1,
            loop = false,
            xScale = 0.8,
            yScale = 0.8,
            onAnimationEndEvent = function()
                self.revealSprite:remove()
                self.revealSprite = nil
            end
        },
        true
    )
    self.revealSprite:addState("reveal", 1, 6, {tickStep = 1}, false)
    self.revealSprite:moveTo(300, 120)
    self.revealSprite:add()
    self.revealSprite:changeState("animate", true)
    self.revealSprite:playAnimation()
end

function GameScene:scaleAnimation()
    local scaleTable = gfx.imagetable.new("images/shuffleAnimation/scale-table-200-360")
    self.scaleSprite = AnimatedSprite.new(scaleTable)
    self.scaleSprite:addState("scale", 1, 60, {tickStep = 1, loop = false, onAnimationEndEvent = function()
        self.scaleSprite:remove()
        self.scaleSprite = nil
        self:showPlacementSprite()
        self.state = "ready"
        self:showRevealPrompt()
    end}, true)
    self.scaleSprite:moveTo(300, 80)
    self.scaleSprite:add()
    self.scaleSprite:changeState("scale", true)
    self.scaleSprite:playAnimation()
end

-- --- Update Method ---
function GameScene:update()
    gfx.sprite.update()

    if pd.buttonJustPressed(pd.kButtonA) then
        if self.state == "shuffle" then
            if self.shuffleAnimSprite then
                self.shuffleAnimSprite:changeState("idle")
                if self.firstPromptSprite then self.firstPromptSprite:remove() self.firstPromptSprite = nil end
                pd.timer.performAfterDelay(500, function()
                    self.shuffleAnimSprite:remove()
                    self.shuffleAnimSprite = nil
                    self:scaleAnimation()
                end)
            end            
        elseif self.state == "ready" then
            self:drawCardLogic()
            self.state = "revealed"
            pd.timer.performAfterDelay(2000, function()
                self:showFortunePrompt()
                self.state = "fortune"
            end)
        elseif self.state == "fortune" then
            if self.playerCard and self.isInverted ~= nil then
                SCENE_MANAGER:switchScene(PostScene, self.playerCard, self.isInverted)
            else
                print("Error: Card not drawn yet or inverted state missing for PostScene transition.")
            end
        end
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        if self.shuffleAnimSprite then
            self.shuffleAnimSprite:changeState("idle")
            self.shuffleAnimSprite:pauseAnimation()
        end
        SCENE_MANAGER:switchScene(GameScene)
        if self.fortunePromptSprite then 
            self.fortunePromptSprite:remove() 
        end
    end

    -- --- Crank Shuffle Logic ---
    if self.state == "shuffle" and self.shuffleAnimSprite then
        local crankChange, acceleratedChange = pd.getCrankChange()
        if crankChange ~= 0 then
            -- Loop the frame index in both directions
            self.shuffleFrame = ((self.shuffleFrame - 1 + math.floor(acceleratedChange / 4)) % self.shuffleFrameCount) + 1
            self.shuffleAnimSprite:setFrame(self.shuffleFrame)
        end
    end

    if pd.buttonJustPressed(pd.kButtonUp) then
        if self.shuffleAnimSprite then
            self.shuffleAnimSprite:changeState("shuffle")
            self.shuffleAnimSprite:playAnimation()
        end
    end
end

function GameScene:deinit()
    if self.promptTextSprite then self.promptTextSprite:remove() end
    if self.fortunePromptSprite then self.fortunePromptSprite:remove() end
    if self.cardPlacementSprite then self.cardPlacementSprite:remove() end
    if self.drawnCardVisual then self.drawnCardVisual:remove() end
    if self.invertedTextSprite then self.invertedTextSprite:remove() end
    if self.shuffleAnimSprite then self.shuffleAnimSprite:remove() end
    GameScene.super.deinit(self)
end