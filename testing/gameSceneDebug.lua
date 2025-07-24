import "scripts/deck"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('GameSceneDebug').extends(gfx.sprite)

function GameSceneDebug:init()
    -- Background
    local bgImage = gfx.image.new("images/bg/tarot_playspace")
    local bgSprite = gfx.sprite.new(bgImage)
    bgSprite:moveTo(200, 120)
    bgSprite:add()

    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)

    -- Card placement background
    self.cardPlacementSprite = gfx.sprite.new(gfx.image.new("images/decknback/placementzone_diamond"))
    self.cardPlacementSprite:setScale(1.5)
    self.cardPlacementSprite:moveTo(300, 120)
    self.cardPlacementSprite:add()

    -- Initialize debug state
    self.currentSuit = 1  -- 1=Cups, 2=Wands, 3=Swords, 4=Pentacles, 5=Major Arcana
    self.currentCardNumber = 1
    self.maxCardsPerSuit = {14, 14, 14, 14, 22}  -- Cups, Wands, Swords, Pentacles, Major Arcana
    self.suitNames = {"Cups", "Wands", "Swords", "Pentacles", "Major Arcana"}
    
    self.drawnCardVisual = nil
    self.isComplete = false

    -- Show initial prompt
    self:showDebugPrompt()
    self:showCurrentCard()

    self:add()
end

function GameSceneDebug:showDebugPrompt()
    if self.promptSprite then self.promptSprite:remove() end
    
    local promptText
    if self.isComplete then
        promptText = "Debug Complete!\nAll cards shown.\nPress B to exit."
    else
        promptText = string.format("Debug Mode\n%s %d/%d\nPress A for next\nPress B to reset", 
            self.suitNames[self.currentSuit], 
            self.currentCardNumber, 
            self.maxCardsPerSuit[self.currentSuit])
    end
    
    local width, height = gfx.getTextSize(promptText)
    if width == 0 or height == 0 then width, height = 10, 10 end
    
    local textImage = gfx.image.new(width, height)
    gfx.pushContext(textImage)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawTextAligned(promptText, 0, 0, kTextAlignment.left)
    gfx.popContext()
    
    self.promptSprite = gfx.sprite.new(textImage)
    self.promptSprite:setCenter(0, 0)
    self.promptSprite:moveTo(8, 8)
    self.promptSprite:add()
end

function GameSceneDebug:showCurrentCard()
    if self.isComplete then return end
    
    -- Remove previous card
    if self.drawnCardVisual then
        self.drawnCardVisual:remove()
        self.drawnCardVisual = nil
    end
    
    -- Create new card
    self.drawnCardVisual = Card(self.currentCardNumber, self.currentSuit)
    -- Don't let the card randomly invert itself in debug mode
    self.drawnCardVisual.inverted = false
    self.drawnCardVisual:setRotation(0)
end

function GameSceneDebug:nextCard()
    if self.isComplete then return end
    
    -- Move to next card
    self.currentCardNumber = self.currentCardNumber + 1
    
    -- Check if we've reached the end of current suit
    if self.currentCardNumber > self.maxCardsPerSuit[self.currentSuit] then
        -- Move to next suit
        self.currentSuit = self.currentSuit + 1
        self.currentCardNumber = 1
        
        -- Check if we've gone through all suits
        if self.currentSuit > #self.maxCardsPerSuit then
            self.isComplete = true
            if self.drawnCardVisual then
                self.drawnCardVisual:remove()
                self.drawnCardVisual = nil
            end
            self:showDebugPrompt()
            return
        end
    end
    
    -- Show the next card
    self:showCurrentCard()
    self:showDebugPrompt()
end

function GameSceneDebug:update()
    gfx.sprite.update()

    if pd.buttonJustPressed(pd.kButtonA) then
        if not self.isComplete then
            self:nextCard()
        end
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        -- Exit debug scene (you can change this to go to MenuScene or wherever)
        SCENE_MANAGER:switchScene(GameSceneDebug)
    end
end

function GameSceneDebug:deinit()
    if self.promptSprite then self.promptSprite:remove() end
    if self.cardPlacementSprite then self.cardPlacementSprite:remove() end
    if self.drawnCardVisual then self.drawnCardVisual:remove() end
    GameSceneDebug.super.deinit(self)
end