local Performer = include('lib/ensemble/performer')
VELOCITY_CONSTANT = 5 / 127

local JustFriendsPerformer = {
  name = 'Just Friends'
}

setmetatable(JustFriendsPerformer, { __index = Performer })

function JustFriendsPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function JustFriendsPerformer:_get_available_mods()
  return {
    { mod = 'octave_shift', id = 'jf_octave_shift' },
    { mod = 'voice_mode', id = 'jf_voice_mode' }
  }
end

function JustFriendsPerformer:init()
  crow.ii.jf.mode(1)
  if cat_breed_registry and cat_breed_registry.register_breeds then
    cat_breed_registry:register_breeds(self, self:_get_available_mods())
  end
end

-- crow.ii.jf.trigger( channel, state )
-- crow.ii.jf.run_mode( mode )
-- crow.ii.jf.run( volts )
-- crow.ii.jf.transpose( pitch )
-- crow.ii.jf.vtrigger( channel, level )
-- crow.ii.jf.mode( mode )
-- crow.ii.jf.tick( clock-or-bpm )
-- crow.ii.jf.play_voice( channel, pitch/divs, level/repeats )
-- crow.ii.jf.play_note( pitch/divs, level/repeats )
-- crow.ii.jf.god_mode( state )
-- crow.ii.jf.retune( channel, numerator, denominator )
-- crow.ii.jf.quantize( divisions )
-- ii.jf[1].trigger(1,1) -- device #1
-- ii.jf[2].trigger(1,1) -- device #2

function JustFriendsPerformer:play_note(sequence, note, velocity, envelope_duration)
  local adj_note = note - params:get('marco_root')
  local pitch = (adj_note >= 0 and adj_note or 0) / 12
  local device = params:get('marco_performer_jf_device_'..sequence)
  crow.ii.jf[device].play_note(pitch, velocity * VELOCITY_CONSTANT)
end

function JustFriendsPerformer:apply_effect(index, data)
  local function log_data(label, idx, d)
    local parts = {}
    for k, v in pairs(d) do table.insert(parts, tostring(k)..'='..tostring(v)) end
    print(string.format('[%s] Applying effect on index: %s | data: {%s}', label, tostring(idx), table.concat(parts, ', ')))
  end
  if data.mod == 'octave_shift' then
    log_data('JustFriendsPerformer', index, data)
    -- TODO: Implement octave shift effect for Just Friends
  elseif data.mod == 'voice_mode' then
    log_data('JustFriendsPerformer', index, data)
    -- TODO: Implement voice mode effect for Just Friends
  end
end

return JustFriendsPerformer