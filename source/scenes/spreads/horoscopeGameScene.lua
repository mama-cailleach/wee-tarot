import "baseSpreadGameScene"

local HOROSCOPE_CONFIG = {
    cardCount = 12,
    cardPositions = {
        { x = 67, y = 84 }, { x = 122, y = 84 }, { x = 177, y = 84 }, { x = 232, y = 84 }, { x = 287, y = 84 }, { x = 342, y = 84 },
        { x = 67, y = 136 }, { x = 122, y = 136 }, { x = 177, y = 136 }, { x = 232, y = 136 }, { x = 287, y = 136 }, { x = 342, y = 136 }
    },
    defaultScale = 0.43,
    zoomScale = 0.58,
    revealDelay = 260,
    promptText = "HOROSCOPE (12)\nUse crank, then press A",
    postSceneClass = HoroscopePostScene
}

class('HoroscopeGameScene').extends(BaseSpreadGameScene)

function HoroscopeGameScene:init()
    HoroscopeGameScene.super.init(self, HOROSCOPE_CONFIG)
end
