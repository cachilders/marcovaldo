local Sheet = {
  affect_arrangement = nil,
  led = nil,
  source = nil,
  values = nil,
  height = 8, -- WIP; solve for different sizes for this application
  width = 16
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

function Sheet:update(i, values)
  self.source = i
  self.values = values
end

function Sheet:press(x, y, z)
  default_mode_timeout_extend()
end

return Sheet
