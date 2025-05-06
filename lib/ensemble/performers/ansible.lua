local Performer = include('lib/ensemble/performer')

local AnsiblePerformer = {
  name = 'Ansible'
}

setmetatable(AnsiblePerformer, { __index = Performer })

function AnsiblePerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function AnsiblePerformer:_get_available_mods()
  return {
    { mod = 'transpose', id = 'ansible_transpose' },
    { mod = 'repeats', id = 'ansible_repeats' }
  }
end

function AnsiblePerformer:init()
  -- Register Ansible mods as cat breeds by default
  if cat_breed_registry and cat_breed_registry.register_breeds then
    cat_breed_registry:register_breeds(self, self:_get_available_mods())
  end
end

function AnsiblePerformer:play_note(sequence, note, velocity, envelope_duration)
  local output = params:get('marco_performer_ansible_output_'..sequence)
  crow.ii.ansible.cv_slew(envelope_duration * params:get('marco_performer_slew_'..sequence) / 100)
  crow.ii.ansible.trigger_time(output, envelope_duration)
  crow.ii.ansible.cv(output, note / 12)
  crow.ii.ansible.trigger_pulse(output)
end

function AnsiblePerformer:apply_effect(index, data)
  if data.mod == 'transpose' then
    -- Example: transpose the CV by a semitone (or random interval)
    local output = params:get('marco_performer_ansible_output_'..index)
    local interval = (data.interval or 1) / 12 -- default: up one semitone
    crow.ii.ansible.cv(output, interval)
  elseif data.mod == 'repeats' then
    -- Example: trigger multiple pulses in quick succession
    local output = params:get('marco_performer_ansible_output_'..index)
    local repeats = data.repeats or 3
    local spacing = data.spacing or 0.05
    for i = 1, repeats do
      crow.ii.ansible.trigger_pulse(output)
      clock.sleep(spacing)
    end
  end
end

return AnsiblePerformer