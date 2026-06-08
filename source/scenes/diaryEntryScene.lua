local pd <const> = playdate
local gfx <const> = pd.graphics

import "data/save/playerProfileStore"
import "data/spreadReadingData"
import "libraries/utils"
local ImageCache = import "libraries/imageCache"
local DebugStats = import "libraries/debugStats"
ImageCache.setup({ maxEntries = 2, maxBytes = 131072 })

class('DiaryEntryScene').extends(gfx.sprite)

local MONTH_NAMES_FULL = {
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
}

local CARD_Z_NORMAL <const> = 200
local CARD_Z_ZOOMED <const> = 320
local ARROW_Z <const> = 30

local function createWhiteTextSprite(text, width, height, alignment)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    local sprite = gfx.sprite.spriteWithText(text, width, height, nil, nil, nil, alignment or kTextAlignment.center)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    return sprite
end

function DiaryEntryScene:init(entry, returnState)
    DiaryEntryScene.super.init(self)

    self.entry = entry or {}
    if type(returnState) == "table" then
        self.returnState = returnState
    else
        self.returnState = {
            browserMode = "year",
            selectedYearIndex = type(returnState) == "number" and returnState or 1
        }
    end

    --[[
    self.bgImage = gfx.image.new("images/bg/journal1")
    self.bgSprite = gfx.sprite.new(self.bgImage)
    self.bgSprite:moveTo(200, 120)
    self.bgSprite:add()
    ]]

    self.bgImage = gfx.image.new("images/bg/journal1")
    self.bgSprite = gfx.sprite.new(self.bgImage)
    self.bgSprite:moveTo(200,120)
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
    self.selectedCardIndex = 0
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

        self.crankSoundPlaying = false
        self.crankInactivityTimer = nil
        self.lastCrankTime = 0
        self.bodyImage = nil
        self.lastBodyRenderTime = 0
        self.bodyNeedsRender = false
        self.fullBodyImage = nil
        self.fullBodySprite = nil
        self.fullBodyRenderThreshold = 800

    self:renderHeader()
    self:renderBody()
    self:buildArrows()
    self:renderSelectedCard()

    self:add()
end

function DiaryEntryScene:getCardCount()
    if type(self.entry.cards) ~= "table" then
        return 0
    end

    return #self.entry.cards
end

function DiaryEntryScene:getNavigationCount()
    return self:getCardCount() + 1
end

function DiaryEntryScene:getSpreadKey()
    return SpreadReadingData.normalizeSpreadKey(self.entry.spreadType)
end

function DiaryEntryScene:getSpreadName()
    if self:getSpreadKey() == "three_card" then
        return "Root-Trunk-\nBranch"
    end
    return SpreadReadingData.getSpreadDisplayName(self.entry.spreadType)
end

function DiaryEntryScene:buildArrows()
    if not self.arrowRight then
        self.arrowRight = createWhiteTextSprite("®", 40, 40, kTextAlignment.center)
        self.arrowRight:setRotation(90)
        self.arrowRight:moveTo(self.cardCenterX + 70, self.cardCenterY)
        self.arrowRight:setZIndex(ARROW_Z)
        self.arrowRight:add()
    end

    if not self.arrowLeft then
        self.arrowLeft = createWhiteTextSprite("®", 40, 40, kTextAlignment.center)
        self.arrowLeft:setRotation(270)
        self.arrowLeft:moveTo(self.cardCenterX - 70, self.cardCenterY)
        self.arrowLeft:setZIndex(ARROW_Z)
        self.arrowLeft:add()
    end

    self:syncArrowVisibility()
end

function DiaryEntryScene:syncArrowVisibility()
    local showArrows = self.currentCardScale ~= self.zoomScale
    if self.arrowLeft then
        self.arrowLeft:setVisible(showArrows)
    end
    if self.arrowRight then
        self.arrowRight:setVisible(showArrows)
    end
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

function DiaryEntryScene:toOrdinal(day)
    local suffix = "th"
    local mod100 = day % 100
    if mod100 < 11 or mod100 > 13 then
        local mod10 = day % 10
        if mod10 == 1 then
            suffix = "st"
        elseif mod10 == 2 then
            suffix = "nd"
        elseif mod10 == 3 then
            suffix = "rd"
        end
    end
    return tostring(day) .. suffix
end

function DiaryEntryScene:formatPreviewDate(date)
    local day, month, year = string.match(date or "", "^(%d%d)%-(%d%d)%-(%d%d%d%d)$")
    if not day or not month or not year then
        return "Erstwhile"
    end

    local monthIndex = tonumber(month) or 0
    local monthText = MONTH_NAMES_FULL[monthIndex] or "???"
    local dayText = self:toOrdinal(tonumber(day) or 0)

    return dayText .. " of \n" .. monthText .. "\n" .. year
end

function DiaryEntryScene:formatPreviewTime(timeText)
    if type(timeText) ~= "string" then
        return "00.00"
    end

    timeText = string.gsub(timeText, ":", ".")

    if not string.match(timeText, "^%d%d%.%d%d$") then
        return "00.00"
    end

    return timeText
end

function DiaryEntryScene:buildSpreadSummaryText()
    local lines = {}
    local spreadKey = self:getSpreadKey()
    local config = SpreadReadingData.getConfig(spreadKey)

    table.insert(lines, self:formatPreviewDate(self.entry.date))
    table.insert(lines, "at")
    table.insert(lines, self:formatPreviewTime(self.entry.time))
    table.insert(lines, "ºººººººº")
    table.insert(lines, "")

    if type(self.entry.cards) == "table" then
        table.insert(lines, "Cards Pulled:")
        table.insert(lines, "")
        for _, card in ipairs(self.entry.cards) do
            local position = card.position or 0
            local cardName = card.name or "Unknown Card"
            local orientation = card.inverted and " (reversed)" or ""
            local positionLabel = config and position > 0 and SpreadReadingData.getPositionName(spreadKey, position) or tostring(position)
            table.insert(lines, positionLabel .. ". " .. cardName .. orientation .. "\n")
        end
    end

    return table.concat(lines, "\n")
end

function DiaryEntryScene:getCardDetails()
    local details = {}
    if type(self.entry.cards) ~= "table" then
        return details
    end

    local spreadKey = self:getSpreadKey()
    local config = SpreadReadingData.getConfig(spreadKey)

    for _, card in ipairs(self.entry.cards) do
        local position = tonumber(card.position) or (#details + 1)
        local cardName = card.name or "Unknown Card"
        local inverted = card.inverted == true
        local positionLabel = config and position > 0
            and SpreadReadingData.getPositionName(spreadKey, position)
            or ("Card " .. tostring(position))

        table.insert(details, {
            position = position,
            positionLabel = positionLabel,
            cardName = cardName,
            inverted = inverted,
            themes = SpreadReadingData.pickKeywords(cardName, inverted, 3)
        })
    end

    return details
end

function DiaryEntryScene:getSelectedCardDetail()
    if self.selectedCardIndex == 0 then
        return nil
    end

    local cardDetails = self:getCardDetails()
    return cardDetails[self.selectedCardIndex]
end

function DiaryEntryScene:buildCardDetailText(detail)
    if type(detail) ~= "table" then
        return "No card selected."
    end

    local lines = {}
    local cardName = detail.cardName or "Unknown Card"
    local position = detail.position or 0
    local orientation = detail.inverted and "Reversed" or "Upright"
    local positionLabel = detail.positionLabel or ("Card " .. tostring(position))

    table.insert(lines, cardName)
    table.insert(lines, "")
    table.insert(lines, positionLabel)
    table.insert(lines, "")
    table.insert(lines, "Orientation: " .. orientation)

    if type(detail.themes) == "table" and #detail.themes > 0 then
        table.insert(lines, "")
        table.insert(lines, "Themes:")
        table.insert(lines, table.concat(detail.themes, ", "))
    end
    table.insert(lines, "")
    table.insert(lines, "ºººººººº")

    return table.concat(lines, "\n")
end

function DiaryEntryScene:buildBodyText()
    local selectedCard = self:getSelectedCard()
    local bodyText

    if selectedCard and selectedCard.isSpreadCard then
        bodyText = self:buildSpreadSummaryText()
    else
        bodyText = self:buildCardDetailText(self:getSelectedCardDetail())
    end

    local wrappedLines = utils.wrapTextToLines(bodyText or "", self.viewWidth, gfx.getSystemFont())
    return table.concat(wrappedLines, "\n")
end

function DiaryEntryScene:renderHeader()
    if self.headerSprite then
        self.headerSprite:remove()
        self.headerSprite = nil
    end

    local headerText = self:buildHeaderText()
    self.headerSprite = createWhiteTextSprite(headerText, 186, 24, kTextAlignment.center)
    if self.headerSprite then
        self.headerSprite:setCenter(0, 0)
        self.headerSprite:moveTo(self.viewX, 6)
        self.headerSprite:setZIndex(300)
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
    if self.selectedCardIndex == 0 then
        return {
            isSpreadCard = true,
            name = self:getSpreadName(),
            imagePath = "images/spreads/" .. self:getSpreadKey()
        }
    end

    if type(self.entry.cards) ~= "table" or #self.entry.cards == 0 then
        return nil
    end

    if self.selectedCardIndex < 1 then
        self.selectedCardIndex = self:getNavigationCount() - 1
    elseif self.selectedCardIndex > #self.entry.cards then
        self.selectedCardIndex = 0
    end

    return self.entry.cards[self.selectedCardIndex]
end

function DiaryEntryScene:renderSelectedCard()
    local isZoomed = self.currentCardScale == self.zoomScale
    local cardY = isZoomed and self.zoomY or self.cardCenterY
    local cardZ = isZoomed and CARD_Z_ZOOMED or CARD_Z_NORMAL

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
        self.cardFallbackSprite = createWhiteTextSprite("No cards", 120, 40, kTextAlignment.center)
        if self.cardFallbackSprite then
            self.cardFallbackSprite:setCenter(0.5, 0.5)
            self.cardFallbackSprite:moveTo(self.cardCenterX, cardY)
            self.cardFallbackSprite:setZIndex(cardZ)
            self.cardFallbackSprite:add()
        end
        self:syncArrowVisibility()
        return
    end

    local cardNameText = card.isSpreadCard and self:getSpreadName() or card.name or "Unknown Card"
    self.cardNameSprite = createWhiteTextSprite(cardNameText, 160, 80, kTextAlignment.center)
    if self.cardNameSprite then
        self.cardNameSprite:setCenter(0.5, 0.5)
        self.cardNameSprite:moveTo(self.cardCenterX, 40)
        self.cardNameSprite:setZIndex(300)
        self.cardNameSprite:add()
    end

    local cardImage = nil
    if card.isSpreadCard then
        cardImage = Card.loadImageWithZoomFallback(card.imagePath, isZoomed)
    else
        cardImage = Card.loadImageWithZoomFallback(Card.getImagePath(card.number, card.suit, false), isZoomed)
    end

    if not cardImage then
        local fallbackName = card.name or "Unknown Card"
        self.cardFallbackSprite = createWhiteTextSprite(fallbackName, 120, 60, kTextAlignment.center)
        if self.cardFallbackSprite then
            self.cardFallbackSprite:setCenter(0.5, 0.5)
            self.cardFallbackSprite:moveTo(self.cardCenterX, cardY)
            self.cardFallbackSprite:setZIndex(cardZ)
            self.cardFallbackSprite:add()
        end
        self:syncArrowVisibility()
        return
    end

    self.cardSprite = gfx.sprite.new(cardImage)
    if self.cardSprite then
        self.cardSprite:setCenter(0.5, 0.5)
        self.cardSprite:moveTo(self.cardCenterX, cardY)
        self.cardSprite:setRotation(card.inverted and 180 or 0)
        self.cardSprite:setZIndex(cardZ)
        self.cardSprite:add()
    end

    self:syncArrowVisibility()
end

function DiaryEntryScene:renderBody()
    -- Reuse body image and sprite to avoid frequent allocations
    local bodyText = self:buildBodyText()
    local _, textHeight = gfx.getTextSizeForMaxWidth(bodyText, self.viewWidth)
    local fullHeight = math.max(self.viewHeight, textHeight + 12)
    self.maxScroll = math.max(0, fullHeight - self.viewHeight)

    -- Cache key for this entry + selected card so cached full-body matches current selection
    local entryIdPart = tostring(self.entry.id or self.entry.date or tostring(self.entry))
    local cacheKey = "diary_full_" .. entryIdPart .. "_sel_" .. tostring(self.selectedCardIndex or 0)

    -- If the full rendered text fits under threshold, pre-render the whole text (using cache)
    if fullHeight <= (self.fullBodyRenderThreshold or 800) then
        local img = ImageCache.getOrCreate(cacheKey, function()
            local created = gfx.image.new(self.viewWidth, fullHeight)
            if created then
                gfx.pushContext(created)
                    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
                    gfx.drawTextInRect(bodyText, 0, 0, self.viewWidth, fullHeight, nil, nil, kTextAlignment.center)
                    gfx.setImageDrawMode(gfx.kDrawModeCopy)
                gfx.popContext()
                DebugStats.inc('fullImageCreates')
            end
            return created
        end, { width = self.viewWidth, height = fullHeight })

        self.fullBodyImage = img

        if self.fullBodyImage then
            if not self.fullBodySprite then
                if self.bodySprite then self.bodySprite:remove() self.bodySprite = nil end
                self.fullBodySprite = gfx.sprite.new(self.fullBodyImage)
                self.fullBodySprite:setCenter(0, 0)
                self.fullBodySprite:moveTo(self.viewX, self.viewY + 14 - self.scrollY)
                self.fullBodySprite:setZIndex(100)
                self.fullBodySprite:add()
            else
                -- ensure sprite shows current image (in case cache returned a new image for a different selection)
                self.fullBodySprite:setImage(self.fullBodyImage)
                self.fullBodySprite:moveTo(self.viewX, self.viewY + 14 - self.scrollY)
                self.fullBodySprite:markDirty()
            end
        end
    else
        -- Tiled rendering for long entries: render only visible tiles and compose viewport
        local tileHeight = self.tileHeight or 256
        local startTile = math.floor(self.scrollY / tileHeight)
        local endTile = math.floor((self.scrollY + self.viewHeight - 1) / tileHeight)

        -- remove any full-body sprite so viewport is visible
        if self.fullBodySprite then
            self.fullBodySprite:remove()
            self.fullBodySprite = nil
        end

        if not self.bodyImage then
            self.bodyImage = gfx.image.new(self.viewWidth, self.viewHeight)
            if not self.bodyImage then return end
        end

        gfx.pushContext(self.bodyImage)
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRect(0, 0, self.viewWidth, self.viewHeight)
            -- draw visible tiles
            for ti = startTile, endTile do
                local tileKey = cacheKey .. "_tile_" .. tostring(ti)
                local tileImg = ImageCache.getOrCreate(tileKey, function()
                    local timg = gfx.image.new(self.viewWidth, tileHeight)
                    if timg then
                        gfx.pushContext(timg)
                            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
                            gfx.drawTextInRect(bodyText, 0, - (ti * tileHeight), self.viewWidth, fullHeight, nil, nil, kTextAlignment.center)
                            gfx.setImageDrawMode(gfx.kDrawModeCopy)
                        gfx.popContext()
                        DebugStats.inc('tileCreates')
                    end
                    return timg
                end, { width = self.viewWidth, height = tileHeight })

                if tileImg then
                    local drawY = (ti * tileHeight) - self.scrollY
                    tileImg:draw(0, drawY)
                end
            end
        gfx.popContext()

        if not self.bodySprite then
            self.bodySprite = gfx.sprite.new(self.bodyImage)
            self.bodySprite:setCenter(0, 0)
            self.bodySprite:moveTo(self.viewX, self.viewY + 14)
            self.bodySprite:setZIndex(100)
            self.bodySprite:add()
        else
            self.bodySprite:setImage(self.bodyImage)
            self.bodySprite:markDirty()
        end
        DebugStats.inc('viewportRenders')
    end

    self.lastBodyRenderTime = pd.getElapsedTime()
    self.bodyNeedsRender = false
end



function DiaryEntryScene:update()
    local crankTicks = pd.getCrankTicks(self.ticksPerRevolution)
    if crankTicks ~= 0 and self.maxScroll > 0 then
        local nextScroll = self.scrollY + (crankTicks * self.scrollStep)
        local clampedScroll = math.max(0, math.min(nextScroll, self.maxScroll))
        if clampedScroll ~= self.scrollY then
            self.scrollY = clampedScroll
            -- mark for re-render; throttle actual render to reduce churn
            self.bodyNeedsRender = true
        end

        self.lastCrankTime = pd.getElapsedTime()

        if not self.crankSoundPlaying then
            Sound.startCrankLoop()
            self.crankSoundPlaying = true
        end
    end

    -- Throttle body render: only redraw if enough time passed
    if self.bodyNeedsRender and (pd.getElapsedTime() - (self.lastBodyRenderTime or 0) > 0.04) then
        self:renderBody()
    end

    if self.crankSoundPlaying and pd.getElapsedTime() - self.lastCrankTime > 0.1 then
        Sound.stopCrankLoop()
        self.crankSoundPlaying = false
    end

    if pd.buttonJustPressed(pd.kButtonLeft) then
        Sound.playABut()
        local navigationCount = self:getNavigationCount()
        if navigationCount > 0 then
            self.selectedCardIndex = (self.selectedCardIndex - 1 + navigationCount) % navigationCount
            self.scrollY = 0
            self:renderBody()
            self:renderSelectedCard()
            self:animateArrowLeft()
        end
    end

    if pd.buttonJustPressed(pd.kButtonRight) then
        Sound.playABut()
        local navigationCount = self:getNavigationCount()
        if navigationCount > 0 then
            self.selectedCardIndex = (self.selectedCardIndex + 1) % navigationCount
            self.scrollY = 0
            self:renderBody()
            self:renderSelectedCard()
            self:animateArrowRight()
        end
    end

    -- Debug: press A while holding B to dump render stats
    if pd.buttonJustPressed(pd.kButtonA) and pd.buttonIsPressed(pd.kButtonB) then
        DebugStats.log()
    end

    if pd.buttonJustPressed(pd.kButtonUp) then
        Sound.playABut()
        if self.currentCardScale ~= self.zoomScale then
            self.currentCardScale = self.zoomScale
            self:renderSelectedCard()
        end
    end

    if pd.buttonJustPressed(pd.kButtonDown) then
        Sound.playABut()
        if self.currentCardScale ~= self.selectedScale then
            self.currentCardScale = self.selectedScale
            self:renderSelectedCard()
        end
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        Sound.playSFX("b_button")
        SCENE_MANAGER:switchScene(DiaryEntriesListScene, self.returnState)
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

        if self.crankSoundPlaying then
            Sound.stopCrankLoop()
            self.crankSoundPlaying = false
        end
    self.imagetable = nil
        self.bgImage = nil
        self.bodyImage = nil
        if self.fullBodySprite then self.fullBodySprite:remove() self.fullBodySprite = nil end
        self.fullBodyImage = nil
end
