local Performer = include('lib/ensemble/performer')

local WTapePerformer = {
  name = WT
}

setmetatable(WTapePerformer, { __index = Performer })

function WTapePerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function WTapePerformer:init()
  self:init_effects()
end

function WTapePerformer:configure(options)
  local device = params:get('marco_performer_w_device_'..WRONG_STOP_SEQ)
  local loop_length = params:get('marco_performer_w_loop_length_'..WRONG_STOP_SEQ)
  if not options then
    crow.ii.wtape[device].play(0)
    crow.ii.wtape[device].record(0)
    crow.ii.wtape[device].timestamp(5000)
    crow.ii.wtape[device].loop_start()
    crow.ii.wtape[device].seek(loop_length)
    crow.ii.wtape[device].loop_scale(0)
    crow.ii.wtape[device].loop_end()
    crow.ii.wtape[device].timestamp(5000)
    crow.ii.wtape[device].loop_active(1)
    crow.ii.wtape[device].echo_mode(0)
    crow.ii.wtape[device].freq(0)
    crow.ii.wtape[device].play(1)
  else
    for k,v in pairs(options) do
      crow.ii.wtape[device][k](v)
    end
  end
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
    local beat_time = 60 / params:get('clock_tempo')
    local device = params:get('marco_performer_w_device_'..WRONG_STOP_SEQ)
    local strength = params:get('marco_performer_w_erase_strength_'..WRONG_STOP_SEQ)
    local x = data.x
    local y = data.y
    clock.run(
      function()
        if effect_num % 2 == 0 then
          crow.ii.wtape[device].erase_strength(strength)
          crow.ii.wtape[device].record(1)
          clock.sleep(beat_time * 5)
          crow.ii.wtape[device].record(0)
        else 
          local freq = (10 / 8 * y) - 5
          crow.ii.wtape[device].freq(freq)
          clock.sleep(beat_time * 5)
          crow.ii.wtape[device].freq(0)
        end
      end
    )
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

function WTapePerformer:play_note(sequence, note, velocity, envelope_duration)
  -- TODO: I believe this performer will be a cat, rather than a discrete voice.
  local device = params:get('marco_performer_w_device_'..sequence)
  crow.ii.wtape[device].freq(note / 12)
  crow.ii.wtape[device].seek(envelope_duration) -- Just goofin; might want to init a loop and bounce around in it
end

return WTapePerformer  