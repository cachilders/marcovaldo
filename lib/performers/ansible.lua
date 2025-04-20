local Performer = require 'lib/performer'

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

function AnsiblePerformer:play_note(voice, note, velocity, envelope_duration)
  -- Send note to Ansible
end

function AnsiblePerformer:apply_effect(index, data)
  -- no-op
end

return AnsiblePerformer 