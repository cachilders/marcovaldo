local Performer = include('lib/ensemble/performer')
local VELOCITY_CONSTANT = 5/127 -- to test

local WSynthPerformer = {
  name = WS
}

setmetatable(WSynthPerformer, { __index = Performer })

function WSynthPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function WSynthPerformer:init()
  self.clocks = {}
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
    local beat_time = 60 / params:get('clock_tempo')
    clock.run(
      function()
        -- do something
        clock.sleep(beat_time)
        -- reset
      end
    )
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
  local attack = self._scale_to_w(params:get('marco_attack_'..sequence))
  local curve = params:get('marco_performer_w_curve_'..sequence)
  local ramp = params:get('marco_performer_w_ramp_'..sequence)
  local fm_i = params:get('marco_performer_w_fm_i_'..sequence)
  local fm_env = params:get('marco_performer_w_fm_env_'..sequence)
  local fm_rat_n = params:get('marco_performer_w_fm_rat_n_'..sequence)
  local fm_rat_d = params:get('marco_performer_w_fm_rat_d_'..sequence)
  local adj_note = note - params:get('marco_root')
  local vo = (adj_note >= 0 and adj_note or 0) / 12
  local divided_duration = envelope_duration / (self.divisions or 1)
  local repeats = (self.repeats or 1) <= (self.divisions or 1) and (self.repeats or 1) or (self.divisions or 1)
  local division_gap = repeats > 1 and (envelope_duration - (divided_duration * repeats)) / (repeats - 1) or 0
  crow.ii.wsyn[device].ar_mode(1)
  crow.ii.wsyn[device].lpg_time(envelope_duration)
  crow.ii.wsyn[device].lpg_symmetry(attack)
  crow.ii.wsyn[device].curve(curve)
  crow.ii.wsyn[device].ramp(ramp)
  crow.ii.wsyn[device].fm_index(fm_i)
  crow.ii.wsyn[device].fm_env(fm_env)
  crow.ii.wsyn[device].fm_ratio(fm_rat_n, fm_rat_d)
  crow.ii.wsyn[device].lpg_symmetry(attack)
  crow.ii.wsyn[device].play_note(vo, velocity * VELOCITY_CONSTANT)
end

return WSynthPerformer
