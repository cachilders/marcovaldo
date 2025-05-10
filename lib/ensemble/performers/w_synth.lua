local Performer = include('lib/ensemble/performer')
local VELOCITY_CONSTANT = 5/127 -- to test

local WSynthPerformer = {
  clocks = nil,
  name = 'W/Synth',
  effects = nil
}

setmetatable(WSynthPerformer, { __index = Performer })

function WSynthPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function WSynthPerformer:init()
  print('[WSynthPerformer:init] Starting initialization')
  self:init_effects()
end

-- velocity( voice, velocity ) -- strike the vactrol of <voice> at <velocity> in volts (s8, s16V)
-- pitch( voice, pitch ) -- set <voice> to <pitch> in volts-per-octave (s8, s16V)
-- play_voice( voice, pitch, velocity ) -- set <voice> to <pitch> (v8) and strike the vactrol at <velocity> (V) (s8, s8, s16V)
-- play_note( pitch, level ) -- dynamically assign a voice, set to <pitch> (v8), strike with <velocity> (s16V, s16V)
-- ar_mode( is_ar ) -- in attack-release mode, all notes are "plucked" and no "release" is required (s8)
-- curve ( curve ) -- cross-fade waveforms: -5=square, 0=triangle, 5=sine (s16V)
-- ramp( ramp ) -- waveform symmetry: -5=rampwave, 0=triangle, 5=sawtooth (NB: affects FM tone) (s16V)
-- fm_index( index ) -- amount of FM modulation. -5=negative, 0=minimum, 5=maximum (s16V)
-- fm_env( amount ) -- amount of vactrol envelope applied to fm index, -5 to +5 (s16V)
-- fm_ratio( numerator, denominator ) -- ratio of the FM modulator to carrier as a ratio. floating point values up to 20.0 supported (s16V, s16V)
-- lpg_time( time ) -- vactrol time constant. -5=drones, 0=vtl5c3, 5=blits (s16V)
-- lpg_symmetry( symmetry ) -- vactrol attack-release ratio. -5=fastest attack, 5=long swells (s16V)
-- patch( jack, param ) -- patch a hardware *jack* to a *param* destination (s8, s8)
-- voices( count ) -- set number of polyphonic voices to allocate. use 0 for unison mode (s8)

function WSynthPerformer:_create_effect(effect_num)
  return function(data)
    print('[WSynthPerformer] Effect '..effect_num..' not implemented')
  end
end

function WSynthPerformer:init_effects()
  self.effects = {
    self:_create_effect(1),
    self:_create_effect(2),
    self:_create_effect(3),
    self:_create_effect(4)
  }
end

function WSynthPerformer._scale_to_w(val)
  return (val*0.1) - 5
end

function WSynthPerformer:play_note(sequence, note, velocity, envelope_duration)
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

return WSynthPerformer