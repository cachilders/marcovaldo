local Sheet = require('lib/chart/sheet')

local SequenceSheet = {}

function SequenceSheet:new(options)
    local instance = Sheet:new(options or {})
    setmetatable(self, {__index = Sheet})
    setmetatable(instance, self)
    self.__index = self
    return instance
end

function SequenceSheet:press_to_sheet(x, y, z)
    if z == 1 then
        local steps_per_row = 16
        if x < 1 or x > steps_per_row or y < 1 or y > 8 then return end
        local step_index = (y - 1) * steps_per_row + x
        local sequence = self:get('sequence')
        if sequence and sequence.notes and step_index >= 1 and step_index <= #sequence.notes then
            if sequence.notes[step_index] == 0 then
                sequence.notes[step_index] = params:get('marco_root')
            else
                sequence.notes[step_index] = 0
            end
            self:refresh()
        end
    end
end

function SequenceSheet:refresh()
    self:clear()
    local sequence = self:get('sequence')
    if not sequence or not sequence.notes then return end
    local notes = sequence.notes
    local steps_per_row = 16
    for i = 1, #notes do
        local x = ((i - 1) % steps_per_row) + 1
        local y = math.floor((i - 1) / steps_per_row) + 1
        local brightness = 4 -- default: muted
        if notes[i] and notes[i] ~= 0 then
            brightness = 12 -- active note
        end
        if self:get('current_step') and self:get('current_step') == i then
            brightness = 15 -- currently playing
        end
        self:get('grid'):led(x, y, brightness)
    end
    self:get('grid'):refresh()
end

return SequenceSheet
