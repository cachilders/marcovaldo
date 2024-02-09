local constants = include('lib/constants')
local Screen = include('lib/console/screen')

local LABELS = {'Steps', 'Pulses', 'Octaves', 'Subdivision'}
local ROW_WIDTH = 16
local FIELD_START_X = 17
local FIELD_START_Y = 20
local FONT_FACE = 1
local FONT_SIZE = 8
local LABEL_START_Y = 10
local PULSE_FACE = 25
local PULSE_SIZE = 6

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
  local values = self.values[1]
  local steps = values[1]
  local octaves = values[3]
  local subdivision = values[4]
  screen.move(FIELD_START_X, FIELD_START_Y)
  screen.text(self._enclose_field(steps))
  screen.move(FIELD_START_X, FIELD_START_Y * 2)
  screen.text(self._enclose_field(octaves))
  screen.move(FIELD_START_X, FIELD_START_Y * 3)
  screen.text(self._enclose_field(constants.LABELS.SUBDIVISION[subdivision]))
end

function SequenceScreen:_draw_labels()
  screen.move(FIELD_START_X, LABEL_START_Y)
  screen.text(LABELS[1])
  screen.move_rel(25, 0)
  screen.text(LABELS[2])
  screen.move(FIELD_START_X, LABEL_START_Y + 20)
  screen.text(LABELS[3])
  screen.move(FIELD_START_X, LABEL_START_Y + 40)
  screen.text(LABELS[4])
end

function SequenceScreen:_draw_pulses()
  local pulse_positions = self.values[1][2]
  if pulse_positions then
    local pulse_string = ''
    local row = 1
    local x_start = FIELD_START_X + screen.text_extents(LABELS[1]) + 25 -- TODO cleanup
    local y = 20
    screen.font_face(PULSE_FACE)
    screen.font_size(PULSE_SIZE)
    for i = 1, #pulse_positions do
      local pulse = constants.GLYPHS.REST
      if pulse_positions[i] then
        pulse = constants.GLYPHS.BANG
      end

      pulse_string = pulse_string..pulse

      if i % ROW_WIDTH == 0 then
        screen.move(x_start, y)
        screen.text(pulse_string)
        pulse_string = ''
        row = row + 1
        y = y + 6
      elseif i == #pulse_positions then
        screen.move(x_start, y)
        screen.text(pulse_string)
        pulse_string = ''
      end
    end  
    screen.font_face(FONT_FACE)
    screen.font_size(FONT_SIZE)
  end
end

function SequenceScreen:_draw_title()
  local title = SEQUENCE..' '..self.source
  screen.text_rotate(2, LABEL_START_Y, title, 90)
end

return SequenceScreen