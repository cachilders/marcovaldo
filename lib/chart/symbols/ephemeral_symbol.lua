local Symbol = include('lib/chart/symbol')

local EphemeralSymbol = {
  source_type = ''
  -- Make discrete cat, path, photon symbols if needed,
  -- but for now keep it simple
}

function EphemeralSymbol:new(options)
  local instance = Symbol:new(options or {})
  setmetatable(self, {__index = Symbol})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

return EphemeralSymbol
