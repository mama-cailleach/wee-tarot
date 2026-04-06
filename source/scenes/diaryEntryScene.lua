local pd <const> = playdate
local gfx <const> = pd.graphics

import "data/save/playerProfileStore"

class('DiaryEntryScene').extends(gfx.sprite)

function DiaryEntryScene:init(entry, returnIndex)
    DiaryEntryScene.super.init(self)

    self.entry = entry or {}
    self.returnIndex = returnIndex or 1

    self.bgImage = gfx.image.new("images/bg/journal1")
    self.bgSprite = gfx.sprite.new(self.bgImage)
    self.bgSprite:moveTo(200, 120)
    self.bgSprite:add()

    self.headerSprite = nil
    self.bodySprite = nil
    self.cardPlacementSprite = nil
    self.cardSprite = nil
    self.cardFallbackSprite = nil
    self.cardNameSprite = nil
    self.arrowLeft = nil
    self.arrowRight = nil

    self.viewX = 220
    self.viewY = 2
    self.viewWidth = 170
    self.viewHeight = 228

    self.cardCenterX = 95
    self.cardCenterY = 160
    self.selectedCardIndex = 1
    self.selectedScale = 1.0
    self.zoomScale = 1.725
    self.zoomY = 120
    self.currentCardScale = self.selectedScale
    self.suitFolders = { "cups", "wands", "swords", "pentacles", "majorArcana" }

    self.scrollY = 0
    self.maxScroll = 0
    self.scrollStep = 14
    self.ticksPerRevolution = 30

    self:renderCardPlacement()

    self:renderHeader()
    self:renderBody()
    self:renderSelectedCard()

    self:add()
end

function DiaryEntryScene:buildArrows()
    self.arrowRight = gfx.sprite.spriteWithText("®", 40, 40, nil, nil, nil, kTextAlignment.center)
    self.arrowRight:setRotation(90)
    self.arrowRight:moveTo(self.cardCenterX + 70, self.cardCenterY)
    self.arrowRight:add()
    self.arrowLeft = gfx.sprite.spriteWithText("®", 40, 40, nil, nil, nil, kTextAlignment.center)
    self.arrowLeft:setRotation(270)
    self.arrowLeft:moveTo(self.cardCenterX - 70, self.cardCenterY)
    self.arrowLeft:add()
end

function DiaryEntryScene:animateArrowLeft()
    if not self.arrowLeft then return end
    local pointLeft1 = playdate.geometry.point.new(self.cardCenterX - 70, self.arrowLeft.y)
    local pointLeft2 = playdate.geometry.point.new(self.cardCenterX - 80, self.arrowLeft.y)
    local animatorLeft = gfx.animator.new(250, pointLeft2, pointLeft1, playdate.easingFunctions.outCubic)
    self.arrowLeft:setAnimator(animatorLeft)
end

function DiaryEntryScene:animateArrowRight()
    if not self.arrowRight then return end
    local pointRight1 = playdate.geometry.point.new(self.cardCenterX + 70, self.arrowRight.y)
    local pointRight2 = playdate.geometry.point.new(self.cardCenterX + 80, self.arrowRight.y)
    local animatorRight = gfx.animator.new(250, pointRight2, pointRight1, playdate.easingFunctions.outCubic)
    self.arrowRight:setAnimator(animatorRight)
end

function DiaryEntryScene:buildHeaderText()
    local date = PlayerProfileStore.formatDiaryDate(self.entry.date or "00-00-0000")
    local spread = self.entry.spreadType or "unknown"
    return date .. " + " .. spread
end

function DiaryEntryScene:buildBodyText()
    local lines = {}

    if type(self.entry.cards) == "table" then
        for _, card in ipairs(self.entry.cards) do
            local position = card.position or 0
            local cardName = card.name or "Unknown Card"
            local orientation = card.inverted and " (reversed)" or ""
            table.insert(lines, "[" .. tostring(position) .. "] " .. cardName .. orientation)
        end
    end

    if type(self.entry.fortuneLines) == "table" and #self.entry.fortuneLines > 0 then
        table.insert(lines, "")
        for _, line in ipairs(self.entry.fortuneLines) do
            table.insert(lines, line)
        end
    elseif type(self.entry.fortuneText) == "string" and #self.entry.fortuneText > 0 then
        table.insert(lines, "")
        table.insert(lines, self.entry.fortuneText)
    else
        table.insert(lines, "")
        table.insert(lines, "No reading text available.")
    end

    return table.concat(lines, "\n")
end

function DiaryEntryScene:renderHeader()
    if self.headerSprite then
        self.headerSprite:remove()
        self.headerSprite = nil
    end

    local headerText = self:buildHeaderText()
    self.headerSprite = gfx.sprite.spriteWithText(headerText, 186, 24, nil, nil, nil, kTextAlignment.left)
    if self.headerSprite then
        self.headerSprite:setCenter(0, 0)
        self.headerSprite:moveTo(self.viewX, 6)
        self.headerSprite:add()
    end
end

function DiaryEntryScene:renderCardPlacement()
    if self.cardPlacementSprite then
        self.cardPlacementSprite:remove()
        self.cardPlacementSprite = nil
    end

    local placementImage = gfx.image.new("images/decknback/placementzone_no_diamond")
    if placementImage then
        self.cardPlacementSprite = gfx.sprite.new(placementImage)
        self.cardPlacementSprite:moveTo(self.cardCenterX, self.cardCenterY)
        self.cardPlacementSprite:add()
    end
end

function DiaryEntryScene:getSelectedCard()
    if type(self.entry.cards) ~= "table" or #self.entry.cards == 0 then
        return nil
    end

    if self.selectedCardIndex < 1 then
        self.selectedCardIndex = #self.entry.cards
    elseif self.selectedCardIndex > #self.entry.cards then
        self.selectedCardIndex = 1
    end

    return self.entry.cards[self.selectedCardIndex]
end

function DiaryEntryScene:renderSelectedCard()
    local cardY = self.currentCardScale == self.zoomScale and self.zoomY or self.cardCenterY

    if self.cardSprite then
        self.cardSprite:remove()
        self.cardSprite = nil
    end

    if self.cardFallbackSprite then
        self.cardFallbackSprite:remove()
        self.cardFallbackSprite = nil
    end

    if self.cardNameSprite then
        self.cardNameSprite:remove()
        self.cardNameSprite = nil
    end

    local card = self:getSelectedCard()
    if not card then
        self.cardFallbackSprite = gfx.sprite.spriteWithText("No cards", 120, 40, nil, nil, nil, kTextAlignment.center)
        if self.cardFallbackSprite then
            self.cardFallbackSprite:setCenter(0.5, 0.5)
            self.cardFallbackSprite:moveTo(self.cardCenterX, cardY)
            self.cardFallbackSprite:add()
        end
        return
    end

    local cardNameText = card.name or "Unknown Card"
    self.cardNameSprite = gfx.sprite.spriteWithText(cardNameText, 160, 80, nil, nil, nil, kTextAlignment.center)
    if self.cardNameSprite then
        self.cardNameSprite:setCenter(0.5, 0.5)
        self.cardNameSprite:moveTo(self.cardCenterX, 40)
        self.cardNameSprite:add()
    end

    local suitFolder = self.suitFolders[card.suit]
    local cardNumber = card.number
    local cardImage = nil
    if suitFolder and cardNumber then
        cardImage = gfx.image.new("images/" .. suitFolder .. "/" .. tostring(cardNumber))
    end

    if not cardImage then
        local fallbackName = card.name or "Unknown Card"
        self.cardFallbackSprite = gfx.sprite.spriteWithText(fallbackName, 120, 60, nil, nil, nil, kTextAlignment.center)
        if self.cardFallbackSprite then
            self.cardFallbackSprite:setCenter(0.5, 0.5)
            self.cardFallbackSprite:moveTo(self.cardCenterX, cardY)
            self.cardFallbackSprite:add()
        end
        return
    end

    self.cardSprite = gfx.sprite.new(cardImage)
    if self.cardSprite then
        self.cardSprite:setCenter(0.5, 0.5)
        self.cardSprite:moveTo(self.cardCenterX, cardY)
        self.cardSprite:setScale(self.currentCardScale)
        self.cardSprite:setRotation(card.inverted and 180 or 0)
        self.cardSprite:add()
    end
end

function DiaryEntryScene:renderBody()
    if self.bodySprite then
        self.bodySprite:remove()
        self.bodySprite = nil
    end

    local bodyText = self:buildBodyText()
    local _, textHeight = gfx.getTextSizeForMaxWidth(bodyText, self.viewWidth)
    local fullHeight = math.max(self.viewHeight, textHeight + 12)
    self.maxScroll = math.max(0, fullHeight - self.viewHeight)

    local bodyImage = gfx.image.new(self.viewWidth, self.viewHeight)
    if not bodyImage then
        return
    end

    gfx.pushContext(bodyImage)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.drawTextInRect(bodyText, 0, -self.scrollY, self.viewWidth, fullHeight, nil, nil, kTextAlignment.left)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
    gfx.popContext()

    self.bodySprite = gfx.sprite.new(bodyImage)
    if self.bodySprite then
        self.bodySprite:setCenter(0, 0)
        self.bodySprite:moveTo(self.viewX, self.viewY + 14)
        self.bodySprite:add()
    end

    self:buildArrows()
end



function DiaryEntryScene:update()
    local crankTicks = pd.getCrankTicks(self.ticksPerRevolution)
    if crankTicks ~= 0 and self.maxScroll > 0 then
        local nextScroll = self.scrollY + (crankTicks * self.scrollStep)
        local clampedScroll = math.max(0, math.min(nextScroll, self.maxScroll))
        if clampedScroll ~= self.scrollY then
            self.scrollY = clampedScroll
            self:renderBody()
        end
    end

    if pd.buttonJustPressed(pd.kButtonLeft) then
        if type(self.entry.cards) == "table" and #self.entry.cards > 0 and self.selectedCardIndex > 1 then
            self.selectedCardIndex = self.selectedCardIndex - 1
            self:renderSelectedCard()
            self:animateArrowLeft()
        end
    end

    if pd.buttonJustPressed(pd.kButtonRight) then
        if type(self.entry.cards) == "table" and #self.entry.cards > 0 and self.selectedCardIndex < #self.entry.cards then
            self.selectedCardIndex = self.selectedCardIndex + 1
            self:renderSelectedCard()
            self:animateArrowRight()
        end
    end

    if pd.buttonJustPressed(pd.kButtonUp) then
        if self.currentCardScale ~= self.zoomScale then
            self.currentCardScale = self.zoomScale
            self:renderSelectedCard()
        end
    end

    if pd.buttonJustPressed(pd.kButtonDown) then
        if self.currentCardScale ~= self.selectedScale then
            self.currentCardScale = self.selectedScale
            self:renderSelectedCard()
        end
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        cards_slow2:play(1)
        SCENE_MANAGER:switchScene(DiaryEntriesListScene, self.returnIndex)
    end
end

function DiaryEntryScene:deinit()
    if self.bgSprite then self.bgSprite:remove() self.bgSprite = nil end
    if self.headerSprite then self.headerSprite:remove() self.headerSprite = nil end
    if self.bodySprite then self.bodySprite:remove() self.bodySprite = nil end
    if self.cardPlacementSprite then self.cardPlacementSprite:remove() self.cardPlacementSprite = nil end
    if self.cardSprite then self.cardSprite:remove() self.cardSprite = nil end
    if self.cardFallbackSprite then self.cardFallbackSprite:remove() self.cardFallbackSprite = nil end
    if self.cardNameSprite then self.cardNameSprite:remove() self.cardNameSprite = nil end
    if self.arrowLeft then self.arrowLeft:remove() self.arrowLeft = nil end
    if self.arrowRight then self.arrowRight:remove() self.arrowRight = nil end
end
