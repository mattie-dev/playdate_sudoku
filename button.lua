import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
local gfx <const> = playdate.graphics

function setupButton(text, isBold, isSelected, x, y, clickAction)
    local button = gfx.sprite.new()
    local buttonWidth = gfx.getTextSize(text)
    local buttonHeight = gfx.getFont(isBold and gfx.font.kVariantBold or gfx.font.kVariantNormal):getHeight()
    button.isSelected = isSelected
    button:add()
    button:setSize(buttonWidth+20, buttonHeight+10)
    button:moveTo(x, y)
    function button:draw(x, y, width, height)
        if button.isSelected then
            gfx.fillRoundRect(x,y,width,height,6)
        else
            gfx.drawRoundRect(x,y,width,height,6)
        end
        gfx.drawText(text, x+10,y+7)
    end
    button.clickAction = clickAction
    return button
end

function handleButtonsforbuttons(screen)
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
            screen.selected.clickAction(screen)
        end
        if playdate.buttonJustPressed( playdate.kButtonB ) then
            screen.backAction()
        end
    end
end

function cycleThroughButtonsOnScreen(bool,screen,movement)
  if screen.buttonCanBePressed[bool] then
    screen.buttonCanBePressed[bool] = false
    playdate.timer.new(movespeed,setBoolToTrue, bool, screen)
      local newSelected = table.indexOfElement(screen.Buttons, screen.selected) + movement
      if newSelected < 1 then
         newSelected = table.getsize(screen.Buttons)
      elseif newSelected > table.getsize(screen.Buttons) then
          newSelected = 1
      end
      screen.selected:markDirty()
      screen.selected.isSelected = false
      screen.selected = screen.Buttons[newSelected]
      screen.difficulty = newSelected
      screen.selected.isSelected = true
      screen.selected:markDirty()
  end
end