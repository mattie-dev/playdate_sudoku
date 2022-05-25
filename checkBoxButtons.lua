import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
local gfx <const> = playdate.graphics


function setupCheckBoxAndLabel(text, isBold, isSelected, x, y, clickAction, property)
    local button = gfx.sprite.new()
    local buttonWidth = gfx.getTextSize(text)
    local buttonHeight = gfx.getFont(isBold and gfx.font.kVariantBold or gfx.font.kVariantNormal):getHeight()
    button.isSelected = isSelected
    button.isSet = isSet
    button.property = property
    button:add()
    button:setSize(buttonWidth+30, buttonHeight)
    button:moveTo(x, y)
    function button:draw(x, y, width, height)
        if button.isSelected then
            gfx.fillRect(x+width-20,y,20,height)
        else
            gfx.drawRect(x+width-20,y,20,height)
        end
      gfx.setColor(gfx.kColorXOR)
        if settings[button.property] then
            gfx.drawLine(x+width-20,y,width,height)
            gfx.drawLine(x+width-20,height,width,y)
        end
        gfx.drawText(text, x,y)
        gfx.setColor(gfx.kColorXOR)
    end
    button.clickAction = clickAction
    return button
end



function handleButtonsforCheckBoxs(screen)
    function screen.title:update()
        if playdate.buttonIsPressed( playdate.kButtonUp ) then
          cycleThroughButtonsOnScreen("up",screen, -1)
        end
        if playdate.buttonIsPressed( playdate.kButtonRight ) then
            
        end
        if playdate.buttonIsPressed( playdate.kButtonDown ) then
            cycleThroughButtonsOnScreen("down",screen, 1)
        end
        if playdate.buttonIsPressed( playdate.kButtonLeft ) then
            
        end
        if playdate.buttonJustPressed( playdate.kButtonA ) then
            screen.selected.clickAction(screen.selected.property)
            screen.selected:markDirty()
        end
        if playdate.buttonJustPressed( playdate.kButtonB ) then
            screen.backAction()
        end
    end
end