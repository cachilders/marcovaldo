local Performer = include('lib/ensemble/performer')

local WTapePerformer = {
  name = 'W/Tape',
  effects = nil
}

setmetatable(WTapePerformer, { __index = Performer })

function WTapePerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function WTapePerformer:init()
  print('[WTapePerformer:init] Starting initialization')
  self:init_effects()
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

function WTapePerformer:_create_effect(effect_num)
  return function(data)
    print('[WTapePerformer] Effect '..effect_num..' not implemented')
  end
end

function WTapePerformer:init_effects()
  self.effects = {
    self:_create_effect(1),
    self:_create_effect(2),
    self:_create_effect(3),
    self:_create_effect(4)
  }
end

function WTapePerformer:apply_effect(breed, data)
  print('[WTapePerformer:apply_effect] Applying effect:', breed)
  print('[WTapePerformer:apply_effect] Data:', data.x, data.y)
  
  if params:get('marco_wrong_stop') == 2 then
    local device = params:get('marco_performer_w_device_1') -- Use the first sequence's device setting
    
    if breed == 1 then -- pounce
      crow.ii.wtape[device].play(math.random(-1, 1)) -- Random direction (reverse, stop, forward)
    elseif breed == 2 then -- scratch
      crow.ii.wtape[device].speed(math.random(-20, 20) / 10) -- Random speed between -2 and 2
    elseif breed == 3 then -- purr
      crow.ii.wtape[device].loop_active(1) -- Enable looping
      crow.ii.wtape[device].loop_scale(math.random(-3, 3)) -- Random loop scale
    elseif breed == 4 then -- meow
      crow.ii.wtape[device].seek(math.random(-5, 5)) -- Random seek
    end
  end
end

function WTapePerformer:play_note(sequence, note, velocity, envelope_duration)
  -- TODO: I believe this performer will be a cat, rather than a discrete voice.
  local device = params:get('marco_performer_w_device_'..sequence)
  crow.ii.wtape[device].freq(note / 12)
  crow.ii.wtape[device].seek(envelope_duration) -- Just goofin; might want to init a loop and bounce around in it
end

return WTapePerformer  