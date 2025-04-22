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
  local output = params:get('marco_ansible_output')
  -- figure out how we can do envelopes
  crow.ii.ansible.output[output].volts = (note - params:get('marco_root'))/12
  crow.ii.ansible.output[output].action = 'pulse'
  crow.ii.ansible.output[output].time = envelope_duration
end

function AnsiblePerformer:apply_effect(index, data)
  -- no-op
end

return AnsiblePerformer 