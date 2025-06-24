local pd <const> = playdate
local gfx <const> = pd.graphics

class('CardScene').extends(gfx.sprite)

-- Accept cardNumber, cardSuit, isInverted as arguments
function CardScene:init(cardNumber, cardSuit, isInverted)
    -- Show placement background
    self.cardPlacementSprite = gfx.sprite.new(gfx.image.new("images/decknback/placementzone_diamond"))
    self.cardPlacementSprite:setScale(1.5)
    self.cardPlacementSprite:moveTo(300, 120)
    self.cardPlacementSprite:add()

    -- Show the card
    self.drawnCardVisual = Card(cardNumber, cardSuit)
    if isInverted then
        self.drawnCardVisual:setRotation(180)
        self.drawnCardVisual.inverted = true
    end
    self.drawnCardVisual:moveTo(300, 120)
    self.drawnCardVisual:add()

    self.cardNumber = cardNumber
    self.cardSuit = cardSuit
    self.isInverted = isInverted

    self:add()
end

function CardScene:update()
    gfx.sprite.update()
    -- Press B to return to PostScene (or change to your desired scene)
    if pd.buttonJustPressed(pd.kButtonB) then
        SCENE_MANAGER:switchScene(PostScene, self.cardNumber, self.cardSuit, self.isInverted)
    end
end

function CardScene:deinit()
    if self.cardPlacementSprite then self.cardPlacementSprite:remove() end
    if self.drawnCardVisual then self.drawnCardVisual:remove() end
    CardScene.super.deinit(self)
end