local console_constants = include('lib/console/constants')
local Screen = include('lib/console/screen')

local HEIGHT = console_constants.SCREEN_HEIGHT
local WIDTH = console_constants.SCREEN_WIDTH
local X_RULE = WIDTH / 2
local Y_RULE = HEIGHT / 2
local LEVEL_OPERAND = 15/127

local InfoScreen = {
  clocks = {nil, nil, nil, nil},
  values = {'', '', '', ''}
}

function InfoScreen:new(options)
  local instance = options or {}
  setmetatable(self, {__index = Screen})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function InfoScreen:draw()
  self:_draw_cross()
  if self.values then
    self:_draw_notes()
  end
end

function InfoScreen:update(sequence, values)
  local duration = values.envelope_duration
  local note = values.note
  local level = math.floor(values.velocity * LEVEL_OPERAND)
  local last_clock = self.clocks[sequence]
  if last_clock then
    clock.cancel(last_clock)
  end
  self.clocks[sequence] = self:_disappearing_ink(sequence, note, duration)
end

function InfoScreen:_disappearing_ink(index, string, duration)
  return clock.run(function()
    self.values[index] = string
    clock.sleep(duration)
    self.values[index] = ''
  end)
end

function InfoScreen:_draw_cross()
  screen.move(0, Y_RULE)
  screen.line(WIDTH, Y_RULE)
  screen.move(X_RULE, 0)
  screen.line(X_RULE, HEIGHT)
end

function InfoScreen:_draw_notes()
  screen.font_face(console_constants.FONTS.MED.FACE)
  screen.font_size(console_constants.FONTS.MED.SIZE)
  screen.move(X_RULE - 7, Y_RULE - 6)
  screen.text_right(self.values[1])
  screen.move(X_RULE - 7, Y_RULE + 18)
  screen.text_right(self.values[2])
  screen.move(X_RULE + 4, Y_RULE - 6)
  screen.text(self.values[3])
  screen.move(X_RULE + 4, Y_RULE + 18)
  screen.text(self.values[4])
end

function InfoScreen:_reset_level()
  screen.level = 15
end

return InfoScreen