local console_constants = include('lib/console/constants')
local Screen = include('lib/console/screen')

local FIELD_LABELS = {'Note', 'Active', 'Strength', 'Width'}
local PULSE = 'Pulse'

local StepScreen = {
  type = STEP
}

function StepScreen:new(options)
  local instance = options or {}
  setmetatable(self, {__index = Screen})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function StepScreen:draw()
  self:_draw_labels()
  self:_draw_fields()
  self:_draw_note()
  self:_draw_title()
end

function StepScreen:_draw_fields()
  screen.font_face(console_constants.FONTS.BASIC.FACE)
  screen.font_size(console_constants.FONTS.BASIC.SIZE)
  local values = self.values[1]
  local active = values[2]
  local strength = values[3]
  local width = values[4]
  screen.move(console_constants.FIELD_START_X, console_constants.FIELD_START_Y)
  screen.text(self._enclose_field(active and 'Yes' or 'No'))
  screen.move(console_constants.FIELD_START_X, console_constants.FIELD_START_Y * 2)
  screen.text(self._enclose_field(strength))
  screen.move(console_constants.FIELD_START_X, console_constants.FIELD_START_Y * 3)
  screen.text(self._enclose_field(width..'%'))
end

function StepScreen:_draw_labels()
  screen.font_face(console_constants.FONTS.BASIC.FACE)
  screen.font_size(console_constants.FONTS.BASIC.SIZE)
  screen.move(console_constants.FIELD_START_X, console_constants.LABEL_START_Y)
  screen.text(FIELD_LABELS[2])
  screen.move(console_constants.FIELD_START_X, console_constants.LABEL_START_Y + 20)
  screen.text(FIELD_LABELS[3])
  screen.move(console_constants.FIELD_START_X, console_constants.LABEL_START_Y + 40)
  screen.text(FIELD_LABELS[4])
end

function StepScreen:_draw_note()
  local scale = self.values[2][1] -- TODO profoundly brittle and built on sand
  local note_index = self.values[1][1]
  local note_num = scale[note_index]
  local note = note_num and music_util.note_num_to_name(note_num, true) or '_'
  screen.font_face(console_constants.FONTS.BIG.FACE)
  screen.font_size(console_constants.FONTS.BIG.SIZE)
  screen.move(console_constants.PULSE_COLUMN_START, 45)
  screen.text(note)
  screen.stroke()
end

return StepScreen