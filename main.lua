

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "smallBoxClass"
import "boardClass"

local gfx <const> = playdate.graphics


getmetatable('').__index = function(str,i) return string.sub(str,i,i) end

local playerSprite = nil

local simple_template = '.34....7.......36.71.....28..25.7...57.....1...38..5..82..6........7.14.6..1....3'
-- local simple_file = playdate.file.open("simple.json")
-- local simple_json = json.decodeFile(simple_file)
-- math.randomseed(playdate.getSecondsSinceEpoch())
-- local puzzle_index = math.random(0,99)
-- simple_template = simple_json[""..puzzle_index..""]

local mainBoard = Board(simple_template)
-- mainBoard:printboard()


function myGameSetUp()
    local offset = 25
    local midpointx, midpointy = playdate.display.getWidth() / 2, playdate.display.getHeight() / 2
    local xoff, yoff = midpointx - (5 * offset), midpointy - (5 * offset)
    for i=1,#mainBoard.boxs do
        local x, y = xoff + (mainBoard.boxs[i].column * offset), yoff + (mainBoard.boxs[i].row * offset)
        mainBoard.boxs[i]:moveTo( x, y )
        mainBoard.boxs[i]:add()
        mainBoard.boxs[i]:setSize(offset,offset)
    end
    

end

myGameSetUp()

local upCanBePressed = true
function setUpCanBePressedToTrue()
    upCanBePressed = true
end
local downCanBePressed = true
function setDownCanBePressedToTrue()
    downCanBePressed = true
end
local leftCanBePressed = true
function setLeftCanBePressedToTrue()
    leftCanBePressed = true
end
local rightCanBePressed = true
function setRightCanBePressedToTrue()
    rightCanBePressed = true
end
local ACanBePressed = true
function setACanBePressedToTrue()
    ACanBePressed = true
end
local BCanBePressed = true
function setBCanBePressedToTrue()
    BCanBePressed = true
end

local movespeed = 200

function playdate.update()


    if playdate.buttonIsPressed( playdate.kButtonUp ) then
        if upCanBePressed then
            upCanBePressed = false
            playdate.timer.new(movespeed,setUpCanBePressedToTrue)
            if mainBoard.selected.row ~= 1 then
                mainBoard.selected:markDirty()
                mainBoard.selected = mainBoard.rows[mainBoard.selected.row -1][mainBoard.selected.column]
                mainBoard.selected:markDirty()
            end
        end
    end
    if playdate.buttonIsPressed( playdate.kButtonRight ) then
        if rightCanBePressed then
            rightCanBePressed = false
            playdate.timer.new(movespeed,setRightCanBePressedToTrue)
            if mainBoard.selected.column ~= 9 then
                mainBoard.selected:markDirty()
                mainBoard.selected = mainBoard.columns[mainBoard.selected.column +1][mainBoard.selected.row]
                mainBoard.selected:markDirty()
            end
        end
    end
    if playdate.buttonIsPressed( playdate.kButtonDown ) then
        if downCanBePressed then
            downCanBePressed = false
            playdate.timer.new(movespeed,setDownCanBePressedToTrue)
            if mainBoard.selected.row ~= 9 then
                mainBoard.selected:markDirty()
                mainBoard.selected = mainBoard.rows[mainBoard.selected.row +1][mainBoard.selected.column]
                mainBoard.selected:markDirty()
            end
        end
    end
    if playdate.buttonIsPressed( playdate.kButtonLeft ) then
        if leftCanBePressed then
            leftCanBePressed = false
            playdate.timer.new(movespeed,setLeftCanBePressedToTrue)
            if mainBoard.selected.column ~= 1 then
                mainBoard.selected:markDirty()
                mainBoard.selected = mainBoard.columns[mainBoard.selected.column - 1][mainBoard.selected.row]
                mainBoard.selected:markDirty()
            end
        end
    end
    if playdate.buttonIsPressed( playdate.kButtonA ) then
        if ACanBePressed then
            ACanBePressed = false
            playdate.timer.new(movespeed,setACanBePressedToTrue)
            if mainBoard.selected.status == status["Empty"] or mainBoard.selected.status == status["Guessed"] then
                if mainBoard.selected.number ~= 9 then
                    mainBoard.selected:markDirty()
                    mainBoard.selected.number = mainBoard.selected.number + 1
                end
            end
        end
    end
    if playdate.buttonIsPressed( playdate.kButtonB ) then
        if BCanBePressed then
            BCanBePressed = false
            playdate.timer.new(movespeed,setBCanBePressedToTrue)
            if mainBoard.selected.status == status["Empty"] or mainBoard.selected.status == status["Guessed"] then
                if mainBoard.selected.number ~= 0 then
                    mainBoard.selected:markDirty()
                    mainBoard.selected.number = mainBoard.selected.number - 1
                end
            end
        end
    end

    
    gfx.sprite.update()
    playdate.timer.updateTimers()

end