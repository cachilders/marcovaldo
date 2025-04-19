local Performer = {
  name = nil,
  params = nil
}

function Performer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Performer:init()
  -- To be implemented by subclasses
end

function Performer:play_note(voice, note, velocity, envelope_duration)
  -- To be implemented by subclasses
end

function Performer:apply_effect(index, data)
  -- To be implemented by subclasses
end

function Performer:get(k)
  return self[k]
end

function Performer:set(k, v)
  self[k] = v
end

return Performer 