local pd <const> = playdate
local gfx <const> = pd.graphics

import "data/save/diaryStore"

-- Diary flush + browser prewarm happen here (spread across frames), not on the hub.
class('BufferScene').extends(gfx.sprite)

local MIN_HOLD_MS <const> = 4000

local WORK_DELAYS_MS <const> = { 500, 1000, 1500, 2000, 3000 }

function BufferScene:init()
    BufferScene.super.init(self)

    self.bgSprite = nil
    self.labelSprite = nil
    self.workTimers = {}
    self.exitTimer = nil

    self.bgSprite = gfx.sprite.new(gfx.image.new(400, 240, gfx.kColorBlack))
    self.bgSprite:moveTo(200, 120)
    self.bgSprite:add()

    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    self.labelSprite = gfx.sprite.spriteWithText("SAVING...\nDON'T TURN OFF THE POWER.", 400, 120, nil, nil, nil, kTextAlignment.center)
    self.labelSprite:moveTo(200, 120)
    self.labelSprite:add()
    gfx.setImageDrawMode(gfx.kDrawModeCopy)

    self:scheduleDiaryWork()

    self.exitTimer = pd.timer.performAfterDelay(MIN_HOLD_MS, function()
        self.exitTimer = nil
        SCENE_MANAGER:switchScene(AfterDialogueScene)
    end)

    self:add()
end

function BufferScene:scheduleDiaryWork()
    self:clearWorkTimers()
    Sound.playSFX("hahahaha")

    table.insert(self.workTimers, pd.timer.performAfterDelay(WORK_DELAYS_MS[1], function()
        DiaryStore.getBrowserData(false)
    end))

    table.insert(self.workTimers, pd.timer.performAfterDelay(WORK_DELAYS_MS[2], function()
        DiaryStore.getBrowserData(true)
    end))

    table.insert(self.workTimers, pd.timer.performAfterDelay(WORK_DELAYS_MS[3], function()
        if GameAssets and GameAssets.prewarmDiaryListAssets then
            GameAssets.prewarmDiaryListAssets()
        end
    end))

    table.insert(self.workTimers, pd.timer.performAfterDelay(WORK_DELAYS_MS[4], function()
        if DiaryStore.hasPendingAppend and DiaryStore.hasPendingAppend() then
            DiaryStore.flushPendingEntryFiles()
        end
    end))

    table.insert(self.workTimers, pd.timer.performAfterDelay(WORK_DELAYS_MS[5], function()
        if DiaryStore.hasPendingAppend and DiaryStore.hasPendingAppend() then
            DiaryStore.finishPendingFlush()
        end
    end))
end

function BufferScene:clearWorkTimers()
    for _, timer in ipairs(self.workTimers) do
        if timer then
            timer:remove()
        end
    end
    self.workTimers = {}
end

function BufferScene:deinit()
    self:clearWorkTimers()

    if self.exitTimer then
        self.exitTimer:remove()
        self.exitTimer = nil
    end

    if self.bgSprite then self.bgSprite:remove() self.bgSprite = nil end
    if self.labelSprite then self.labelSprite:remove() self.labelSprite = nil end

    if BufferScene.super and BufferScene.super.deinit then
        BufferScene.super.deinit(self)
    end
end

