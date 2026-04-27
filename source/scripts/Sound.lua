local pd <const> = playdate

Sound = {}

local SOUND_MODE_MIN <const> = 1
local SOUND_MODE_MAX <const> = 3

local DEFAULTS = {
    soundMode = 1,
    musicVolume = 0.9,
    ambienceVolume = 0.1,
    sfxVolume = {
        cards_fast = 0.45,
        cards_fast2 = 0.45,
        cards_fast3 = 0.45,
        cards_slow = 1.0,
        cards_slow2 = 0.7,
        cards2_slow = 1.0,
        cards2_fast2 = 1.0,
        crank5 = 0.65,
        tuin = 0.5,
        a_but1 = 0.5,
        a_but2 = 0.5,
        a_but3 = 0.5,
        a_but4 = 0.5
    }
}

local music = {}
local ambience = {}
local sfx = {}
local soundMode = DEFAULTS.soundMode

local function clampSoundMode(mode)
    local numeric = tonumber(mode)
    if not numeric then
        return DEFAULTS.soundMode
    end

    numeric = math.floor(numeric)
    if numeric < SOUND_MODE_MIN or numeric > SOUND_MODE_MAX then
        return DEFAULTS.soundMode
    end

    return numeric
end

local function applySoundMode()
    if not music.bgMusic or not ambience.rain then
        return
    end

    if soundMode == 1 then
        music.bgMusic:setVolume(DEFAULTS.musicVolume)
        ambience.rain:setVolume(DEFAULTS.ambienceVolume)
        if not ambience.rain:isPlaying() then
            ambience.rain:play(0)
        end
    elseif soundMode == 2 then
        music.bgMusic:setVolume(DEFAULTS.musicVolume)
        if ambience.rain:isPlaying() then
            ambience.rain:stop()
        end
    elseif soundMode == 3 then
        music.bgMusic:setVolume(0)
        ambience.rain:setVolume(DEFAULTS.ambienceVolume)
        if not ambience.rain:isPlaying() then
            ambience.rain:play(0)
        end
    end
end

function Sound.init(initialSoundMode)
    music.bgMusic = pd.sound.fileplayer.new("sound/bgMusic3quieter")
    music.bgMusic:setVolume(DEFAULTS.musicVolume)
    music.bgMusic:setLoopRange(0, 22)

    ambience.rain = pd.sound.fileplayer.new("sound/rain1quieter")
    ambience.rain:setVolume(DEFAULTS.ambienceVolume)

    sfx.cards_fast = pd.sound.sampleplayer.new("sound/cards_fast")
    sfx.cards_fast:setVolume(DEFAULTS.sfxVolume.cards_fast)

    sfx.cards_fast2 = pd.sound.sampleplayer.new("sound/cards_fast2")
    sfx.cards_fast2:setVolume(DEFAULTS.sfxVolume.cards_fast2)

    sfx.cards_fast3 = pd.sound.sampleplayer.new("sound/cards_fast3")
    sfx.cards_fast3:setVolume(DEFAULTS.sfxVolume.cards_fast3)

    sfx.cards_slow = pd.sound.sampleplayer.new("sound/cards_slow")
    sfx.cards_slow:setVolume(DEFAULTS.sfxVolume.cards_slow)

    sfx.cards_slow2 = pd.sound.sampleplayer.new("sound/cards_slow2")
    sfx.cards_slow2:setVolume(DEFAULTS.sfxVolume.cards_slow2)

    sfx.tuin = pd.sound.sampleplayer.new("sound/tuin")
    sfx.tuin:setVolume(DEFAULTS.sfxVolume.tuin)

    sfx.cards2_slow = pd.sound.sampleplayer.new("sound/cards2_slow")
    sfx.cards2_slow:setVolume(DEFAULTS.sfxVolume.cards2_slow)

    sfx.cards2_fast2 = pd.sound.sampleplayer.new("sound/cards2_fast2")
    sfx.cards2_fast2:setVolume(DEFAULTS.sfxVolume.cards2_fast2)

    sfx.crank5 = pd.sound.sampleplayer.new("sound/crank5")
    sfx.crank5:setVolume(DEFAULTS.sfxVolume.crank5)


    -- NEW SOUNDS V2

    sfx.b_button = pd.sound.sampleplayer.new("sound/b_button")

    sfx.a_but1 = pd.sound.sampleplayer.new("sound/a_but1")

    sfx.a_but2 = pd.sound.sampleplayer.new("sound/a_but2")

    sfx.a_but3 = pd.sound.sampleplayer.new("sound/a_but3")

    sfx.a_but4 = pd.sound.sampleplayer.new("sound/a_but4")

    sfx.pad_a = pd.sound.sampleplayer.new("sound/pad_a")

    sfx.pad_b = pd.sound.sampleplayer.new("sound/pad_b")

    sfx.witchpad = pd.sound.sampleplayer.new("sound/witchpad")

    Sound.setSoundMode(initialSoundMode)
end

function Sound.playSFX(name)
    local player = sfx[name]

    if not player then
        return false
    end

    player:play(1)
    return true
end

function Sound.stopSFX(name)
    local player = sfx[name]
    if not player then
        return false
    end

    player:stop()
    return true
end

function Sound.playABut()
    local variant = math.random(1, 4)
    local player = sfx["a_but" .. variant]

    if not player then
        return false
    end

    player:play(1)
    return true
end

function Sound.playMusic(loopStart, loopEnd)
    local player = music.bgMusic
    if not player then
        return false
    end

    if loopStart ~= nil and loopEnd ~= nil then
        player:setLoopRange(loopStart, loopEnd)
    elseif loopStart ~= nil then
        player:setLoopRange(loopStart)
    end

    if not player:isPlaying() then
        player:play(0)
    end

    applySoundMode()
    return true
end

function Sound.ensureMusicLoop(loopStart, loopEnd)
    return Sound.playMusic(loopStart, loopEnd)
end

function Sound.playAmbience()
    local player = ambience.rain
    if not player then
        return false
    end

    if soundMode == 2 then
        if player:isPlaying() then
            player:stop()
        end
        return false
    end

    if not player:isPlaying() then
        player:play(0)
    end

    return true
end

function Sound.stopAmbience()
    local player = ambience.rain
    if not player then
        return false
    end

    if player:isPlaying() then
        player:stop()
    end

    return true
end

function Sound.setAmbienceVolume(volume)
    local player = ambience.rain
    if not player then
        return false
    end

    local clamped = math.max(0, math.min(1, volume or DEFAULTS.ambienceVolume))
    player:setVolume(clamped)
    DEFAULTS.ambienceVolume = clamped
    return true
end

function Sound.startCrankLoop()
    local player = sfx.crank5
    if not player then
        return false
    end

    player:play(0)
    return true
end

function Sound.stopCrankLoop()
    local player = sfx.crank5
    if not player then
        return false
    end

    player:stop()
    return true
end

function Sound.setSoundMode(mode)
    soundMode = clampSoundMode(mode)
    applySoundMode()

    if PlayerProfileStore and PlayerProfileStore.setSoundMode then
        PlayerProfileStore.setSoundMode(soundMode)
    end

    return soundMode
end

function Sound.getSoundMode()
    return soundMode
end

function Sound.stopAll()
    for _, player in pairs(music) do
        if player and player:isPlaying() then
            player:stop()
        end
    end

    for _, player in pairs(ambience) do
        if player and player:isPlaying() then
            player:stop()
        end
    end

    for _, player in pairs(sfx) do
        if player then
            player:stop()
        end
    end
end

return Sound
