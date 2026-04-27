-- CoreLibs
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/object"
import "CoreLibs/ui"
import "CoreLibs/animation"
import "CoreLibs/crank"
import "CoreLibs/keyboard"

-- myLibs
import "libraries/utils"
import "libraries/AnimatedSprite"
import "data/save/playerProfileStore"
import "scripts/Sound"

-- Scenes
import "scenes/allScenes"


--card script
import "scripts/card"


--Decks
import "scripts/decks/allDecks"

-- Debugs
--import "cardManipulationDebug"


local pd <const> = playdate
local gfx <const> = pd.graphics

--GLOBALS

SCENE_MANAGER = SceneManager()

selectedDeck = "full" -- full, major, minor, cups, pentacles, swords, wands


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
    local loading = gfx.image.new("SystemAssets/launchImage")
    local loadingSprite = gfx.sprite.new(loading)
    loadingSprite:moveTo(200, 120) -- center on screen
    loadingSprite:add()
    SCENE_MANAGER:switchScene(TitleScene)
    --SCENE_MANAGER:switchScene(CardManipulationDebug)
    
end

local storedSoundMode = 1
if PlayerProfileStore and PlayerProfileStore.getSoundMode then
    storedSoundMode = PlayerProfileStore.getSoundMode()
end
Sound.init(storedSoundMode)

startGame()


function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()
    pd.drawFPS(380, 5)
    
end