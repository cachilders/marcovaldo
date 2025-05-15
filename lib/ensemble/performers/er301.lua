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

function ER301Performer:init()
  self.clocks = {}
  self:init_effects()
end

function ER301Performer:_create_effect(effect_num)
  return function(data)
    local beat_time = 60 / params:get('clock_tempo')
    clock.run(
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

function ER301Performer:init_effects()
  self.effects = {
    self:_create_effect(1),
    self:_create_effect(2),
    self:_create_effect(3),
    self:_create_effect(4)
  }
end

function ER301Performer:play_note(sequence, note, velocity, envelope_duration)
  local divided_duration = envelope_duration / (self.divisions or 1)
  local repeats = (self.repeats or 1) <= (self.divisions or 1) and (self.repeats or 1) or (self.divisions or 1)
  local division_gap = repeats > 1 and (envelope_duration - (divided_duration * repeats)) / (repeats - 1) or 0
  crow.ii.er301.cv(params:get('marco_performer_er301_cv_port_'..sequence), note / 12)

  for i = 1, repeats do
    if self.clocks[sequence] then
      clock.cancel(self.clocks[sequence])
      crow.ii.er301.tr(params:get('marco_performer_er301_tr_port_'..sequence), 0)
    end
    self.clocks[sequence] = clock.run(
      function()
        crow.ii.er301.tr(params:get('marco_performer_er301_tr_port_'..sequence), 1)
        clock.sleep(divided_duration)
        crow.ii.er301.tr(params:get('marco_performer_er301_tr_port_'..sequence), 0)
        if repeats > 1 then
          clock.sleep(division_gap)
        end
      end
    )
  end
end

return ER301Performer
