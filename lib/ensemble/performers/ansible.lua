local Performer = include('lib/ensemble/performer')

local AnsiblePerformer = {
  name = ANS
}

setmetatable(AnsiblePerformer, { __index = Performer })

function AnsiblePerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function AnsiblePerformer:init()
  self:init_effects()
  self.clocks = {}
end

function AnsiblePerformer:_create_effect(effect_num)
  return function(data)
    local beat_time = 60 / params:get('clock_tempo')
    clock.run(
      function()
        self.divisions = data.x
        self.repeats = data.y
        clock.sleep(beat_time)
        self.divisions = 1
        self.repeats = 1
      end
    )
  end
end

function AnsiblePerformer:init_effects()
  self.effects = {
    self:_create_effect(1),
    self:_create_effect(2),
    self:_create_effect(3),
    self:_create_effect(4)
  }
end

function AnsiblePerformer:play_note(sequence, note, velocity, envelope_duration)
  local divided_duration = envelope_duration / (self.divisions or 1)
  local repeats = (self.repeats or 1) <= (self.divisions or 1) and (self.repeats or 1) or (self.divisions or 1)
  local division_gap = repeats > 1 and (envelope_duration - (divided_duration * repeats)) / (repeats - 1) or 0
  local output = params:get('marco_performer_ansible_output_'..sequence)
  crow.ii.ansible.cv_slew(envelope_duration * params:get('marco_performer_slew_'..sequence) / 100)
  crow.ii.ansible.trigger_time(output, divided_duration)
  crow.ii.ansible.cv(output, note / 12)

  for i = 1, repeats do
    if self.clocks[sequence] then
      clock.cancel(self.clocks[sequence])
    end
    self.clocks[sequence] = clock.run(
      function()
        crow.ii.ansible.trigger_pulse(output)
        if repeats > 1 then
          clock.sleep(division_gap)
        end
      end
    )
  end
end

return AnsiblePerformer
