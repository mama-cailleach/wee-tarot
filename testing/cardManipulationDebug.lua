import "scripts/deck"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('CardManipulationDebug').extends(gfx.sprite)

function CardManipulationDebug:init()
    -- Background
    local bgImage = gfx.image.new("images/bg/darkcloth")
    local bgSprite = gfx.sprite.new(bgImage)
    bgSprite:moveTo(200, 120)
    bgSprite:add()

    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

    -- Card placement background
    self.cardPlacementSprite = gfx.sprite.new(gfx.image.new("images/decknback/placementzone_diamond"))
    self.cardPlacementSprite:setScale(1)
    self.cardPlacementSprite:moveTo(200, 120)
    self.cardPlacementSprite:add()

    -- Initialize state
    self.drawnCardVisual = nil
    self.cardScale = 1.0
    self.cardRotation = 0
    
    -- Draw initial random card
    self:drawNewCard()
    

    self:add()
end

function CardManipulationDebug:drawNewCard()
    -- Remove previous card
    if self.drawnCardVisual then
        self.drawnCardVisual:remove()
        self.drawnCardVisual = nil
    end
    
    -- Reset scale and rotation
    self.cardScale = 1.0
    self.cardRotation = 0
    
    -- Draw random card
    local deck = Deck()
    local cardDrawn, cardNumber, cardSuit = deck:drawRandomCard()
    
    if cardNumber and cardSuit then
        self.drawnCardVisual = Card(cardNumber, cardSuit)
        self.drawnCardVisual:moveTo(200, 120)
        self.drawnCardVisual:setScale(self.cardScale)
        self.drawnCardVisual:setRotation(self.cardRotation)
    end
end


function CardManipulationDebug:scaleCard()
    self.cardScale = 1.725
    if self.drawnCardVisual then
        self.drawnCardVisual:setScale(self.cardScale)
    end
end

function CardManipulationDebug:rotateCard()
    self.cardRotation = self.cardRotation + 90
    if self.cardRotation >= 91 then
        self.cardRotation = 90
    end
    self.cardRotateScale = 2.70
    if self.drawnCardVisual then
        self.drawnCardVisual:setRotation(self.cardRotation)
        self.drawnCardVisual:setScale(self.cardRotateScale)
    end
end

function CardManipulationDebug:resetCard()
    self.cardScale = 1.0
    self.cardRotation = 0
    if self.drawnCardVisual then
        self.drawnCardVisual:setScale(self.cardScale)
        self.drawnCardVisual:setRotation(self.cardRotation)
    end
end

function CardManipulationDebug:update()
    gfx.sprite.update()

    if pd.buttonJustPressed(pd.kButtonA) then
        self:drawNewCard()
    end

    if pd.buttonJustPressed(pd.kButtonUp) then
        self:scaleCard()
    end

    if pd.buttonJustPressed(pd.kButtonRight) then
        self:rotateCard()
    end

    if pd.buttonJustPressed(pd.kButtonDown) then
        self:resetCard()
    end
end

function CardManipulationDebug:deinit()
    if self.instructionsSprite then self.instructionsSprite:remove() end
    if self.cardPlacementSprite then self.cardPlacementSprite:remove() end
    if self.drawnCardVisual then self.drawnCardVisual:remove() end
    CardManipulationDebug.super.deinit(self)
end
