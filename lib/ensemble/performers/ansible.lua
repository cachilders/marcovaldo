local Performer = include('lib/ensemble/performer')

local AnsiblePerformer = {
  name = 'Ansible',
  effects = nil
}

setmetatable(AnsiblePerformer, { __index = Performer })

function AnsiblePerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function AnsiblePerformer:init()
  print('[AnsiblePerformer:init] Starting initialization')
  self:init_effects()
end

function AnsiblePerformer:_create_effect(effect_num)
  if effect_num == 1 then
    return self:_create_standard_effect(
      'marco_performer_ansible_output_',
      'ansible_transpose',
      function(device, value)
        crow.ii.ansible.cv(device, value)
      end
    )
  elseif effect_num == 2 then
    return function(data)
      local output = params:get('marco_performer_ansible_output_'..data.sequence)
      local mod_reset_value = params:get('ansible_repeats')
      local beat_time = 60 / params:get('clock_tempo')
      local mod_new_value = math.floor((1/32) * ((data.x * data.y) - 32))
      clock.run(
        function()
          for i = 1, mod_new_value do
            crow.ii.ansible.trigger_pulse(output)
            clock.sleep(0.05)
          end
          clock.sleep(beat_time)
          for i = 1, mod_reset_value do
            crow.ii.ansible.trigger_pulse(output)
            clock.sleep(0.05)
          end
        end
      )
    end
  else
    return function(data)
      print('[AnsiblePerformer] Effect '..effect_num..' not implemented')
    end
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
  local output = params:get('marco_performer_ansible_output_'..sequence)
  crow.ii.ansible.cv_slew(envelope_duration * params:get('marco_performer_slew_'..sequence) / 100)
  crow.ii.ansible.trigger_time(output, envelope_duration)
  crow.ii.ansible.cv(output, note / 12)
  crow.ii.ansible.trigger_pulse(output)
end

return AnsiblePerformer