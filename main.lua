-- import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"


-- import "smallBoxClass"
import "boardClass"

local gfx <const> = playdate.graphics

gfx.setImageDrawMode(gfx.kDrawModeNXOR)
gfx.clear()

getmetatable('').__index = function(str,i) return string.sub(str,i,i) end

difficutly = {
    [1] = "simple",
    [2] = "easy",
    [3] = "intermediate",
    [4] = "expert"
}
math.randomseed(playdate.getSecondsSinceEpoch())
-- local simple_template = '.34....7.......36.71.....28..25.7...57.....1...38..5..82..6........7.14.6..1....3'

movespeed = 200
function saveGameData(board)
  if board ~=nil then
    playdate.datastore.write(board, "board_table", true) 
  end
end
function removeGameData()
    playdate.datastore.delete("board_table") 
end
-- removeGameData()

function setUpTitleScreen()
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
      newGameGameButton = setupButton("*New Game*", true, false, screenWidth / 2, screenHeight* (7/10), startNewGame)
      optionsButton = setupButton("*options*", true, false, screenWidth / 2, screenHeight* (9/10), startNewGame)
      titleScreen = {["title"]=titleLabel,["Buttons"]={continueButton,newGameGameButton,optionsButton}, ["selected"]=continueButton,["buttonCanBePressed"] = {["up"] = true,["down"] = true,["left"] = true,["right"] = true,["a"] = true,["b"] = true
      }}
    else
      newGameGameButton = setupButton("*New Game*", true, true, screenWidth / 2, screenHeight* (5/10), startNewGame)
      optionsButton = setupButton("*options*", true, false, screenWidth / 2, screenHeight* (7/10), startNewGame)
      titleScreen = {["title"]=titleLabel,["Buttons"]={newGameGameButton,optionsButton}, ["selected"]=newGameGameButton,["buttonCanBePressed"] = {["up"] = true,["down"] = true,["left"] = true,["right"] = true,["a"] = true,["b"] = true
      }}
    end
        handleButtonsforbuttons(titleScreen)
    return titleScreen
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

function setUpdateForBoard(board)
    function board:update()
        handleButtonsforBoard(board)
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
    setDrawForBoardSprite(mainBoard)
    setUpdateForBoard(mainBoard)
    return mainBoard
end
function reSetUpBoard(oldBoard)  
    local mainBoard = gfx.sprite.new()
    mainBoard.boardData = oldBoard.boardData
    setDrawForBoardSprite(mainBoard)
    setUpdateForBoard(mainBoard)
    return mainBoard
end
function myGameSetUp(board)
    local midpointx, midpointy = playdate.display.getWidth() / 2, playdate.display.getHeight() / 2
    local boardSize = playdate.display.getHeight() *.95
    board:add()
    board:setSize(boardSize,boardSize)
    board:moveTo(midpointx,midpointy)
end



function startNewGame(screen)
  gfx.sprite.removeAll()
  mainBoard = setUpBoard(1)
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
        if playdate.buttonIsPressed( playdate.kButtonA ) then
            screen.selected.clickAction(screen)
        end
        if playdate.buttonIsPressed( playdate.kButtonB ) then
            
        end
    end
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






