import "baseSpreadPostScene"

local ONE_CARD_POST_CONFIG = {
    spreadKey = "one_card",
    previewScale = 0.55,
    previewPositions = {
        { x = 200, y = 74 }
    }
}

class('OneCardPostScene').extends(BaseSpreadPostScene)

function OneCardPostScene:init(cardNames, cardNumbers, cardSuits, cardInverted, selectedCardIndex)
    OneCardPostScene.super.init(self, ONE_CARD_POST_CONFIG, cardNames, cardNumbers, cardSuits, cardInverted, selectedCardIndex)
end