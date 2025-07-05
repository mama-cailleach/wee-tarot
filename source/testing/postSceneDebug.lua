--import "libraries/AnimatedSprite"
import "data/cardDescriptions"

local pd <const> = playdate
local gfx <const> = playdate.graphics

local ALL_CARD_DATA = CARD_DATA

class('PostSceneDebug').extends(gfx.sprite)

-- Define suit and rank order
local suitOrder = {
     "Wands", "Swords", "Pentacles", "Cups"
}

local rankOrder = {
    "Ace", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten",
    "Page", "Knight", "Queen",  "King"
}




function PostSceneDebug:init()
    PostSceneDebug.super.init(self)

    -- Gather all card names (excluding placeholder)
    self.allCardNames = {}
    -- Add suit cards in order
    for _, suit in ipairs(suitOrder) do
        for _, rank in ipairs(rankOrder) do
            local name = rank .. " of " .. suit
            if ALL_CARD_DATA[name] then
                table.insert(self.allCardNames, name)
            end
        end
    end

    -- Add Major Arcana at the end, in order if possible
    local majorOrder = {
        "The Fool", "The Magician", "The High Priestess", "The Empress", "The Emperor",
        "The Hierophant", "The Lovers", "The Chariot", "Strength", "The Hermit",
        "Wheel of Fortune", "Justice", "The Hanged Man", "Death", "Temperance",
        "The Devil", "The Tower", "The Star", "The Moon", "The Sun", "Judgement", "The World"
    }
    for _, name in ipairs(majorOrder) do
        if ALL_CARD_DATA[name] then
            table.insert(self.allCardNames, name)
        end
    end

    self.currentCardIndex = 1
    self.currentInvertedState = false -- false = upright, true = reversed
    self.currentFortuneLineIndex = 1

    self.isDisplayingText = true
    self.currentTextLineIndex = 1
    self.isVariationComplete = false

    -- Scene elements
    local imagetable = gfx.imagetable.new("images/bg/dinahBG-table-400-66")
    self.dinahSprite = AnimatedSprite.new(imagetable)
    self.scrollBoxImg = gfx.image.new("images/textScroll/scroll1b")
    self.scrollBoxSprite = gfx.sprite.new(self.scrollBoxImg)
    self.bButton = nil
    self.aButton = nil
    self.dinahScrollText = nil

    self.dinahText = {}

    self:dinahSpriteLoad()
    self:scrollBoxCreate()
    self:buttonBBlink()
    self:buttonABlink()

    self.scrollBoxSprite:moveTo(202, 170)
    self.scrollBoxSprite:add()
    self.bButton:add()
    self:prepareCurrentVariation()
    self:showTextAtIndex(self.currentTextLineIndex)
    self:add()
end

function PostSceneDebug:prepareCurrentVariation()
    local cardName = self.allCardNames[self.currentCardIndex]
    local isInverted = self.currentInvertedState
    local cardInfo = ALL_CARD_DATA[cardName]

    -- Build dinahText using the same logic as PostScene:addCardTextToDinah
    local lines = {}

    -- 1. Card intro (random)
    local introOptions = {
        "Hmmmm... Hmmmm...\n(squints at the card)\nVery interesting…",
        "(looks at you with a raised eyebrow)",
        "Shh... listen closely.\nNo, closer.",
        "Patience. The universe loves a dramatic pause.",
        "We may glimpse the dawn… or another dark night of the soul. Let's see.",
        "(sighs) Well, every card is a mirror. Know thyself…\nif you dare to look.",
        "Let me peer through the veil… it's a bit wrinkled today.",
        "Ah, this one… I remember its dance with fate.",
    }
    table.insert(lines, introOptions[math.random(1, #introOptions)])

    -- 2. Card name and orientation
    local intro = "You pulled:\n" .. cardName .. (isInverted and "\nUpside down" or "")
    table.insert(lines, intro)

    -- 3. Correspondence
    local correspondence_data = cardInfo.correspondence
    if correspondence_data and #correspondence_data > 0 then
        for _, line in ipairs(correspondence_data) do
            table.insert(lines, line)
        end
    end

    -- 4. Keywords (random intro, random 3 keywords)
    local source_keywords_list
    if isInverted and cardInfo.reversed_keywords then
        source_keywords_list = cardInfo.reversed_keywords
    elseif cardInfo.upright_keywords then
        source_keywords_list = cardInfo.upright_keywords
    end

    local keywordIntroOptions = {
        "The spirits whisper... ",
        "The card's pulse summons forth: ",
        "The oracles of old murmur of: ",
        "From the sands of time, this card reveals: ",
        "This card hums with forgotten truths: ",
        "From the woven threads of fate, we find: ",
        "Here lies the essence unveiled: ",
        "Let these currents stir the soul: "
    }
    local keywordIntro = keywordIntroOptions[math.random(1, #keywordIntroOptions)]
    table.insert(lines, keywordIntro)

    local final_keywords_to_display = {}
    local num_keywords_to_select = 3
    if source_keywords_list and #source_keywords_list > 0 then
        local shuffled_list = self:shuffleTable(source_keywords_list)
        for i = 1, math.min(num_keywords_to_select, #shuffled_list) do
            table.insert(final_keywords_to_display, shuffled_list[i])
        end
        table.insert(lines, table.concat(final_keywords_to_display, ", ") .. ".")
    end

    -- 5. Fortune line (specific index for debug)
    local fortune_lines
    if isInverted and cardInfo.reversed_fortune then
        fortune_lines = cardInfo.reversed_fortune
    else
        fortune_lines = cardInfo.upright_fortune
    end
    -- Defensive: fallback if no fortunes
    if fortune_lines and #fortune_lines > 0 then
        table.insert(lines, fortune_lines[self.currentFortuneLineIndex])
    else
        table.insert(lines, "(No fortune lines for this card/orientation)")
    end

    -- 6. Last line
    table.insert(lines, "You can press A now darling, but I will not tell you what to do.")

    self.dinahText = lines
    self.currentTextLineIndex = 1
    self.isVariationComplete = false
    self.isDisplayingText = true
    self.aButton:remove()
    self.bButton:add()
end

function PostSceneDebug:showTextAtIndex(index)
    if self.dinahScrollText then
        self.dinahScrollText:remove()
    end

    if index > #self.dinahText then
        self.isVariationComplete = true
        self.isDisplayingText = false
        self.bButton:remove()
        self.aButton:add()
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

function PostSceneDebug:nextTextLine()
    self.currentTextLineIndex += 1
    self:showTextAtIndex(self.currentTextLineIndex)
end

function PostSceneDebug:moveToNextVariation()
    local cardName = self.allCardNames[self.currentCardIndex]
    local cardInfo = ALL_CARD_DATA[cardName]
    local fortune_lines
    if self.currentInvertedState and cardInfo.reversed_fortune then
        fortune_lines = cardInfo.reversed_fortune
    else
        fortune_lines = cardInfo.upright_fortune
    end
    local numFortuneLines = fortune_lines and #fortune_lines or 1

    -- Advance to next fortune line
    self.currentFortuneLineIndex += 1
    if self.currentFortuneLineIndex > numFortuneLines then
        self.currentFortuneLineIndex = 1
        -- Toggle upright/reversed
        if self.currentInvertedState then
            self.currentInvertedState = false
            self.currentCardIndex += 1
        else
            self.currentInvertedState = true
        end
    end

    -- If we've gone past the last card, finish
    if self.currentCardIndex > #self.allCardNames then
        print("--- ALL VARIATIONS TESTED ---")
        SCENE_MANAGER:switchScene(TitleScene.new())
        return
    end

    self:prepareCurrentVariation()
    self:showTextAtIndex(self.currentTextLineIndex)
end

function PostSceneDebug:shuffleTable(tbl)
    local size = #tbl
    for i = size, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end

function PostSceneDebug:dinahSpriteLoad()
    self.dinahSprite:addState("idle", 1, 6, {tickStep = 4, yoyo = true})
    self.dinahSprite:addState("transition", 1, 20, {tickStep = 1, loop = false})
    self.dinahSprite:moveTo(200,120)
    self.dinahSprite:add()
    self.dinahSprite:playAnimation()
end

function PostSceneDebug:scrollBoxCreate()
    self.scrollBoxSprite:moveTo(202, 170)
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

function PostSceneDebug:update()
    if pd.buttonJustPressed(pd.kButtonB) and self.isDisplayingText then
        self:nextTextLine()
    end

    if pd.buttonJustPressed(pd.kButtonA) and self.isVariationComplete then
        self:moveToNextVariation()
    end
end

function PostSceneDebug:deinit()
    if self.dinahSprite then self.dinahSprite:remove() end
    if self.scrollBoxSprite then self.scrollBoxSprite:remove() end
    if self.bButton then self.bButton:remove() end
    if self.aButton then self.aButton:remove() end
    if self.dinahScrollText then self.dinahScrollText:remove() end
    PostSceneDebug.super.deinit(self)
end