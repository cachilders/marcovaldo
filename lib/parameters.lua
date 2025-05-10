include('lib/utils')
local textentry = require('textentry')
local fileselect = require('fileselect')

local ANS = 'Ansible'
local CROW = 'Crow'
local SC = 'ER-301'
local DIST = 'Disting'
local JF = 'Just Friends'
local WD = 'W/Delay'
local WS = 'W/Synth'
local WT = 'W/Tape'
local MIDI = 'Midi'
local MX = 'Mx. Synths'

local ENABLED_STATES = {'Enabled', 'Disabled'}
local ERROR_BAD_FILE = 'ERROR: Bad state file'
local I2C_PERFORMERS = {ANS, CROW, SC, DIST, JF, WD, WS} -- Removing WT while we figure out what to do with it
local CROW_DEVICES = {'Host', '1', '2', '3', '4'}
local CROW_OUTPUTS = {'1/2', '3/4'}
local CROW_GATES = {'Gate', 'Envelope'}
local W_V_SPEC = controlspec.def{
  min = -5,
  max = 5,
  warp = 'lin',
  step = 0.01,
  default = 0,
  units = 'v',
  quantum = 0.01,
  wrap = false
}
local W_RAT_SPEC = controlspec.def{
  min = 0,
  max = 20,
  warp = 'lin',
  step = 0.01,
  default = 10,
  quantum = 0.01,
  wrap = false
}
local W_FEEDBACK_SPEC = controlspec.def{
  min = 0,
  max = 5,
  warp = 'lin',
  step = 0.01,
  default = 5,
  quantum = 0.01,
  wrap = false
}
local W_FILTER_SPEC = controlspec.def{
  min = 0,
  max = 5,
  warp = 'lin',
  step = 0.01,
  default = 4,
  quantum = 0.01,
  wrap = false
}
local W_RATE_SPEC = controlspec.def{
  min = 0.125,
  max = 2,
  warp = 'lin',
  step = 0.01,
  default = 0.2,
  quantum = 0.01,
  wrap = false
}
local W_MOD_SPEC = controlspec.def{
  min = -5,
  max = 5,
  warp = 'lin',
  step = 0.01,
  default = 1,
  quantum = 0.01,
  wrap = false
}
local W_AMOUNT_SPEC = controlspec.def{
  min = 0,
  max = 5,
  warp = 'lin',
  step = 0.01,
  default = 0,
  quantum = 0.01,
  wrap = false
}

local Parameters = {
  animations_enabled = nil,
  available_performers = nil,
  midi_device_identifiers = nil,
  root = nil,
  scale = nil,
  scale_names = nil
}

function Parameters._load_state_from_file(filepath)
  local pset_path, match_count = string.gsub(filepath, '.state', '.pset')
  if match_count > 0 then
    state_load(filepath)
    params:read(pset_path)
    params:bang()
  else
    print(ERROR_BAD_FILE)
  end
end

function Parameters._save_state_to_file(filename)
  local filepath = norns.state.data..filename
  params:write(filepath..'.pset')
  state_save(filepath..'.state')
end

function Parameters:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  self.scale_names = get_musicutil_scale_names()
  return instance
end

function Parameters:hydrate(parameters)
  self.animations_enabled:set(self.animations_enabled._value)
  self.root:set(self.root._value)
  self.scale:set(parameters.scale._value)
end

function Parameters:init()
  self:_init_observables()
  self:_init_performers()
  self:_init_midi_devices()
  self:_init_params()
  self:_refresh_performer_params()
  params:bang()
end

function Parameters:_init_observables()
  self.animations_enabled = observable.new(true)
  self.root = observable.new(48)
  self.scale = observable.new('')
end

function Parameters:_init_performers()
  local available_performers = {MX, MIDI}
  if norns.crow.dev then
    for _, device in ipairs(I2C_PERFORMERS) do
      table.insert(available_performers, device)
    end
  end
  self.available_performers = available_performers
end

function Parameters:_init_midi_devices()
  local devices = {}
  
  for i = 1, #midi.vports do
    if midi.vports[i].name ~= 'none' then
      devices[i] = truncate_string(midi.vports[i].name, 16)
    end
  end

  self.midi_device_identifiers = devices
end

function Parameters:_init_params()
  params:add_group('marcovaldo', 'MARCOVALDO', 13)
  params:add_trigger('marco_start', 'Start All Sequences')
  params:set_action('marco_start', function() arrangement:start() end)
  params:add_trigger('marco_pause', 'Pause All Sequences')
  params:set_action('marco_pause', function() arrangement:pause() end)
  params:add_trigger('marco_stop', 'Stop All Sequences')
  params:set_action('marco_stop', function() arrangement:stop() end)
  params:add_trigger('marco_load', 'Load State File')
  params:set_action('marco_load', function() fileselect.enter(norns.state.data, self._load_state_from_file) end)
  params:add_trigger('marco_save', 'Save Current State')
  params:set_action('marco_save', function() textentry.enter(self._save_state_to_file) end)
  params:add_trigger('marco_random', 'Randomize All Sequences')
  params:set_action('marco_random', function() arrangement:randomize() end)
  params:add_trigger('marco_reset', 'Clear All Sequences')
  params:set_action('marco_reset', function() arrangement:reset() end)
  params:add_separator('marco_global_actions_foot', '')
  params:add_separator('marco_global_settings', 'GLOBAL SETTINGS')
  params:add_option('marco_animations', 'Animations', ENABLED_STATES, 1)
  params:set_action('marco_animations', function(i) self.animations_enabled:set(i == 1) end)
  params:add_option('marco_scale', 'Scale Type', self.scale_names, 1)
  params:set_action('marco_scale', function(i) self.scale:set(self.scale_names[i]) end)
  params:add_number('marco_root', 'Root Note', 0, 127, 60, function(param) return music_util.note_num_to_name(param:get(), true) end)
  params:set_action('marco_root', function(i) self.root:set(i) end)
  params:add_number('marco_pulse_constant', 'Cosmological Constant', 50, 150, 75)

  for i = 1, 4 do
    params:add_group('marco_seq_'..i, 'MARCOVALDO > SEQ '..i, 34)
    params:add_trigger('marco_seq_start'..i, 'Start Sequence '..i)
    params:set_action('marco_seq_start'..i, function() arrangement:start(i) end)
    params:add_trigger('marco_seq_pause'..i, 'Pause Sequence '..i)
    params:set_action('marco_seq_pause'..i, function() arrangement:pause(i) end)
    params:add_trigger('marco_seq_stop'..i, 'Stop Sequence '..i)
    params:set_action('marco_seq_stop'..i, function() arrangement:stop(i) end)
    params:add_trigger('marco_seq_random_'..i, 'Randomize Sequence '..i)
    params:set_action('marco_seq_random_'..i, function() arrangement:randomize(i) end)
    params:add_trigger('marco_seq_reset_'..i, 'Clear Sequence '..i)
    params:set_action('marco_seq_reset_'..i, function() arrangement:reset(i) end)
    params:add_separator('marco_seq_actions_foot_'..i, '')
    params:add_separator('marco_seq_settings_'..i, 'SEQUENCE '..i..' SETTINGS')
    params:add_option('marco_performer_'..i, 'Performer', self.available_performers, 1)
    params:set_action('marco_performer_'..i, function(val) self:_refresh_performer_params(i, val) end)
    
    -- Disting EX options: TBD
    
    params:add_number('marco_performer_jf_device_'..i, 'Which JF', 1, 2, 1)

    params:add_option('marco_performer_midi_device_'..i, 'Midi Device', self.midi_device_identifiers, 1)
    params:add_number('marco_performer_midi_channel_'..i, 'Midi Channel', 1, 16, 1)

    params:add_option('marco_performer_crow_device_'..i, 'Which Crow', CROW_DEVICES, 1)
    params:add_option('marco_performer_crow_outputs_'..i, 'Which Outputs', CROW_OUTPUTS, 1)
    params:add_option('marco_performer_crow_gate_'..i, 'Gate Type', CROW_GATES, 1)
    params:set_action('marco_performer_crow_gate_'..i, function() self:_refresh_performer_params() end)

    params:add_number('marco_performer_er301_cv_port_'..i, 'CV Port', 1, 100, 1)
    params:add_number('marco_performer_er301_tr_port_'..i, 'TR Port', 1, 100, 1)

    params:add_number('marco_performer_ansible_output_'..i, 'Output Channel', 1, 4, 1)

    params:add_number('marco_performer_w_device_'..i, 'Which W/', 1, 2, 1)
    params:add_control('marco_performer_w_fm_i_'..i, 'FM Index', W_V_SPEC)
    params:add_control('marco_performer_w_fm_env_'..i, 'FM Envelope', W_V_SPEC)
    params:add_control('marco_performer_w_fm_rat_n_'..i, 'FM Rat. Num.', W_RAT_SPEC)
    params:add_control('marco_performer_w_fm_rat_d_'..i, 'FM Rat. Den.', W_RAT_SPEC)
    params:add_control('marco_performer_w_ramp_'..i, 'Ramp', W_V_SPEC)
    params:add_control('marco_performer_w_curve_'..i, 'Curve', W_V_SPEC)
    
    -- W/ parameters
    params:add_control('marco_performer_w_feedback_'..i, 'Feedback', W_FEEDBACK_SPEC)
    params:add_control('marco_performer_w_filter_'..i, 'Filter', W_FILTER_SPEC)
    params:add_control('marco_performer_w_rate_'..i, 'Rate', W_RATE_SPEC)
    params:add_control('marco_performer_w_mod_rate_'..i, 'Mod Rate', W_MOD_SPEC)
    params:add_control('marco_performer_w_mod_amount_'..i, 'Mod Amount', W_AMOUNT_SPEC)

    params:add_number('marco_performer_slew_'..i, 'CV Slew', 0, 100, 0, function(param) return ''..param:get()..'% of pulse' end)
    params:add_number('marco_attack_'..i, 'Attack', 0, 100, 20, function(param) return ''..param:get()..'% of width' end)
    params:add_number('marco_decay_'..i, 'Decay', 0, 100, 25, function(param) return ''..param:get()..'% of width' end)
    params:add_number('marco_sustain_'..i, 'Sustain', 0, 100, 90, function(param) return ''..param:get()..'% of strength' end)
    params:add_number('marco_release_'..i, 'Release', 0, 100, 20, function(param) return ''..param:get()..'% of width' end)
  end
  
  params:add_group('marco_experimental', 'EXPERIMENTAL', 1)
  params:add_option('marco_wrong_stop', 'The Wrong Stop', {'No', 'Yes'}, 1)
  params:set_action('marco_wrong_stop', function(i) 
    if arrangement and arrangement.sequences then
      arrangement:refresh()
    end
  end)
end

function Parameters:_refresh_performer_params(seq, val)
  if not norns.crow.dev then
    params:hide('marco_experimental')
  else
    params:show('marco_experimental')
  end
  
  local active_performer = self.available_performers[val]
  for i = 1, 4 do
    params:hide('marco_performer_ansible_output_'..i)
    params:hide('marco_performer_slew_'..i)
    params:hide('marco_performer_crow_device_'..i)
    params:hide('marco_performer_crow_outputs_'..i)
    params:hide('marco_performer_crow_gate_'..i)
    params:hide('marco_performer_er301_cv_port_'..i)
    params:hide('marco_performer_er301_tr_port_'..i)
    params:hide('marco_performer_jf_device_'..i)
    params:hide('marco_performer_midi_device_'..i)
    params:hide('marco_performer_midi_channel_'..i)
    params:hide('marco_performer_w_device_'..i)
    params:hide('marco_performer_w_curve_'..i)
    params:hide('marco_performer_w_fm_i_'..i)
    params:hide('marco_performer_w_fm_env_'..i)
    params:hide('marco_performer_w_fm_rat_n_'..i)
    params:hide('marco_performer_w_fm_rat_d_'..i)
    params:hide('marco_performer_w_ramp_'..i)
    params:hide('marco_attack_'..i)
    params:hide('marco_decay_'..i)
    params:hide('marco_sustain_'..i)
    params:hide('marco_release_'..i)
    params:hide('marco_performer_w_feedback_'..i)
    params:hide('marco_performer_w_filter_'..i)
    params:hide('marco_performer_w_rate_'..i)
    params:hide('marco_performer_w_mod_rate_'..i)
    params:hide('marco_performer_w_mod_amount_'..i)
    if seq == i then 
      if active_performer == MX then
        params:show('marco_attack_'..i)
        params:show('marco_decay_'..i)
        params:show('marco_sustain_'..i)
        params:show('marco_release_'..i)
      elseif active_performer == DIST then
        -- noop
      elseif active_performer == JF then
        params:show('marco_performer_jf_device_'..i)
      elseif active_performer == MIDI then
        params:show('marco_performer_midi_device_'..i)
        params:show('marco_performer_midi_channel_'..i)
      elseif active_performer == CROW then
        params:show('marco_performer_crow_device_'..i)
        params:show('marco_performer_crow_outputs_'..i)
        params:show('marco_performer_crow_gate_'..i)
        params:show('marco_performer_slew_'..i)
        if params:get('marco_performer_crow_gate_'..i) == 2 then
          params:show('marco_attack_'..i)
          params:show('marco_decay_'..i)
          params:show('marco_sustain_'..i)
          params:show('marco_release_'..i)
        end
      elseif active_performer == SC then
        params:show('marco_performer_er301_cv_port_'..i)
        params:show('marco_performer_er301_tr_port_'..i)
      elseif active_performer == ANS then
        params:show('marco_performer_ansible_output_'..i)
        params:show('marco_performer_slew_'..i)
      elseif active_performer == WS then
        params:show('marco_performer_w_device_'..i)
        params:show('marco_performer_w_curve_'..i)
        params:show('marco_performer_w_fm_i_'..i)
        params:show('marco_performer_w_fm_env_'..i)
        params:show('marco_performer_w_fm_rat_n_'..i)
        params:show('marco_performer_w_fm_rat_d_'..i)
        params:show('marco_performer_w_ramp_'..i)
        params:show('marco_attack_'..i)
      elseif active_performer == WD then
        params:show('marco_performer_w_device_'..i)
        params:show('marco_performer_w_feedback_'..i)
        params:show('marco_performer_w_filter_'..i)
        params:show('marco_performer_w_rate_'..i)
        params:show('marco_performer_w_mod_rate_'..i)
        params:show('marco_performer_w_mod_amount_'..i)
      else
        params:show('marco_performer_w_device_'..i)
      end
    end
  end
  _menu.rebuild_params()
end

function Parameters:_get_performer_instance(name)
  if ensemble and ensemble.performers then
    return ensemble.performers[name]
  end
  return nil
end

function Parameters:get(k)
  return self[k]
end

function Parameters:get_performer(sequence)
  local performer_index = params:get('marco_performer_'..sequence)
  return self.available_performers[performer_index]
end

return Parameters
