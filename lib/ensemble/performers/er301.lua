local Performer = include('lib/ensemble/performer')

local ER301Performer = {
  clocks = nil,
  name = 'ER-301'
}

setmetatable(ER301Performer, { __index = Performer })

function ER301Performer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function ER301Performer:get_effects()
  return {
    { effect = "sample_start", id = "er301_sample_start" },
    { effect = "grain_size", id = "er301_grain_size" }
  }
end

function ER301Performer:init()
  print('[ER301Performer:init] Starting initialization')
  self.clocks = {}
end

function ER301Performer:play_note(sequence, note, velocity, envelope_duration)
  crow.ii.er301.cv(params:get('marco_performer_er301_cv_port_'..sequence), note / 12)
  if self.clocks[sequence] then
    clock.cancel(self.clocks[sequence])
  end
  self.clocks[sequence] = clock.run(
    function()
      crow.ii.er301.tr(params:get('marco_performer_er301_tr_port_'..sequence), 1)
      clock.sleep(envelope_duration)
      crow.ii.er301.tr(params:get('marco_performer_er301_tr_port_'..sequence), 0)
    end
  )
end

function ER301Performer:apply_effect(effect, data)
  print('[ER301Performer:apply_effect] Received:')
  print('  effect:', effect)
  print('  data:', data)
  if effect.effect == "sample_start" then
    -- TODO: Implement sample start effect for ER-301
    print('[ER301Performer] Applying sample start effect')
  elseif effect.effect == "grain_size" then
    -- TODO: Implement grain size effect for ER-301
    print('[ER301Performer] Applying grain size effect')
  end
end

return ER301Performer