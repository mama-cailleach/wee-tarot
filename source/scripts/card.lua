local pd <const> = playdate
local gfx <const> = pd.graphics

class("Card").extends(gfx.sprite)

function Card:init(cardNumber, cardSuit)
    local suitName = {"cups", "wands", "swords", "pentacles", "majorArcana"}
    local suitFolder = suitName[cardSuit]
    local cardImage = gfx.image.new("images/" .. suitFolder .. "/" .. cardNumber)
    self:setImage(cardImage)
    self:moveTo(300, 120)
    self:setScale(1.5)
    self.inverted = false
    self:upsideDown(self)
    self:add()
end

function Card:update()

end


function Card:upsideDown(drawed)
    local chance = math.random()
    if chance >= 0.51 then
        drawed:setRotation(180)
        self.inverted = true
    end
end