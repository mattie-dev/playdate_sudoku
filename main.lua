-- import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "boardClass"

local gfx <const> = playdate.graphics
local menu = playdate.getSystemMenu()


gfx.setImageDrawMode(gfx.kDrawModeNXOR)
gfx.setBackgroundColor(gfx.kColorWhite)
gfx.setColor(gfx.kColorXOR)
gfx.clear()

-- getmetatable('').__index = function(str,i) return string.sub(str,i,i) end

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
    local titleLabel = setupLabel("*Select Difficutly*", true, screenWidth / 2, screenHeight / 8)
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
        if settings[button.property] then
            gfx.drawLine(x+width-20,y,width,height)
            gfx.drawLine(x+width-20,height,width,y)
        end
        gfx.drawText(text, x,y)
    end
    button.clickAction = clickAction
    return button
end

function findSign(x)
   if x<0 then
     return -1
   elseif x>0 then
     return 1
   else
     return 0
   end
end

function setUpdateForBoard(board)
    function board:update()
        handleButtonsforBoard(board)
        local temp = playdate.getCrankTicks(4)
        if temp ~= 0 then
            local sign = findSign(temp)
            incrementSelectedWithCarnk("crank",math.floor(sign),board)
          -- for i=sign,temp,sign do
          --     incrementSelectedWithCarnk("crank",math.floor(sign),board)
          --   end
        end
    end
    return board
end


function setUpBoard(diff)
    local file_number = math.random(1,10)
    local random_difficutly = math.random(1,4)
    -- local file_name = "puzzles/"..difficutly[random_difficutly]..file_number..".json"
    local file_name = "puzzles/"..difficutly[diff]..file_number..".json"
    local simple_file = playdate.file.open(file_name)
    local simple_json = json.decodeFile(simple_file)
    local puzzle_index = math.random(1,10000)
    simple_template = simple_json[""..puzzle_index..""]
    puzzleCount = nil
    simple_file = nil
    simple_json = nil
    
    local mainBoard = gfx.sprite.new()
    mainBoard.boardData = generateBoard(simple_template)
    for index=1, 81 do
      print(mainBoard.boardData.boxs[index].number.."hi")
    end
    setDrawForBoardSprite(mainBoard)
    setUpdateForBoard(mainBoard)
    return mainBoard
end
function reSetUpBoard(oldBoard)  
    local mainBoard = gfx.sprite.new()
    local template = ""
    for i=1,81 do
      template = template .. (oldBoard.boardData.boxs[i].number ~= 0 and oldBoard.boardData.boxs[i].number or ".")
    end
    mainBoard.boardData = generateBoard(template)
    for i=1,81 do
      mainBoard.boardData.boxs[i].status = oldBoard.boardData.boxs[i].status
    end
    setDrawForBoardSprite(mainBoard)
    setUpdateForBoard(mainBoard)
    return mainBoard
end

function showBoardInstrucitons()
  local leftSide = gfx.sprite.new()
  leftSide:add()
  leftSide:setSize(100,465)
  leftSide:moveTo(30,0)
  local rightSide = gfx.sprite.new()
  rightSide:add()
  rightSide:setSize(100,465)
  rightSide:moveTo(playdate.display.getWidth()-30,0)
  function leftSide:draw(x, y, width, height)
    -- gfx.drawRect(x,y,width,height)
    gfx.drawTextAligned("*How To\nPlay*\n\n*D-Pad*:\nMove\n\n*A/Crank*:\nIncrease\n\n*B/Crank*:\nDecrease", x + width/2, y+ 10, kTextAlignment.center)
  end
  function rightSide:draw(x, y, width, height)
    -- gfx.drawRect(x,y,width,height)
    gfx.drawTextAligned("*How To\nPlay*\n\n*Menu*:\nGo Home\n\nReturns\nHome\nWhen\nComplete", x + width/2, y+ 10, kTextAlignment.center)
  end
end


function myGameSetUp(board)
    local midpointx, midpointy = playdate.display.getWidth() / 2, playdate.display.getHeight() / 2
    local boardSize = playdate.display.getHeight() *.95
    board:add()
    board:setSize(boardSize,boardSize)
    board:moveTo(midpointx,midpointy)
    local menuItem, error = menu:addMenuItem("Sudoku Home", function()
        titleScreen = setUpTitleScreen()
    end)
    if settings["Show Instructions"] then
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




-- local buttonCanBePressed = {
--     ["up"] = true,
--     ["down"] = true,
--     ["left"] = true,
--     ["right"] = true,
--     ["a"] = true,
--     ["b"] = true
-- }
function setBoolToTrue(bool, data)
    data.buttonCanBePressed[bool] = true
end






function moveSelected(bool,rowMove, columnMove,board)
    if board.boardData.buttonCanBePressed[bool] then
        board.boardData.buttonCanBePressed[bool] = false
        playdate.timer.new(movespeed,setBoolToTrue, bool, board.boardData)
        local newRow = board.boardData.selected.row + rowMove
        if newRow <1 then
            newRow = 1
        elseif newRow > 9 then
            newRow = 9
        end
        local newColumn = board.boardData.selected.column + columnMove
        if newColumn <1 then
            newColumn = 1
        elseif newColumn > 9 then
            newColumn = 9
        end
        board.boardData.selected = board.boardData.rows[newRow][newColumn]
        board:markDirty()
    end
end

function incrementSelected(bool,amountToAdd, board)
  if board.boardData.buttonCanBePressed[bool] then
      board.boardData.buttonCanBePressed[bool] = false
      playdate.timer.new(movespeed,setBoolToTrue,bool,board.boardData)
      if board.boardData.selected.status == status["Empty"] or board.boardData.selected.status == status["Guessed"] then
          local newNumber = board.boardData.selected.number + amountToAdd
          board.boardData.selected.status = status["Guessed"]
          if newNumber > 9 then
              newNumber = 9
          elseif newNumber <= 0 then
              newNumber = 0
              board.boardData.selected.status = status["Empty"]
          end
          board.boardData.selected.number = newNumber
          
          board:markDirty()
      end
      if checkIfBoardIsFinishedAndValid(board) then
        print("Congradgulations!")
        playdate.timer.new(5000,setUpTitleScreen)
      end
  end  
end

function handleButtonsforBoard(board)
    if playdate.buttonIsPressed( playdate.kButtonUp ) then
        moveSelected('up', -1, 0, board)
    end
    if playdate.buttonIsPressed( playdate.kButtonRight ) then
        moveSelected('right', 0, 1, board)
    end
    if playdate.buttonIsPressed( playdate.kButtonDown ) then
        moveSelected('down', 1, 0, board)
    end
    if playdate.buttonIsPressed( playdate.kButtonLeft ) then
        moveSelected('left', 0, -1, board)
    end
    if playdate.buttonIsPressed( playdate.kButtonA ) then
        incrementSelected('a',1, board)
    end
    if playdate.buttonIsPressed( playdate.kButtonB ) then
        incrementSelected('b',-1, board)
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


function incrementSelectedWithCarnk(bool,amountToAdd, board)
  if board.boardData.buttonCanBePressed[bool] then
      -- board.boardData.buttonCanBePressed[bool] = false
      playdate.timer.new(movespeed,setBoolToTrue,bool,board.boardData)
      if board.boardData.selected.status == status["Empty"] or board.boardData.selected.status == status["Guessed"] then
          local newNumber = board.boardData.selected.number + amountToAdd
          board.boardData.selected.status = status["Guessed"]
          if newNumber > 9 then
              newNumber = 9
          elseif newNumber <= 0 then
              newNumber = 0
              board.boardData.selected.status = status["Empty"]
          end
          board.boardData.selected.number = newNumber
          
          board:markDirty()
      end
  end  
  if checkIfBoardIsFinishedAndValid(board) then
    print("Congradgulations!")
    playdate.timer.new(5000,setUpTitleScreen)
  end
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






