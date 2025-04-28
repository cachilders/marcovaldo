-- Sheet: Base class for transient sequence/step editor states on the monome grid
-- This class manages a 16x8 grid view for sequence and step editing, replacing the main chart when active.

local Sheet = {}
Sheet.__index = Sheet

function Sheet:new(options)
    -- grid must always be injected; never connect hardware here
    local instance = setmetatable({
        mode = options and options.mode or nil, -- 'sequence' or 'step'
        sequence = options and options.sequence or nil, -- sequence object reference
        selected_step = options and options.selected_step or 1, -- step index for step mode
        leds = {}, -- 2D array for LED states
        grid = options and options.grid or nil, -- grid must be provided by parent chart
        current_step = options and options.current_step or nil, -- currently playing step index
    }, Sheet)
    return instance
end

function Sheet:get(k)
    return self[k]
end

function Sheet:set(k, v)
    self[k] = v
end

-- Called when entering the editor state
function Sheet:enter()
    self:refresh()
end

-- Called when exiting the editor state
function Sheet:exit()
    self:clear()
end

-- Clear all LEDs on the grid
function Sheet:clear()
    self.grid:all(0)
    self.grid:refresh()
end

-- Redraw the grid based on current state
function Sheet:refresh()
    -- To be implemented in subclasses
end

function Sheet:update(index, value)
    -- receive new data from ensemble/sequence and reflect it on the grid 
end

-- Handle grid key events
function Sheet:press_to_sheet(x, y, z)
    -- To be implemented in subclasses
end

return Sheet
