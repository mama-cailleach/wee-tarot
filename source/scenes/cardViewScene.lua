--import "scripts/deck"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('CardViewScene').extends(gfx.sprite)

--Helpers to extract card number and suit from card name

local function parseCardName(cardName)
    -- Major Arcana
    local majorArcana = {
        "The Fool", "The Magician", "The High Priestess", "The Empress", "The Emperor",
        "The Hierophant", "The Lovers", "The Chariot", "Strength", "The Hermit",
        "Wheel of Fortune", "Justice", "The Hanged Man", "Death", "Temperance",
        "The Devil", "The Tower", "The Star", "The Moon", "The Sun", "Judgement", "The World"
    }
    for i, name in ipairs(majorArcana) do
        if cardName == name then
            return i, 5 -- 5 = majorArcana
        end
    end

    -- Minor Arcana
    local suits = {["Cups"]=1, ["Wands"]=2, ["Swords"]=3, ["Pentacles"]=4}
    local ranks = {
        ["Ace"]=1, ["Two"]=2, ["Three"]=3, ["Four"]=4, ["Five"]=5, ["Six"]=6,
        ["Seven"]=7, ["Eight"]=8, ["Nine"]=9, ["Ten"]=10,
        ["Page"]=11, ["Knight"]=12, ["Queen"]=13, ["King"]=14
    }
    local rank, suit = cardName:match("^(%w+) of (%w+)$")
    if rank and suit and suits[suit] and ranks[rank] then
        return ranks[rank], suits[suit]
    end

    -- fallback
    return 1, 1
end

function CardViewScene:init(cardName, cardNumber, cardSuit, isInverted)
    self.card = cardName
    self.cardNumber = cardNumber
    self.cardSuit = cardSuit
    self.invert = isInverted

    self.bgSprite = gfx.sprite.new(gfx.image.new("images/bg/darkcloth"))
    self.bgSprite:moveTo(200,120)
    self.bgSprite:add()

    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

    self.onlyMajor = onlyMajor

    self.drawnCardVisual = nil

    self:showPlacementSprite()
    self:drawCardLogic()

    self:add()
end



-- --- Card Drawing Logic ---

function CardViewScene:drawCardLogic()

    -- Remove previous card visual if it exists
    if self.drawnCardVisual then
        self.drawnCardVisual:remove()
        self.drawnCardVisual = nil
    end

    self.drawnCardVisual = Card(self.cardNumber, self.cardSuit)
    if self.invert then
        self.drawnCardVisual:setRotation(180)
        self.drawnCardVisual.inverted = true
    end
end

-- --- Shuffle Animation Setup (if needed) ---

function CardViewScene:showPlacementSprite(x, y)
        self.cardPlacementSprite = gfx.sprite.new(gfx.image.new("images/decknback/placementzone_diamond"))
        self.cardPlacementSprite:setScale(1)
        self.cardPlacementSprite:moveTo(x or 200, y or 120)
        self.cardPlacementSprite:add()
end

-- --- Update Method ---
function CardViewScene:update()
    gfx.sprite.update()
    if pd.buttonJustPressed(pd.kButtonA) then
        thunder:play(1)
        SCENE_MANAGER:switchScene(AfterDialogueScene)
    end
end




function CardViewScene:deinit()
    if self.bgSprite then self.bgSprite:remove() self.bgSprite = nil end
    if self.cardPlacementSprite then self.cardPlacementSprite:remove() self.cardPlacementSprite = nil end
    if self.drawnCardVisual then self.drawnCardVisual:remove() self.drawnCardVisual = nil end

end