local Symbol = include('lib/chart/symbol')

local RadiationSymbol = {
  active = true
  -- Sounds radiate from centers (four sequencers)
  -- centers can change position or mute but not
  -- delete. remove is a mute action. press hold
  -- and press moves the center
}

function RadiationSymbol:new(options)
  local instance = options or {}
  setmetatable(self, {__index = Symbol})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

return RadiationSymbol
