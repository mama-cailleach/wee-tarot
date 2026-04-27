--- Sound Manager 
-- @module Sound

Sound = {}

-- Sound storage
local sounds = {}
local music = {}
local currentMusic = nil
local ambient = {}
local currentAmbient = nil

-- Settings
local soundEnabled = true
local musicEnabled = true
local soundVolume = 1.0
local musicVolume = 0.6

--- Initialize sound system with game audio
function Sound.init()
    -- Preload sound effects
    
    -- gamefx
    sounds.ball_bouncey = playdate.sound.sampleplayer.new("assets/audio/sfx/ball02")
    sounds.bueiro = playdate.sound.sampleplayer.new("assets/audio/sfx/buerocskate4")
    sounds.crash4 = playdate.sound.sampleplayer.new("assets/audio/sfx/crash4")
    sounds.crash5 = playdate.sound.sampleplayer.new("assets/audio/sfx/crash5")
    sounds.crash6 = playdate.sound.sampleplayer.new("assets/audio/sfx/crash6")
    sounds.oil = playdate.sound.sampleplayer.new("assets/audio/sfx/oil2") 
    sounds.pastel = playdate.sound.sampleplayer.new("assets/audio/sfx/pastel")
    sounds.curb_skate = playdate.sound.sampleplayer.new("assets/audio/sfx/curb3")

    -- beep
    sounds.beep1 = playdate.sound.sampleplayer.new("assets/audio/sfx/beep1")
    sounds.beep2 = playdate.sound.sampleplayer.new("assets/audio/sfx/beep2")

    -- UI
    sounds.sfxon = playdate.sound.sampleplayer.new("assets/audio/sfx/sfxon1")
    sounds.abutton = playdate.sound.sampleplayer.new("assets/audio/sfx/abutton2")
    sounds.bbutton = playdate.sound.sampleplayer.new("assets/audio/sfx/bbutton1")
    sounds.dpad = playdate.sound.sampleplayer.new("assets/audio/sfx/dpad3")
    sounds.click = playdate.sound.sampleplayer.new("assets/audio/sfx/click1")
    sounds.tchin = playdate.sound.sampleplayer.new("assets/audio/sfx/tchin")

    -- separate fileplayer for ambient skate loop for reliable looping
    ambient.skate_bg1 = playdate.sound.fileplayer.new("assets/audio/sfx/loop7-3")


    -- Preload music tracks 
    music.certo_jeito = playdate.sound.fileplayer.new("assets/audio/music/certo_jeito_pd")
    music.antropo = playdate.sound.fileplayer.new("assets/audio/music/antropo_pd")
    music.chesty1 = playdate.sound.fileplayer.new("assets/audio/music/chesty1_pd1") 
    music.chesty2 = playdate.sound.fileplayer.new("assets/audio/music/chesty2_pd1")
    music.chesty3 = playdate.sound.fileplayer.new("assets/audio/music/chesty3_pd1")
    music.knuckles = playdate.sound.fileplayer.new("assets/audio/music/knucklesntails_pd")
    music.figurethings = playdate.sound.fileplayer.new("assets/audio/music/figurethings_pd")
 

    -- Set initial volumes
    for _, sound in pairs(sounds) do
        if sound then sound:setVolume(soundVolume) end
    end
    
    for _, track in pairs(music) do
        if track then track:setVolume(musicVolume) end       
    end

    if ambient then
        for _, amb in pairs(ambient) do
            if amb then amb:setVolume(soundVolume) end
        end
    end

    -- dunno if needed but just in case
    Sound.setVolumes(soundVolume, musicVolume)
end

-- Ambient control (preferred: fileplayer for reliable looping)
function Sound.playAmbient(name)
    if not sounds[name] and not music[name] and not ambient[name] then return end
    -- stop existing ambient
    if currentAmbient and currentAmbient.stop then
        currentAmbient:stop()
    end
    local player = ambient[name] or music[name] or sounds[name]
    currentAmbient = player
    -- if fileplayer, play with loop
    if currentAmbient.play then
        -- try infinite loop if supported (fileplayer)
        pcall(function()
            currentAmbient:play(0)
        end)
        -- fallback to sampleplayer play
        if not currentAmbient.isPlaying or not currentAmbient:isPlaying() then
            currentAmbient:play()
        end
    end
end

function Sound.stopAmbient()
    if currentAmbient and currentAmbient.stop then
        currentAmbient:stop()
    end
    currentAmbient = nil
end

--- Play a sound effect
-- @string soundName Name of the sound to play
-- @number[opt] volume Volume override (0-1)
function Sound.playSound(soundName, volume)
    if not soundEnabled or not sounds[soundName] then return end
    
    local vol = volume or soundVolume
    sounds[soundName]:setVolume(vol)
    sounds[soundName]:play()
end

--- Play background music
-- @string musicName Name of music track
-- @bool[opt=true] loop Should music loop
function Sound.playMusic(musicName, loop)
    if not musicEnabled or not music[musicName] then return end
    
    -- Stop current music
    if currentMusic then
        currentMusic:stop()
    end
    
    currentMusic = music[musicName]
    -- Always restore volume when playing (track might have been muted before)
    currentMusic:setVolume(musicVolume)
    local shouldLoop = loop ~= false -- Default to true
    currentMusic:play(shouldLoop and 0 or 1) -- 0 = infinite loop, 1 = play once
end

--- Stop current music
function Sound.stopMusic()
    if currentMusic then
        currentMusic:stop()
        currentMusic = nil
    end
end

--- Toggle sound effects on/off
function Sound.toggleSound()
    soundEnabled = not soundEnabled
    Noble.Settings.set("soundEnabled", soundEnabled)
    -- Apply volume changes immediately
    for _, sound in pairs(sounds) do
        if sound then
            sound:setVolume(soundEnabled and soundVolume or 0)
        end
    end
    
    -- apply to ambient aswell
    for _, amb in pairs(ambient) do
        if amb then
            amb:setVolume(soundEnabled and soundVolume or 0)
        end
    end

    return soundEnabled
end

--- Toggle music on/off by making volume zero 
function Sound.toggleMusic()
    musicEnabled = not musicEnabled
    Noble.Settings.set("musicEnabled", musicEnabled)
    if not musicEnabled and currentMusic then
        currentMusic:setVolume(0)
    elseif musicEnabled and currentMusic then
        -- Check if track is still playing before restoring volume
        if currentMusic:isPlaying() then
            currentMusic:setVolume(musicVolume)
        else
            -- Track stopped while muted, clear it so next scene can start fresh
            currentMusic = nil
        end
    end
    
    return musicEnabled
end

--- Set volumes
-- @number soundVol Sound effects volume (0-1)
-- @number musicVol Music volume (0-1)
function Sound.setVolumes(soundVol, musicVol)
    if soundVol then
        soundVolume = math.max(0, math.min(1, soundVol))
        for _, sound in pairs(sounds) do
            if sound then sound:setVolume(soundVolume) end
        end
        for _, amb in pairs(ambient) do
            if amb then amb:setVolume(soundVolume) end
        end
    end
    
    if musicVol then
        musicVolume = math.max(0, math.min(1, musicVol))
        for _, track in pairs(music) do
            if track then track:setVolume(musicVolume) end
        end
        if currentMusic then currentMusic:setVolume(musicVolume) end
    end
    
end

--- Get current settings
function Sound.getSettings()
    -- Always return the latest values from Noble.Settings
    local sfxEnabled = Noble.Settings.get("soundEnabled")
    local musicEnabled = Noble.Settings.get("musicEnabled")
    return musicEnabled, sfxEnabled
    -- old system, for backup only here (return soundEnabled, musicEnabled, soundVolume, musicVolume)
end



-- Simple solution for now 

Sound.musicTracks = {"certo_jeito", "antropo", "knuckles", "figurethings"}

local lastTrackIndex = 0
--- Play a random music track
function Sound.playRandomMusic()
    local randomIndex = math.random(1, #Sound.musicTracks)
    Sound.playMusic(Sound.musicTracks[randomIndex], false)
    lastTrackIndex = randomIndex
end

--- Play the next track in rotation
function Sound.playNextMusic()
    lastTrackIndex = lastTrackIndex + 1
    if lastTrackIndex > #Sound.musicTracks then
        lastTrackIndex = 1
    end
    Sound.playMusic(Sound.musicTracks[lastTrackIndex], false)
end

-- helper for checking if specific music is playing
function Sound.isMusicPlaying(trackName)
    return currentMusic and currentMusic:isPlaying() and currentMusic == music[trackName]
end

--helper for checking if any music is playing
function Sound.isAnyMusicPlaying()
    return currentMusic and pcall(function() return currentMusic:isPlaying() end) and currentMusic:isPlaying()
end



function Sound.duckAmbient(duckVolume)
    if not currentAmbient or not currentAmbient.setVolume then return end

    if currentAmbient:getVolume() == 0.0 then
        return
    end
    

    -- store previous volume (only first duck stores it)
    if Sound._ambientPrevVolume == nil then
        local ok, vol = pcall(function() return currentAmbient:getVolume() end)
        Sound._ambientPrevVolume = (ok and vol) or 1.0
    end
    duckVolume = math.max(0, math.min(1, duckVolume or 0.3))
    pcall(function() currentAmbient:setVolume(duckVolume) end)
    Sound._ambientDucked = true
end

function Sound.restoreAmbient()
    if not currentAmbient or not currentAmbient.setVolume then return end
    if Sound._ambientPrevVolume ~= nil then
        pcall(function() currentAmbient:setVolume(Sound._ambientPrevVolume) end)
        Sound._ambientPrevVolume = nil
    end
    Sound._ambientDucked = false
end

-- Duck for a specific duration (ms) then restore automatically
function Sound.temporarilyDuckAmbient(duckVolume, durationMs)
    durationMs = durationMs or 500
    Sound.duckAmbient(duckVolume)
    if Sound._ambientDuckTimer then
        Sound._ambientDuckTimer:remove()
        Sound._ambientDuckTimer = nil
    end
    Sound._ambientDuckTimer = playdate.timer.performAfterDelay(durationMs, function()
        Sound._ambientDuckTimer = nil
        Sound.restoreAmbient()
    end)
end