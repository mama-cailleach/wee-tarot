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
    self.scrollOffset = 0
    self.maxScroll = 0
    self.visibleLines = 3 -- Number of lines to show at once
    self.scrollY = 0
    self.scrollBoxHeight = 60
    self.scrollBoxWidth = 310

    -- --- Call initial setup methods ---
    self:dinahSpriteLoad()
    self:buttonABlink()

    -- Add card specific text, now as a method call
    self:addCardTextToDinah(self.card)
    self.maxScroll = math.max(0, #self.dinahTextLines - self.visibleLines)

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
    self:drawScrollTextWindow()
    self.canButton = true
end

-- text display logic (currentIndex is now self.currentIndex)
function PostScene:drawScrollTextWindow()
    -- Create an image for the scroll box
    local img = gfx.image.new(self.scrollBoxWidth, self.scrollBoxHeight)
    gfx.pushContext(img)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(0, 0, self.scrollBoxWidth, self.scrollBoxHeight)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawTextInRect(self.dinahTextBlock, 0, -self.scrollY, self.scrollBoxWidth, 1000, nil, "...", kTextAlignment.left)
    gfx.popContext()
    if self.dinahScrollText then self.dinahScrollText:remove() end
    self.dinahScrollText = gfx.sprite.new(img)
    self.dinahScrollText:moveTo(190, 180) -- Center as before
    self.dinahScrollText:add()
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

    -- Crank scroll logic
    if self.canButton then
        local crankChange = pd.getCrankChange()
        if crankChange ~= 0 then
            local _, textHeight = gfx.getTextSize(self.dinahTextBlock)
            local maxScrollY = math.max(0, textHeight - self.scrollBoxHeight)
            self.scrollY = math.max(0, math.min(self.scrollY + crankChange * 2, maxScrollY)) -- *2 for speed, adjust as needed
            self:drawScrollTextWindow()
        end
    end

    if pd.buttonJustPressed(pd.kButtonA) and self.canButton then
        if self.dinahScrollText then
            self.dinahScrollText:remove()
        end
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

    local lines = {}

    -- 1. Card intro
    local introOptions = {
        "Hmmmm... Hmmmm... (squints at the card) Very interesting…",
        "(looks at you with a raised eyebrow)",
        "Shh... listen closely.\nNo, closer.",
        "Patience. The universe loves a dramatic pause.",
        "We may glimpse the dawn… or another dark night of the soul. Let's see.",
        "(sighs) Well, every card is a mirror. Know thyself… if you dare to look.",
        "Let me peer through the veil… it's a bit wrinkled today.",
        "Ah, this one… I remember its dance with fate.",
    }
    table.insert(lines, introOptions[math.random(1, #introOptions)])
    table.insert(lines, "")

    local intro = "You pulled:\n" .. cardName .. (self.invert and "\nUpside down" or "")
    table.insert(lines, intro)
    table.insert(lines, "")

    -- 2. Correspondence
    local correspondence_data = cardInfo.correspondence
    if correspondence_data and #correspondence_data > 0 then
        table.insert(lines, table.concat(correspondence_data))
        table.insert(lines, "")
    end

    -- 3. Keywords
    local source_keywords_list
    if self.invert and cardInfo.reversed_keywords then
        source_keywords_list = cardInfo.reversed_keywords
    elseif cardInfo.upright_keywords then
        source_keywords_list = cardInfo.upright_keywords
    end

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
    table.insert(lines, keywordIntroOptions[math.random(1, #keywordIntroOptions)])
    table.insert(lines, "")

    local final_keywords_to_display = {}
    local num_keywords_to_select = 3
    if source_keywords_list and #source_keywords_list > 0 then
        if #source_keywords_list <= num_keywords_to_select then
            final_keywords_to_display = source_keywords_list
        else
            local shuffled_list = shuffle_table(source_keywords_list)
            for i = 1, num_keywords_to_select do
                table.insert(final_keywords_to_display, shuffled_list[i])
                
            end
        end
        table.insert(lines, table.concat(final_keywords_to_display, ", "))
        table.insert(lines, "")
    end

    -- 4. Fortune line
    local fortune_lines
    if self.invert and cardInfo.reversed_fortune then
        fortune_lines = cardInfo.reversed_fortune
    else
        fortune_lines = cardInfo.upright_fortune
    end
    table.insert(lines, fortune_lines[math.random(1, #fortune_lines)])

    -- Store as lines for scrolling
    self.dinahTextLines = {}
    for _, block in ipairs(lines) do
        for line in tostring(block):gmatch("([^\n]*)\n?")do
                    -- Always insert, even if empty
        table.insert(self.dinahTextLines, line)
        end
    end
    self.dinahTextBlock = table.concat(self.dinahTextLines, "\n")
end