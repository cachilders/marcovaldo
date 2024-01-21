local Pane = {
  edge_length = 8,
  page = 1,
  pane = 1,
  plan = nil
}

function Pane:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Pane:init()
  self.plan:init()
  self:update_offsets()
end

function Pane:get(k)
  return self[k]
end

function Pane:set(k, v)
  self[k] = v
end

function Pane:mark(x, y, z)
  local x_offset, y_offset = self:_determine_offsets()
  self.plan:mark(x - x_offset, y - y_offset, z)
end

function Pane:update_offsets()
  local x_offset, y_offset = self:_determine_offsets()

  self.plan:set('x_offset', x_offset)
  self.plan:set('y_offset', y_offset)
end

function Pane:_determine_offsets()
  local x_offset = 0
  local y_offset = 0

  if self.pane > 2 then
    y_offset = self.edge_length
  elseif self.pane % 2 == 0 then
    x_offset = self.edge_length
  end

  return x_offset, y_offset
end

function Pane:refresh()
  self.plan:refresh()
end

function Pane:step()
  self.plan:step()
end

return Pane