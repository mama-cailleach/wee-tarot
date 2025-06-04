local pd <const> = playdate
local gfx <const> = pd.graphics

-- reset card/"shuffle"
function cardDisplay()
    textSprite = gfx.sprite.new()
    textSprite:setCenter(0, 0)
    textSprite:moveTo(10, 10)
    textSprite:add()
    cardDrawText()
    --cardDisplayBack()
    local testdeck = gfx.image.new("images/decknback/placementzone_diamond")
    local testsprite = gfx.sprite.new(testdeck)
    testsprite:setScale(1.5)
    testsprite:moveTo(300, 120)
    testsprite:add()
end

-- draw card and display
function cardDisplayUpdate()
    local cardDrawed, cardNumber, cardSuit = combineDecks()
    local cardText = "Your Card:\n" .. cardDrawed
    local cardTextWiBg = createTextWithBackground(cardText, gfx.kColorWhite, gfx.kColorBlack, 2, 1)
    textSprite:setImage(cardTextWiBg)
    return cardDrawed, cardNumber, cardSuit
end

-- draw major arcana only and display
function cardMajorDisplayUpdate()
    local majorDrawed, majorNumber, majorSuit  = drawMajor()
    local cardText = "Your Card:\n" .. majorDrawed
    local cardTextWiBg = createTextWithBackground(cardText, gfx.kColorWhite, gfx.kColorBlack, 2, 1)
    textSprite:setImage(cardTextWiBg)
    return majorDrawed, majorNumber, majorSuit
end



-- press a to draw
function cardDrawText()
    local cardText = "Press A to\ndraw a card"
    local cardTextWiBg = createTextWithBackground(cardText, gfx.kColorWhite, gfx.kColorBlack, 2, 1)
    textSprite:setImage(cardTextWiBg)

end



function InvertedText()
    local invertedSprite = gfx.sprite.new()
    invertedSprite:setCenter(0, 0)
    invertedSprite:moveTo(10, 80)
    invertedSprite:add()
    local invertedText = " Inverted"
    local invertedTextWiBg = createTextWithBackground(invertedText, gfx.kColorWhite, gfx.kColorBlack, 2, 1)
    invertedSprite:setImage(invertedTextWiBg)
end

-- back of the card shuffle function
function cardDisplayBack()
    imagetableShuffle = gfx.imagetable.new("images/shuffleAnimation/cardShuffle-table-174-300")
    shuffleSprite = AnimatedSprite.new(imagetableShuffle)
    shuffleSprite:addState("idle", 1, 1)
    shuffleSprite:addState("shuffle", 1, 23, {tickStep = 1})
    shuffleSprite:addState("crankShuffle", 1, 23, {tickStep = 1}, false)
    shuffleSprite:moveTo (300, 80)
    shuffleSprite:add()
    shuffleSprite:playAnimation()
    
end






-- press b to shuffle text
function pressBToShuffle()
    local shuffleText = "Press A for\nyour fortune" -- or A for your reading
    local shuffleTextWiBg = createTextWithBackground(shuffleText, gfx.kColorWhite, gfx.kColorBlack, 2, 1)
    local shuffleSprite = gfx.sprite.new()
    shuffleSprite:setImage(shuffleTextWiBg)
    shuffleSprite:setCenter(0,0)
    shuffleSprite:moveTo(10, 165)
    shuffleSprite:add()
end


