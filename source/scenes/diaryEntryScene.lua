local pd <const> = playdate
local gfx <const> = pd.graphics

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

    self.viewX = 210
    self.viewY = 6
    self.viewWidth = 186
    self.viewHeight = 228

    self.scrollY = 0
    self.maxScroll = 0
    self.scrollStep = 14

    self:renderHeader()
    self:renderBody()

    self:add()
end

function DiaryEntryScene:buildHeaderText()
    local date = self.entry.date or "00-00-0000"
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
end

function DiaryEntryScene:update()
    if pd.buttonJustPressed(pd.kButtonDown) then
        if self.scrollY < self.maxScroll then
            self.scrollY = math.min(self.scrollY + self.scrollStep, self.maxScroll)
            self:renderBody()
        end
    end

    if pd.buttonJustPressed(pd.kButtonUp) then
        if self.scrollY > 0 then
            self.scrollY = math.max(self.scrollY - self.scrollStep, 0)
            self:renderBody()
        end
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        cards_slow2:play(1)
        SCENE_MANAGER:switchScene(DiaryScene, self.returnIndex)
    end
end

function DiaryEntryScene:deinit()
    if self.bgSprite then self.bgSprite:remove() self.bgSprite = nil end
    if self.headerSprite then self.headerSprite:remove() self.headerSprite = nil end
    if self.bodySprite then self.bodySprite:remove() self.bodySprite = nil end
end
