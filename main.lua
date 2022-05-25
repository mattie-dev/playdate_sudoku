-- import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "boardClass"
import "button"
import "checkBoxButtons"

local gfx <const> = playdate.graphics
local menu = playdate.getSystemMenu()


gfx.setImageDrawMode(gfx.kDrawModeNXOR)
gfx.setBackgroundColor(gfx.kColorWhite)
gfx.setColor(gfx.kColorXOR)
gfx.clear()

difficutly = {
    [1] = "simple",
    [2] = "easy",
    [3] = "intermediate",
    [4] = "expert"
}
math.randomseed(playdate.getSecondsSinceEpoch())

movespeed = 200
settings = {
  ["Dark Mode"]=false,
  ["Highlight same sumber as selected"] = false,
  ["Indicate where number can't go"] = false,
  ["Show Instructions"]=false
}
function saveSettings()
  playdate.datastore.write(settings, "settings", true)
  useSettings()
end
function setSettings()
  if playdate.datastore.read("settings") ~= nil then
    settings = playdate.datastore.read("settings")
    useSettings()
  else
    saveSettings()
  end
end
function useSettings()
  if settings["Dark Mode"] then
    playdate.display.setInverted(true)
  else
    playdate.display.setInverted(false)
  end
end

setSettings()



function saveGameData(board)
  if board ~=nil then
    playdate.datastore.write(board, "board_table", true) 
  end
  
end
function removeGameData()
    playdate.datastore.delete("board_table") 
end
function useless()
end
-- removeGameData()


function setUpTitleScreen()
    menu:removeAllMenuItems()
    gfx.sprite.removeAll()
    local screenWidth= playdate.display.getWidth() 
    local screenHeight = playdate.display.getHeight() 
    local titleLabel = setupLabel("*Sudoku*", true, screenWidth / 2, screenHeight / 4)
    local continueButton = {}
    local newGameGameButton = {}
    local optionsButton = {}
    local titleScreen = {}
    -- local testBoard = setUpBoard(1)
    -- saveGameData(testBoard)
    if playdate.datastore.read("board_table") ~= nil then
      continueButton = setupButton("*Continue*", true, true,screenWidth / 2, screenHeight* (5/10), resumeGame)
      newGameGameButton = setupButton("*New Game*", true, false, screenWidth / 2, screenHeight* (7/10), showDifficultyScreen)
      settingsButton = setupButton("*Settings*", true, false, screenWidth / 2, screenHeight* (9/10), showSettingsScreen)
      titleScreen = {["title"]=titleLabel,["Buttons"]={continueButton,newGameGameButton,settingsButton}, ["selected"]=continueButton,["buttonCanBePressed"] = {["up"] = true,["down"] = true,["left"] = true,["right"] = true,["a"] = true,["b"] = true
      }, ["backAction"] = useless}
    else
      newGameGameButton = setupButton("*New Game*", true, true, screenWidth / 2, screenHeight* (5/10), showDifficultyScreen)
      settingsButton = setupButton("*Settings*", true, false, screenWidth / 2, screenHeight* (7/10), showSettingsScreen)
      titleScreen = {["title"]=titleLabel,["Buttons"]={newGameGameButton,settingsButton}, ["selected"]=newGameGameButton,["buttonCanBePressed"] = {["up"] = true,["down"] = true,["left"] = true,["right"] = true,["a"] = true,["b"] = true
      }, ["backAction"] = useless}
    end
        handleButtonsforbuttons(titleScreen)
    return titleScreen
end

function setUpDifficultyScreen()
    local screenWidth= playdate.display.getWidth() 
    local screenHeight = playdate.display.getHeight() 
    local titleLabel = setupLabel("*Select Difficutly*", true, screenWidth / 2, screenHeight / 8)
    local easyButton = {}
    local normalButton = {}
    local hardButton = {}
    local veryHardButton = {}
    local difficutlyScreen = {}
    -- local testBoard = setUpBoard(1)
    -- saveGameData(testBoard)
    easyButton = setupButton("*Easy*", true, true,screenWidth / 2, screenHeight* (3/10), startNewGame)
    normalButton = setupButton("*Normal*", true, false, screenWidth / 2, screenHeight* (5/10), startNewGame)
    hardButton = setupButton("*Hard*", true, false, screenWidth / 2, screenHeight* (7/10), startNewGame)
    veryHardButton = setupButton("*Very Hard*", true, false, screenWidth / 2, screenHeight* (9/10), startNewGame)
    difficutlyScreen = {["title"]=titleLabel,["Buttons"]={easyButton,normalButton,hardButton, veryHardButton}, ["selected"]=easyButton,["buttonCanBePressed"] = {["up"] = true,["down"] = true,["left"] = true,["right"] = true,["a"] = false,["b"] = true
    },["difficulty"]=1, ["backAction"] = showTitleScreen}
    handleButtonsforbuttons(difficutlyScreen)
    playdate.timer.new(movespeed,setBoolToTrue, "a", difficutlyScreen)
    return difficutlyScreen
end

function setUpSettingsScreen()
    local screenWidth= playdate.display.getWidth() 
    local screenHeight = playdate.display.getHeight() 
    local titleLabel = setupLabel("*Settings*", true, screenWidth / 2, screenHeight / 8)
    local darkModeButton = {}
    local similarButton = {}
    local wrongButton = {}
    local instructionButton = {}
    local settingsScreen = {}
    darkModeButton = setupCheckBoxAndLabel("*Dark Mode*", true, true,screenWidth / 2, screenHeight* (3/10), togglePropertyInSettings, "Dark Mode")
    similarButton = setupCheckBoxAndLabel("*Highlight Similar*", true, false, screenWidth / 2, screenHeight* (5/10), togglePropertyInSettings,  "Highlight same sumber as selected")
    wrongButton = setupCheckBoxAndLabel("*Show Blocked Boxs*", true, false, screenWidth / 2, screenHeight* (7/10), togglePropertyInSettings,  "Indicate where number can't go")
    instructionButton = setupCheckBoxAndLabel("*Show Instructions*", true, false, screenWidth / 2, screenHeight* (9/10), togglePropertyInSettings,  "Show Instructions")
    settingsScreen = {["title"]=titleLabel,["Buttons"]={darkModeButton,similarButton,wrongButton, instructionButton}, ["selected"]=darkModeButton,["buttonCanBePressed"] = {["up"] = true,["down"] = true,["left"] = true,["right"] = true,["a"] = false,["b"] = true
    }, ["backAction"] = showTitleScreen}
    handleButtonsforCheckBoxs(settingsScreen)
    return settingsScreen
end

function togglePropertyInSettings(property)
  settings[property] = not settings[property]
  saveSettings()
end


function setupLabel(text,isBold, x, y)
    local label = gfx.sprite.new()
    local labelWidth = gfx.getTextSize(text)
    local labelHeight = gfx.getFont(isBold and gfx.font.kVariantBold or gfx.font.kVariantNormal):getHeight()
    label:add()
    label:setSize(labelWidth, labelHeight)
    label:moveTo(x, y)
    function label:draw(x, y, width, height)
        gfx.drawText(text, x,y)
    end
    return label
end



function showBoardInstrucitons()
  local leftSide = gfx.sprite.new()
  leftSide:add()
  leftSide:setSize(100,465)
  leftSide:moveTo(30,0)
  local rightSide = gfx.sprite.new()
  rightSide:add()
  rightSide:setSize(100,415)
  rightSide:moveTo(playdate.display.getWidth()-30,0)
  function leftSide:draw(x, y, width, height)
    -- gfx.drawRect(x,y,width,height)
    gfx.drawTextAligned("*How To\nPlay*\n\n*D-Pad*:\nMove\n\n*A/Crank*:\nIncrease\n\n*B/Crank*:\nDecrease", x + width/2, y+ 10, kTextAlignment.center)
  end
  function rightSide:draw(x, y, width, height)
    -- gfx.drawRect(x,y,width,height)
    gfx.drawTextAligned("*Menu*:\nGo Home\nON/OFF\nGuide\n\nGame\nDetects\nWhen\nComplete", x + width/2, y+ 10, kTextAlignment.center)
  end
end


function myGameSetUp(board)
    local midpointx, midpointy = playdate.display.getWidth() / 2, playdate.display.getHeight() / 2
    local boardSize = playdate.display.getHeight() *.95
    board:add()
    board:setSize(boardSize,boardSize)
    board:moveTo(midpointx,midpointy)
    timerLabel = gfx.sprite.new()
    timerLabel:add()
    timerLabel:setSize(70, 18)
    timerLabel:moveTo(playdate.display.getWidth()-40,225)
    -- board.boardData.timeInSeconds = 0
    function board:OncePerSecond()
        board.boardData.timeInSeconds = board.boardData.timeInSeconds + 1
        boardTimer = playdate.timer.new(1000,board.OncePerSecond)
        timerLabel:markDirty()
    end
    boardTimer = playdate.timer.new(1000,board.OncePerSecond)
    function timerLabel:draw(x, y, width, height)
      -- gfx.drawRect(x,y,width,height)
      local minute = board.boardData.timeInSeconds//60 > 9 and tostring(board.boardData.timeInSeconds//60) or "0"..tostring(board.boardData.timeInSeconds//60)
      local second = board.boardData.timeInSeconds%60 > 9 and tostring(board.boardData.timeInSeconds%60) or "0"..tostring(board.boardData.timeInSeconds%60)
      gfx.drawTextAligned(minute..":"..second, x + width/2, y + 1, kTextAlignment.center)
    end
    local menuItem, error = menu:addMenuItem("Sudoku Home", function()
      boardTimer:remove()
        titleScreen = setUpTitleScreen()
        saveGameData(board)
    end)
    local checkmarkMenuItem, error = menu:addCheckmarkMenuItem("Instructions", settings["Show Instructions"], function(value)
        local temp = settings["Show Instructions"]
        if temp ~= value then
          settings["Show Instructions"] = value
          saveSettings()
          if settings["Show Instructions"] and not board.completed then
            showBoardInstrucitons()
          else
            gfx.sprite:removeAll()
            board:add()
            timerLabel:add()
          end
        end
    end)
    if settings["Show Instructions"] and not board.completed then
      showBoardInstrucitons()
    end
end



function startNewGame(screen)
  gfx.sprite.removeAll()
  local dif = screen.difficulty ~= nil and screen.difficulty or 1
  mainBoard = setUpBoard(dif)
  myGameSetUp(mainBoard)
end
function resumeGame()
  gfx.sprite.removeAll()
  mainBoard = reSetUpBoard(playdate.datastore.read("board_table"))
  myGameSetUp(mainBoard)
end


function setBoolToTrue(bool, data)
    data.buttonCanBePressed[bool] = true
end

function finshedBoard(board)
  saveGameData(board)
  board.completed = true
  gfx.sprite:removeAll()
  board:add()
  timerLabel:add()
  boardTimer:remove()
  local screenWidth= playdate.display.getWidth() 
  local screenHeight = playdate.display.getHeight() 
  local congradulatioinsLabel = gfx.sprite.new()
  congradulatioinsLabel:add()
  local text = "*Congradulations*"
  local labelWidth = gfx.getTextSize(text)
  local labelHeight = gfx.getFont(gfx.font.kVariantBold):getHeight()
  timerLabel:moveTo((labelWidth/2) *1.2,200)
  congradulatioinsLabel:setSize(labelWidth*1.1,labelHeight*4.1)
  congradulatioinsLabel:moveTo((labelWidth/2) *1.2, screenHeight/2)
  congradulatioinsLabel.countDown = 11
  board:moveBy(labelWidth/2,0)
  board.boardData.selected = nil
  function board:update()
    
  end
  function congradulatioinsLabel:draw(x, y, width, height)
    gfx.fillRect(x,y,width,height)
    -- gfx.drawText(text,x+labelWidth*0.05,y+labelHeight*0.05)
    gfx.drawTextAligned("*Congradulations*", x+(labelWidth/2)+(labelWidth*0.05),y+(labelHeight/2)+(labelHeight*0.05), kTextAlignment.center)
    gfx.drawTextAligned("Return Home In:", x+(labelWidth/2)+(labelWidth*0.05),y+(labelHeight/2)+(labelHeight*1.1), kTextAlignment.center)
    gfx.drawTextAligned(self.countDown, x+(labelWidth/2)+(labelWidth*0.05),y+(labelHeight/2)+(labelHeight*2.05), kTextAlignment.center)
  end
  function congradulatioinsLabel:updateCountDown()
    if congradulatioinsLabel.countDown >1 then
      congradulatioinsLabel.countDown = congradulatioinsLabel.countDown-1
      congradulatioinsLabel:markDirty()
      playdate.timer.new(1000,congradulatioinsLabel.updateCountDown)
    else
      setUpTitleScreen()
    end
  end
  congradulatioinsLabel.updateCountDown()
  -- playdate.timer.new(11000,setUpTitleScreen)
end

function showDifficultyScreen()
  gfx.sprite.removeAll()
  difficutlyScreen = setUpDifficultyScreen()
end
function showSettingsScreen()
  gfx.sprite.removeAll()
  settingsScreen = setUpSettingsScreen()
end
function showTitleScreen()
  gfx.sprite.removeAll()
  titlScreenScreen = setUpTitleScreen()
end

local titleScreen = setUpTitleScreen()

function playdate.update()
    gfx.sprite.update()
    playdate.timer.updateTimers()
end

function playdate.gameWillTerminate()
  saveGameData(mainBoard)
end

function playdate.deviceWillSleep()
  saveGameData(mainBoard)
end
function playdate.deviceWillLock()
  saveGameData(mainBoard)
end


