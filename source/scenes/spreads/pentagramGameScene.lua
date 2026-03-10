import "baseSpreadGameScene"

local PENTAGRAM_CONFIG = {
    cardCount = 5,
    cardPositions = {
        { x = 120, y = 95 },
        { x = 180, y = 95 },
        { x = 240, y = 95 },
        { x = 150, y = 145 },
        { x = 210, y = 145 }
    },
    defaultScale = 0.62,
    zoomScale = 0.86,
    revealDelay = 380,
    promptText = "PENTAGRAM SPREAD (5)\nUse crank, then press A",
    postSceneClass = PentagramPostScene
}

class('PentagramGameScene').extends(BaseSpreadGameScene)

function PentagramGameScene:init()
    PentagramGameScene.super.init(self, PENTAGRAM_CONFIG)
end
