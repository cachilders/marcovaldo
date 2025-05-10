local Performer = include('lib/ensemble/performer')
VELOCITY_CONSTANT = 5 / 127

local JustFriendsPerformer = {
  name = JF,
  effects = nil
}

setmetatable(JustFriendsPerformer, { __index = Performer })

function JustFriendsPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function JustFriendsPerformer:init()
  print('[JustFriendsPerformer:init] Starting initialization')
  self:init_effects()
  crow.ii.jf.mode(1)
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
function JustFriendsPerformer:_create_effect(effect_num)
  return function(data)
    print('[JustFriendsPerformer] Effect '..effect_num..' not implemented')
  end
end

function JustFriendsPerformer:init_effects()
  self.effects = {
    self:_create_effect(1),
    self:_create_effect(2),
    self:_create_effect(3),
    self:_create_effect(4)
  }
end

function JustFriendsPerformer:play_note(sequence, note, velocity, envelope_duration)
  local adj_note = note - params:get('marco_root')
  local pitch = (adj_note >= 0 and adj_note or 0) / 12
  local device = params:get('marco_performer_jf_device_'..sequence)
  crow.ii.jf[device].play_note(pitch, velocity * VELOCITY_CONSTANT)
end

return JustFriendsPerformer
