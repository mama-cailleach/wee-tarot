--import "libraries/AnimatedSprite"
import "data/cardDescriptions"


local pd <const> = playdate
local gfx <const> = playdate.graphics

local ALL_CARD_DATA = CARD_DATA

-- Creates a shuffled COPY of the table, leaving the original data table untouched.
local function shuffle_table(tbl)
    local n = #tbl
    -- Create a shallow copy to shuffle, so the original data in ALL_CARD_DATA isn't modified
    local shuffled_copy = {}
    for i = 1, n do
        table.insert(shuffled_copy, tbl[i])
    end

    while n > 1 do
        local k = math.random(n) -- Pick a random element from 1 to n
        shuffled_copy[n], shuffled_copy[k] = shuffled_copy[k], shuffled_copy[n] -- Swap it with the current last element
        n = n - 1
    end
    return shuffled_copy

    -- IMPORTANT: Ensure you initialize the random seed once at game startup (e.g., in main.lua)
    -- math.randomseed(pd.getTime()) -- Or os.time() if pd is not available early
    -- This ensures you get different random keywords each run.
end

class('PostScene').extends(gfx.sprite)


function PostScene:init(playerCard, isInverted)
    PostScene.super.init(self) -- IMPORTANT: Call the superclass init for sprite functionality

    self.card = playerCard
    self.invert = isInverted

    -- --- Scene-Specific Variables ---
    self.imagetable = gfx.imagetable.new("images/bg/dinahBG-table-400-66")
    self.dinahSprite = AnimatedSprite.new(self.imagetable)
    self.scrollBoxImg = gfx.image.new("images/textScroll/scroll1b")
    self.scrollBoxSprite = gfx.sprite.new(self.scrollBoxImg)
    self.dinahText = {} -- This will be populated by addCardTextToDinah
    self.currentIndex = 1
    self.dinahScrollText = nil -- The text sprite itself
    self.bButton = nil
    self.aButton = nil
    self.canButton = false
    self.lastText = false
    self.scrollBoxAnimatorIn = nil -- Will be created later

    -- --- Call initial setup methods ---
    self:dinahSpriteLoad()
    self:buttonBBlink()
    self:buttonABlink()

    -- Add card specific text, now as a method call
    self:addCardTextToDinah(self.card)


    -- Set up the scroll box animator, and crucially, its callback
    self.scrollBoxAnimatorIn = gfx.animator.new(3000, 300, 170, pd.easingFunctions.outBack)
    self.scrollBoxSprite:moveTo(202, 300) -- Set initial position for animation
    self.scrollBoxSprite:add() -- Add it so it can be animated

    -- delay for text to come after animation
    pd.timer.performAfterDelay(3200, function ()
        self:onScrollBoxAnimationFinished()
        
    end)

    self:add()

    -- print to see if cards and inverted is corret
    print(self.card)
    print(self.invert)
end


-- Callback for scroll box animation finish
function PostScene:onScrollBoxAnimationFinished()
    self.bButton:add() -- Add B button once animation is done
    self:showTextAtIndex(self.currentIndex) -- Show the first text
    self.canButton = true
end


-- text display logic (currentIndex is now self.currentIndex)
function PostScene:showTextAtIndex(index)
    if self.dinahScrollText then
        self.dinahScrollText:remove()
    end

    -- Check if index is valid, otherwise handle end of text or placeholder
    if index > #self.dinahText then
        self.lastText = true
        self.bButton:remove() -- Remove B button if no more text
        self.scrollBoxSprite:remove()
        self.aButton:add() -- Add A button if ready to transition
        return
    end

    self.dinahScrollText = gfx.sprite.spriteWithText(self.dinahText[index], 310, 200, nil, nil, nil, kTextAlignment.center)
    self.dinahScrollText:moveTo(190, 180) 
    self.dinahScrollText:add()
end


function PostScene:nextTextLogic()
    self.currentIndex = self.currentIndex + 1
    self:showTextAtIndex(self.currentIndex)
end


function PostScene:loadGameAnimation()
    self.dinahSprite.states["transition"].onAnimationEndEvent = function ()
        SCENE_MANAGER:switchScene(GameScene) -- SCENE_MANAGER is global, so it's okay here
    end
end


function PostScene:dinahSpriteLoad()
    self.dinahSprite:addState("idle", 1, 6, {tickStep = 4, yoyo = true})
    self.dinahSprite:addState("transition", 1, 20, {tickStep = 1, loop = false})
    self.dinahSprite:moveTo(200,120)
    self.dinahSprite:add()
    self.dinahSprite:playAnimation()
end



function PostScene:buttonBBlink()
    gfx.setImageDrawMode(gfx.kDrawModeInverted)
    self.bButton = gfx.sprite.spriteWithText("B", 400, 40, nil, nil, nil, kTextAlignment.center)
    self.bButton:moveTo(360, 220)
    -- self.bButton:add() -- Don't add initially, add after anim
    
    local blinkerTimer = pd.timer.new(800, function()
        if self.bButton then self.bButton:setVisible(not self.bButton:isVisible()) end
    end)
    blinkerTimer.repeats = true
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
end

function PostScene:buttonABlink()
    gfx.setImageDrawMode(gfx.kDrawModeInverted)
    self.aButton = gfx.sprite.spriteWithText("A", 400, 40, nil, nil, nil, kTextAlignment.center)
    self.aButton:moveTo(360, 220)
    -- self.aButton:add() -- Don't add initially
    
    local blinkerTimer = pd.timer.new(800, function()
        if self.aButton then self.aButton:setVisible(not self.aButton:isVisible()) end
    end)
    blinkerTimer.repeats = true
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
end


function PostScene:update()
    local scrollBoxY = self.scrollBoxAnimatorIn:currentValue()
    self.scrollBoxSprite:moveTo(202, scrollBoxY)






    if pd.buttonJustPressed(pd.kButtonB) and self.canButton then
        if not self.lastText then
            self:nextTextLogic()
        end
    end
    
    if pd.buttonJustPressed(pd.kButtonA) and self.canButton then
        if self.dinahScrollText then
            self.dinahScrollText:remove()
        end
        self.bButton:remove()
        self.scrollBoxSprite:remove()
        self:loadGameAnimation() -- Call as a method
        self.dinahSprite:changeState("transition")
        if self.lastText then
            self.aButton:remove()
        end
    end
end


-- populating the texts for the reading
function PostScene:addCardTextToDinah(cardName)
    local cardInfo = ALL_CARD_DATA[cardName]

    if not cardInfo then
        print("Warning: No data found for card: " .. cardName .. ". Using placeholder.")
        cardInfo = ALL_CARD_DATA["PlaceholderCard"]
    end

    self.dinahText = {}

    -- 1. Card intro
    local introOptions = {
        "Hmmmm... Hmmmm... (squints at the card) Very interesting...",
        "(looks at you with a raised eyebrow)",
        "Shh... listen closely.\nNo, closer.",
        "Patience. The universe loves a dramatic pause.",
        "We may glimpse the dawn… or another dark night of the soul. Let's see.",
        "(sighs) Well, every card is a mirror. Know thyself... if you dare to look.",
        "Let me peer through the veil… it's a bit wrinkled today.",
        "Ah, this one… I remember its dance with fate.",
    }

    -- Select one random phrase from the list
    local randomIntroIndex = math.random(1, #introOptions)
    local chosenIntro = introOptions[randomIntroIndex]
    table.insert(self.dinahText, chosenIntro)


    local intro ="You pulled:\n" .. cardName .. (self.invert and "\nUpside down" or "")
    table.insert(self.dinahText, intro)
    --are you ready to know your fate/to know thyself/dark knight of the soul(confront you shadow self)/the cards iluminate your answers

    -- 2. Correspondence
    local correspondence_data = cardInfo.correspondence
    if correspondence_data and #correspondence_data > 0 then
        local corrText = table.concat(correspondence_data)
        table.insert(self.dinahText, corrText)
    end

    -- 3. Keywords
    local source_keywords_list
    if self.invert and cardInfo.reversed_keywords then
        source_keywords_list = cardInfo.reversed_keywords
    elseif cardInfo.upright_keywords then -- Fallback to upright if not inverted or no reversed
        source_keywords_list = cardInfo.upright_keywords
    end

    local final_keywords_to_display = {}
    local num_keywords_to_select = 3
    local keywordIntroOptions = {
        "The spirits whisper of: ",
        "The energy of the card calls forth: ",
        "The ancient oracles breath carries: ",
        "The card holds within the sands of time: ",
        "Echoes from your own intuition speak of: ",
        "From the woven threads of fate, we find: ",
        "This is the essence now unveiled: ",
        "Let these currents flow through you: "
    } 
    
    -- Select one random phrase from the list
    local randomIndex = math.random(1, #keywordIntroOptions)
    local chosenIntroPhrase = keywordIntroOptions[randomIndex]
    table.insert(self.dinahText, chosenIntroPhrase)

    if source_keywords_list and #source_keywords_list > 0 then
        if #source_keywords_list <= num_keywords_to_select then
            -- If there are 4 or fewer keywords, just use all of them
            final_keywords_to_display = source_keywords_list
        else
            -- If there are more than 4, shuffle and pick the first 4
            local shuffled_list = shuffle_table(source_keywords_list)
            for i = 1, num_keywords_to_select do
                table.insert(final_keywords_to_display, shuffled_list[i])
            end
        end

        local keywordsText = table.concat(final_keywords_to_display, ", ")
        table.insert(self.dinahText, keywordsText)
    end

    -- 4. Fortune line
    local fortune_lines
    if self.invert and cardInfo.reversed_fortune then
        fortune_lines = cardInfo.reversed_fortune
    else
        fortune_lines = cardInfo.upright_fortune
    end

    local randomIndex = math.random(1, #fortune_lines)
    local chosenFortuneLine = fortune_lines[randomIndex]
    table.insert(self.dinahText, chosenFortuneLine)

    print("DinahTexts updated with lines for: " .. cardName)
end