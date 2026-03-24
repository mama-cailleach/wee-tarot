import "baseSpreadGameScene"
import "pentagramPostScene"

local PENTAGRAM_CONFIG = {
    cardCount = 5,
    cardPositions = {
        { x = 200, y = 58 },
        { x = 80, y = 120 },
        { x = 150, y = 182 },
        { x = 250, y = 182 },
        { x = 320, y = 120 }
    },
    selectedCardPositions = {
        { x = 200, y = 80 },
        { x = 80, y = 120 },
        { x = 150, y = 160 },
        { x = 250, y = 160 },
        { x = 320, y = 120 }
    },
    zoomCardPositions = {
        { x = 200, y = 120 },
        { x = 80, y = 120 },
        { x = 150, y = 120 },
        { x = 250, y = 120 },
        { x = 320, y = 120 }
    },
    defaultScale = 0.75,
    selectedScale = 1.0,
    zoomScale = 1.725,
    revealDelay = 380,
    postSceneClass = PentagramPostScene
}

class('PentagramGameScene').extends(BaseSpreadGameScene)

function PentagramGameScene:init(restoreState)
    PentagramGameScene.super.init(self, PENTAGRAM_CONFIG, restoreState)
end
