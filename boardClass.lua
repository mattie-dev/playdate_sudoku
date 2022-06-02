-- import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics

status = {
    ["Given"] = 1,
    ["Empty"] = 2,
    ["Guessed"] = 3
}

function generateBoard(template,timeSpent)
    local board = {}
    board.boxs = {}
    board.rows = {{}, {}, {}, {}, {}, {}, {}, {}, {}}
    board.columns = {{}, {}, {}, {}, {}, {}, {}, {}, {}}
    board.bigBoxs = {{}, {}, {}, {}, {}, {}, {}, {}, {}}
    local numbers = {}
    template:gsub(".",function(c) table.insert(numbers,c) end)
    for r=1, 9 do
        for c=1, 9 do
            n = (c) + ((r-1) * 9)
            local b = {
                ["row"]=r,
                ["column"]=c,
                ["number"]=numbers[n] ~= "." and numbers[n] or 0,
                ["possible"]={
                    [1] = false,
                    [2] = false,
                    [3] = false,
                    [4] = false,
                    [5] = false,
                    [6] = false,
                    [7] = false,
                    [8] = false,
                    [9] = false
                },
                ["status"]=numbers[n] ~= "." and status["Given"] or status["Empty"],
                ["bigBox"]=findBigBoxGivenRowAndColumn(r,c)
            }
            if board.number == 0 then
                board.status = status['Empty']
            end
            table.insert(board.boxs,b)
            table.insert(board.rows[b.row],b)
            table.insert(board.columns[b.column],b)
            table.insert(board.bigBoxs[b.bigBox],b)
        end
    end
    board.selected = board.boxs[1]
    board.buttonCanBePressed = {
        ["up"] = true,
        ["down"] = true,
        ["left"] = true,
        ["right"] = true,
        ["a"] = false,
        ["b"] = true,
        ["crank"] = true
    }
    board.timeInSeconds = timeSpent or 0
    board.completed = false
    -- board.possibleSprite = gfx.sprite.new()
    -- board.possibleSprite.selected = 1
    board.isNoting = false
    board.possibleSelected = 5
    playdate.timer.new(movespeed,setBoolToTrue, "a", board)
    return board
end



function setDrawForBoardSprite(boardSprite)
    function boardSprite:draw(x, y, width, height)
        gfx.setColor(gfx.kColorBlack == gfx.getBackgroundColor() and gfx.kColorWhite or gfx.kColorBlack)
        local thickLineWidth, thinLineWidth = 5, 1
        local smallBoxWidth = width/9 
        local smallBoxHeight = height/9
        gfx.setLineWidth(thickLineWidth)
        gfx.drawRect(0, 0, width, height)
        -- Draw Thick Lines
        gfx.drawLine(0,height/3,width,height/3)
        gfx.drawLine(0,2*height/3,width,2*height/3)
        gfx.drawLine(width/3,0,width/3,height)
        gfx.drawLine(2*width/3,0,2*width/3,height)
        -- Draw Thin Lines
        gfx.setLineWidth(thinLineWidth)
        gfx.drawLine(0,(1*height)/9,width,(1*height)/9)
        gfx.drawLine(0,(2*height)/9,width,(2*height)/9)
        gfx.drawLine(0,(4*height)/9,width,(4*height)/9)
        gfx.drawLine(0,(5*height)/9,width,(5*height)/9)
        gfx.drawLine(0,(7*height)/9,width,(7*height)/9)
        gfx.drawLine(0,(8*height)/9,width,(8*height)/9)
        gfx.drawLine((1*width)/9,0,(1*width)/9,height)
        gfx.drawLine((2*width)/9,0,(2*width)/9,height)
        gfx.drawLine((4*width)/9,0,(4*width)/9,height)
        gfx.drawLine((5*width)/9,0,(5*width)/9,height)
        gfx.drawLine((7*width)/9,0,(7*width)/9,height)
        gfx.drawLine((8*width)/9,0,(8*width)/9,height)
        if self.boardData.selected ~= nil  and not self.boardData.isNoting then
            local selectedx, selectedy = ((self.boardData.selected.column-1)*smallBoxWidth), ((self.boardData.selected.row-1)*smallBoxHeight)
            playdate.graphics.fillRect(selectedx, selectedy, smallBoxWidth+1, smallBoxHeight+1)
        end
        for index=1, 81 do
            local sbx = ((self.boardData.boxs[index].column-1)*smallBoxWidth)
            local sby = ((self.boardData.boxs[index].row-1)*smallBoxHeight)
            if self.boardData.boxs[index].number == 0 then
              drawPossibleNumbersForSmallBox(sbx,sby,smallBoxWidth,smallBoxHeight,self.boardData,index)
            end
            drawSmallBoxNumber(self.boardData,sbx,sby,smallBoxWidth,smallBoxHeight,index)
            if settings["Highlight same sumber as selected"] and self.boardData.selected ~= nil then
                highlightSameNumber(self, index, thickLineWidth, sbx, sby, smallBoxWidth, smallBoxHeight)
            end
            if settings["Indicate where number can't go"] and self.boardData.selected ~= nil then
                indicateSpotsNumberCanNotGo(self, index, sbx, sby, smallBoxWidth, smallBoxHeight)
            end
        end
    end
    gfx.setColor(gfx.kColorXOR)
    return boardSprite
end

function drawSmallBoxNumber(boardData,x,y,width,height,index)
  local text = boardData.boxs[index].number ~= 0 and boardData.boxs[index].number or ''
  if boardData.boxs[index].status == status["Given"] then
      local textWidth = gfx.getTextSize("*"..text)
      local textHeight = gfx.getFont(gfx.font.kVariantBold):getHeight()
      gfx.drawTextAligned("*"..text,x + (width/2), y+(height - textHeight),kTextAlignment.center)
  else
      local textWidth = gfx.getTextSize(text)
      local textHeight = gfx.getFont():getHeight()
      gfx.drawTextAligned(text,x + (width/2 ), y+(height - textHeight),kTextAlignment.center)
  end
end


function drawPossibleNumbersForSmallBox(x,y,width,height, boardData,index)
  local originalSystemFont = gfx.getSystemFont()
  local possibleNumberFont = gfx.font.new("font-Bitmore")
  gfx.setFont(possibleNumberFont)
  local x1,x2,x3 = x+width*(1/6), x+width*(3/6), x+width*(5/6)
  local y1,y2, y3 = y+height*(1/12), y+height*(5/12), y+height*(9/12)
  local w1 = width*(1/3)
  local w2 = width*(2/3)
  local w3 = width*(3/3)
  local h1 = height*(1/3)
  local h2 = height*(2/3)
  local h3 = height*(3/3)
  if boardData.isNoting and boardData.selected == boardData.boxs[index] then
    if boardData.possibleSelected == 1 then
      gfx.fillRect(x,y,w1,h1)
    elseif boardData.possibleSelected == 2 then
      gfx.fillRect(x+w1,y,w1,h1)
    elseif boardData.possibleSelected == 3 then
      gfx.fillRect(x+w2,y,w1,h1)
    elseif boardData.possibleSelected == 4 then
      gfx.fillRect(x,y+h1,w1,h1)
    elseif boardData.possibleSelected == 5 then
      gfx.fillRect(x+w1,y+h1,w1,h1)
    elseif boardData.possibleSelected == 6 then
      gfx.fillRect(x+w2,y+h1,w1,h1)
    elseif boardData.possibleSelected == 7 then
      gfx.fillRect(x,y+h2,w1,h1)
    elseif boardData.possibleSelected == 8 then
      gfx.fillRect(x+w1,y+h2,w1,h1)
    elseif boardData.possibleSelected == 9 then
      gfx.fillRect(x+w2,y+h2,w1,h1)
    end
  end
  if boardData.boxs[index].possible[1] then
      gfx.drawTextAligned("1",x1,y1,kTextAlignment.center)
  end
  if boardData.boxs[index].possible[2] then
      gfx.drawTextAligned("2",x2,y1,kTextAlignment.center)
  end
  if boardData.boxs[index].possible[3] then
      gfx.drawTextAligned("3",x3,y1,kTextAlignment.center)
  end
  
  if boardData.boxs[index].possible[4] then
      gfx.drawTextAligned("4",x1,y2,kTextAlignment.center)
  end
  if boardData.boxs[index].possible[5] then
      gfx.drawTextAligned("5",x2,y2,kTextAlignment.center)
  end
  if boardData.boxs[index].possible[6] then
      gfx.drawTextAligned("6",x3,y2,kTextAlignment.center)
  end
  
  if boardData.boxs[index].possible[7] then
      gfx.drawTextAligned("7",x1,y3,kTextAlignment.center)
  end
  if boardData.boxs[index].possible[8] then
      gfx.drawTextAligned("8",x2,y3,kTextAlignment.center)
  end
  if boardData.boxs[index].possible[9] then
      gfx.drawTextAligned("9",x3,y3,kTextAlignment.center)
  end
  gfx.setFont(originalSystemFont)
end


function highlightSameNumber(board, index, thickLineWidth, sbx, sby, smallBoxWidth, smallBoxHeight)
    if tonumber(board.boardData.selected.number) == tonumber(board.boardData.boxs[index].number) and board.boardData.selected.number ~= 0 then
        gfx.drawRoundRect(sbx + thickLineWidth/2  , sby + thickLineWidth/2, smallBoxWidth - thickLineWidth, smallBoxHeight - thickLineWidth,2)
    end
end


function indicateSpotsNumberCanNotGo(board, index, sbx, sby, smallBoxWidth, smallBoxHeight)
    if board.boardData.boxs[index].status == status["Empty"] and board.boardData.selected.status ~= status["Empty"] and not board.boardData.boxs[index].possible[math.floor(board.boardData.selected.number)] then
        local shouldDraw = false
        for j=1, 9 do
            local r = board.boardData.rows[board.boardData.boxs[index].row][j]
            local c = board.boardData.columns[board.boardData.boxs[index].column][j]
            local bb = board.boardData.bigBoxs[board.boardData.boxs[index].bigBox][j]     
            if tonumber(r.number) == tonumber(board.boardData.selected.number) or tonumber(c.number) == tonumber(board.boardData.selected.number) or tonumber(bb.number) == tonumber(board.boardData.selected.number) then
                shouldDraw = true
            end
        end
        if shouldDraw then
            -- gfx.drawLine(sbx, sby,sbx + smallBoxWidth, sby + smallBoxHeight)
            -- gfx.drawLine(sbx,sby + smallBoxHeight,sbx + smallBoxWidth, sby)
            for r=1,smallBoxWidth do
                for c=1, smallBoxHeight do
                    if (r%2 == 0 and c%2 == 1) or (r%2 == 1 and c%2 == 0) then
                    gfx.drawPixel(sbx+c,sby+r)                        
                    end
                end
            end
            
        end
    end
end

function showPossibleNumberSelector(boardData,board)
    if boardData.selected ~= nil and boardData.selected.status ~= status.Given then
        function board:update()
        end
        local midpointx = playdate.display.getWidth() / 2
        local midpointy = playdate.display.getHeight() / 2
        local boardSize = (playdate.display.getHeight() *.95) / 2
        -- printTable(boardData.selected.possible)
        local possibleSize = midpointx - (boardSize * 1.05)
        boardData.possibleSprite:setSize(possibleSize,possibleSize)
        boardData.possibleSprite:moveTo(midpointx/4.6,midpointy+1)
        boardData.possibleSprite:add()
        function boardData.possibleSprite:draw(x, y, width, height)
            gfx.drawRect(x,y,width,height)
            gfx.drawLine(x+width/3,y,x+width/3,y+height)
            gfx.drawLine(x+width*(2/3),y,x+width*(2/3),y+height)
            gfx.drawLine(x,y+height*(1/3),x+width,y+height*(1/3))
            gfx.drawLine(x,y+height*(2/3),x+width,y+height*(2/3))
            local originalSystemFont = gfx.getSystemFont()
            print(originalSystemFont)
            local possibleNumberFont = gfx.font.new("font-Bitmore")
            gfx.setFont(possibleNumberFont)
            print(gfx.getSystemFont())
            if boardData.selected.possible[1] then
                gfx.drawTextAligned("1",x+width*(1/6),y+height*(1/12),kTextAlignment.center)
            end
            if boardData.selected.possible[2] then
                gfx.drawTextAligned("2",x+width*(3/6),y+height*(1/12),kTextAlignment.center)
            end
            if boardData.selected.possible[3] then
                gfx.drawTextAligned("3",x+width*(5/6),y+height*(1/12),kTextAlignment.center)
            end
            
            if boardData.selected.possible[4] then
                gfx.drawTextAligned("4",x+width*(1/6),y+height*(5/12),kTextAlignment.center)
            end
            if boardData.selected.possible[5] then
                gfx.drawTextAligned("5",x+width*(3/6),y+height*(5/12),kTextAlignment.center)
            end
            if boardData.selected.possible[6] then
                gfx.drawTextAligned("6",x+width*(5/6),y+height*(5/12),kTextAlignment.center)
            end
            
            if boardData.selected.possible[7] then
                gfx.drawTextAligned("7",x+width*(1/6),y+height*(9/12),kTextAlignment.center)
            end
            if boardData.selected.possible[8] then
                gfx.drawTextAligned("8",x+width*(3/6),y+height*(9/12),kTextAlignment.center)
            end
            if boardData.selected.possible[9] then
                gfx.drawTextAligned("9",x+width*(5/6),y+height*(9/12),kTextAlignment.center)
            end
            gfx.setFont(originalSystemFont)
        end
        function boardData.possibleSprite:update()
            if playdate.buttonJustPressed( playdate.kButtonB ) then
                boardData.possibleSprite:remove()
                board.boardData.buttonCanBePressed["b"] = false
                playdate.timer.new(movespeed,setBoolToTrue, "b", board.boardData)
                setUpdateForBoard(board) 
            end
        end
    else
        boardData.possibleSprite:remove()
    end
end


function findBigBoxGivenRowAndColumn(row,column)
    if row < 4 and column < 4 then
        return 1
    elseif row < 4 and column < 7 then
        return 2
    elseif row < 4 then
        return 3
    elseif row < 7 and column < 4 then
        return 4
    elseif row < 7 and column < 7 then
        return 5
    elseif row < 7 then
        return 6
    elseif column < 4 then
        return 7
    elseif column < 7 then
        return 8
    else
        return 9
    end
end


function checkIfBoardIsFinishedAndValid(board)
    local data = board.boardData
    local rows= data.rows
    local columns = data.columns
    local bigBoxs = data.bigBoxs
    local isValid = true
    for i=1,9 do
        local rowNumbers = {}
        local columnNumbers = {}
        local bigBoxNumbers = {}
      for j=1,9 do
          if rowNumbers[math.floor(rows[i][j].number)] == nil and columnNumbers[math.floor(columns[i][j].number)] == nil and bigBoxNumbers[math.floor(bigBoxs[i][j].number)] == nil and rows[j][i].number ~= 0 then
             rowNumbers[math.floor(rows[i][j].number)] = true
             columnNumbers[math.floor(columns[i][j].number)] = true
             bigBoxNumbers[math.floor(bigBoxs[i][j].number)] = true
         else
             isValid = false
             return isValid
         end
      end
    end
    return isValid
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
        end
    end
    return board
end

function setUpBoard(diff)
    local file_number = math.random(1,10)
    local random_difficutly = math.random(1,4)
    local file_name = "puzzles/"..difficutly[diff]..file_number..".json"
    -- print(file_name)
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
    mainBoard.boardData = generateBoard(template,oldBoard.boardData.timeInSeconds)
    for i=1,81 do
      mainBoard.boardData.boxs[i].status = oldBoard.boardData.boxs[i].status
      mainBoard.boardData.boxs[i].possible = oldBoard.boardData.boxs[i].possible
    end
    setDrawForBoardSprite(mainBoard)
    setUpdateForBoard(mainBoard)
    return mainBoard
end

function turnOnNotingMode(bool, board)
  if board.boardData.buttonCanBePressed[bool] and board.boardData.selected.status ~= status.Given then
    board.boardData.buttonCanBePressed[bool] = false
    playdate.timer.new(movespeed,setBoolToTrue,bool,board.boardData)
    board.boardData.isNoting = true
    if board.boardData.selected ~= nil and board.boardData.selected.status ~= status.Given  then
      board.boardData.selected.number = 0
    end
    board:markDirty()
  end
end

function turnOffNotingMode(bool, board)
  if board.boardData.buttonCanBePressed[bool] then
    board.boardData.buttonCanBePressed[bool] = false
    playdate.timer.new(movespeed,setBoolToTrue,bool,board.boardData)
    board.boardData.isNoting = false
    board.boardData.possibleSelected = 5
    board:markDirty()
  end
end

function moveSelected(bool,rowMove, columnMove,board)
  if not board.boardData.isNoting then
      if board.boardData.buttonCanBePressed[bool] then
          board.boardData.buttonCanBePressed[bool] = false
          playdate.timer.new(movespeed,setBoolToTrue, bool, board.boardData)
          local newRow = board.boardData.selected.row + rowMove
          if newRow <1 then
              newRow = 9
          elseif newRow > 9 then
              newRow = 1
          end
          local newColumn = board.boardData.selected.column + columnMove
          if newColumn <1 then
              newColumn = 9
          elseif newColumn > 9 then
              newColumn = 1
          end
          board.boardData.selected = board.boardData.rows[newRow][newColumn]
          board:markDirty()
      end
    end
end

function movePossibleSelected(bool,rowMove, columnMove,board)
  if board.boardData.isNoting then
      if board.boardData.buttonCanBePressed[bool] then
          board.boardData.buttonCanBePressed[bool] = false
          playdate.timer.new(movespeed,setBoolToTrue, bool, board.boardData)
          local temp = board.boardData.possibleSelected
          if rowMove == 1 then
            if temp < 7 then
              board.boardData.possibleSelected = temp + 3
            else
              board.boardData.possibleSelected = temp - 6
            end
          elseif rowMove == -1 then
            if temp > 3 then
              board.boardData.possibleSelected = temp - 3
            else
              board.boardData.possibleSelected = temp + 6
            end
          elseif columnMove == 1 then
            if temp % 3 ~= 0 then
              board.boardData.possibleSelected = temp + 1
            else
              board.boardData.possibleSelected = temp - 2
            end
          elseif columnMove == -1 then
            if temp % 3 ~= 1 then
              board.boardData.possibleSelected = temp - 1
            else
              board.boardData.possibleSelected = temp + 2
            end
          end
          board:markDirty()
      end
    end
end

function incrementSelected(bool,amountToAdd, board)
  if not board.boardData.isNoting then
    if board.boardData.buttonCanBePressed[bool] then
        board.boardData.buttonCanBePressed[bool] = false
        playdate.timer.new(movespeed,setBoolToTrue,bool,board.boardData)
        if board.boardData.selected.status == status["Empty"] or board.boardData.selected.status == status["Guessed"] then
            local newNumber = board.boardData.selected.number + amountToAdd
            board.boardData.selected.status = status["Guessed"]
            if newNumber > 9 then
              newNumber = 0
              board.boardData.selected.status = status["Empty"]
            elseif newNumber == 0 then
              newNumber = 0
              board.boardData.selected.status = status["Empty"]
            elseif newNumber < 0 then
              newNumber = 9
            end
            board.boardData.selected.number = newNumber
            
            board:markDirty()
        end
        if checkIfBoardIsFinishedAndValid(board) then
          finshedBoard(board)
        end
    end  
  end
end
function incrementSelectedWithCarnk(bool,amountToAdd, board)
  if not board.boardData.isNoting then
    if board.boardData.buttonCanBePressed[bool] then
        -- board.boardData.buttonCanBePressed[bool] = false
        playdate.timer.new(movespeed,setBoolToTrue,bool,board.boardData)
        if board.boardData.selected.status == status["Empty"] or board.boardData.selected.status == status["Guessed"] then
            local newNumber = board.boardData.selected.number + amountToAdd
            board.boardData.selected.status = status["Guessed"]
            if newNumber > 9 then
              newNumber = 0
              board.boardData.selected.status = status["Empty"]
            elseif newNumber == 0 then
              newNumber = 0
              board.boardData.selected.status = status["Empty"]
            elseif newNumber < 0 then
              newNumber = 9
            end
            board.boardData.selected.number = newNumber
            
            board:markDirty()
        end
    end  
    if checkIfBoardIsFinishedAndValid(board) then
      finshedBoard(board)
    end
  end
end

function togglePossibleNumber(bool,board)
  if board.boardData.isNoting and board.boardData.selected.status == status.Empty then
    if board.boardData.buttonCanBePressed[bool] then
      board.boardData.buttonCanBePressed[bool] = false
      playdate.timer.new(movespeed,setBoolToTrue,bool,board.boardData)
      board.boardData.selected.possible[board.boardData.possibleSelected] = not board.boardData.selected.possible[board.boardData.possibleSelected]
      board:markDirty()
    end
  end
end

function handleButtonsforBoard(board)
  if playdate.buttonJustPressed( playdate.kButtonA ) and playdate.buttonJustPressed( playdate.kButtonB ) then
      turnOnNotingMode('a',board)
      return
  end
    if playdate.buttonIsPressed( playdate.kButtonUp ) then
        moveSelected('up', -1, 0, board)
        movePossibleSelected('up', -1, 0, board)
    end
    if playdate.buttonIsPressed( playdate.kButtonRight ) then
        moveSelected('right', 0, 1, board)
        movePossibleSelected('right', 0, 1, board)
    end
    if playdate.buttonIsPressed( playdate.kButtonDown ) then
        moveSelected('down', 1, 0, board)
        movePossibleSelected('down', 1, 0, board)
    end
    if playdate.buttonIsPressed( playdate.kButtonLeft ) then
        moveSelected('left', 0, -1, board)
        movePossibleSelected('left', 0, -1, board)
    end
    if playdate.buttonIsPressed( playdate.kButtonA ) and not playdate.buttonIsPressed( playdate.kButtonB ) then -- and not playdate.buttonJustPressed(playdate.kButtonA) then
        incrementSelected('a',1, board)
        togglePossibleNumber('a',board)
    end
    if playdate.buttonIsPressed( playdate.kButtonB ) and not playdate.buttonIsPressed( playdate.kButtonA ) then -- and not playdate.buttonJustPressed(playdate.kButtonB) then
        incrementSelected('b',-1, board)
        turnOffNotingMode('b',board)
    end
end


