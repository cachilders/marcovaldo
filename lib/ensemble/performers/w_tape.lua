local Performer = include('lib/ensemble/performer')

local WTapePerformer = {
  name = 'W/Tape'
}

setmetatable(WTapePerformer, { __index = Performer })

function WTapePerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function WTapePerformer:get_effects()
  return {
    { effect = "tape_speed", id = "wtape_speed" },
    { effect = "direction", id = "wtape_direction" }
  }
end

function WTapePerformer:init()
  print('[WTapePerformer:init] Starting initialization')
end

-- record(is_recording) - is_recording: bool - Set recording state
-- play(is_playing) - is_playing: int (1 = forward, 0 = stop, -1 = reverse) - Set playback state and direction
-- reverse() - no args - Reverse tape direction
-- speed(rate, [denominator]) - rate: float, denominator: optional - Set speed as a rate or ratio (negative = reverse)
-- freq(v8) - v8: float (volts/octave) - Set speed as frequency (1V/oct), maintains reverse state
-- erase_strength(level) - level: int (0 = overdub, 1 = overwrite) - Set erase head strength (feedback amount)
-- monitor_level(gain) - gain: float - Set gain of dry path (IN to OUT)
-- rec_level(gain) - gain: float - Set gain of recorded material
-- echo_mode(active) - active: bool (1 = on, 0 = off) - Set echo mode (playback before erase)
-- loop_start() - no args - Set current position as loop start
-- loop_end() - no args - Set current position as loop end, jump to start
-- loop_active(is_active) - is_active: bool (1 = on, 0 = off) - Enable/disable looping
-- loop_scale(scale) - scale: int (positive = multiply, negative = divide, 0 = reset) - Multiply/divide loop size, 0 resets to original window
-- loop_next(direction) - direction: int (positive = forward, negative = back, 0 = retrigger) - Move loop window by its length or retrigger loop
-- timestamp(seconds) - seconds: float - Move tape to absolute position (seconds)
-- seek(seconds) - seconds: float - Move tape relative to current position (seconds)

function WTapePerformer:play_note(sequence, note, velocity, envelope_duration)
  -- TODO: I believe this performer will be a cat, rather than a discrete voice.
  local device = params:get('marco_performer_w_device_'..sequence)
  crow.ii.wtape[device].freq(note / 12)
  crow.ii.wtape[device].seek(envelope_duration) -- Just goofin; might want to init a loop and bounce around in it
end

function WTapePerformer:apply_effect(effect, data)
  print('[WTapePerformer:apply_effect] Received:')
  print('  effect:', effect)
  print('  data:', data)
  if effect.effect == "tape_speed" then
    -- TODO: Implement tape speed effect for W/Tape
    print('[WTapePerformer] Applying tape speed effect')
  elseif effect.effect == "direction" then
    -- TODO: Implement direction effect for W/Tape
    print('[WTapePerformer] Applying direction effect')
  end
end

return WTapePerformer