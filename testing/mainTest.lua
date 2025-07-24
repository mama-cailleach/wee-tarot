-- You can copy and paste this example directly as your main.lua file to see it in action
import "CoreLibs/graphics"
import "CoreLibs/animator"


local pd <const> = playdate
local gfx <const> = pd.graphics

-- We'll be demonstrating how to use an animator to animate a square moving across the screen
local square = playdate.graphics.image.new(20, 20, playdate.graphics.kColorBlack)

-- 1000ms, or 1 second
local animationDuration = 2000
-- We're animating from the left to the right of the screen
local startX, endX = -20, 400
-- Setting an easing function to get a nice, smooth movement
local easingFunction = playdate.easingFunctions.inOutCubic
local animator = playdate.graphics.animator.new(animationDuration, startX, endX, easingFunction)
animator.repeatCount = -1 -- Make animator repeat forever


scrollBoxImg = gfx.image.new("images/textScroll/scroll1b")
scrollBoxSprite = gfx.sprite.new(scrollBoxImg)
scrollBoxSprite:moveTo(-20, 120)
scrollBoxSprite:add()

function playdate.update()
    -- Clear the screen
    playdate.graphics.clear()

    -- By using :currentValue() as the x value, the square follows along with the animation
    square:draw(200, animator:currentValue())

    scrollBoxSprite:moveTo(animator:currentValue(), 120)
end