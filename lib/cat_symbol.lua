local Symbol = include('lib/symbol')

local CatSymbol = {
  laziness = 4
}
CatSymbol.__index = CatSymbol

function CatSymbol:new(options)
  local instance = Symbol:new(options or {})
  setmetatable(CatSymbol, {__index = Symbol})
  setmetatable(instance, CatSymbol)
  instance.laziness = math.random(4, 16)
  return instance
end

function CatSymbol:_bored()
  local bored = true
  for i = 1, self.laziness do
    if bored then
      bored = math.random(0, 1) == 1
    end
  end
  return bored
end

function CatSymbol:_inclination()
  local DIRECTIONS = {{0, -1}, {1, 0}, {0, 1}, {-1, 0}}
  return DIRECTIONS[math.random(1, 4)]
end

function CatSymbol:refresh()
  local lumen = self.lumen
  if self:_bored() then
    local last = {self.x, self.y}
    local next = self:_inclination()
    self.lumen = 10
    self.x = last[1] + next[1]
    self.y = last[2] + next[2]
    self.shift(last[1], last[2], self)
  end
  self.led(self.x + self.x_offset, self.y + self.y_offset, self.lumen)
  self.lumen = lumen
end

return CatSymbol