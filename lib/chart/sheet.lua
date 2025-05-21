local Sheet = {
  affect_arrangement = nil,
  led = nil,
  source = nil,
  values = nil,
  y_offset = 0
}

function Sheet:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Sheet:get(k)
  return self[k]
end

function Sheet:set(k, v)
  self[k] = v
end

function Sheet:coords_to_step(x, y)
  return (y - 1) * PANE_EDGE_LENGTH + x
end

function Sheet:step_to_coords(step)
  local y = math.floor((step - 1) / PANE_EDGE_LENGTH) + 1
  local x = ((step - 1) % PANE_EDGE_LENGTH) + 1
  return x, y
end

function Sheet:update(index, values)
  self.source = index
  self.values = values
  self:refresh()
end

function Sheet:press(x, y, z)
  default_mode_timeout_extend()
end

function Sheet:refresh()
  -- To be implemented by subclasses
end

return Sheet
