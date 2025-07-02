local pd <const> = playdate
local gfx <const> = playdate.graphics



class('AfterDialogueScene').extends(gfx.sprite)


function AfterDialogueScene:init()
    AfterDialogueScene.super.init(self)

    -- scene variables
    self.imagetable = gfx.imagetable.new("images/bg/dinahBG-table-400-266")
    self.dinahSprite = AnimatedSprite.new(self.imagetable)
    self.aButton = nil
    self.aButtonBlinkTimer = nil
    self.scrollBoxAnimatorIn = nil
    self:dinahSpriteLoad()
    self:optionsText()
    self.optionsTextOn = true

    self:add()
end


function AfterDialogueScene:dinahSpriteLoad()
    self.dinahSprite:addState("idle", 1, 6, {tickStep = 4, yoyo = true})
    self.dinahSprite:addState("transition", 1, 17, {tickStep = 1, loop = false})
    self.dinahSprite:moveTo(200,120)
    self.dinahSprite:add()
    self.dinahSprite:playAnimation()
end

function AfterDialogueScene:makeButtonSprite(letter, x, y, radius)
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

function AfterDialogueScene:optionsText()
    gfx.setImageDrawMode(gfx.kDrawModeInverted)
    -- Remove old sprites if they exist
    if self.settingsText then self.settingsText:remove() end
    if self.interactText then self.interactText:remove() end



    -- Use the typewriter utility for both texts
    self.settingsText = utils.PromptTextTypewriterOneWay(
        "menu",
        35, 203,   -- x, y
        80        -- delayPerChar
    )
    self.interactText = utils.PromptTextTypewriterOneWay(
        "reading",
        282, 203,  -- x, y
        80        -- delayPerChar
    )
    
    self.settingsButton = self:makeButtonSprite("B", 16, 222, 14)
    self.interactButton = self:makeButtonSprite("A", 384, 222, 14)

end

function AfterDialogueScene:loadGameAnimation()
    self.dinahSprite.states["transition"].onAnimationEndEvent = function ()
        SCENE_MANAGER:switchScene(GameScene)
    end
end

function AfterDialogueScene:update()

    if self.optionsTextOn then
        -- Only allow A/B for options after text is gone
        if pd.buttonJustPressed(pd.kButtonB) then
            SCENE_MANAGER:switchScene(SettingsScene)
        end
        if pd.buttonJustPressed(pd.kButtonA) then
            self:loadGameAnimation()
            self.dinahSprite:changeState("transition")
        end
    end
end



