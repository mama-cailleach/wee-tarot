import "scripts/decks/allDecks"

class('Deck').extends()

function Deck:init()
    self.cupsDeck = cupsDeck
    self.wandsDeck = wandsDeck
    self.pentaclesDeck = pentaclesDeck
    self.swordsDeck = swordsDeck
    self.majorArcanaDeck = majorArcanaDeck

    self.allDecks = {
        self.cupsDeck,
        self.wandsDeck,
        self.swordsDeck,
        self.pentaclesDeck,
        self.majorArcanaDeck
    }
end

function Deck:drawMajor()
    if #self.majorArcanaDeck == 0 then return nil end
    local draw = math.random(1, #self.majorArcanaDeck)
    local majorDrawed = self.majorArcanaDeck[draw]
    local majorNumber = draw
    local majorSuit = 5
    return majorDrawed, majorNumber, majorSuit
end

function Deck:drawRandomCard()
    local row = math.random(1, #self.allDecks)
    local selectedDeck = self.allDecks[row]
    if #selectedDeck == 0 then return nil end
    local column = math.random(1, #selectedDeck)
    local cardDrawed = selectedDeck[column]
    local cardNumber = column
    local cardSuit = row
    return cardDrawed, cardNumber, cardSuit
end

function Deck:shuffle()
    -- Shuffle each deck in place
    for _, deck in ipairs(self.allDecks) do
        for i = #deck, 2, -1 do
            local j = math.random(i)
            deck[i], deck[j] = deck[j], deck[i]
        end
    end
end

function Deck:reset()
    -- Optionally re-populate and shuffle decks
    self:init()
    self:shuffle()
end

function Deck:isEmpty()
    for _, deck in ipairs(self.allDecks) do
        if #deck > 0 then return false end
    end
    return true
end


return Deck