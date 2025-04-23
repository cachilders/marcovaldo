local Performer = include('lib/ensemble/performer')
local VELOCITY_CONSTANT = 5/127 -- to test

local WSynthPerformer = {
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
  -- no-op
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


function WSynthPerformer:play_note(sequence, note, velocity, envelope_duration)
  local device = params:get('marco_performer_w_device_'..sequence)
  local attack = (params:get('marco_attack_'..sequence)*.1) - 5
  crow.ii.wsyn[device].ar_mode(1) -- Investigate alternate options
  crow.ii.wsyn[device].lpg_symmetry(attack) -- Expand with attack and release as best we can
  crow.ii.wsyn[device].play_note((params:get('marco_root'))/12, velocity * VELOCITY_CONSTANT)
end

function WSynthPerformer:apply_effect(index, data)
  -- no-op
end

return WSynthPerformer 