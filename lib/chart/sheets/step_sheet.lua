local Sheet = include('lib/chart/sheet')

local StepSheet = {}

function StepSheet:new(options)
  local instance = Sheet:new(options or {})
  setmetatable(self, {__index = Sheet})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function StepSheet:press_to_sheet(x, y, z)
  if z == 1 then
    local note = (y - 1) * 16 + (x - 1)
    self.sequence.notes[self.selected_step] = note
    self:refresh()
  end
end

function StepSheet:refresh()
  self:clear()
  if not self.sequence or not self.selected_step then return end
  local note = self.sequence.notes[self.selected_step] or 0
  -- Map MIDI 0-127 to x (1-16), y (1-8)
  local x = (note % 16) + 1
  local y = math.floor(note / 16) + 1
  if note > 0 then
    self.grid:led(x, y, 15)
  end
  self.grid:refresh()
end

return StepSheet
