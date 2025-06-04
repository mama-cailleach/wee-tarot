local pd <const> = playdate
local gfx <const> = pd.graphics

class('GameSceneOG').extends(gfx.sprite)


function GameSceneOG:init()
    
    local bgImage = gfx.image.new("images/bg/tarot_playspace")
    local bgSprite = gfx.sprite.new(bgImage)
    bgSprite:moveTo(200,120)
    bgSprite:add()
    

    gfx.setImageDrawMode(gfx.kDrawModeFillWhite) -- for white text
    cardDisplay()
    self.APressed = false
    self.readyPost = 0
    

    self:add()

end

-- variables for update

local ticksPerRevolution = 360 * 4
local playerCard
local isInverted = false
local majorDrawed, majorNumber, majorSuit
local cardDrawed, cardNumber, cardSuit
local card

-- Debug for testing
local majorCard = 0
local function majorCardDebug()
        majorCard += 1
        print(majorCard)
        if majorCard == 13 then
            majorCard = 0
        end
end

function GameSceneOG:update()
    -- draw card
    if pd.buttonJustPressed(pd.kButtonA) and not self.APressed then
        self.APressed = true
        --shuffleSprite:stopAnimation()
        if onlyMajor then
            majorCardDebug() -- debug
            majorDrawed, majorNumber, majorSuit = cardMajorDisplayUpdate()
            card = Card(majorCard, majorSuit) --majorNumber
            playerCard = majorArcanaDeck[majorCard]  --majorDrawed
        else
            cardDrawed, cardNumber, cardSuit = cardDisplayUpdate()
            card = Card(cardNumber, cardSuit)
            playerCard = cardDrawed
        end
        if card.inverted then
            InvertedText()
            isInverted = true
        else
            isInverted = false
        end

    elseif pd.buttonJustPressed(pd.kButtonA) and self.APressed then
        pressBToShuffle()
        self.readyPost += 1
    end

    if pd.buttonJustPressed(pd.kButtonA) and self.APressed and self.readyPost >= 2 then
        SCENE_MANAGER:switchScene(PostScene, playerCard, isInverted)
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        SCENE_MANAGER:switchScene(GameSceneOG)
    end
    
    -- improve crank shuffle
    if self.APressed then
        return
    else
        --[[    
        local crankTicks = pd.getCrankTicks(ticksPerRevolution)
        if crankTicks ~= 0 then
            shuffleSprite:playAnimation()
            shuffleSprite:changeState("crankShuffle")
            --shuffleSprite:toggleAnimation()
        elseif shuffleSprite.currentState ~= "crankShuffle" then
            --return
        else
            if shuffleSprite:pauseAnimation() then
                return
            end
        end
        
        if pd.buttonJustPressed(pd.kButtonDown) then
            if shuffleSprite.currentState ~= "idle" then
                shuffleSprite:changeState("idle")
            end
        end
        
        if pd.buttonJustPressed(pd.kButtonUp) then
            shuffleSprite:changeState("shuffle")
            shuffleSprite:playAnimation()
        end]]
    
    end
    

end



