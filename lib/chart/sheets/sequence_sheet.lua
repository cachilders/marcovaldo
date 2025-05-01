local Sheet = include('lib/chart/sheet')

local SequenceSheet = {}

function SequenceSheet:new(options)
  local instance = Sheet:new(options or {})
  setmetatable(self, {__index = Sheet})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function SequenceSheet:refresh()
  local pulse_positions = self.values[1][2] -- https://vscode.dev/github/cachilders/marcovaldo/blob/feat-editor-charts/lib/arrangement/sequence.lua#L154
  local step_count = self.values[1][1] -- https://vscode.dev/github/cachilders/marcovaldo/blob/feat-editor-charts/lib/arrangement/sequence.lua#L153
  for c = 1, self.width do
    for r = 1, self.height do
      local step = c * r
      local step_value = pulse_positions[step]
      if step <= step_count then -- we also care if this index is the current step in the sequence
        if step_value then
          self.led(c, r, 16)
        else
          self.led(c, r, 4)
        end
      else
        self.led(c, r, 0)
      end
    end
  end
end

return SequenceSheet
