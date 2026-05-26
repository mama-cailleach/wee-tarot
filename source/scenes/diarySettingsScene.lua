local pd <const> = playdate
local gfx <const> = pd.graphics

import "data/save/playerProfileStore"

class('DiarySettingsScene').extends(gfx.sprite)

function DiarySettingsScene:init(source, returnState)
    DiarySettingsScene.super.init(self)

    self.source = source or "settings"
    self.returnState = returnState

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
    self.entriesListDescending = PlayerProfileStore.getEntriesListDescending()

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

    self.menuOptions = { "Name", "Order", "Back" }
    self.selectedMenuIndex = 1
    self.menuSprites = {}
    self.orderValueSprite = nil
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

    self:renderOrderValue()

    self:updateSelectorPosition()
end

function DiarySettingsScene:renderOrderValue()
    if self.orderValueSprite then
        self.orderValueSprite:remove()
        self.orderValueSprite = nil
    end

    local orderText = self.entriesListDescending and "Descending" or "Ascending"

    self.orderValueSprite = gfx.sprite.spriteWithText(orderText, 320, 40, nil, nil, nil, kTextAlignment.left)
    if self.orderValueSprite then
        self.orderValueSprite:setCenter(0, 0)
        self.orderValueSprite:moveTo(245, self:getMenuRowY(2) + 28)
        self.orderValueSprite:add()
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

function DiarySettingsScene:goBack()
    Sound.playSFX("cards_slow2")

    if self.source == "diary" then
        SCENE_MANAGER:switchScene(DiaryEntriesListScene, self.returnState)
    else
        SCENE_MANAGER:switchScene(SettingsScene)
    end
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
        Sound.playSFX("cards_fast2")
        if self.selectedMenuIndex == 1 then
            self:startNameEdit()
        elseif self.selectedMenuIndex == 2 then
            self.entriesListDescending = PlayerProfileStore.setEntriesListDescending(not self.entriesListDescending)
            self:renderOrderValue()
        elseif self.selectedMenuIndex == 3 then
            self:goBack()
        end
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        self:goBack()
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
    if self.orderValueSprite then self.orderValueSprite:remove() self.orderValueSprite = nil end
    if self.settingsLabel then self.settingsLabel:remove() self.settingsLabel = nil end
    if self.selectorSprite then self.selectorSprite:remove() self.selectorSprite = nil end

    for _, sprite in ipairs(self.menuSprites) do
        if sprite then sprite:remove() end
    end
    self.menuSprites = {}
end
