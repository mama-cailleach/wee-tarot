import "scripts/deck"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('GameScene').extends(gfx.sprite)


-- pre lodaing imagetable
local explodeImagetable = gfx.imagetable.new("images/shuffleAnimation/explode_finale-table-400-240")
local scaleTable = gfx.imagetable.new("images/shuffleAnimation/scaled_card-table-400-240")
local imagetableShuffle = gfx.imagetable.new("images/shuffleAnimation/1_card_shuffle-table-400-240")

function GameScene:init()
    self.deck = Deck()


    self.bgSprite = gfx.sprite.new(gfx.image.new("images/bg/tarot_playspace"))
    self.bgSprite:moveTo(200,120)
    self.bgSprite:add()

    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

    self.state = "shuffle"
    self.onlyMajor = onlyMajor

    self.fortunePromptSprite = gfx.sprite.new()
    self.fortunePromptSprite:setCenter(0, 0)
    self.fortunePromptSprite:moveTo(10, 165)

    self.invertedTextSprite = nil
    self.shuffleAnimSprite = nil
    self.shuffleFinishTimer = nil


    self:setup16CardShuffleAnimation()
    self.shuffleFrame = 1
    self.shuffleFrameCount = self.shuffleAnimSprite.imagetable:getLength()

    self.ticksPerRevolution = 360 -- Adjust for smoother crank interaction

    self.drawnCardVisual = nil
    self.playerCard = nil
    self.isInverted = false
    self:showFirstPrompt()

    self.crankEnabled = true

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

function GameScene:showFortunePrompt()
    local textFortune = "Are you ready\nfor your fortune?"
    local width, height = gfx.getTextSize(textFortune)
    local fortuneTextImage = gfx.image.new(width, height)
    gfx.pushContext(fortuneTextImage)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawTextAligned(textFortune, 0, 0, kTextAlignment.left)
    gfx.popContext()
    self.fortunePromptSprite:setImage(fortuneTextImage)
    self.fortunePromptSprite:moveTo(10, 165)
    self.fortunePromptSprite:add()
end

function GameScene:showFirstPrompt()
    cards_slow:play(0)

    self.firstPrompts = {
    "Set your intentions, let the cards\nhear your silent whispers.",
    "Let your energy flow... \nand the answers will find you.",
    "Clear your mind, focus your heart,\nand allow the truth to unfold.",
    "Shuffle with purpose. Your\nquestion shapes the path ahead.",
    "Breathe deep, steady your spirit,\nand invite clarity into the cards.",
    "The deck awaits your touch,\nguide it with your thoughts.",
    "With each shuffle, your destiny\nstirs. Trust the journey."
}

    if self.firstPromptSprite then 
        self.firstPromptSprite:remove() 
    end
    local prompt = self.firstPrompts[math.random(#self.firstPrompts)]
    self.firstPromptSprite = self:showPromptTextTypewriter(prompt, 20, 4, 40, 1500)

     -- Remove any existing timer
    if self.firstPromptTimer then 
    self.firstPromptTimer:remove() 
    self.firstPromptTimer = nil 
    end

    -- Only keep showing prompts if still in shuffle state and A hasn't been pressed
    self.firstPromptTimer = pd.timer.performAfterDelay(math.random(20000, 25000), function()
        if self.state == "shuffle" and not pd.buttonIsPressed(pd.kButtonA) then
            self:showFirstPrompt()
        end
    end)

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
    self.playerCardNumber = cardNumber
    self.playerCardSuit = cardSuit
    self.isInverted = self.drawnCardVisual and self.drawnCardVisual.inverted or false

    --[[ is card inverted check
    if self.drawnCardVisual then
        self.isInverted = self.drawnCardVisual.inverted
    end]]

    self:revealAnimation()
end

-- --- Shuffle Animation Setup (if needed) ---

--OG 16card
function GameScene:setup16CardShuffleAnimation()
    if self.shuffleAnimSprite then self.shuffleAnimSprite:remove() self.shuffleAnimSprite = nil end
    self.shuffleAnimSprite = AnimatedSprite.new(imagetableShuffle)
    self.shuffleAnimSprite:addState("idle", 1, 1)
    self.shuffleAnimSprite:addState("shuffle", 1, 60, {tickStep = 1})
    self.shuffleAnimSprite:moveTo(220, 135)
    self.shuffleAnimSprite:add()
    self.shuffleAnimSprite:playAnimation()
end

function GameScene:setupCardExplodeAnimation()
    if self.explodeAnimSprite then self.explodeAnimSprite:remove() self.explodeAnimSprite = nil end
    self.explodeAnimSprite = AnimatedSprite.new(explodeImagetable)
    self.explodeAnimSprite:addState("explode", 1, 100, {tickStep = 1, loop = false, onAnimationEndEvent = function()
        -- what happens after
        self.explodeAnimSprite:remove()
        self.explodeAnimSprite = nil
    end}, true)
    self.explodeAnimSprite:moveTo(208, 125)
    self.explodeAnimSprite:add()
    self.explodeAnimSprite:playAnimation()
end


function GameScene:showPlacementSprite(x, y)
        -- Change background image
    if self.bgSprite then
        local newBgImage = gfx.image.new("images/bg/darkcloth")
        self.bgSprite:setImage(newBgImage)
    end
    if not self.cardPlacementSprite then
        self:revealAnimation(200, 110)
        self.cardPlacementSprite = gfx.sprite.new(gfx.image.new("images/decknback/placementzone_diamond"))
        self.cardPlacementSprite:setScale(1)
        self.cardPlacementSprite:moveTo(x or 200, y or 120)
        self.cardPlacementSprite:add()
    end
    if self.shuffleAnimSprite then
        self.shuffleAnimSprite:remove()
        self.shuffleAnimSprite = nil
    end
end

function GameScene:revealAnimation(x, y)
    if self.revealSprite then self.revealSprite:remove() self.revealSprite = nil end
    local revealTable = gfx.imagetable.new("images/shuffleAnimation/reveal-table-236-342")
    self.revealSprite = AnimatedSprite.new(revealTable)
    self.revealSprite:addState(
        "animate", 3, 6,
        {
            tickStep = 1,
            loop = false,
            xScale = 0.6,
            yScale = 0.6,
            onAnimationEndEvent = function()
                if self.revealSprite then
                    self.revealSprite:remove()
                    self.revealSprite = nil
                end
            end
        },
        true
    )
    self.revealSprite:addState("reveal", 1, 6, {tickStep = 1}, false)
    self.revealSprite:moveTo(x or 200, y or 120)
    self.revealSprite:add()
    self.revealSprite:changeState("animate", true)
    self.revealSprite:playAnimation()
end

function GameScene:scaleAnimation(x, y)
    if self.scaleSprite then self.scaleSprite:remove() self.scaleSprite = nil end
    self.scaleSprite = AnimatedSprite.new(scaleTable)
    self.scaleSprite:addState("scale", 1, 60, {tickStep = 1, loop = false, onAnimationEndEvent = function()
        self.scaleSprite:remove()
        self.scaleSprite = nil
        self:showPlacementSprite()
        self.state = "revealed"
    end}, true)
    self.scaleSprite:moveTo(x or 180, y or 120)
    self.scaleSprite:add()
    self.scaleSprite:changeState("scale", true)
    self.scaleSprite:playAnimation()
end

-- --- Update Method ---
function GameScene:update()
    gfx.sprite.update()

    if pd.buttonJustPressed(pd.kButtonA) then
        if self.state == "shuffle" and self.shuffleAnimSprite and not self.shuffleFinishTimer then
            if self.firstPromptSprite then 
                self.firstPromptSprite:remove() 
                self.firstPromptSprite = nil 
            end
            if self.firstPromptTimer then
            self.firstPromptTimer:remove()
            self.firstPromptTimer = nil
            end

            -- Play forward from current frame to last frame at normal speed
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
                        self.shuffleAnimSprite:remove()
                        self.shuffleAnimSprite = nil
                        self:setupCardExplodeAnimation()
                        cards_slow:stop()
                        cards2_slow:play(1)
                        pd.timer.performAfterDelay(2800, function()
                            self:scaleAnimation(200, 110)
                        end)
                    end)
                end
            end

            self.shuffleFinishTimer = pd.timer.keyRepeatTimerWithDelay(1000/500, 1000/500, advanceFrame)
        end  
        
        
        if self.state == "fortune" then
            if self.playerCard and self.isInverted ~= nil then
                cards_fast2:play(1)
                SCENE_MANAGER:switchScene(PostScene, self.playerCard, self.playerCardNumber, self.playerCardSuit, self.isInverted)
            else
                print("Error: Card not drawn yet or inverted state missing for PostScene transition.")
            end
        end
    end
    
    if self.state == "revealed" and not self.revealedTimersStarted then
        cards_fast3:play(1)
        self.revealedTimersStarted = true
        pd.timer.performAfterDelay(1400, function()
            self:drawCardLogic()
            self.state = "fortune"
        end)                   
    end

    -- --- Crank Shuffle Logic ---
    if self.state == "shuffle" and self.shuffleAnimSprite and not self.shuffleFinishTimer then
        local crankChange, acceleratedChange = pd.getCrankChange()
        if crankChange ~= 0 then           
            -- Loop the frame index in both directions / it takes 4 crank units to advance 1 frame.
            self.shuffleFrame = ((self.shuffleFrame - 1 + math.floor(crankChange / 4)) % self.shuffleFrameCount) + 1
            self.shuffleAnimSprite:setFrame(self.shuffleFrame)
        end

                
        --self.crankEnabled = false

        --[[ This way, a full crank rotation = one full animation cycle.
        local crankPos = pd.getCrankPosition() -- 0..359
        local frame = math.floor((crankPos / 360) * self.shuffleFrameCount) + 1
        self.shuffleAnimSprite:setFrame(frame)]]
    end
end



function GameScene:showPromptTextTypewriter(text, x, y, delayPerChar, visibleTime, fadeOutTime)
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

    -- Timer to reveal each character
    local typeTimer
    typeTimer = pd.timer.keyRepeatTimerWithDelay(delayPerChar or 40, delayPerChar or 40, function()
        if currentLength < #text then
            updateText()
        else
            typeTimer:remove()
            -- After full text is shown, wait, then typewriter-remove
            pd.timer.performAfterDelay(visibleTime or 1200, function()
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
                removeTimer = pd.timer.keyRepeatTimerWithDelay(fadeOutTime or delayPerChar or 40, fadeOutTime or delayPerChar or 40, function()
                    if removeLength > 0 then
                        updateRemoveText()
                    else
                        removeTimer:remove()
                        promptSprite:remove()
                    end
                end)
            end)
        end
    end)

    -- Show the first character immediately
    updateText()

    return promptSprite
end



function GameScene:deinit()
    if self.promptTextSprite then self.promptTextSprite:remove() self.promptTextSprite = nil end
    if self.fortunePromptSprite then self.fortunePromptSprite:remove() self.fortunePromptSprite = nil end
    if self.cardPlacementSprite then self.cardPlacementSprite:remove() self.cardPlacementSprite = nil end
    if self.drawnCardVisual then self.drawnCardVisual:remove() self.drawnCardVisual = nil end
    if self.invertedTextSprite then self.invertedTextSprite:remove() self.invertedTextSprite = nil end
    if self.shuffleAnimSprite then self.shuffleAnimSprite:remove() self.shuffleAnimSprite = nil end
    if self.firstPromptSprite then self.firstPromptSprite:remove() self.firstPromptSprite = nil end
    if self.firstPromptTimer then self.firstPromptTimer:remove() self.firstPromptTimer = nil end
    if self.shuffleFinishTimer then self.shuffleFinishTimer:remove() self.shuffleFinishTimer = nil end
    -- Remove any other timers or sprites you create
    --GameScene.super.deinit(self)
end