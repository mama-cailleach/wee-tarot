local pd <const> = playdate
local gfx <const> = pd.graphics

class('CardViewScene').extends(gfx.sprite)

function CardViewScene:init(cardName, cardNumber, cardSuit, isInverted)
    cards_slow:play(1)
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
    else
        self.drawnCardVisual:setRotation(0)
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
        cards_slow2:play(1)
        SCENE_MANAGER:switchScene(AfterDialogueScene)
    end
end




function CardViewScene:deinit()
    if self.bgSprite then self.bgSprite:remove() self.bgSprite = nil end
    if self.cardPlacementSprite then self.cardPlacementSprite:remove() self.cardPlacementSprite = nil end
    if self.drawnCardVisual then self.drawnCardVisual:remove() self.drawnCardVisual = nil end

end