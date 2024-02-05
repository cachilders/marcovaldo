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
    local i = 1
    screen.text(self.name)
    screen.move(2, 20)
    for k, v in pairs(self.values) do
      -- TODO temp
      v = v == true and 'true' or v == false and 'false' or v
      screen.text(k..': '..v)
      i = i + 1
      screen.move(2, i * 10 + 10)
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