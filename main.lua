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

-- local simple_template = '.34....7.......36.71.....28..25.7...57.....1...38..5..82..6........7.14.6..1....3'
math.randomseed(playdate.getSecondsSinceEpoch())
local file_number = math.random(1,10)
local random_difficutly = math.random(1,4)
local file_name = "puzzles/"..difficutly[random_difficutly]..file_number..".json"
local file_name = "puzzles/"..difficutly[1]..file_number..".json"
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



function myGameSetUp()
    local midpointx, midpointy = playdate.display.getWidth() / 2, playdate.display.getHeight() / 2
    local boardSize = playdate.display.getHeight() *.95
    mainBoard:add()
    mainBoard:setSize(boardSize,boardSize)
    mainBoard:moveTo(midpointx,midpointy)
end

myGameSetUp()

local buttonCanBePressed = {
    ["up"] = true,
    ["down"] = true,
    ["left"] = true,
    ["right"] = true,
    ["a"] = true,
    ["b"] = true
}
function setBoolToTrue(bool)
    buttonCanBePressed[bool] = true
end


local movespeed = 200



function moveSelected(bool,rowMove, columnMove,board)
    if buttonCanBePressed[bool] then
        buttonCanBePressed[bool] = false
        playdate.timer.new(movespeed,setBoolToTrue,bool)
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
  if buttonCanBePressed[bool] then
      buttonCanBePressed[bool] = false
      playdate.timer.new(movespeed,setBoolToTrue,bool)
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






function playdate.update()

    handleButtonsforBoard(mainBoard)
    gfx.sprite.update()
    playdate.timer.updateTimers()

end
