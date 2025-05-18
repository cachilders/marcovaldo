local Performer = include('lib/ensemble/performer')

local ER301Performer = {
  name = SC
}

setmetatable(ER301Performer, { __index = Performer })

function ER301Performer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function ER301Performer:_create_effect(effect_num)
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

function ER301Performer:play_note(sequence, note, velocity, envelope_duration)
  local divided_duration = envelope_duration / (self.divisions or 1)
  local repeats = (self.repeats or 1) <= (self.divisions or 1) and (self.repeats or 1) or (self.divisions or 1)
  local division_gap = repeats > 1 and (envelope_duration - (divided_duration * repeats)) / (repeats - 1) or 0
  local voice_clock = self:_get_next_clock('voice')

  for i = 1, repeats do
    if voice_clock then
      clock.cancel(voice_clock)
      crow.ii.er301.tr(params:get('marco_performer_er301_tr_port_'..sequence), 0)
    end
    voice_clock = clock.run(
      function()
        local tr_port = params:get('marco_performer_er301_tr_port_'..sequence)
        local cv_port = params:get('marco_performer_er301_cv_port_'..sequence)
        crow.ii.er301.cv_slew(params:get('marco_performer_slew_'..sequence) / 100)
        crow.ii.er301.cv(cv_port, note / 12)
        crow.ii.er301.tr(tr_port, 1)
        clock.sleep(divided_duration)
        crow.ii.er301.tr(tr_port, 0)
        crow.ii.er301.cv_off(cv_port, 0)
        if repeats > 1 then
          clock.sleep(division_gap)
        end
      end
    )
  end
end

return ER301Performer
