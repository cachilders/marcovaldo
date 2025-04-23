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

function AnsiblePerformer:init()
  -- Initialize Ansible
end

function AnsiblePerformer:play_note(sequence, note, velocity, envelope_duration)
  local output = params:get('marco_performer_ansible_output_'..sequence)
  crow.ii.ansible.slew(envelope_duration * params:get('marco_performer_ansible_slew_'..sequence) / 100)
  crow.ii.ansible.cv(output, note / 12)
  crow.ii.ansible.trigger_time(output, envelope_duration)
end

function AnsiblePerformer:apply_effect(index, data)
  -- no-op
end

return AnsiblePerformer 