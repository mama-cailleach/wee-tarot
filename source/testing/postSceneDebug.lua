--import "libraries/AnimatedSprite"
import "data/cardDescriptions"


local pd <const> = playdate
local gfx <const> = playdate.graphics

local ALL_CARD_DATA = CARD_DATA

local KEYWORD_INTRO_OPTIONS = {
        "The spirits whisper of: ",
        "It speaks of: ",
        "Reflections within the card: ",
        "The card carries energies of: ",
        "This card resonates with: ",
        "Some guiding truths are: "
    }

class('PostSceneDebug').extends(gfx.sprite)

function PostSceneDebug:init()
    PostSceneDebug.super.init(self)

    -- --- Debug Iteration State ---
    self.allCardNames = {}
    for name, _ in pairs(ALL_CARD_DATA) do
        if name ~= "PlaceholderCard" then -- Exclude placeholder from iteration
            table.insert(self.allCardNames, name)
        end
    end
    table.sort(self.allCardNames) -- Sort alphabetically for consistent testing order

    self.currentCardIndex = 1
    self.currentInvertedState = false -- false for upright, true for inverted
    self.currentKeywordIntroIndex = 1
    self.currentFortuneLineIndex = 1

    self.isDisplayingText = true -- Set to true immediately as there's no animation delay
    self.currentTextLineIndex = 1
    self.isVariationComplete = false

    -- --- Scene Elements ---
    local imagetable = gfx.imagetable.new("images/bg/dinahBG-table-400-66")
    self.dinahSprite = AnimatedSprite.new(imagetable)
    self.scrollBoxImg = gfx.image.new("images/textScroll/scroll1b")
    self.scrollBoxSprite = gfx.sprite.new(self.scrollBoxImg)
    self.bButton = nil
    self.aButton = nil
    self.dinahScrollText = nil
    -- self.scrollBoxAnimatorIn = nil -- REMOVED: No longer needed

    self.dinahText = {}

    -- Call initial setup methods
    self:dinahSpriteLoad()
    self:scrollBoxCreate()
    self:buttonBBlink()
    self:buttonABlink()

    -- Directly position scroll box and show first text
    self.scrollBoxSprite:moveTo(202, 170) -- Set directly to final position
    self.scrollBoxSprite:add()
    self.bButton:add() -- Show B button immediately
    self:showTextAtIndex(self.currentTextLineIndex) -- Show the first text instantly

    self:add() -- Add the scene itself (if it's a sprite)

    -- The first variation is already started by direct calls above
end

-- --- Helper Methods ---

-- REMOVED: onScrollBoxAnimationFinished - not needed without animator

-- Refactored text display logic
function PostSceneDebug:showTextAtIndex(index)
    if self.dinahScrollText then
        self.dinahScrollText:remove()
    end

    if index > #self.dinahText then
        -- All lines for the current variation are displayed
        self.isVariationComplete = true
        self.isDisplayingText = false -- No more lines to advance within this variation
        self.bButton:remove()
        self.aButton:add()    -- Now A button can advance to next variation
        print("--- VARIATION COMPLETE ---")
        return
    end

    self.dinahScrollText = gfx.sprite.spriteWithText(
        self.dinahText[index],
        310, -- Width
        200, -- Height
        nil, nil, nil,
        kTextAlignment.center
    )
    self.dinahScrollText:moveTo(190, 180)
    self.dinahScrollText:add()
    print("Displaying line " .. index .. ": " .. self.dinahText[index])
end

-- Advance to the next line within the current variation
function PostSceneDebug:nextTextLine()
    self.currentTextLineIndex += 1
    self:showTextAtIndex(self.currentTextLineIndex)
end

-- --- Logic to advance to the next full dialogue variation ---
function PostSceneDebug:startCurrentVariation()
    local cardName = self.allCardNames[self.currentCardIndex]
    local isInverted = self.currentInvertedState
    local keywordIntroIndex = self.currentKeywordIntroIndex
    local fortuneLineIndex = self.currentFortuneLineIndex

    print("\n--- DEBUGGING VARIATION ---")
    print(string.format("Card: %s, Inverted: %s, Keyword Intro: %d, Fortune Line: %d",
        cardName, tostring(isInverted), keywordIntroIndex, fortuneLineIndex))

    -- Populate self.dinahText for this specific variation
    self:addCardTextToDinahDebug(cardName, isInverted, keywordIntroIndex, fortuneLineIndex)

    self.currentTextLineIndex = 1 -- Reset line index for new text
    self.isVariationComplete = false
    self.isDisplayingText = true -- Text appears instantly
    self.aButton:remove()    -- Hide A button until variation is complete
    self.bButton:add()       -- Show B button for advancing text lines

    -- Display the first line instantly
    self:showTextAtIndex(self.currentTextLineIndex)
end

function PostSceneDebug:moveToNextVariation()
    local cardName = self.allCardNames[self.currentCardIndex]
    local cardInfo = ALL_CARD_DATA[cardName]
    local fortune_lines = self.currentInvertedState and cardInfo.reversed_fortune or cardInfo.upright_fortune
    local numFortuneLines = #fortune_lines
    local numKeywordIntros = #KEYWORD_INTRO_OPTIONS

    -- Cycle through fortune lines
    self.currentFortuneLineIndex += 1
    if self.currentFortuneLineIndex > numFortuneLines then
        self.currentFortuneLineIndex = 1 -- Reset fortune line index
        self.currentKeywordIntroIndex += 1 -- Advance to next keyword intro
    end

    -- Cycle through keyword intros
    if self.currentKeywordIntroIndex > numKeywordIntros then
        self.currentKeywordIntroIndex = 1 -- Reset keyword intro index
        self.currentInvertedState = not self.currentInvertedState -- Toggle inverted state
    end

    -- Cycle through inverted state
    if not self.currentInvertedState and self.currentKeywordIntroIndex == 1 and self.currentFortuneLineIndex == 1 then
        -- This condition means we've just finished all inverted states and keyword/fortune combos for the current card,
        -- and are about to loop back to upright for the *next* card.
        self.currentCardIndex += 1
    end

    -- Cycle through cards
    if self.currentCardIndex > #self.allCardNames then
        print("--- ALL VARIATIONS TESTED ---")
        -- TODO: Add logic for what happens when all variations are exhausted
        SCENE_MANAGER:switchScene(TitleScene.new()) -- Example: Go back to title
        return
    end

    self:startCurrentVariation()
end

-- --- MODIFIED addCardTextToDinah FOR DEBUGGING ---
-- This version takes specific indices instead of using math.random
function PostSceneDebug:addCardTextToDinahDebug(cardName, isInverted, keywordIntroIndex, fortuneLineIndex)
    local cardInfo = ALL_CARD_DATA[cardName]

    if not cardInfo then
        print("Warning: No data found for card: " .. cardName .. ". Using placeholder.")
        cardInfo = ALL_CARD_DATA["PlaceholderCard"]
    end

    -- Clear and re-populate self.dinahText
    self.dinahText = {
        "Hmmmm... Hmmmm... \n" .. cardName .. (isInverted and "\nUpside down..." or "")
    }

    -- Add Correspondence
    local correspondence_data = cardInfo.correspondence
    if correspondence_data and #correspondence_data > 0 then
        table.insert(self.dinahText,table.concat(correspondence_data))
    end

    -- Add Keywords to self.dinahText
    local source_keywords_list
    if isInverted and cardInfo.reversed_keywords then
        source_keywords_list = cardInfo.reversed_keywords
    elseif cardInfo.upright_keywords then
        source_keywords_list = cardInfo.upright_keywords
    end

    local final_keywords_to_display = {}
    local num_keywords_to_select = 3 -- always select 3 for testing

    local chosenIntroPhrase = KEYWORD_INTRO_OPTIONS[keywordIntroIndex] -- Use specific index as before

    if source_keywords_list and #source_keywords_list > 0 then        
        local shuffled_list = self:shuffleTable(source_keywords_list)
        for i = 1, math.min(num_keywords_to_select, #shuffled_list) do
            table.insert(final_keywords_to_display, shuffled_list[i])
        end

        table.insert(self.dinahText, chosenIntroPhrase .. table.concat(final_keywords_to_display, ", "))
    end

    -- Add the specific fortune line
    local fortune_lines
    if isInverted and cardInfo.reversed_fortune then
        fortune_lines = cardInfo.reversed_fortune
    else
        fortune_lines = cardInfo.upright_fortune
    end

    local chosenFortuneLine = fortune_lines[fortuneLineIndex] -- Use specific index
    table.insert(self.dinahText, chosenFortuneLine)

    print("DinahTexts updated for debug variation.")
end

function PostSceneDebug:shuffleTable(tbl)
    local size = #tbl
    for i = size, 2, -1 do
        local j = math.random(i) -- Generate a random index between 1 and i
        tbl[i], tbl[j] = tbl[j], tbl[i] -- Swap elements
    end
    return tbl
end


-- --- Remaining PostScene methods (copy/paste and adapt to use self.) ---

function PostSceneDebug:dinahSpriteLoad()
    self.dinahSprite:addState("idle", 1, 6, {tickStep = 4, yoyo = true})
    self.dinahSprite:addState("transition", 1, 20, {tickStep = 1, loop = false})
    self.dinahSprite:moveTo(200,120)
    self.dinahSprite:add()
    self.dinahSprite:playAnimation()
end

function PostSceneDebug:scrollBoxCreate()
    self.scrollBoxSprite:moveTo(202, 170) -- Directly set to final position
    -- self.scrollBoxSprite:add() -- Already added in init
end

function PostSceneDebug:buttonBBlink()
    gfx.setImageDrawMode(gfx.kDrawModeInverted)
    self.bButton = gfx.sprite.spriteWithText("B", 400, 40, nil, nil, nil, kTextAlignment.center)
    self.bButton:moveTo(360, 220)
    local blinkerTimer = pd.timer.new(800, function()
        if self.bButton then self.bButton:setVisible(not self.bButton:isVisible()) end
    end)
    blinkerTimer.repeats = true
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
end

function PostSceneDebug:buttonABlink()
    gfx.setImageDrawMode(gfx.kDrawModeInverted)
    self.aButton = gfx.sprite.spriteWithText("A", 400, 40, nil, nil, nil, kTextAlignment.center)
    self.aButton:moveTo(360, 220)
    local blinkerTimer = pd.timer.new(800, function()
        if self.aButton then self.aButton:setVisible(not self.aButton:isVisible()) end
    end)
    blinkerTimer.repeats = true
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
end

function PostSceneDebug:loadGameAnimation()
    self.dinahSprite.states["transition"].onAnimationEndEvent = function ()
        SCENE_MANAGER:switchScene(GameScene) -- Assuming GameScene exists
    end
end

function PostSceneDebug:update()
    -- No animator to update for the scroll box, it's fixed.

    if pd.buttonJustPressed(pd.kButtonB) and self.isDisplayingText then
        self:nextTextLine() -- Advance to next line within current variation
    end

    if pd.buttonJustPressed(pd.kButtonA) and self.isVariationComplete then
        -- Only advance to next variation if current one is fully displayed
        self:moveToNextVariation()
    end
end

function PostSceneDebug:deinit()
    -- Clean up all sprites and timers
    if self.dinahSprite then self.dinahSprite:remove() end
    if self.scrollBoxSprite then self.scrollBoxSprite:remove() end
    if self.bButton then self.bButton:remove() end
    if self.aButton then self.aButton:remove() end
    if self.dinahScrollText then self.dinahScrollText:remove() end

    -- Removed: if self.scrollBoxAnimatorIn then self.scrollBoxAnimatorIn:remove() end
    -- If your button blinkers create separate timers, ensure they are removed too.

    PostSceneDebug.super.deinit(self)
end