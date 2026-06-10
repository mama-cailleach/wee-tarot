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
import "libraries/gameAssets"
import "data/save/playerProfileStore"
import "data/save/diaryStore"
import "scripts/Sound"
import "scripts/screenShake"

-- Scenes
import "scenes/allScenes"


--card script
import "scripts/card"


--Decks
import "scripts/decks/allDecks"

-- Debugs
--import "cardManipulationDebug"
--import "shuffleAnimationTestScene"


local pd <const> = playdate
local gfx <const> = pd.graphics

--GLOBALS

SCENE_MANAGER = SceneManager()

selectedDeck = "full" -- full, major, minor, cups, pentacles, swords, wands
selectedSpread = "one_card"


-- font tarotheque (https://www.dafont.com/gschaftlhuber.d11133?text=Hello+%E9+%E3+%E7)
local fontPaths = {
    [gfx.font.kVariantNormal] = "fonts/tarotheque-v1-20",
    [gfx.font.kVariantBold] = "fonts/tarotheque-v2-20",
    [gfx.font.kVariantItalic] = "fonts/tarotheque-v1-20"
}

--CHANGE FONT - folder path and no .fnt // here apply to whole game
local myFont = gfx.font.newFamily(fontPaths)
gfx.setFont(myFont)

local bootComplete = false
local loadingSprite = nil

local function finishBootAndStartTitle()
    if loadingSprite then
        loadingSprite:remove()
        loadingSprite = nil
    end
    bootComplete = true
    SCENE_MANAGER:switchScene(TitleScene)
end

local function beginBoot()
    local loading = gfx.image.new("SystemAssets/launchImage")
    loadingSprite = gfx.sprite.new(loading)
    loadingSprite:moveTo(200, 120)
    loadingSprite:add()
    GameAssets.beginPreload()
end

local storedSoundMode = 1
if PlayerProfileStore and PlayerProfileStore.getSoundMode then
    storedSoundMode = PlayerProfileStore.getSoundMode()
end
Sound.init(storedSoundMode)

pd.setCrankSoundsDisabled(true)

beginBoot()

function pd.crankDocked()
    Sound.playSFX("docking")
end

function pd.crankUndocked()
    Sound.playSFX("undocking")
end


function pd.update()
    if bootComplete and DiaryStore and DiaryStore.tickFlush then
        DiaryStore.tickFlush(SCENE_MANAGER.transitioning)
    end

    gfx.sprite.update()
    pd.timer.updateTimers()

    if not bootComplete then
        GameAssets.advancePreload()
        if not GameAssets.isPreloadComplete() then
            pd.drawFPS(380, 5)
            return
        end
        DiaryStore.warmCache()
        finishBootAndStartTitle()
    end

    pd.drawFPS(380, 5)

end
