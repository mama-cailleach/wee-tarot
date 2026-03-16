import "baseSpreadGameScene"
import "celticCrossPostScene"

local CELTIC_CROSS_CONFIG = {
    cardCount = 10,
    cardPositions = {
        { x = 83, y = 84 }, { x = 139, y = 84 }, { x = 195, y = 84 }, { x = 251, y = 84 }, { x = 307, y = 84 },
        { x = 83, y = 136 }, { x = 139, y = 136 }, { x = 195, y = 136 }, { x = 251, y = 136 }, { x = 307, y = 136 }
    },
    defaultScale = 0.47,
    zoomScale = 0.64,
    revealDelay = 300,
    promptText = "CELTIC CROSS (10)\nUse crank, then press A",
    postSceneClass = CelticCrossPostScene
}

class('CelticCrossGameScene').extends(BaseSpreadGameScene)

function CelticCrossGameScene:init(restoreState)
    CelticCrossGameScene.super.init(self, CELTIC_CROSS_CONFIG, restoreState)
end
