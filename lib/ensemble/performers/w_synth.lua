local Performer = include('lib/ensemble/performer')
local VELOCITY_CONSTANT = 5/127 -- to test

local WSynthPerformer = {
  clocks = nil,
  name = 'W/Synth'
}

setmetatable(WSynthPerformer, { __index = Performer })

function WSynthPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function WSynthPerformer:init()
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

function WSynthPerformer._scale_to_w(val)
  return (val*0.1) - 5
end

function WSynthPerformer:play_note(sequence, note, velocity, envelope_duration)
  local device = params:get('marco_performer_w_device_'..sequence)
  local attack = self._scale_to_w(params:get('marco_attack_'..sequence))
  local curve = params:get('marco_performer_w_curve_'..sequence)
  local ramp = params:get('marco_performer_w_ramp_'..sequence)
  local fm_i = params:get('marco_performer_w_fm_i_'..sequence)
  local fm_env = params:get('marco_performer_w_fm_env_'..sequence)
  local fm_rat_n = params:get('marco_performer_w_fm_rat_n_'..sequence)
  local fm_rat_d = params:get('marco_performer_w_fm_rat_d_'..sequence)
  local adj_note = note - params:get('marco_root')
  local pitch = (adj_note >= 0 and adj_note or 0) / 12
  crow.ii.wsyn[device].ar_mode(1)
  crow.ii.wsyn[device].lpg_time(envelope_duration)
  crow.ii.wsyn[device].lpg_symmetry(attack)
  crow.ii.wsyn[device].curve(curve)
  crow.ii.wsyn[device].ramp(ramp)
  crow.ii.wsyn[device].fm_index(fm_i)
  crow.ii.wsyn[device].fm_env(fm_env)
  crow.ii.wsyn[device].fm_ratio(fm_rat_n, fm_rat_d)
  crow.ii.wsyn[device].lpg_symmetry(attack)
  crow.ii.wsyn[device].play_note(pitch, velocity * VELOCITY_CONSTANT)
end

function WSynthPerformer:apply_effect(index, data)
  -- no-op
end

return WSynthPerformer 