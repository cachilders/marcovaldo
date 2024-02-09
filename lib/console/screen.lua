local ERROR = 'ERROR: NO DATA'

local Screen = {
  name = '',
  type = '',
  values = nil
}

function Screen:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Screen:refresh()
  screen.move(2, 5)
  if self.values then
    screen.text(self.name)
    screen.move(2, 20)
    for i, v in ipairs(self.values[1]) do
      -- TODO temp
      v = v == true and 'true' or v == false and 'false' or v
      screen.text(i..': '..v)
      screen.move(2, i * 10 + 20)
    end
  else
    screen.text(ERROR)
  end
end

function Screen:update(i, values)
  self.name = self.type..' '..i
  self.values = values
end

return Screen