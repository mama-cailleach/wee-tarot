local pd <const> = playdate
local gfx <const> = pd.graphics

import "data/save/playerProfileStore"

class('DiaryScene').extends(gfx.sprite)

function DiaryScene:init()
    DiaryScene.super.init(self)
    Sound.playSFX("pad_a")

    self.buttonUppress = false


    self.bgFrameImage = gfx.image.new("images/bg/journal_frames2")
    self.bgFrameSprite = gfx.sprite.new(self.bgFrameImage)
    self.bgFrameSprite:moveTo(200, 120)
    self.bgFrameSprite:setZIndex(10)
    self.bgFrameSprite:add()

    --[[
    self.bgKeyImage = gfx.image.new("images/bg/moonkey")
    self.bgKeySprite = gfx.sprite.new(self.bgKeyImage)
    self.bgKeySprite:moveTo(200, 120)
    self.bgKeySprite:setZIndex(11)
    self.bgKeySprite:add()]]

    self.keyImagetable = gfx.imagetable.new("images/bg/moonkey-table-400-273")
    self.bgKeySprite = AnimatedSprite.new(self.keyImagetable)
    self.bgKeySprite:addState("idle", 1, 1, {tickStep = 5, yoyo = false})
    self.bgKeySprite:addState("anim", 1, 12, {tickStep = 2, yoyo = true, loop = 4, onAnimationEndEvent = function() self.bgKeySprite:changeState("idle") SCENE_MANAGER:switchScene(DiaryEntriesListScene) end})
    self.bgKeySprite:moveTo(200,120)
    self.bgKeySprite:setZIndex(10)
    self.bgKeySprite:add()
    self.bgKeySprite:playAnimation("idle")


    self.imagetable = gfx.imagetable.new("images/bg/diary_anim-table-400-273")
    self.bgSprite = AnimatedSprite.new(self.imagetable)
    self.bgSprite:addState("anim", 1, 7, {tickStep = 5, yoyo = true})
    self.bgSprite:moveTo(200,120)
    self.bgSprite:setZIndex(0)
    self.bgSprite:add()
    self.bgSprite:playAnimation()

    self.lockSpriteSheet = gfx.imagetable.new("images/bg/lock_mov-table-400-273")
    self.lockSprite = AnimatedSprite.new(self.lockSpriteSheet)
    self.lockSprite:addState("move", 1, 11, {tickStep = 4.5, yoyo = false, loop = false, onAnimationEndEvent = function() self.lockSprite:changeState("pause") end})
    self.lockSprite:addState("pause", 12, 12, {tickStep = 72, yoyo = false, loop = false, onAnimationEndEvent = function() self.lockSprite:changeState("move") end})
    self.lockSprite:addState("still", 12, 12, {tickStep = 5, yoyo = false})
    self.lockSprite:moveTo(200, 120)
    self.lockSprite:setZIndex(8)
    self.lockSprite:add()
    pd.timer.performAfterDelay(5000, function() self.lockSprite:playAnimation("move") end)

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

    -- A on the lock

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
    

    -- Circle A

    self.interactButton = self:makeButtonSprite("A", 297, 122, 25)
        
    self.blinkTime = 800
    --blink text logic 
    self.blinkerTimer = pd.timer.new(self.blinkTime, function()
        self.interactButton:setVisible(not self.interactButton:isVisible())
    end)
    self.blinkerTimer.repeats = true
    ]]

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

    if pd.buttonJustPressed(pd.kButtonA) and self.buttonUppress == false then
        self.buttonUppress = true
        self.lockSprite:changeState("still")
        self.bgKeySprite:changeState("anim")
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        Sound.playSFX("b_button")
        --self.interactButton:remove()
        SCENE_MANAGER:switchScene(AfterDialogueScene)
    end

end

function DiaryScene:deinit()
    if self.bgSprite then self.bgSprite:remove() self.bgSprite = nil end
    if self.diaryLabel then self.diaryLabel:remove() self.diaryLabel = nil end
    if self.diaryLine then self.diaryLine:remove() self.diaryLine = nil end
    if self.interactButton then self.interactButton:remove() self.interactButton = nil end
    if self.blinkerTimer then self.blinkerTimer:remove() self.blinkerTimer = nil end
    if self.bgFrameSprite then self.bgFrameSprite:remove() self.bgFrameSprite = nil end
    if self.bgKeySprite then self.bgKeySprite:remove() self.bgKeySprite = nil end
    if self.lockSprite then self.lockSprite:remove() self.lockSprite = nil end
    self.buttonUppress = false

end
