-- CoreLibs
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/object"
import "CoreLibs/ui"
import "CoreLibs/animation"
import "CoreLibs/crank"

-- myLibs
import "libraries/utils"
import "libraries/AnimatedSprite"

-- Scenes
import "scenes/allScenes"
import "scripts/sideMenu"


--card scripts
import "scripts/card"


--Decks
import "scripts/decks/allDecks"

-- DEBUG SCENES
import "testing/PostSceneDebug"
import "testing/gameSceneDebug"



local pd <const> = playdate
local gfx <const> = pd.graphics

--GLOBALS

SCENE_MANAGER = SceneManager()

bgMusic1 = pd.sound.fileplayer.new("sound/bgMusic2")
bgMusic1:setLoopRange(0,22) -- Title Loop no beats



-- font tarotheque (https://www.dafont.com/gschaftlhuber.d11133?text=Hello+%E9+%E3+%E7)
local fontPaths = {
    [gfx.font.kVariantNormal] = "fonts/tarotheque-v1-20",
    [gfx.font.kVariantBold] = "fonts/tarotheque-v2-20",
    [gfx.font.kVariantItalic] = "fonts/tarotheque-v1-20"
}

--CHANGE FONT - folder path and no .fnt // here apply to whole game
local myFont = gfx.font.newFamily(fontPaths)
gfx.setFont(myFont)

-- call first scene (do I need this as a function?)
local function startGame()
    --SCENE_MANAGER:switchScene(PostSceneDebug) DEBUG
    SCENE_MANAGER:switchScene(PostSceneDebug)
    
end

startGame()


function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()
    pd.drawFPS(380, 5)
    
end