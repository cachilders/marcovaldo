local Ring = {
  dirty = true,
  id = 1,
  lumen = 10,
  range = 64,
  x = 1
}

function Ring:init(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Ring:set(k, v)
  self[k] = v
end

function Ring:get(k)
  return self[k]
end

return Ring
