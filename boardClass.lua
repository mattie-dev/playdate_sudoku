import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "smallBoxClass"


-- local gfx <const> = playdate.graphics



class('Board').extends()
-- 
function Board:init(template)
    self.boxs = {}
    self.rows = {{}, {}, {}, {}, {}, {}, {}, {}, {}}
    self.columns = {{}, {}, {}, {}, {}, {}, {}, {}, {}}
    self.bigBoxs = {{}, {}, {}, {}, {}, {}, {}, {}, {}}
    for r=1, 9 do
        for c=1, 9 do
            n = (c) + ((r-1) * 9)
            local b = smallBox(r,c,template[n] ~= '.' and tonumber(template[n]) or 0, self)
            table.insert(self.boxs,b)
            table.insert(self.rows[b.row],b)
            table.insert(self.columns[b.column],b)
            table.insert(self.bigBoxs[b.bigBox],b)
        end
    end
    self.selected = self.boxs[1]
end

function Board:printboard()
    for r=1, 9 do
        local row = ''
        for c=1, 9 do
            row = row .. self.rows[r][c].number .. ' '
        end
        print(row)
    end
end
