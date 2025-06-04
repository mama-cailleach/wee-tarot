local pd <const> = playdate
local gfx <const> = pd.graphics

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