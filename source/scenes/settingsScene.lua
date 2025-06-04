local pd <const> = playdate
local gfx <const> = playdate.graphics

class('SettingsScene').extends(gfx.sprite)


function SettingsScene:init()
    self.bgImage = gfx.image.new("images/bg/dinah01")
    self.bgSprite = gfx.sprite.new(self.bgImage)
    self.bgSprite:moveTo(200,120)
    self.bgSprite:add()

    self.cardPlacementSprite = gfx.sprite.new(gfx.image.new("images/decknback/placementzone_diamond"))
    self.cardPlacementSprite:setScale(1.9, 1.6)
    self.cardPlacementSprite:moveTo(200, 120)
    self.cardPlacementSprite:add()

    self.blankCardImage = gfx.image.new("images/decknback/empty2")
    self.blankCardSprite = gfx.sprite.new(self.blankCardImage)
    self.blankCardSprite:moveTo(200,120)
    self.blankCardSprite:setScale(1.9, 1.6)
    self.blankCardSprite:add()

    self.arrowImage = gfx.image.new("images/decknback/deck_crest")
    self.arrowSprite = gfx.sprite.new(self.arrowImage)
    self.arrowSprite:moveTo(150,70)
    self.arrowSprite:setScale(0.2)
    self.arrowSprite:add()
    
    gfx.setImageDrawMode(gfx.kDrawModeXOR) -- for text color

    self.titleText = gfx.sprite.spriteWithText("SETTINGS", 400, 200, nil, nil, nil, kTextAlignment.center)  
    self.titleText:moveTo(200, 32)
    self.titleText:setScale(1)
    self.titleText:add()

    self:addButton("Deck", 200, 70)
    self:addButton("SFX", 200, 110)
    self:addButton("Music", 200, 150)
    self:addButton("Cloth", 200, 190)

    gfx.setImageDrawMode(gfx.kDrawModeXOR)
    self:addButton("Change: A", 65, 220)
    self:addButton("Back: B", 350, 220)


    
    self:add()
end




function SettingsScene:update()
    if pd.buttonJustPressed(pd.kButtonB) then
        SCENE_MANAGER:switchScene(MenuScene)
    end

    local topY = 70
    local bottomY = 190
    local step = 40

    if pd.buttonJustPressed(pd.kButtonDown) then
        if self.arrowSprite.y < bottomY then
            self.arrowSprite:moveBy(0, step)
        end
    elseif pd.buttonJustPressed(pd.kButtonUp) then  
        if self.arrowSprite.y > topY then
            self.arrowSprite:moveBy(0, -step)
        end
    end
end

function SettingsScene:textOut()
    self.titleText:remove()
    
end

function SettingsScene:addButton(text, x, y)
    local buttonText = gfx.sprite.spriteWithText(text, 400, 200, nil, nil, nil, kTextAlignment.center)
    buttonText:moveTo(x, y)
    buttonText:add()
    
    self:add(buttonText)
end
