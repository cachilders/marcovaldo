local Performer = include('lib/ensemble/performer')

local ER301Performer = {
  name = 'ER-301'
}

setmetatable(ER301Performer, { __index = Performer })

function ER301Performer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function ER301Performer:init()
  -- Initialize ER-301
end

function ER301Performer:play_note(sequence, note, velocity, envelope_duration)
  crow.ii.er301.cv(params:get('marco_performer_er301_cv_port_'..sequence), note / 12)
  clock.run(
    function()
      crow.ii.er301.tr(params:get('marco_performer_er301_tr_port_'..sequence), 1)
      clock.sleep(envelope_duration)
      crow.ii.er301.tr(params:get('marco_performer_er301_tr_port_'..sequence), 0)
    end
  )
end

function ER301Performer:apply_effect(index, data)
  -- no-op
end

return ER301Performer 