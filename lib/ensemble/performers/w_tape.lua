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

function WTapePerformer:play_note(sequence, note, velocity, envelope_duration)
  local device = params:get('marco_performer_w_device_'..sequence)
  local output = params:get('marco_performer_w_outputs_'..sequence)
  local gate = params:get('marco_performer_w_gate_'..sequence)
  local atk, dec, sus, rel = params:get('marco_attack_'..sequence), params:get('marco_decay_'..sequence), params:get('marco_sustain_'..sequence), params:get('marco_release_'..sequence)
  local sus_dur = envelope_duration - (envelope_duration * (atk + dec + rel) / 100)
  sus = sus * velocity / 100
  sus_dur = sus_dur >= 0 and sus_dur or 0
  local a, d, sus_v, r = envelope_duration * atk / 100, envelope_duration * dec / 100, sus, envelope_duration * rel / 100
  note = note / 12
  if device == 1 then
    crow.output[output].slew = 0
    crow.output[output].volts = note
    if gate == 1 then
      crow.output[output].action = string.format("pulse(%f, %f)", envelope_duration, velocity)
      crow.output[output]()
    elseif gate == 2 then
      local envelope = string.format("{ to(0,0), to(%f,%f), to(%f,%f), to(%f,%f), to(0,%f) }", velocity, a, sus_v, d, sus_v, sus_dur, r)
      crow.output[output].action = envelope
      crow.output[output]()
    end
  else
    device = device - 1
    crow.ii.crow[device].slew(output, 0)
    crow.ii.crow[device].volts(output, note)
    if gate == 1 then
      clock.run(
        function()
          crow.ii.crow[device].volts(output, 10)
          clock.sleep(envelope_duration)
          crow.ii.crow[device].volts(output, 0)
        end
      )
    elseif gate == 2 then
      clock.run(
        function()
          crow.ii.crow[device].slew(output, 0)
          crow.ii.crow[device].volts(output, 0)
          crow.ii.crow[device].slew(output, a)
          crow.ii.crow[device].volts(output, velocity)
          clock.sleep(a)
          crow.ii.crow[device].slew(output, d)
          crow.ii.crow[device].volts(output, sus_v)
          clock.sleep(d)
          clock.sleep(sus_dur)
          crow.ii.crow[device].slew(output, r)
          crow.ii.crow[device].volts(output, 0)
        end
      )
    end
  end
end

return WTapePerformer