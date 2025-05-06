local Symbol = include('lib/chart/symbol')

local CatSymbol = {
  act = nil,
  breed = nil, -- stores the breed (performer/mod reference)
  laziness = 4,
  shift = nil
}

function CatSymbol:new(options)
  local instance = Symbol:new(options or {})
  setmetatable(self, {__index = Symbol})
  setmetatable(instance, self)
  self.__index = self
  instance.laziness = math.random(3, 9)
  -- breed is now assigned by CatPlan:_add, not randomly here
  return instance
end

function CatSymbol:step()
  local lumen = self.lumen
  if self:_bored() then
    local last = {self.x, self.y}
    local next = self:_inclination()
    self.x = last[1] + next[1]
    self.y = last[2] + next[2]
    self.act(last[1], last[2]) -- act now uses breed from self, not a flavor index
    self.shift(last[1], last[2], self)
  end
  self:refresh(self.x + self.x_offset, self.y + self.y_offset, self.lumen)
  self.lumen = lumen
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

return CatSymbol