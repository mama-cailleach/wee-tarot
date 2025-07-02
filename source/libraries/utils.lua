local pd <const> = playdate
local gfx <const> = pd.graphics

utils = {}

function createTextWithBackground(text, textColor, backgroundColor, paddingX, paddingY)
    local font = gfx.getSystemFont()
    local textWidth, textHeight = gfx.getTextSize(text, font)

    local backgroundWidth = textWidth + 2 * paddingX
    local backgroundHeight = textHeight + 1 * paddingY

    local image = gfx.image.new(backgroundWidth, backgroundHeight)

    gfx.pushContext(image)
        -- 1. Draw the background rectangle
        gfx.setColor(backgroundColor)
        gfx.fillRect(0, 0, backgroundWidth, backgroundHeight)

        -- 2. Draw the text on top
        gfx.drawText(text, paddingX, paddingY)
    gfx.popContext()

    return image
end


-- max string lenght for big scroll
-- "hello hello dear friends this is"


--[[
EXAMPLE FOR USING THIS
local myText = "Hello!"
local whiteColor = gfx.kColorWhite
local blackColor = gfx.kColorBlack
local paddingHorizontal = 5
local paddingVertical = 3

local textWithBackground = createTextWithBackground(myText, whiteColor, blackColor, paddingHorizontal, paddingVertical)

local textSprite = gfx.sprite.new(textWithBackground)
textSprite:moveTo(50, 50)
textSprite:add()

]]



-- type writer style boomerang text

function utils.PromptTextTypewriterBoomerang(text, x, y, delayPerChar, visibleTime, fadeOutTime)
    local width, height = gfx.getTextSize(text)
    if width == 0 or height == 0 then width, height = 10, 10 end

    local promptSprite = gfx.sprite.new()
    promptSprite:setCenter(0, 0)
    promptSprite:moveTo(x or 8, y or 8)
    promptSprite:add()

    local currentLength = 0
    local function updateText()
        currentLength += 1
        local shownText = string.sub(text, 1, currentLength)
        local textImage = gfx.image.new(width, height)
        gfx.pushContext(textImage)
            gfx.setColor(gfx.kColorWhite)
            gfx.drawTextAligned(shownText, 0, 0, kTextAlignment.left)
        gfx.popContext()
        promptSprite:setImage(textImage)
    end

    local typeTimer
    typeTimer = pd.timer.keyRepeatTimerWithDelay(delayPerChar or 40, delayPerChar or 40, function()
        if currentLength < #text then
            updateText()
        else
            typeTimer:remove()
            pd.timer.performAfterDelay(visibleTime or 1200, function()
                local removeLength = #text
                local function updateRemoveText()
                    removeLength -= 1
                    local shownText = string.sub(text, 1, removeLength)
                    local textImage = gfx.image.new(width, height)
                    gfx.pushContext(textImage)
                        gfx.setColor(gfx.kColorWhite)
                        gfx.drawTextAligned(shownText, 0, 0, kTextAlignment.left)
                    gfx.popContext()
                    promptSprite:setImage(textImage)
                end

                local removeTimer
                removeTimer = pd.timer.keyRepeatTimerWithDelay(fadeOutTime or delayPerChar or 40, fadeOutTime or delayPerChar or 40, function()
                    if removeLength > 0 then
                        updateRemoveText()
                    else
                        removeTimer:remove()
                        promptSprite:remove()
                    end
                end)
            end)
        end
    end)

    updateText()
    return promptSprite
end




function utils.PromptTextTypewriterOneWay(text, x, y, delayPerChar)
    local font = gfx.getSystemFont()
    local width, height = gfx.getTextSize(text, font)
    if width == 0 or height == 0 then width, height = 10, 10 end

    local promptSprite = gfx.sprite.new()
    promptSprite:setCenter(0, 0)
    promptSprite:moveTo(x or 8, y or 8)
    promptSprite:add()

    local currentLength = 0
    local function updateText()
        currentLength += 1
        local shownText = string.sub(text, 1, currentLength)
        local textImage = gfx.image.new(width, height)
        gfx.pushContext(textImage)
            gfx.setColor(gfx.kColorWhite)
            gfx.drawTextAligned(shownText, 0, 0, kTextAlignment.left)
        gfx.popContext()
        promptSprite:setImage(textImage)
    end

    local typeTimer -- declare first!
    typeTimer = pd.timer.keyRepeatTimerWithDelay(delayPerChar or 40, delayPerChar or 40, function()
        if currentLength < #text then
            updateText()
        else
            typeTimer:remove()
            -- After full text is shown, wait, then fade out (hide)
        end
    end)

    -- Show the first character immediately
    updateText()

    return promptSprite
end

return utils


--[[
example

call this at the top of the scene
local utilities = import "libraries/utils"

then use 
utilities.PromptTextTypewriterBoomerang("Hello!", 20, 4, 40, 2000)








]]