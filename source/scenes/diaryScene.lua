local pd <const> = playdate
local gfx <const> = pd.graphics

import "data/save/playerProfileStore"

class('DiaryScene').extends(gfx.sprite)

function DiaryScene:init()
    DiaryScene.super.init(self)

    self.bgImage = gfx.image.new("images/bg/journal6")
    self.bgSprite = gfx.sprite.new(self.bgImage)
    self.bgSprite:moveTo(200, 120)
    self.bgSprite:add()

    self.diaryLabel = gfx.sprite.spriteWithText("This diary\n belongs to", 320, 80, nil, nil, nil, kTextAlignment.left)
    self.diaryLabel:setCenter(0, 0)
    self.diaryLabel:moveTo(40, 45)
    self.diaryLabel:add()

    self.name = PlayerProfileStore.getName()

    self.diaryLine = gfx.sprite.spriteWithText(self.name, 120, 120, nil, nil, nil, kTextAlignment.center)
    self.diaryLine:setCenter(0, 0)
    self.diaryLine:moveTo(48, 120)
    self.diaryLine:add()

    --[[
    gfx.setImageDrawMode(gfx.kDrawModeXOR)
    self.startText = gfx.sprite.spriteWithText("A", 400, 40, nil, nil, nil, kTextAlignment.center)  
    self.startText:moveTo(365, 120)
    self.startText:setZIndex(10)
    self.startText:add()
    
    self.blinkTime = 800
    --blink text logic 
    self.blinkerTimer = pd.timer.new(self.blinkTime, function()
        self.startText:setVisible(not self.startText:isVisible())
    end)
    self.blinkerTimer.repeats = true
    
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    ]]

    self.interactButton = self:makeButtonSprite("A", 297, 122, 24)
        
    self.blinkTime = 800
    --blink text logic 
    self.blinkerTimer = pd.timer.new(self.blinkTime, function()
        self.interactButton:setVisible(not self.interactButton:isVisible())
    end)
    self.blinkerTimer.repeats = true

    self:add()
end

function DiaryScene:makeButtonSprite(letter, x, y, radius)
    local r = radius or 16
    local img = gfx.image.new(r*2, r*2)
    gfx.pushContext(img)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillCircleAtPoint(r, r, r)
        gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
        gfx.setLineWidth(2)
        gfx.drawCircleAtPoint(r, r, r)
        local font = gfx.getSystemFont()
        local w, h = gfx.getTextSize(letter, font)
        gfx.drawTextAligned(letter, r - w/2, r - h/2, kTextAlignment.left)
    gfx.popContext()
    local sprite = gfx.sprite.new(img)
    sprite:moveTo(x, y)
    sprite:add()
    return sprite
end


function DiaryScene:update()

    if pd.buttonJustPressed(pd.kButtonA) then
        Sound.playSFX("cards_fast2")
        self.interactButton:remove()
        SCENE_MANAGER:switchScene(DiaryEntriesListScene)
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        Sound.playSFX("cards_slow2")
        self.interactButton:remove()
        SCENE_MANAGER:switchScene(AfterDialogueScene)
    end

end

function DiaryScene:deinit()
    if self.bgSprite then self.bgSprite:remove() self.bgSprite = nil end
    if self.diaryLabel then self.diaryLabel:remove() self.diaryLabel = nil end
    if self.diaryLine then self.diaryLine:remove() self.diaryLine = nil end
    if self.interactButton then self.interactButton:remove() self.interactButton = nil end
    if self.blinkerTimer then self.blinkerTimer:remove() self.blinkerTimer = nil end

end
