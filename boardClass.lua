import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"

-- import "smallBoxClass"

local gfx <const> = playdate.graphics

status = {
    ["Given"] = 1,
    ["Empty"] = 2,
    ["Guessed"] = 3
}



class('Board').extends(gfx.sprite)

function Board:init(template)
    self.boxs = {}
    self.rows = {{}, {}, {}, {}, {}, {}, {}, {}, {}}
    self.columns = {{}, {}, {}, {}, {}, {}, {}, {}, {}}
    self.bigBoxs = {{}, {}, {}, {}, {}, {}, {}, {}, {}}
    for r=1, 9 do
        for c=1, 9 do
            n = (c) + ((r-1) * 9)
            local b = {
                ["row"]=r,
                ["column"]=c,
                ["number"]=template[n] ~= "." and template[n] or 0,
                ["status"]=template[n]  ~= "." and status["Given"] or status["Empty"],
                ["bigBox"]=findBigBoxGivenRowAndColumn(r,c)
            }
            table.insert(self.boxs,b)
            table.insert(self.rows[b.row],b)
            table.insert(self.columns[b.column],b)
            table.insert(self.bigBoxs[b.bigBox],b)
        end
    end
    self.selected = self.boxs[1]
end





function Board:draw(x, y, width, height)
    local thickLineWidth, thinLineWidth = 5, 1
    local smallBoxWidth, smallBoxHeight = width/9, height/9
    
    gfx.setLineWidth(thickLineWidth)
    -- gfx.setColor(gfx.kColorBlack)
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
    gfx.setColor(gfx.kColorBlack)
    
    local selectedx, selectedy = ((self.selected.column-1)*smallBoxWidth), ((self.selected.row-1)*smallBoxHeight)
    playdate.graphics.fillRect(selectedx, selectedy, smallBoxWidth+1, smallBoxHeight+1)
    for index=1, 81 do
        local sbx = ((self.boxs[index].column-1)*smallBoxWidth)
        local sby = ((self.boxs[index].row-1)*smallBoxHeight)
        local text = self.boxs[index].number ~= 0 and self.boxs[index].number or ''
        if self.boxs[index].status == status["Given"] then
            local textWidth = gfx.getTextSize("*"..text)
            local textHeight = gfx.getFont(gfx.font.kVariantBold):getHeight()
            gfx.drawText("*"..text, sbx + (smallBoxWidth/2 - textWidth/2), sby+(smallBoxHeight - textHeight)) 
        else
            local textWidth = gfx.getTextSize(text)
            local textHeight = gfx.getFont():getHeight()
            gfx.drawText(text,sbx+ (smallBoxWidth/2 - textWidth/2),sby+(smallBoxHeight - textHeight))
            -- gfx.drawText(text, sbx + (smallBoxWidth/2 - textWidth/2), sby-(smallBoxHeight + textHeight))
        end
    end
end



function generateBoard(template)
    local board = {}
    board.boxs = {}
    board.rows = {{}, {}, {}, {}, {}, {}, {}, {}, {}}
    board.columns = {{}, {}, {}, {}, {}, {}, {}, {}, {}}
    board.bigBoxs = {{}, {}, {}, {}, {}, {}, {}, {}, {}}
    for r=1, 9 do
        for c=1, 9 do
            n = (c) + ((r-1) * 9)
            -- local b = smallBox(r,c,template[n] ~= '.' and tonumber(template[n]) or 0, self)
            local b = {
                ["row"]=r,
                ["column"]=c,
                ["number"]=template[n] ~= "." and template[n] or 0,
                ["status"]=template[n] ~= "." and status["Given"] or status["Empty"],
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
    return board
end

function setDrawForBoardSprite(boardSprite)
    function boardSprite:draw(x, y, width, height)
        local thickLineWidth, thinLineWidth = 5, 1
        local smallBoxWidth, smallBoxHeight = width/9, height/9
        gfx.setLineWidth(thickLineWidth)
        -- gfx.setColor(gfx.kColorBlack)
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
        gfx.setColor(gfx.kColorBlack)
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
                -- gfx.drawText(text, sbx + (smallBoxWidth/2 - textWidth/2), sby-(smallBoxHeight + textHeight))
            end
        end
    end
    return boardSprite
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

-- function Board:printboard()
--     for r=1, 9 do
--         local row = ''
--         for c=1, 9 do
--             row = row .. self.rows[r][c].number .. ' '
--         end
--         print(row)
--     end
-- end
