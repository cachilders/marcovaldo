local Performer = {
  clocks = nil,
  divisions = 1,
  effects = nil,
  max_clock_indices = {effect = 4, voice = 4},
  name = 'Performer',
  next_clock_index = {effect = 1, voice = 1},
  repeats = 1
}

function Performer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Performer:init()
  self:_init_clocks()
  self:_init_effects()
end

function Performer:_init_clocks()
  self.clocks = {
    effect = {},
    voice = {}
  }
end

function Performer:_advance_clock_index(type)
  self.next_clock_index[type] = util.wrap(self.next_clock_index[type] + 1, 1, self.max_clock_indices[type])
end

function Performer:_get_next_clock(type)
  local clock = self.clocks[type][self.next_clock_index[type]]
  self:_advance_clock_index(type)
  return clock
end

function Performer:_create_effect(effect_num)
  -- Base class has no effects
  return function(data)
    -- No-op
  end
end

function Performer:_init_effects()
  self.effects = {
    self:_create_effect(1),
    self:_create_effect(2),
    self:_create_effect(3),
    self:_create_effect(4)
  }
end

function Performer:apply_effect(effect, data, sequence)
  if self.effects and self.effects[effect] then
    self.effects[effect](data, sequence)
  end
end

function Performer:play_note(sequence, note, velocity, envelope_duration)
  -- Base class has no play_note implementation
end

function Performer:get(k)
  return self[k]
end

function Performer:set(k, v)
  self[k] = v
end

return Performer 