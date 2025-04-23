local Performer = include('lib/ensemble/performer')

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

function JustFriendsPerformer:init()
  -- Initialize Just Friends
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
  -- Figure out how we can do envelopes
  crow.ii.jf.play_note((note - params:get('marco_root'))/12, velocity/127)
end

function JustFriendsPerformer:apply_effect(index, data)
  -- no-op
end

return JustFriendsPerformer 