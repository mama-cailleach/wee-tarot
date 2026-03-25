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

    -- Fool image variants for zoom filter comparison.
    self.cardImages = {
        original = gfx.image.new("images/majorArcana/1"),
        bicubic = gfx.image.new("images/zoomTest/bicubic"),
        nearest = gfx.image.new("images/zoomTest/nearestneighboor"),
        lanczos3 = gfx.image.new("images/zoomTest/lanczos3")
    }

    self.drawnCardVisual = gfx.sprite.new(self.cardImages.original)
    self.drawnCardVisual:moveTo(200, 120)
    self.drawnCardVisual:add()
    

    self:add()
end

function CardManipulationDebug:setVariant(imageKey)
    if self.drawnCardVisual then
        self.drawnCardVisual:setImage(self.cardImages[imageKey])
        self.drawnCardVisual:setScale(1)
        self.drawnCardVisual:setRotation(0)
    end
end

function CardManipulationDebug:update()
    gfx.sprite.update()

    if pd.buttonJustPressed(pd.kButtonUp) then
        self:setVariant("bicubic")
    end

    if pd.buttonJustPressed(pd.kButtonLeft) then
        self:setVariant("original")
        if self.drawnCardVisual then
            self.drawnCardVisual:setScale(1.725)
        end
    end

    if pd.buttonJustPressed(pd.kButtonRight) then
        self:setVariant("lanczos3")
    end

    if pd.buttonJustPressed(pd.kButtonDown) then
        self:setVariant("nearest")
    end

    if pd.buttonJustPressed(pd.kButtonA) then
        self:setVariant("original")
    end
end

function CardManipulationDebug:deinit()
    if self.instructionsSprite then self.instructionsSprite:remove() end
    if self.cardPlacementSprite then self.cardPlacementSprite:remove() end
    if self.drawnCardVisual then self.drawnCardVisual:remove() end
    CardManipulationDebug.super.deinit(self)
end
