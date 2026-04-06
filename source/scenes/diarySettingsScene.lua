local pd <const> = playdate
local gfx <const> = pd.graphics

import "data/save/playerProfileStore"

class('DiarySettingsScene').extends(gfx.sprite)

function DiarySettingsScene:init()
    DiarySettingsScene.super.init(self)

    self.bgImage = gfx.image.new("images/bg/journal4")
    self.bgSprite = gfx.sprite.new(self.bgImage)
    self.bgSprite:moveTo(200, 120)
    self.bgSprite:add()

    self.diaryLabel = gfx.sprite.spriteWithText("This diary\n belongs to", 320, 80, nil, nil, nil, kTextAlignment.left)
    self.diaryLabel:setCenter(0, 0)
    self.diaryLabel:moveTo(40, 45)
    self.diaryLabel:add()

    self.maxNameLength = PlayerProfileStore.getMaxNameLength()
    self.name = PlayerProfileStore.getName()
    self.isEditingName = false

    self.diaryLine = gfx.sprite.spriteWithText(self.name, 120, 120, nil, nil, nil, kTextAlignment.center)
    self.diaryLine:setCenter(0, 0)
    self.diaryLine:moveTo(48, 120)
    self.diaryLine:add()


    self.settingsLabel = gfx.sprite.spriteWithText("MEND", 150, 40, nil, nil, nil, kTextAlignment.left)
    if self.settingsLabel then
        self.settingsLabel:setCenter(0, 0)
        self.settingsLabel:moveTo(260, 1)
        self.settingsLabel:add()
    end

    self.menuOptions = { "Name", "Date", "Back" }
    self.selectedMenuIndex = 1
    self.menuSprites = {}
    self.dateValueSprite = nil
    self.dateDisplayReversed = PlayerProfileStore.getDateDisplayReversed()
    self.selectorSprite = nil
    self.menuRowYPositions = { 45, 95, 190 }


    local selectorImage = gfx.image.new("images/bg/icon_knot1_smol")
    if selectorImage then
        self.selectorSprite = gfx.sprite.new(selectorImage)
        self.selectorSprite:add()
    end

    self:renderMenu()

    self:add()
end

function DiarySettingsScene:setDiaryLineText(text)
    if self.diaryLine then
        self.diaryLine:remove()
        self.diaryLine = nil
    end

    local displayText = text
    if type(displayText) ~= "string" or #displayText == 0 then
        displayText = "?"
    end

    self.diaryLine = gfx.sprite.spriteWithText(displayText, 120, 120, nil, nil, nil, kTextAlignment.center)
    if self.diaryLine then
        self.diaryLine:setCenter(0, 0)
        self.diaryLine:moveTo(48, 120)
        self.diaryLine:add()
    end
end

function DiarySettingsScene:startNameEdit()
    if self.isEditingName or pd.keyboard.isVisible() then
        return
    end

    self.isEditingName = true
    pd.keyboard.setCapitalizationBehavior(pd.keyboard.kCapitalizationWords)
    pd.keyboard.text = self.name

    pd.keyboard.textChangedCallback = function()
        if #pd.keyboard.text > self.maxNameLength then
            pd.keyboard.text = string.sub(pd.keyboard.text, 1, self.maxNameLength)
        end
        self:setDiaryLineText(pd.keyboard.text)
    end

    pd.keyboard.keyboardWillHideCallback = function(confirmed)
        if confirmed then
            self.name = PlayerProfileStore.setName(pd.keyboard.text)
            self:setDiaryLineText(self.name)
        else
            self:setDiaryLineText(self.name)
        end
        self.isEditingName = false
        pd.keyboard.textChangedCallback = nil
        pd.keyboard.keyboardWillHideCallback = nil
    end

    pd.keyboard.show(self.name)
end

function DiarySettingsScene:renderMenu()
    for _, sprite in ipairs(self.menuSprites) do
        if sprite then sprite:remove() end
    end
    self.menuSprites = {}

    for i, option in ipairs(self.menuOptions) do
        local sprite = gfx.sprite.spriteWithText(option, 150, 40, nil, nil, nil, kTextAlignment.left)
        if sprite then
            sprite:setCenter(0, 0)
            sprite:moveTo(260, self:getMenuRowY(i))
            sprite:add()
            table.insert(self.menuSprites, sprite)
        end
    end

    self:renderDateValue()

    self:updateSelectorPosition()
end

function DiarySettingsScene:renderDateValue()
    if self.dateValueSprite then
        self.dateValueSprite:remove()
        self.dateValueSprite = nil
    end

    local now = pd.getTime and pd.getTime()
    local day = now and now.day or nil
    local month = now and now.month or nil
    local year = now and now.year or nil
    local dayPart = day and string.format("%02d", day) or "00"
    local monthPart = month and string.format("%02d", month) or "00"
    local yearPart = year and string.format("%04d", year) or "0000"
    local dateText = PlayerProfileStore.formatDiaryDate(dayPart .. "-" .. monthPart .. "-" .. yearPart)


    self.dateValueSprite = gfx.sprite.spriteWithText(dateText, 320, 40, nil, nil, nil, kTextAlignment.left)
    if self.dateValueSprite then
        self.dateValueSprite:setCenter(0, 0)
        self.dateValueSprite:moveTo(245, self:getMenuRowY(2) + 28)
        self.dateValueSprite:add()
    end
end

function DiarySettingsScene:getMenuRowY(index)
    if self.menuRowYPositions and self.menuRowYPositions[index] then
        return self.menuRowYPositions[index]
    end
    return 45 + (index - 1) * 70
end

function DiarySettingsScene:updateSelectorPosition()
    if not self.selectorSprite then return end

    local y = self:getMenuRowY(self.selectedMenuIndex)
    self.selectorSprite:moveTo(240, y + 18)
end

function DiarySettingsScene:update()
    if self.isEditingName or pd.keyboard.isVisible() then
        return
    end

    if pd.buttonJustPressed(pd.kButtonUp) then
        if self.selectedMenuIndex > 1 then
            self.selectedMenuIndex = self.selectedMenuIndex - 1
            self:updateSelectorPosition()
        end
    end

    if pd.buttonJustPressed(pd.kButtonDown) then
        if self.selectedMenuIndex < #self.menuOptions then
            self.selectedMenuIndex = self.selectedMenuIndex + 1
            self:updateSelectorPosition()
        end
    end

    if pd.buttonJustPressed(pd.kButtonA) then
        cards_fast2:play(1)
        if self.selectedMenuIndex == 1 then
            self:startNameEdit()
        elseif self.selectedMenuIndex == 2 then
            self.dateDisplayReversed = PlayerProfileStore.setDateDisplayReversed(not self.dateDisplayReversed)
            self:renderDateValue()
        elseif self.selectedMenuIndex == 3 then
            SCENE_MANAGER:switchScene(SettingsScene)
        end
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        cards_slow2:play(1)
        SCENE_MANAGER:switchScene(SettingsScene)
    end

end

function DiarySettingsScene:deinit()
    if pd.keyboard.isVisible() then
        pd.keyboard.hide()
    end
    pd.keyboard.textChangedCallback = nil
    pd.keyboard.keyboardWillHideCallback = nil

    if self.bgSprite then self.bgSprite:remove() self.bgSprite = nil end
    if self.diaryLabel then self.diaryLabel:remove() self.diaryLabel = nil end
    if self.diaryLine then self.diaryLine:remove() self.diaryLine = nil end
    if self.dateValueSprite then self.dateValueSprite:remove() self.dateValueSprite = nil end
    if self.settingsLabel then self.settingsLabel:remove() self.settingsLabel = nil end
    if self.selectorSprite then self.selectorSprite:remove() self.selectorSprite = nil end

    for _, sprite in ipairs(self.menuSprites) do
        if sprite then sprite:remove() end
    end
    self.menuSprites = {}
end
