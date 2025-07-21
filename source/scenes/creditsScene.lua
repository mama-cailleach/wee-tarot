local pd <const> = playdate
local gfx <const> = playdate.graphics

class('CreditsScene').extends(gfx.sprite)


function CreditsScene:init()
    self.bgImage = gfx.image.new("images/bg/darkcloth")
    self.bgSprite = gfx.sprite.new(self.bgImage)
    self.bgSprite:moveTo(200,120)
    self.bgSprite:add()

    
    gfx.setImageDrawMode(gfx.kDrawModeNXOR) -- for text color

    self.titleText = gfx.sprite.spriteWithText("CREDITS", 400, 200, nil, nil, nil, kTextAlignment.center)  
    self.titleText:moveTo(200, 30)
    self.titleText:setScale(1)
    self.titleText:add()


    self.creditsEnd = false
    

        

    
    self.creditsText = "\n\nWEE TAROT \n\n\n" ..
                       "Game by\nmama \n\n" ..
                       "Cards by\nSarah Seekins \n\n" ..
                       "Sound by\nFilipe Miu \n\n" ..
                       "Thanks!\nCler McCallum\nFelipe Miu\nVitor Fiacadori\nRaphaël Calabro\nPD Community\nMãe Dináh\n\n\n\n" ..
                       "xxx" ..
                        "\n\n"

    self.scrollBoxHeight = 160
    self.scrollBoxWidth = 300
    self.minScroll = -60 -- Start 60px below the top
    self.scrollY = self.minScroll
    local _, textHeight = gfx.getTextSizeForMaxWidth(self.creditsText, self.scrollBoxWidth)
    self.maxScroll = math.max(0, textHeight - self.scrollBoxHeight)
    self.scrollSpeed = 1 -- pixels per frame, adjust as needed
 
    
    self:drawScrollTextWindow(50, 60)

    self:add()
    
end


function CreditsScene:drawScrollTextWindow(x, y)
    local img = gfx.image.new(self.scrollBoxWidth, self.scrollBoxHeight)
    gfx.pushContext(img)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        --gfx.setColor(gfx.kColorBlack)
        gfx.drawTextInRect(self.creditsText, 0, -self.scrollY, self.scrollBoxWidth, 1500, nil, "...", kTextAlignment.center)
    gfx.popContext()
    if self.creditSprite then self.creditSprite:remove() end
    self.creditSprite = gfx.sprite.new(img)
    self.creditSprite:setCenter(0, 0)
    self.creditSprite:moveTo(x, y)
    self.creditSprite:add()
end




function CreditsScene:update()
    -- Animate scrollY up to maxScroll
    if self.scrollY < self.maxScroll then
        self.scrollY = math.min(self.scrollY + self.scrollSpeed, self.maxScroll)
        self.scrollY = math.max(self.scrollY, self.minScroll)
        self:drawScrollTextWindow(50, 60) -- adjust x, y as needed
    end

    if self.scrollY >= self.maxScroll then
        -- Optionally, after a delay, switch scene
        if not self.creditsEnd then
            self.creditsEnd = true
            
            pd.timer.performAfterDelay(2000, function()
                cards_fast2:play(1)
                SCENE_MANAGER:switchScene(SettingsScene)
            end)
        end
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        cards_slow:play(1)
        SCENE_MANAGER:switchScene(SettingsScene)
    end

end



