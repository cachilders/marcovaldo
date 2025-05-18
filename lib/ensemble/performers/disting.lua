local Performer = include('lib/ensemble/performer')
local VELOCITY_CONSTANT = 5/127

local DistingPerformer = {
  name = DIST
}

setmetatable(DistingPerformer, { __index = Performer })

function DistingPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function DistingPerformer:_create_effect(effect_num)
  return function(data)
    local fallback, min, max
    local beat_time = 60 / params:get('clock_tempo')
    local temp
    local x = data.x
    local y = data.y
    local effect_clock = self:_get_next_clock('effect')
    
    crow.ii.disting.event = function(e, val)
      if e.name == 'parameter' then
        fallback = val
      elseif e.name == 'parameter_min' then
        min = val
      elseif e.name == 'parameter_max' then
        max = val
      end
      if fallback and min and max then
        if effect_clock then
          clock.cancel(effect_clock)
        end
        effect_clock = clock.run(
          function()
            if x <= 4 then
              temp = fallback - ((fallback - min)/PANE_EDGE_LENGTH * y)
            else
              temp = fallback + ((max - fallback)/PANE_EDGE_LENGTH * y)
            end
            crow.ii.disting.parameter(effect_num, temp)
            clock.sleep(beat_time)
            crow.ii.disting.parameter(effect_num, fallback)
          end
        )
      end
    end
    crow.ii.disting.get('parameter', effect_num)
    crow.ii.disting.get('parameter_min', effect_num)
    crow.ii.disting.get('parameter_max', effect_num)
  end
end

function DistingPerformer:play_note(sequence, note, velocity, envelope_duration)
  local adj_note = note - params:get('marco_root')
  local vo = (adj_note >= 0 and adj_note or 0) / 12
  local voice_clock = self:_get_next_clock('voice')

  if voice_clock then
    clock.cancel(voice_clock)
  end
  voice_clock = clock.run(
    function()
      crow.ii.disting.note_pitch(note, vo)
      crow.ii.disting.note_velocity(note, velocity * VELOCITY_CONSTANT)
      clock.sleep(envelope_duration)
      crow.ii.disting.note_off(note)
    end
  )
end

return DistingPerformer
