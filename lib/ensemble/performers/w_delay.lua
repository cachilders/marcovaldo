local music_util = require('musicutil')
local Performer = include('lib/ensemble/performer')
local VELOCITY_CONSTANT = 10 / 127

local WDelayPerformer = {
  clocks = nil,
  name = 'W/Delay'
}

setmetatable(WDelayPerformer, { __index = Performer })

function WDelayPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function WDelayPerformer:_get_available_mods()
  return {
    { mod = 'delay_time', id = 'wdelay_time' },
    { mod = 'feedback', id = 'wdelay_feedback' }
  }
end

function WDelayPerformer:init()
  self.clocks = {}
  -- Initialize W/
  if cat_breed_registry and cat_breed_registry.register_breeds then
    cat_breed_registry:register_breeds(self, self:_get_available_mods())
  end
end

function WDelayPerformer:play_note(sequence, note, velocity, envelope_duration)
  local device = params:get('marco_performer_w_device_'..sequence)
  if self.clocks[sequence] then
    clock.cancel(self.clocks[sequence])
  end
  self.clocks[sequence] = clock.run(
    -- TODO: Parameterize all additional available settings once defaults and ranges are identified
    function()
      crow.ii.wdel[device].time(envelope_duration / note)
      crow.ii.wdel[device].freq(music_util.note_num_to_freq(note))
      crow.ii.wdel[device].pluck(velocity * VELOCITY_CONSTANT)
      crow.ii.wdel[device].freeze(1)
      clock.sleep(envelope_duration)
      crow.ii.wdel[device].freeze(0)
    end
  )
end

function WDelayPerformer:apply_effect(index, data)
  local function log_data(label, idx, d)
    local parts = {}
    for k, v in pairs(d) do table.insert(parts, tostring(k)..'='..tostring(v)) end
    print(string.format('[%s] Applying effect on index: %s | data: {%s}', label, tostring(idx), table.concat(parts, ', ')))
  end
  if data.mod == 'delay_time' then
    log_data('WDelayPerformer', index, data)
    -- TODO: Implement delay time effect for W/Delay
  elseif data.mod == 'feedback' then
    log_data('WDelayPerformer', index, data)
    -- TODO: Implement feedback effect for W/Delay
  end
end

return WDelayPerformer