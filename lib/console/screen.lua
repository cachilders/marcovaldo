local console_constants = include('lib/console/constants')
local console_constants = include('lib/console/constants')
local ERROR = 'ERROR: NO DATA'

local Screen = {
  source = '',
  type = '',
  values = nil
}

function Screen._enclose_field(string)
  return console_constants.GLYPHS.DIV_L..' '..string..' '..console_constants.GLYPHS.DIV_R
end

function Screen:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Screen:draw()
  screen.font_face(console_constants.FONTS.BASIC.FACE)
  screen.font_size(console_constants.FONTS.BASIC.SIZE)
  screen.move(2, 5)
  if self.values then
    screen.text(self.type..' '..self.source)
    screen.move(2, 20)
    for i, v in ipairs(self.values[1]) do
      v = v == true and 'true' or v == false and 'false' or type(v) == 'table' and 'TABLE' or v
      screen.text(i..': '..v)
      screen.move(2, i * 10 + 20)
    end
  else
    screen.text(ERROR)
  end
end

function Screen:update(i, values)
  self.source = i
  self.values = values
end

function Screen:_draw_title()
  screen.font_face(console_constants.FONTS.BASIC.FACE)
  screen.font_size(console_constants.FONTS.BASIC.SIZE)
  local title = self.type..' '..self.source
  screen.text_rotate(2, 10, title, 90)
end

return Screen