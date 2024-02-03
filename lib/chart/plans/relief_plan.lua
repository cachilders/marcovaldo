local Plan = include('lib/chart/plan')
local ReliefSymbol = include('lib/chart/symbols/relief_symbol')

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

    for c = 1, PANE_EDGE_LENGTH do
      features[c] = features[c] or {}
      for r = 1, PANE_EDGE_LENGTH do
        features[c][r] = self:_local_clone(ephemeron[c][r]) or features[c][r]
      end
    end
  end

  self.features = features
end

function ReliefPlan:_local_clone(symbol)
  local clone = nil 
  if symbol then
    local type = symbol:get('source_type')
    local lumen = type == 'cat' and 10 or type == 'path' and 15 or type == 'radiation' and 2 or 3
    clone = ReliefSymbol:new({
      led = symbol:get('led'),
      lumen = lumen,
      x = symbol:get('x'),
      x_offset = self.x_offset,
      y = symbol:get('y'),
      y_offset = self.y_offset
    })
  end

  return clone
end

return ReliefPlan
