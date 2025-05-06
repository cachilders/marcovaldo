local Performer = include('lib/ensemble/performer')
local VELOCITY_CONSTANT = 10 / 127

local DistingPerformer = {
  clocks = nil,
  name = 'Disting'
}

setmetatable(DistingPerformer, { __index = Performer })

function DistingPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function DistingPerformer:_get_available_mods()
  return {
    { mod = 'algorithm', id = 'disting_algorithm' },
    { mod = 'parameter_a', id = 'disting_param_a' }
  }
end

function DistingPerformer:init()
  local clocks = {}
  for i = 1, 4 do
    clocks[i] = {}
  end
  self.clocks = clocks

  -- Initialize Disting EX
  if cat_breed_registry and cat_breed_registry.register_breeds then
    cat_breed_registry:register_breeds(self, self:_get_available_mods())
  end
end

function DistingPerformer:play_note(sequence, note, velocity, envelope_duration)
  if self.clocks[sequence][note] then
    clock.cancel(self.clocks[sequence][note])
  end

  self.clocks[sequence][note] = clock.run(
    function()
      crow.ii.disting.note_pitch(note, (note - params:get('marco_root')) / 12)
      crow.ii.disting.note_velocity(note, velocity * VELOCITY_CONSTANT)
      clock.sleep(envelope_duration)
      crow.ii.disting.note_off(note)
    end
  )
end

function DistingPerformer:apply_effect(index, data)
  local function log_data(label, idx, d)
    local parts = {}
    for k, v in pairs(d) do table.insert(parts, tostring(k)..'='..tostring(v)) end
    print(string.format('[%s] Applying effect on index: %s | data: {%s}', label, tostring(idx), table.concat(parts, ', ')))
  end
  if data.mod == 'algorithm' then
    log_data('DistingPerformer', index, data)
    -- TODO: Implement algorithm effect for Disting EX
  elseif data.mod == 'parameter_a' then
    log_data('DistingPerformer', index, data)
    -- TODO: Implement parameter A effect for Disting EX
  end
end

return DistingPerformer