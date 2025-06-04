local pd <const> = playdate
local gfx <const> = pd.graphics

function drawMajor()
    local draw = math.random(1, #majorArcanaDeck)
    local majorDrawed = majorArcanaDeck[draw]
    local majorNumber = draw
    local majorSuit = 5
    return majorDrawed, majorNumber, majorSuit
end

function combineDecks()
    local allDecks = {cupsDeck, wandsDeck, swordsDeck, pentaclesDeck, majorArcanaDeck}
    local row, column = math.random(1, 5), math.random(1, 22)
    local newColumn = math.random(1, 14)
    if allDecks[row][column] == nil then
        cardDrawed = allDecks[row][newColumn]
        cardNumber = newColumn
    else
        cardDrawed = allDecks[row][column]
        cardNumber = column
    end
    local cardSuit = row
    return cardDrawed, cardNumber, cardSuit
end