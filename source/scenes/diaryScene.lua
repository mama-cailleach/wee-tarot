local pd <const> = playdate
local gfx <const> = pd.graphics

import "data/save/playerProfileStore"

class('DiaryScene').extends(gfx.sprite)

function DiaryScene:init()
    DiaryScene.super.init(self)

    self.bgImage = gfx.image.new("images/bg/journal1")
    self.bgSprite = gfx.sprite.new(self.bgImage)
    self.bgSprite:moveTo(200, 120)
    self.bgSprite:add()

    self.diaryLabel = gfx.sprite.spriteWithText("Diary of", 320, 40, nil, nil, nil, kTextAlignment.left)
    self.diaryLabel:setCenter(0, 0)
    self.diaryLabel:moveTo(40, 80)
    self.diaryLabel:add()

    self.name = PlayerProfileStore.getName()

    self.diaryLine = gfx.sprite.spriteWithText(self.name, 120, 40, nil, nil, nil, kTextAlignment.center)
    self.diaryLine:setCenter(0, 0)
    self.diaryLine:moveTo(40, 120)
    self.diaryLine:add()

    self.menuOptions = { "Entries", "Edit", "Back" }
    self.selectedMenuIndex = 1
    self.menuSprites = {}
    self.selectorSprite = nil

    local selectorImage = gfx.image.new("images/bg/icon_knot1_smol")
    if selectorImage then
        self.selectorSprite = gfx.sprite.new(selectorImage)
        self.selectorSprite:add()
    end

    self:renderMenu()

    self:add()
end

function DiaryScene:renderMenu()
    for _, sprite in ipairs(self.menuSprites) do
        if sprite then sprite:remove() end
    end
    self.menuSprites = {}

    local startY = 20
    local rowHeight = 30
    for i, option in ipairs(self.menuOptions) do
        local sprite = gfx.sprite.spriteWithText(option, 100, 40, nil, nil, nil, kTextAlignment.left)
        if sprite then
            sprite:setCenter(0, 0)
            sprite:moveTo(260, startY + (i - 1) * rowHeight)
            sprite:add()
            table.insert(self.menuSprites, sprite)
        end
    end

    self:updateSelectorPosition()
end

function DiaryScene:updateSelectorPosition()
    if not self.selectorSprite then return end
    
    local startY = 20
    local rowHeight = 30
    local y = startY + (self.selectedMenuIndex - 1) * rowHeight
    self.selectorSprite:moveTo(240, y + 20)
end

function DiaryScene:update()
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
            SCENE_MANAGER:switchScene(DiaryEntriesListScene)
        elseif self.selectedMenuIndex == 2 then
            SCENE_MANAGER:switchScene(DiarySettingsScene)
        elseif self.selectedMenuIndex == 3 then
            SCENE_MANAGER:switchScene(AfterDialogueScene)
        end
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        cards_slow2:play(1)
        SCENE_MANAGER:switchScene(AfterDialogueScene)
    end

end

function DiaryScene:deinit()
    if self.bgSprite then self.bgSprite:remove() self.bgSprite = nil end
    if self.diaryLabel then self.diaryLabel:remove() self.diaryLabel = nil end
    if self.diaryLine then self.diaryLine:remove() self.diaryLine = nil end
    if self.selectorSprite then self.selectorSprite:remove() self.selectorSprite = nil end
    
    for _, sprite in ipairs(self.menuSprites) do
        if sprite then sprite:remove() end
    end
    self.menuSprites = {}
end
