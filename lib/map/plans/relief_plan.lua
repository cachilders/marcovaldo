local Plan = include('lib/map/plan')
local ReliefSymbol = include('lib/map/symbols/relief_symbol')

local ReliefPlan = {
  ephemera = nil,
  features = nil
}

function ReliefPlan:new(options)
  local instance = Plan:new(options or {})
  setmetatable(self, {__index = Plan})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function ReliefPlan:refresh()
  self:_ingest_ephemera()
  self:_refresh_all_symbols()
end

function ReliefPlan:_ingest_ephemera()
  local features = {}

  for i = 1, #self.ephemera do
    local ephemeron = self.ephemera[i]

    for r = 1, PANE_EDGE_LENGTH do
      features[r] = features[r] or {}
      for c = 1, PANE_EDGE_LENGTH do
        features[r][c] = self:_local_clone(ephemeron[r][c]) or features[r][c]
      end
    end
  end

  self.features = features
end

function ReliefPlan:_local_clone(symbol)
  -- Needs work
  local clone = nil 
  if symbol then
    clone = ReliefSymbol:new({
      led = symbol:get('led'),
      x = symbol:get('x'),
      x_offset = self.x_offset,
      y = symbol:get('y'),
      y_offset = self.y_offset
    })
  end

  return clone
end

return ReliefPlan
