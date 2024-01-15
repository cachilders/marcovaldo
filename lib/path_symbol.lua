local Symbol = include('lib/symbol')

local PathSymbol = {}
PathSymbol.__index = PathSymbol

function PathSymbol:new(options)
  local instance = Symbol:new(options or {})
  setmetatable(PathSymbol, {__index = Symbol})
  setmetatable(instance, PathSymbol)
  return instance
end

function PathSymbol:update()
  -- We'll see. Setting next or head (if tail) as
  -- active might belong in here and leave the
  -- drawing to the path and let symbols do
  -- symbols.
end

return PathSymbol
