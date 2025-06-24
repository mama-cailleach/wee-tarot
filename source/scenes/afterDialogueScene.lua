--import "libraries/AnimatedSprite"

local pd <const> = playdate
local gfx <const> = playdate.graphics

class('afterDialogueScene').extends(gfx.sprite)


function afterDialogueScene:init()
    afterDialogueScene.super.init(self)

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


function afterDialogueScene:dinahSpriteLoad()
    self.dinahSprite:addState("idle", 1, 6, {tickStep = 4, yoyo = true})
    self.dinahSprite:addState("transition", 1, 17, {tickStep = 1, loop = false})
    self.dinahSprite:moveTo(200,120)
    self.dinahSprite:add()
    self.dinahSprite:playAnimation()
end



function afterDialogueScene:optionsText()
    gfx.setImageDrawMode(gfx.kDrawModeInverted)
    self.settingsText = gfx.sprite.spriteWithText("first time? B", 400, 120, nil, nil, nil, kTextAlignment.left)
    self.settingsText:moveTo(75, 220)
    self.settingsText:add()
    self.interactText = gfx.sprite.spriteWithText("reading? A", 400, 120, nil, nil, nil, kTextAlignment.right)
    self.interactText:moveTo(333, 220)
    self.interactText:add()
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
end

function afterDialogueScene:loadGameAnimation()
    self.dinahSprite.states["transition"].onAnimationEndEvent = function ()
        SCENE_MANAGER:switchScene(GameScene)
    end
end

function afterDialogueScene:update()

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



