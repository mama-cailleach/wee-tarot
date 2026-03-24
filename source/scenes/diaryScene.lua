local pd <const> = playdate
local gfx <const> = pd.graphics

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

    self.diaryLine = gfx.sprite.spriteWithText("________________", 320, 40, nil, nil, nil, kTextAlignment.left)
    self.diaryLine:setCenter(0, 0)
    self.diaryLine:moveTo(40, 120)
    self.diaryLine:add()

    self:add()
end
