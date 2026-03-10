import "baseSpreadGameScene"

local THREE_CARD_CONFIG = {
    cardCount = 3,
    cardPositions = {
        { x = 160, y = 120 },
        { x = 200, y = 120 },
        { x = 240, y = 120 }
    },
    defaultScale = 0.72,
    zoomScale = 0.95,
    revealDelay = 450,
    promptText = "3 CARD SPREAD\nUse crank, then press A",
    postSceneClass = ThreeCardPostScene
}

class('ThreeCardGameScene').extends(BaseSpreadGameScene)

function ThreeCardGameScene:init()
    ThreeCardGameScene.super.init(self, THREE_CARD_CONFIG)
end
