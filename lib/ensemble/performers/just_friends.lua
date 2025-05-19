local Performer = include('lib/ensemble/performer')
VELOCITY_CONSTANT = 5 / 127

local JustFriendsPerformer = {
  max_clock_indices = {effect = 4, voice = 6},
  name = JF
}

setmetatable(JustFriendsPerformer, { __index = Performer })

function JustFriendsPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function JustFriendsPerformer:_create_effect(effect_num)
  return function(data)
    local beat_time = 60 / params:get('clock_tempo')
    local effect_clock = self:_get_next_clock('effect')
    if effect_clock then
      clock.cancel(effect_clock)
    end
    effect_clock = clock.run(
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

function JustFriendsPerformer:play_note(sequence, note, velocity, envelope_duration)
  local divided_duration = envelope_duration / (self.divisions or 1)
  local repeats = (self.repeats or 1) <= (self.divisions or 1) and (self.repeats or 1) or (self.divisions or 1)
  local division_gap = repeats > 1 and (envelope_duration - (divided_duration * repeats)) / (repeats - 1) or 0
  local voice_index = self.next_clock_index['voice']
  local voice_clock = self:_get_next_clock('voice')
  for i = 1, repeats do
    if voice_clock then
      clock.cancel(voice_clock)
    end
    voice_clock = clock.run(
      function()
        local adj_note = note - params:get('marco_root')
        local pitch = (adj_note >= 0 and adj_note or 0) / 12
        local device = params:get('marco_performer_jf_device_'..sequence)
        crow.ii.jf[device].mode(params:get('marco_performer_jf_mode_'..sequence) == 1 and 1 or 0)
        crow.ii.jf[device].pitch(pitch)
        crow.ii.jf[device].vtrigger(voice_index, velocity * VELOCITY_CONSTANT)
        clock.sleep(divided_duration)
        crow.ii.jf[device].vtrigger(voice_index, 0)
        crow.ii.jf[device].play_note(pitch, velocity * VELOCITY_CONSTANT)
        if self.repeats > 1 then
          clock.sleep(division_gap)
        end
      end
    )
  end
end

return JustFriendsPerformer
