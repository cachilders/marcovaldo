local Symbol = include('lib/symbol')

local Plan = {
  led = nil,
  features = nil,
  height = 8,
  width = 8,
  x_offset = 0,
  y_offset = 0
}

function Plan:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  instance.features = self:_gesso()
  return instance
end

function Plan:update()
  for r = 1, self.height do
    for c = 1, self.width do
      local symbol = self.features[r][c]
      if symbol then
        symbol:update()
      end
    end
  end
end

function Plan:mark(x, y, z)
  if z == 0 and self.features[y][x] then
    self:_remove(x, y)
  elseif z == 0 then
    self:_add(x, y)
  end
end

function Plan:_add(x, y)
  local symbol = {
    led = self.led,
    lumen = 5,
    x = x,
    x_offset = self.x_offset,
    y = y,
    y_offset = self.y_offset,
    head = nil, -- Trim the props for the base class
    tail = false, -- this is only a note for future to suggest behavior
    prime = true,
    die = function(x, y) self.features[y][x] = nil end,
    shift = function(x, y, to_x, to_y) print('Shift symbol at '..x, y..' to '..to_x, to_y) end, -- callback to move within the plan features
  }
  self.features[y][x] = Symbol:new(symbol)
end

function Plan:_remove(x, y)
  self.features[y][x] = nil
end

function Plan:_gesso()
  local features = {}
  for r = 1, self.height do
    features[r] = {}
    for c = 1, self.width do
      features[r][c] = nil
    end
  end
  return features
end

return Plan
