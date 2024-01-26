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
        features[r][c] = ephemeron[r][c] or features[r][c]
      end
    end
  end

  self.features = features
end

return ReliefPlan
