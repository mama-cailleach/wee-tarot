import "scenes/spreads/baseSpreadGameScene"
import "libraries/AnimatedSprite"

local pd <const> = playdate
local gfx <const> = pd.graphics

local PREVIEW_ANIMATIONS = {
    {
        name = "card_spin_slide",
        path = "images/shuffleAnimation/card_spin_slide-table-400-240",
        x = 208,
        y = 125
    },
    {
        name = "explode_finale",
        path = "images/shuffleAnimation/explode_finale-table-400-240",
        x = 208,
        y = 125
    },
    {
        name = "exploding_deck1",
        path = "images/shuffleAnimation/exploding_deck1-table-400-240",
        x = 208,
        y = 125
    },
    {
        name = "exploding_deck2",
        path = "images/shuffleAnimation/exploding_deck2-table-400-240",
        x = 208,
        y = 125
    },
    {
        name = "final_full_deck",
        path = "images/shuffleAnimation/final_full_deck-table-400-240",
        x = 208,
        y = 125
    },
    {
        name = "deck_laying_full",
        path = "images/shuffleAnimation/deck_laying_full-table-400-240",
        x = 200,
        y = 120
    },
        {
        name = "deck_laying_full_lower",
        path = "images/shuffleAnimation/deck_laying_full_lower-table-400-240",
        x = 200,
        y = 120
    }
}

local SHUFFLE_TEST_CONFIG = {
    cardCount = 1,
    cardPositions = {
        { x = 200, y = 120 }
    },
    selectedCardPositions = {
        { x = 200, y = 120 }
    },
    zoomCardPositions = {
        { x = 200, y = 120 }
    },
    defaultScale = 1,
    selectedScale = 1,
    zoomScale = 1,
    revealDelay = 1,
    enableCardDimming = false,
    dimNonSelectedWhenZoomed = false,
    firstPromptRepeatMin = 999999,
    firstPromptRepeatMax = 999999,
    firstPromptVisibleTime = 1,
    firstPromptFadeOutTime = 1,
    promptText = ""
}

class('ShuffleAnimationTestScene').extends(BaseSpreadGameScene)

function ShuffleAnimationTestScene:init(startIndex)
    self.startIndex = math.max(1, startIndex or 1)
    ShuffleAnimationTestScene.super.init(self, SHUFFLE_TEST_CONFIG)

    self.previewIndex = self.startIndex
    self.previewAnimSprite = nil
    self.statusSprite = nil
    self.previewRunning = false

    self:showStatus()
end

function ShuffleAnimationTestScene:showFirstPrompt()
end

function ShuffleAnimationTestScene:showStatus(text)
    local message = text or self:getStatusText()

    if self.statusSprite then
        self.statusSprite:remove()
        self.statusSprite = nil
    end

    local width, height = gfx.getTextSize(message)
    if width == 0 or height == 0 then
        width, height = 10, 10
    end

    local statusImage = gfx.image.new(width, height)
    gfx.pushContext(statusImage)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawTextAligned(message, 0, 0, kTextAlignment.left)
    gfx.popContext()

    self.statusSprite = gfx.sprite.new(statusImage)
    self.statusSprite:setCenter(0, 0)
    self.statusSprite:moveTo(8, 8)
    self.statusSprite:setZIndex(1000)
    self.statusSprite:add()

    print("Status: " .. message)
end

function ShuffleAnimationTestScene:getStatusText()
    local animation = PREVIEW_ANIMATIONS[self.previewIndex]
    if not animation then
        return "No preview animations configured."
    end

    return "Crank to shuffle the idle frame.\nA to preview: " .. animation.name .. "\nPreview " .. self.previewIndex .. " of " .. #PREVIEW_ANIMATIONS
end

function ShuffleAnimationTestScene:startPreviewAnimation()
    if self.previewRunning then return end

    local animation = PREVIEW_ANIMATIONS[self.previewIndex]
    if not animation then
        self:showStatus("No preview animations configured.")
        return
    end

    self.previewRunning = true
    self:showStatus("Playing: " .. animation.name)

    if self.crankInactivityTimer then
        self.crankInactivityTimer:remove()
        self.crankInactivityTimer = nil
    end

    if self.crankSoundPlaying then
        Sound.stopCrankLoop()
        self.crankSoundPlaying = false
    end

    if self.shuffleAnimSprite then
        self.shuffleAnimSprite:remove()
        self.shuffleAnimSprite = nil
    end

    local imagetable = gfx.imagetable.new(animation.path)
    if not imagetable then
        self.previewRunning = false
        self:showStatus("Missing animation asset: " .. animation.name)
        return
    end

    if self.previewAnimSprite then
        self.previewAnimSprite:remove()
        self.previewAnimSprite = nil
    end

    self.previewAnimSprite = AnimatedSprite.new(imagetable)
    self.previewAnimSprite:addState("play", 1, imagetable:getLength(), {
        tickStep = 1,
        loop = true,
        yoyo = true,
        onAnimationEndEvent = function()
            if self.previewAnimSprite then
                self.previewAnimSprite:remove()
                self.previewAnimSprite = nil
            end

            local nextIndex = self.previewIndex + 1
            if nextIndex > #PREVIEW_ANIMATIONS then
                nextIndex = 1
            end

            SCENE_MANAGER:switchScene(ShuffleAnimationTestScene, nextIndex)
        end
    }, true)
    self.previewAnimSprite:moveTo(animation.x or 200, animation.y or 120)
    self.previewAnimSprite:add()
    self.previewAnimSprite:playAnimation()
end

function ShuffleAnimationTestScene:update()
    gfx.sprite.update()

    if pd.buttonJustPressed(pd.kButtonA) then
        self:startPreviewAnimation()
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        if self.previewAnimSprite then
            self.previewAnimSprite:remove()
            self.previewAnimSprite = nil
        end

        local nextIndex = self.previewIndex + 1
        if nextIndex > #PREVIEW_ANIMATIONS then
            nextIndex = 1
        end

        SCENE_MANAGER:switchScene(ShuffleAnimationTestScene, nextIndex)
    end

    if self.state == "shuffle" and self.shuffleAnimSprite and not self.previewRunning then
        local crankChange = pd.getCrankChange()
        if crankChange ~= 0 then
            self.shuffleFrame = ((self.shuffleFrame - 1 + math.floor(crankChange / 7)) % self.shuffleFrameCount) + 1
            self.shuffleAnimSprite:setFrame(self.shuffleFrame)

            if not self.crankSoundPlaying then
                Sound.startCrankLoop()
                self.crankSoundPlaying = true
            end

            if self.crankInactivityTimer then
                self.crankInactivityTimer:remove()
                self.crankInactivityTimer = nil
            end

            local scene = self
            self.crankInactivityTimer = pd.timer.performAfterDelay(100, function()
                if scene.crankSoundPlaying then
                    Sound.stopCrankLoop()
                    scene.crankSoundPlaying = false
                end
                scene.crankInactivityTimer = nil
            end)
        end
    end
end

function ShuffleAnimationTestScene:deinit()
    if self.previewAnimSprite then self.previewAnimSprite:remove() self.previewAnimSprite = nil end
    if self.statusSprite then self.statusSprite:remove() self.statusSprite = nil end
    ShuffleAnimationTestScene.super.deinit(self)
end