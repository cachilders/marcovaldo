local Performer = {
  name = nil,
  effects = nil
}

function Performer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  instance.effects = nil
  return instance
end

function Performer:init()
  self:init_effects()
end

function Performer:init_effects()
  -- Override in subclasses to set up effects
  -- Should set self.effects to a table of 4 effect functions
end

function Performer:play_note(sequence, note, velocity, envelope_duration)
  -- Override in subclasses
end

function Performer:apply_effect(effect, data)
  -- effect is 1-4
  -- data contains x,y coordinates
  if self.effects and self.effects[effect] then
    self.effects[effect](data)
  end
end

return Performer 