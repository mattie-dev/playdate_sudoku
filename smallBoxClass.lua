import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

local gfx <const> = playdate.graphics

status = {
    ["Given"] = 1,
    ["Empty"] = 2,
    ["Guessed"] = 3
}


class('smallBox').extends(gfx.sprite)

function smallBox:init(irow,icolumn,inumber,iboard)
    self.row = irow
    self.column = icolumn
    self.number = inumber
    self.status = self.number ~= 0 and status["Given"] or status["Empty"]
    self.bigBox = findBigBoxGivenRowAndColumn(self.row,self.column)
    self.board = iboard
    -- print('r' .. self.row .. "c" .. self.column .. '= ' .. self.number .. ', bb=' .. self.bigBox)
end



function smallBox:getAsString()
    return 'r' .. self.row .. "c" .. self.column .. '= ' .. self.number .. ', bb=' .. self.bigBox
end

function smallBox:printBox()
    print(self.getAsString())
end

function smallBox:update()
    -- local width, height = self:getSize()
    -- local x, y = self:getPosition()
    -- self:draw(x, y, width, height)
end

function smallBox:draw(x, y, width, height)
    local text = self.number ~= 0 and self.number or ''
    local textx, texty = width/2 - gfx.getFont():getTextWidth(text)/2, height/2 - gfx.getFont():getHeight()/2.5
    if self.status == status["Given"] then
        gfx.drawText("*"..text.."*", textx , texty)
    else
        gfx.drawText(text, textx , texty)
    end
    gfx.setLineWidth(1)
    gfx.drawRect(0, 0, width, height)
    -- print(self:getAsString())
    if self.row == 1 or self.row == 4 or self.row == 7 then
        gfx.setLineWidth(5)
        gfx.drawLine(0,0,width,0)
    end
    if self.row == 9 then
        gfx.setLineWidth(7)
        gfx.drawLine(0,height,width,height)
    end
    if self.column == 1 or self.column == 4 or self.column == 7 then
        gfx.setLineWidth(5)
        gfx.drawLine(0,0,0,height)
    end
    if self.column == 9  then
        gfx.setLineWidth(7)
        gfx.drawLine(width,0,width,height)
    end
    if self == self.board.selected then
        gfx.setLineWidth(7)
        gfx.drawRect(0, 0, width, height)
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