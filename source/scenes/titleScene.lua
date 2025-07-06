local pd <const> = playdate
local gfx <const> = playdate.graphics

--local utilities = import "libraries/utils"

class('TitleScene').extends(gfx.sprite)


function TitleScene:init()
    self:bgAnim2()
    bgMusic:play(0)
    
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite) -- for white text

    self.titleText = gfx.sprite.spriteWithText("WEE TAROT", 400, 200, nil, nil, nil, kTextAlignment.center)  
    self.titleText:moveTo(200, 42)
    self.titleText:add()

     -- --- TEXT ANIMATION LOOP PARAMETERS ---
    self.titleBaseY = 42    -- The original, center Y position of the text
    self.titleAmplitude = 4 -- How many pixels the text will move up and down from titleBaseY
    self.titleSpeed = 3.0 -- Controls the speed/frequency of the oscillation.
                        

    self.startText = gfx.sprite.spriteWithText("Press A to start", 400, 40, nil, nil, nil, kTextAlignment.center)  
    self.startText:moveTo(198, 200)
    self.startText:setZIndex(100)
    self.startText:add()

    self.blinkTime = 800
    --blink text logic 
    self.blinkerTimer = pd.timer.new(self.blinkTime, function()
        self.startText:setVisible(not self.startText:isVisible())
        end)
    self.blinkerTimer.repeats = true

    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    --self:sideMenuCreate()




    self:add()
end




function TitleScene:update()

    local currentTime = pd.getElapsedTime()
    -- currentTime * self.titleSpeed determines how fast we move through the sine wave cycle.
    local oscillationOffset = self.titleAmplitude * math.sin(currentTime * self.titleSpeed)
    -- Calculate the new Y position
    local newY = self.titleBaseY + oscillationOffset

    --[[
    -- Move the title text sprite to its new calculated position and fucks with blink of press A
    if currentTime >= 5 then
        self.blinkerTimer.repeats = false
        self.titleText:moveTo(self.titleText.x, newY)
            local blinkerTimer2 = pd.timer.new(2000, function()
            self.startText:setVisible(not self.startText:isVisible())
            end)
            blinkerTimer2.repeats = true
    end ]]
  

    if pd.buttonJustPressed(pd.kButtonA) then
        self.BGSprite:changeState("anim")
        self.startText:remove()
        self:changeAnim()
    end

end

function TitleScene:changeAnim()
    self.BGSprite.states["anim"].onAnimationEndEvent = function ()
        self.BGSprite:changeState("idleEnd")
        self:loadMenuAnimation()
    end
end

function TitleScene:soundTrigger()
    pd.timer.performAfterDelay(200, function()
        thunder:play(1)
    end)
    pd.timer.performAfterDelay(500, function()
        ambience:play(0)
    end)
    pd.timer.performAfterDelay(600, function()
        ambience:setVolume(0.18)
        pd.timer.performAfterDelay(200, function()
            ambience:setVolume(0.25)
        end)
    end)

end


function TitleScene:loadMenuAnimation()
    self.BGSprite.states["idleEnd"].onAnimationEndEvent = function ()
        SCENE_MANAGER:switchScene(MenuScene)
        bgMusic:setLoopRange(0)
        self:soundTrigger()

    end
end

function TitleScene:bgAnim2()
    local imagetableShuffle = gfx.imagetable.new("images/bg/titleBGAnim-table-400-391")
    self.BGSprite = AnimatedSprite.new(imagetableShuffle)
    self.BGSprite:addState("idle", 1, 1)
    self.BGSprite:addState("anim", 1, 34, {tickStep = 1.5, loop = false} )
    self.BGSprite:addState("idleEnd", 34, 34, {tickStep = 6, loop = false} )
    self.BGSprite:moveTo (200, 120)
    self.BGSprite:add()
    self.BGSprite:playAnimation()
end

function TitleScene:textOut()
    self.titleText:remove()
    
end




-- Side Menu stuff NOT IN USE ATM

function TitleScene:sideMenuCreate()
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


