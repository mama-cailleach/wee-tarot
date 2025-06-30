local pd <const> = playdate
local gfx <const> = playdate.graphics


function sideMenuCreate()
-- MENU only 3 allowed

local systemMenu = pd.getSystemMenu()
    --not really working??? maybe dont do on menu?
    systemMenu:addOptionsMenuItem("Deck", {"Major", "Full"}, "Full", function(flag)
    if flag == "Full" then
        onlyMajor = false
    elseif flag== "Major" then
        onlyMajor = true
    end
    end)

--[[ Menu????
    systemMenu:addOptionsMenuItem("spread size", {"1", "2", "3"}, "1", function(spread)
    if spread == "1" then
        -- 1 card spread
    elseif spread == "2" then
        -- 2 card spread
    elseif spread == "3" then
        -- 3 card spread
    end
    end)
    systemMenu:addOptionsMenuItem("reader", {"EN", "PTBR", "SCOT", "GAID"}, "EN", function(lang)
    if lang == "EN" then
            -- English
    elseif lang == "PTBR" then
            -- ptbr
    elseif lang == "SCOT" then
            -- scots
    elseif lang == "GAID" then
        -- gàidhligh
    end
    end)
    systemMenu:addCheckmarkMenuItem("SFX", true, function(flag)
    if flag then
        --[[ 
        SFX ON & OFF LOGIC || TO DO!!!

        if not SFX:getVolume() == 0 then
            SFX:setVolume(1)
        end
    else
        SFX:setVolume(0)

    
    end
    end)
    ]]
end





-- EXAMPLE FOR SWITCH SCENE / ADD MENU ITEM
--[[

systemMenu:addMenuItem("Switch", function()
    SCENE_MANAGER:switchScene(NewScene)
end)


-- EXAMPLE FOR ITEM LIST


local menu = pd.getSystemMenu()
menu:addOptionsMenuItem("Musica", {"baixa", "media", "alta", "desligada"}, "media", function(value)
    if value == "baixa" then
        GAME_MUSIC:setVolume(0.33)
    elseif value == "media" then
        GAME_MUSIC:setVolume(0.66)
    elseif value == "alta" then
        GAME_MUSIC:setVolume(1)
    elseif value == "desl" then
        GAME_MUSIC:setVolume(0)
    end
end)



-- EXAMPLE FOR CHECKLIST


local menu = pd.getSystemMenu()

menu:addCheckmarkMenuItem("Musica", true, function(flag)
    if flag then
        if not BgMusic:isPlaying() then
            BgMusic:play(0)
        end
    else
        BgMusic:stop()
    end
end)

]]