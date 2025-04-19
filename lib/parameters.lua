local textentry = require('textentry')
local fileselect = require('fileselect')
local ENABLED_STATES = {'Enabled', 'Disabled'}
local ERROR_BAD_FILE = 'ERROR: Bad state file'

local Parameters = {
  animations_enabled = nil,
  available_performers = nil,
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
  self:_init_params()
  params:bang()
end

function Parameters:_init_observables()
  self.animations_enabled = observable.new(true)
  self.root = observable.new(48)
  self.scale = observable.new('')
end

function Parameters:_init_performers()
  local available_performers = {'MxSynths'} -- 'MIDI', 'Crow', 'Disting EX', 'ER-301', `W/`, 'Ansible'
  table.sort(available_performers)
  self.available_performers = available_performers
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
  params:add_number('marco_root', 'Root Note', 0, 127, 48, function(param) return music_util.note_num_to_name(param:get(), true) end)
  params:set_action('marco_root', function(i) self.root:set(i) end)
  params:add_number('marco_pulse_constant', 'Cosmological Constant', 50, 150, 75)

  for i = 1, 4 do
    params:add_group('marco_seq_'..i, 'MARCOVALDO > SEQ '..i, 12)
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
    params:add_number('marco_attack_'..i, 'Attack', 0, 100, 20, function(param) return ''..param:get()..'% of width' end)
    params:add_number('marco_decay_'..i, 'Decay', 0, 100, 25, function(param) return ''..param:get()..'% of width' end)
    params:add_number('marco_sustain_'..i, 'Sustain', 0, 100, 90, function(param) return ''..param:get()..'% of strength' end)
    params:add_number('marco_release_'..i, 'Release', 0, 100, 20, function(param) return ''..param:get()..'% of width' end)
  end
end

function Parameters:get_performer(sequence)
  local performer_index = params:get('marco_performer_'..sequence)
  return self.available_performers[performer_index]
end

return Parameters