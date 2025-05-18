local Performer = include('lib/ensemble/performer')
VELOCITY_CONSTANT = 5 / 127

local JustFriendsPerformer = {
  name = JF
}

setmetatable(JustFriendsPerformer, { __index = Performer })

function JustFriendsPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function JustFriendsPerformer:init()
  self:_init_clocks()
  self:_init_effects()
  crow.ii.jf.mode(1)
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

-- crow:	-- commands
-- crow:	ii.jf.trigger( channel, state )
-- crow:	ii.jf.run_mode( mode )
-- crow:	ii.jf.run( volts )
-- crow:	ii.jf.transpose( pitch )
-- crow:	ii.jf.vtrigger( channel, level )
-- crow:	ii.jf.mode( mode )
-- crow:	ii.jf.tick( clock_or_bpm )
-- crow:	ii.jf.play_voice( channel, pitch_or_divs, level_or_repeats )
-- crow:	ii.jf.play_note( pitch_or_divs, level_or_repeats )
-- crow:	ii.jf.god_mode( state )
-- crow:	ii.jf.retune( channel, numerator, denominator )
-- crow:	ii.jf.quantize( divisions )
-- crow:	ii.jf.pitch( channel, pitch )
-- crow:	ii.jf.address( index )
-- crow:	-- request params
-- crow:	ii.jf.get( 'trigger', channel )
-- crow:	ii.jf.get( 'run_mode' )
-- crow:	ii.jf.get( 'run' )
-- crow:	ii.jf.get( 'transpose' )
-- crow:	ii.jf.get( 'mode' )
-- crow:	ii.jf.get( 'tick' )
-- crow:	ii.jf.get( 'god_mode' )
-- crow:	ii.jf.get( 'quantize' )
-- crow:	ii.jf.get( 'speed' )
-- crow:	ii.jf.get( 'tsc' )
-- crow:	ii.jf.get( 'ramp' )
-- crow:	ii.jf.get( 'curve' )
-- crow:	ii.jf.get( 'fm' )
-- crow:	ii.jf.get( 'time' )
-- crow:	ii.jf.get( 'intone' )
-- crow:	-- then receive
-- crow:	ii.jf.event = function( e, value )
-- crow:	if e.name == 'trigger' then
-- crow:	-- handle trigger response
-- crow:	-- e.arg: first argument, ie channel
-- crow:	-- e.device: index of device
-- crow:	elseif e.name == 'run_mode' then
-- crow:	elseif e.name == 'run' then
-- crow:	elseif e.name == 'transpose' then
-- crow:	elseif e.name == 'mode' then
-- crow:	elseif e.name == 'tick' then
-- crow:	elseif e.name == 'god_mode' then
-- crow:	elseif e.name == 'quantize' then
-- crow:	elseif e.name == 'speed' then
-- crow:	elseif e.name == 'tsc' then
-- crow:	elseif e.name == 'ramp' then
-- crow:	elseif e.name == 'curve' then
-- crow:	elseif e.name == 'fm' then
-- crow:	elseif e.name == 'time' then
-- crow:	elseif e.name == 'intone' then
-- crow:	end
-- crow:	end

function JustFriendsPerformer:play_note(sequence, note, velocity, envelope_duration)
  local divided_duration = envelope_duration / (self.divisions or 1)
  local repeats = (self.repeats or 1) <= (self.divisions or 1) and (self.repeats or 1) or (self.divisions or 1)
  local division_gap = repeats > 1 and (envelope_duration - (divided_duration * repeats)) / (repeats - 1) or 0
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
        crow.ii.jf[device].play_note(pitch, velocity * VELOCITY_CONSTANT)
        if self.repeats > 1 then
          clock.sleep(division_gap)
        end
      end
    )
  end
end

return JustFriendsPerformer
