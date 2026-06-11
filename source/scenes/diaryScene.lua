local pd <const> = playdate
local gfx <const> = pd.graphics

import "data/save/playerProfileStore"

class('DiaryScene').extends(gfx.sprite)

function DiaryScene:init()
    DiaryScene.super.init(self)
    if not Sound.isSFXPlaying("pad_a") then
        Sound.playSFX("pad_a")
    end

    self.buttonUppress = false
    self.lockStartTimer = nil
    self.bgFrameSprite = nil
    self.bgSprite = nil
    self.bgKeySprite = nil
    self.lockSprite = nil

    -- Cached assets: one setup during fade-in (staggered timers caused audible hitches).
    self.bgSprite = AnimatedSprite.new(GameAssets.getDiaryAnimImagetable())
    self.bgSprite:addState("anim", 1, 7, {tickStep = 5, yoyo = true})
    self.bgSprite:moveTo(200, 120)
    self.bgSprite:setZIndex(0)
    self.bgSprite:add()
    self.bgSprite:playAnimation()

    self.bgFrameSprite = gfx.sprite.new(GameAssets.getJournalFramesImage())
    self.bgFrameSprite:moveTo(200, 120)
    self.bgFrameSprite:setZIndex(10)
    self.bgFrameSprite:add()

    self.lockSprite = AnimatedSprite.new(GameAssets.getLockMovImagetable())
    self.lockSprite:addState("move", 1, 11, {
        tickStep = 4.5,
        yoyo = false,
        loop = false,
        onAnimationEndEvent = function()
            self.lockSprite:changeState("pause")
        end
    })
    self.lockSprite:addState("pause", 12, 12, {
        tickStep = 72,
        yoyo = false,
        loop = false,
        onAnimationEndEvent = function()
            self.lockSprite:changeState("move")
        end
    })
    self.lockSprite:addState("still", 12, 12, {tickStep = 5, yoyo = false})
    self.lockSprite:moveTo(200, 120)
    self.lockSprite:setZIndex(8)
    self.lockSprite:add()

    self.bgKeySprite = AnimatedSprite.new(GameAssets.getMoonKeyImagetable())
    self.bgKeySprite:addState("idle", 1, 1, {tickStep = 5, yoyo = false})
    self.bgKeySprite:addState("anim", 1, 12, {
        tickStep = 2,
        yoyo = true,
        loop = 4,
        onAnimationEndEvent = function()
            self.bgKeySprite:changeState("idle")
            SCENE_MANAGER:switchScene(DiaryEntriesListScene)
        end
    })
    self.bgKeySprite:moveTo(200, 120)
    self.bgKeySprite:setZIndex(10)
    self.bgKeySprite:add()
    self.bgKeySprite:playAnimation("idle")

    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    self.diaryLabel = gfx.sprite.spriteWithText("This diary\n belongs to", 320, 80, nil, nil, nil, kTextAlignment.left)
    self.diaryLabel:setCenter(0, 0)
    self.diaryLabel:moveTo(40, 45)
    self.diaryLabel:setZIndex(20)
    self.diaryLabel:add()

    self.name = PlayerProfileStore.getName()
    self.diaryLine = gfx.sprite.spriteWithText(self.name, 120, 120, nil, nil, nil, kTextAlignment.center)
    self.diaryLine:setCenter(0, 0)
    self.diaryLine:moveTo(48, 120)
    self.diaryLine:setZIndex(20)
    self.diaryLine:add()
    gfx.setImageDrawMode(gfx.kDrawModeCopy)

    self.lockStartTimer = pd.timer.performAfterDelay(5000, function()
        self.lockStartTimer = nil
        if self.lockSprite then
            self.lockSprite:playAnimation("move")
        end
    end)

    self:add()
end

function DiaryScene:makeButtonSprite(letter, x, y, radius)
    local r = radius or 16
    local img = gfx.image.new(r * 2, r * 2)
    gfx.pushContext(img)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillCircleAtPoint(r, r, r)
        gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
        gfx.setLineWidth(2)
        gfx.drawCircleAtPoint(r, r, r)
        local font = gfx.getSystemFont()
        local w, h = gfx.getTextSize(letter, font)
        gfx.drawTextAligned(letter, r - w / 2, r - h / 2, kTextAlignment.left)
    gfx.popContext()
    local sprite = gfx.sprite.new(img)
    sprite:moveTo(x, y)
    sprite:add()
    return sprite
end

function DiaryScene:update()
    if pd.buttonJustPressed(pd.kButtonA) and self.buttonUppress == false then
        self.buttonUppress = true
        if self.lockSprite then
            self.lockSprite:changeState("still")
        end
        if self.bgKeySprite then
            self.bgKeySprite:changeState("anim")
            Sound.playSFX("unlocking")
        end
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        Sound.playSFX("b_button")
        Sound.playSFX("cards_fast2")
        SCENE_MANAGER:switchScene(AfterDialogueScene)
    end
end

function DiaryScene:deinit()
    if self.lockStartTimer then
        self.lockStartTimer:remove()
        self.lockStartTimer = nil
    end

    if self.bgSprite then self.bgSprite:remove() self.bgSprite = nil end
    if self.diaryLabel then self.diaryLabel:remove() self.diaryLabel = nil end
    if self.diaryLine then self.diaryLine:remove() self.diaryLine = nil end
    if self.interactButton then self.interactButton:remove() self.interactButton = nil end
    if self.blinkerTimer then self.blinkerTimer:remove() self.blinkerTimer = nil end
    if self.bgFrameSprite then self.bgFrameSprite:remove() self.bgFrameSprite = nil end
    if self.bgKeySprite then self.bgKeySprite:remove() self.bgKeySprite = nil end
    if self.lockSprite then self.lockSprite:remove() self.lockSprite = nil end
    self.buttonUppress = false

    if DiaryScene.super and DiaryScene.super.deinit then
        DiaryScene.super.deinit(self)
    end
end
