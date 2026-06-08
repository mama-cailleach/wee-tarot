local pd <const> = playdate
local gfx <const> = pd.graphics

import "data/save/diaryStore"

class('CardViewScene').extends(gfx.sprite)

function CardViewScene:init(cardName, cardNumber, cardSuit, isInverted, spreadKey, diaryCards)
    Sound.playSFX("cards_slow")
    self.card = cardName
    self.cardNumber = cardNumber
    self.cardSuit = cardSuit
    self.invert = isInverted
    self.spreadKey = spreadKey or "one_card"
    self.diaryCards = diaryCards
    self.diaryEntrySaved = false

    self.bgSprite = gfx.sprite.new(gfx.image.new("images/bg/darkcloth"))
    self.bgSprite:moveTo(200,120)
    self.bgSprite:add()

    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

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

function CardViewScene:buildDiaryCards()
    if type(self.diaryCards) == "table" and #self.diaryCards > 0 then
        return self.diaryCards
    end

    return {
        {
            name = self.card,
            number = self.cardNumber,
            suit = self.cardSuit,
            inverted = self.invert == true,
            position = 1
        }
    }
end

function CardViewScene:queueReadingToDiary()
    if self.diaryEntrySaved then
        return
    end

    DiaryStore.queueCompletedReading(self.spreadKey, self:buildDiaryCards())
    self.diaryEntrySaved = true
end

function CardViewScene:finishReading()
    self:queueReadingToDiary()
    SCENE_MANAGER:switchScene(BufferScene)
end

-- --- Update Method ---
function CardViewScene:update()
    gfx.sprite.update()
    if pd.buttonJustPressed(pd.kButtonA) then
        Sound.playSFX("cards_slow2")
        self:finishReading()
    end

    if pd.buttonJustPressed(pd.kButtonUp) then
        if self.drawnCardVisual then
            self.drawnCardVisual:setZoomed(true)
        end
    end

    if pd.buttonJustPressed(pd.kButtonDown) then
        if self.drawnCardVisual then
            self.drawnCardVisual:setZoomed(false)
        end
    end


end




function CardViewScene:deinit()
    if self.bgSprite then self.bgSprite:remove() self.bgSprite = nil end
    if self.cardPlacementSprite then self.cardPlacementSprite:remove() self.cardPlacementSprite = nil end
    if self.drawnCardVisual then self.drawnCardVisual:remove() self.drawnCardVisual = nil end

end