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

    self.APressed = false
    self.readyPost = 0
    self.onlyMajor = onlyMajor

    self.promptTextSprite = gfx.sprite.new()
    self.promptTextSprite:setCenter(0, 0)
    self.promptTextSprite:moveTo(10, 10)
    self.promptTextSprite:add()
    self:updatePromptText("Press A to\nreveal a card")

    self.fortunePromptSprite = gfx.sprite.new()
    self.fortunePromptSprite:setCenter(0, 0)
    self.fortunePromptSprite:moveTo(10, 165)

    self.cardPlacementSprite = gfx.sprite.new(gfx.image.new("images/decknback/placementzone_diamond"))
    self.cardPlacementSprite:setScale(1.5)
    self.cardPlacementSprite:moveTo(300, 120)
    self.cardPlacementSprite:add()

    self.invertedTextSprite = nil
    self.shuffleAnimSprite = nil

    --self:setupShuffleAnimation()
    if self.shuffleAnimSprite then
        self.shuffleAnimSprite:playAnimation("idle")
    end

    self.drawnCardVisual = nil
    self.playerCard = nil
    self.isInverted = false

    self:add()
end

-- --- UI Methods ---

function GameScene:updatePromptText(text)
    local textImage = createTextWithBackground(text, gfx.kColorWhite, gfx.kColorBlack, 2, 1)
    self.promptTextSprite:setImage(textImage)
end

function GameScene:showRevealPrompt()
    self:updatePromptText("Press A to\nreveal a card")
end

function GameScene:showDrawnCard(cardName)
    self:updatePromptText("Your Card:\n" .. cardName)
end

function GameScene:showDrawnMajorCard(cardName)
    self:updatePromptText("Your Card:\n" .. cardName)
end

function GameScene:showFortunePrompt()
    local fortuneTextImage = createTextWithBackground("Press A for\nyour fortune", gfx.kColorWhite, gfx.kColorBlack, 2, 1)
    self.fortunePromptSprite:setImage(fortuneTextImage)
    self.fortunePromptSprite:add()
end

function GameScene:displayInvertedText(show)
    if show and not self.invertedTextSprite then
        self.invertedTextSprite = gfx.sprite.new()
        self.invertedTextSprite:setCenter(0, 0)
        self.invertedTextSprite:moveTo(10, 80)
        self.invertedTextSprite:add()
        local invertedText = " Inverted"
        local invertedTextWiBg = createTextWithBackground(invertedText, gfx.kColorWhite, gfx.kColorBlack, 2, 1)
        self.invertedTextSprite:setImage(invertedTextWiBg)
    elseif not show and self.invertedTextSprite then
        self.invertedTextSprite:remove()
        self.invertedTextSprite = nil
    end
end

function GameScene:showCardBack()
    -- Already handled by self.cardPlacementSprite in init
end

function GameScene:showShufflePrompt()
    self:updatePromptText("Press B to shuffle")
end

-- --- Card Drawing Logic ---

function GameScene:drawCardLogic()
    local cardDrawed, cardNumber, cardSuit
    if self.onlyMajor then
        cardDrawed, cardNumber, cardSuit = self.deck:drawMajor()
        self:showDrawnMajorCard(cardDrawed)
    else
        cardDrawed, cardNumber, cardSuit = self.deck:drawRandomCard()
        self:showDrawnCard(cardDrawed)
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

    --is card inverted check
    if self.drawnCardVisual then
        self.isInverted = self.drawnCardVisual.inverted
        self:displayInvertedText(self.isInverted)
    end

    -- Show the card name in the prompt
    if cardDrawed then
        self:updatePromptText("Your Card:\n" .. tostring(cardDrawed))
    end
end

-- --- Shuffle Animation Setup (if needed) ---
function GameScene:setupShuffleAnimation()
    -- Example: load and setup shuffle animation sprite
    local imagetableShuffle = gfx.imagetable.new("images/shuffleAnimation/cardShuffle-table-174-300")
    self.shuffleAnimSprite = AnimatedSprite.new(imagetableShuffle)
    self.shuffleAnimSprite:addState("idle", 1, 1)
    self.shuffleAnimSprite:addState("shuffle", 1, 23, {tickStep = 1})
    self.shuffleAnimSprite:addState("crankShuffle", 1, 23, {tickStep = 1}, false)
    self.shuffleAnimSprite:moveTo(300, 80)
    self.shuffleAnimSprite:add()
    self.shuffleAnimSprite:playAnimation()
end

-- --- Update Method ---
function GameScene:update()
    gfx.sprite.update()

    if pd.buttonJustPressed(pd.kButtonA) and not self.APressed then
        self.APressed = true
        self:drawCardLogic()
    elseif pd.buttonJustPressed(pd.kButtonA) and self.APressed and self.readyPost == 0 then
        self:showFortunePrompt()
        self.readyPost = 1
    elseif pd.buttonJustPressed(pd.kButtonA) and self.APressed and self.readyPost >= 1 then
        if self.playerCard and self.isInverted ~= nil then
            SCENE_MANAGER:switchScene(PostScene, self.playerCard, self.isInverted)
        else
            print("Error: Card not drawn yet or inverted state missing for PostScene transition.")
        end
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        SCENE_MANAGER:switchScene(GameScene)
        if self.fortunePromptSprite then self.fortunePromptSprite:remove() end
    end

    -- --- Crank Shuffle Logic (Uncomment and adapt if using) ---
    -- if not self.APressed then -- Only animate shuffle before card is drawn
    --     local crankTicks = pd.getCrankTicks(ticksPerRevolution)
    --     if crankTicks ~= 0 then
    --         self.shuffleAnimSprite:changeState("crankShuffle")
    --         self.shuffleAnimSprite:playAnimation()
    --     elseif self.shuffleAnimSprite and self.shuffleAnimSprite.currentState == "crankShuffle" then
    --         self.shuffleAnimSprite:pauseAnimation()
    --     end
    -- end
    -- if pd.buttonJustPressed(pd.kButtonDown) then
    --     if self.shuffleAnimSprite and self.shuffleAnimSprite.currentState ~= "idle" then
    --         self.shuffleAnimSprite:changeState("idle")
    --     end
    -- end
    -- if pd.buttonJustPressed(pd.kButtonUp) then
    --     if self.shuffleAnimSprite then
    --         self.shuffleAnimSprite:changeState("shuffle")
    --         self.shuffleAnimSprite:playAnimation()
    --     end
    -- end
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