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


--card scripts
import "scripts/card"


--Decks
import "scripts/decks/allDecks"


local pd <const> = playdate
local gfx <const> = pd.graphics

--GLOBALS

SCENE_MANAGER = SceneManager()

onlyMajor = false -- global variable 
soundMode = 1 -- 1 = Music&Rain, 2 = Just Music, 3 = Just Rain


-- SOUND

bgMusic = pd.sound.fileplayer.new("sound/bgMusic3quieter")
bgMusic:setVolume(0.9)
bgMusic:setLoopRange(0,22) -- Title Loop no beats

ambience = pd.sound.fileplayer.new("sound/rain1quieter")
ambience:setVolume(0.1)



cards_fast = pd.sound.sampleplayer.new("sound/cards_fast")
cards_fast:setVolume(0.55)
cards_slow = pd.sound.sampleplayer.new("sound/cards_slow")
cards2_fast = pd.sound.sampleplayer.new("sound/cards2_fast")
cards2_slow = pd.sound.sampleplayer.new("sound/cards2_slow")

cards_fast2 = pd.sound.sampleplayer.new("sound/cards_fast2")
cards_fast2:setVolume(0.55)
cards_slow2 = pd.sound.sampleplayer.new("sound/cards_slow2")
cards_fast3 = pd.sound.sampleplayer.new("sound/cards_fast3")   
cards_fast3:setVolume(0.55)

cards2_fast2 = pd.sound.sampleplayer.new("sound/cards2_fast2")




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
    SCENE_MANAGER:switchScene(TitleScene)
    
end

startGame()


function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()
    --pd.drawFPS(380, 5)
    
end