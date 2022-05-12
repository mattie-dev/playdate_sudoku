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






function generateBoard(template)
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
    playdate.timer.new(movespeed,setBoolToTrue, "a", board)
    return board
end



function setDrawForBoardSprite(boardSprite)
    function boardSprite:draw(x, y, width, height)
        gfx.setColor(gfx.kColorBlack == gfx.getBackgroundColor() and gfx.kColorWhite or gfx.kColorBlack)
        local thickLineWidth, thinLineWidth = 5, 1
        local smallBoxWidth, smallBoxHeight = width/9, height/9
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
        -- gfx.setColor(gfx.kColorBlack)
        local selectedx, selectedy = ((self.boardData.selected.column-1)*smallBoxWidth), ((self.boardData.selected.row-1)*smallBoxHeight)
        playdate.graphics.fillRect(selectedx, selectedy, smallBoxWidth+1, smallBoxHeight+1)
        for index=1, 81 do
            local sbx, sby = ((self.boardData.boxs[index].column-1)*smallBoxWidth), ((self.boardData.boxs[index].row-1)*smallBoxHeight)
            local text = self.boardData.boxs[index].number ~= 0 and self.boardData.boxs[index].number or ''
            if self.boardData.boxs[index].status == status["Given"] then
                local textWidth = gfx.getTextSize("*"..text)
                local textHeight = gfx.getFont(gfx.font.kVariantBold):getHeight()
                gfx.drawText("*"..text, sbx + (smallBoxWidth/2 - textWidth/2), sby+(smallBoxHeight - textHeight)) 
            else
                local textWidth = gfx.getTextSize(text)
                local textHeight = gfx.getFont():getHeight()
                gfx.drawText(text,sbx+ (smallBoxWidth/2 - textWidth/2),sby+(smallBoxHeight - textHeight))
            end
            if settings["Highlight same sumber as selected"] then
                highlightSameNumber(self, index, thickLineWidth, sbx, sby, smallBoxWidth, smallBoxHeight)
            end
            if settings["Indicate where number can't go"] then
                indicateSpotsNumberCanNotGo(self, index, sbx, sby, smallBoxWidth, smallBoxHeight)
            end
        end
    end
    gfx.setColor(gfx.kColorXOR)
    return boardSprite
end


function highlightSameNumber(board, index, thickLineWidth, sbx, sby, smallBoxWidth, smallBoxHeight)
    if tonumber(board.boardData.selected.number) == tonumber(board.boardData.boxs[index].number) and board.boardData.selected.number ~= 0 then
        gfx.drawRoundRect(sbx + thickLineWidth/2  , sby + thickLineWidth/2, smallBoxWidth - thickLineWidth, smallBoxHeight - thickLineWidth,2)
    end
end


function indicateSpotsNumberCanNotGo(board, index, sbx, sby, smallBoxWidth, smallBoxHeight)
    if board.boardData.boxs[index].status == status["Empty"] and board.boardData.selected.status ~= status["Empty"] then
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
            gfx.drawLine(sbx, sby,sbx + smallBoxWidth, sby + smallBoxHeight)
            gfx.drawLine(sbx,sby + smallBoxHeight,sbx + smallBoxWidth, sby)
        end
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
