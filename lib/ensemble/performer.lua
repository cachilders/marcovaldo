local Performer = {
  clocks = nil,
  divisions = nil,
  effects = nil,
  name = 'Performer',
  repeats = nil
}

function Performer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Performer:init()
  self:init_effects()
end

function Performer:_create_standard_effect(device_param, value_param, setter_func)
  return function(data)
    local device = params:get(device_param..data.sequence)
    local mod_reset_value = params:get(value_param)
    local beat_time = 60 / params:get('clock_tempo')
    local mod_new_value = (1/32) * ((data.x * data.y) - 32)
    clock.run(
      function()
        setter_func(device, mod_new_value)
        clock.sleep(beat_time)
        setter_func(device, mod_reset_value)
      end
    )
  end
end

function Performer:_create_effect(effect_num)
  -- Base class has no effects
  return function(data)
    -- No-op
  end
end

function Performer:init_effects()
  self.effects = {
    self:_create_effect(1),
    self:_create_effect(2),
    self:_create_effect(3),
    self:_create_effect(4)
  }
end

function Performer:apply_effect(index, data)
  if self.effects and self.effects[index] then
    self.effects[index](data)
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