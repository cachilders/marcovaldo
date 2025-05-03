local console_constants = include('lib/console/constants')
local Screen = include('lib/console/screen')

local FIELD_LABELS = {'Steps', 'Pulses', 'Octaves', 'Subdivision'}
local ROW_WIDTH = 16

local SequenceScreen = {
  type = SEQUENCE
}

function SequenceScreen:new(options)
  local instance = options or {}
  setmetatable(self, {__index = Screen})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function SequenceScreen:draw()
  self:_draw_labels()
  self:_draw_fields()
  self:_draw_pulses()
  self:_draw_title()
end

function SequenceScreen:_draw_fields()
  screen.font_face(console_constants.FONTS.BASIC.FACE)
  screen.font_size(console_constants.FONTS.BASIC.SIZE)
  local values = self.values[1]
  local steps = values[1]
  local octaves = values[3]
  local subdivision = values[4]
  screen.move(console_constants.FIELD_START_X, console_constants.FIELD_START_Y)
  screen.text(self._enclose_field(steps))
  screen.move(console_constants.FIELD_START_X, console_constants.FIELD_START_Y * 2)
  screen.text(self._enclose_field(octaves))
  screen.move(console_constants.FIELD_START_X, console_constants.FIELD_START_Y * 3)
  screen.text(self._enclose_field(console_constants.LABELS.SUBDIVISION[subdivision]))
end

function SequenceScreen:_draw_labels()
  screen.font_face(console_constants.FONTS.BASIC.FACE)
  screen.font_size(console_constants.FONTS.BASIC.SIZE)
  screen.move(console_constants.FIELD_START_X, console_constants.LABEL_START_Y)
  screen.text(FIELD_LABELS[1])
  screen.move_rel(25, 0)
  screen.text(FIELD_LABELS[2])
  screen.move(console_constants.FIELD_START_X, console_constants.LABEL_START_Y + 20)
  screen.text(FIELD_LABELS[3])
  screen.move(console_constants.FIELD_START_X, console_constants.LABEL_START_Y + 40)
  screen.text(FIELD_LABELS[4])
end

function SequenceScreen:_draw_pulses()
  screen.font_face(console_constants.FONTS.CRAMPED.FACE)
  screen.font_size(console_constants.FONTS.CRAMPED.SIZE)
  local pulse_positions = self.values[1][2]
  local pulse_string = ''
  local row = 1
  local y = 20
  for i = 1, #pulse_positions do
    local pulse = console_constants.GLYPHS.REST
    if pulse_positions[i] == 1 then
      pulse = console_constants.GLYPHS.BANG
    end

    pulse_string = pulse_string..pulse

    if i % ROW_WIDTH == 0 then
      screen.move(console_constants.PULSE_COLUMN_START, y)
      screen.text(pulse_string)
      pulse_string = ''
      row = row + 1
      y = y + 6
    elseif i == #pulse_positions then
      screen.move(console_constants.PULSE_COLUMN_START, y)
      screen.text(pulse_string)
      pulse_string = ''
    end
  end  
end

return SequenceScreen