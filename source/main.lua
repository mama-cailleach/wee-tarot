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


--card script
import "scripts/card"


--Decks
import "scripts/decks/allDecks"


local pd <const> = playdate
local gfx <const> = pd.graphics

--GLOBALS

SCENE_MANAGER = SceneManager()

onlyMajor = false -- global variable for major arcana only option
soundMode = 1 -- 1 = Music&Rain, 2 = Just Music, 3 = Just Rain


-- SOUND

bgMusic = pd.sound.fileplayer.new("sound/bgMusic3quieter") -- bg music loop lofi mix
bgMusic:setVolume(0.9)
bgMusic:setLoopRange(0,22) -- Title Loop no beats

ambience = pd.sound.fileplayer.new("sound/rain1quieter") -- rain
ambience:setVolume(0.1)

cards_fast = pd.sound.sampleplayer.new("sound/cards_fast") -- big intro w/ effect
cards_fast:setVolume(0.45)

cards_fast2 = pd.sound.sampleplayer.new("sound/cards_fast2") -- transition effects quicker
cards_fast2:setVolume(0.45)

cards_fast3 = pd.sound.sampleplayer.new("sound/cards_fast3") -- transition effects bit longer
cards_fast3:setVolume(0.45)

cards_slow = pd.sound.sampleplayer.new("sound/cards_slow") -- transition effects slower quieter

cards_slow2 = pd.sound.sampleplayer.new("sound/cards_slow2") -- transition effects slower louder
cards_slow2:setVolume(0.7)

tuin = pd.sound.sampleplayer.new("sound/tuin") -- just the tail
tuin:setVolume(0.5)

cards2_slow = pd.sound.sampleplayer.new("sound/cards2_slow") -- card shuffle sound 1

cards2_fast2 = pd.sound.sampleplayer.new("sound/cards2_fast2") -- card shuffle sound 2

crank5 = pd.sound.sampleplayer.new("sound/crank5") -- crank sound longish
crank5:setVolume(0.65)

-- end of GLOBALS/SOUND


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
    
end

startGame()


function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()
    --pd.drawFPS(380, 5)
    
end