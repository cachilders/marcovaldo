local ENABLED_STATES = {'Enabled', 'Disabled'}

local Parameters = {
  animations_enabled = nil,
  root = nil,
  scale = nil,
  scale_names = nil
}

function Parameters:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  self.scale_names = get_musicutil_scale_names()
  return instance
end

function Parameters:init()
  self:_init_observables()
  self:_init_params()
  params:bang()
end

function Parameters:_init_observables()
  parameters.animations_enabled = observable.new(true)
  parameters.root = observable.new(48)
  parameters.scale = observable.new('')
end

function Parameters:_init_params()
  params:add_group('marcovaldo', 'MARCOVALDO', 10)
  params:add_trigger('marco_load', 'Load a Prior State')
  params:set_action('marco_load', function() print('TODO: Load') end)
  params:add_trigger('marco_save', 'Save Current State')
  params:set_action('marco_save', function() print('TODO: Save') end)
  params:add_trigger('marco_random', 'Randomize All Sequences')
  params:set_action('marco_random', function() print('TODO: Randomize') end)
  params:add_trigger('marco_reset', 'Clear All Sequences')
  params:set_action('marco_reset', function() print('TODO: Reset') end)
  params:add_separator('marco_global_actions_foot', '')
  params:add_separator('marco_global_settings', 'GLOBAL SETTINGS')
  params:add_option('marco_animations', 'Animations', ENABLED_STATES, 1)
  params:set_action('marco_animations', function(i) parameters.animations_enabled:set(i == 1) end)
  params:add_option('marco_scale', 'Scale Type', parameters.scale_names, 1)
  params:set_action('marco_scale', function(i) parameters.scale:set(parameters.scale_names[i]) end)
  params:add_number('marco_root', 'Root Note', 0, 127, 48, function(param) return music_util.note_num_to_name(param:get(), true) end)
  params:set_action('marco_root', function(i) parameters.root:set(i) end)
  params:add_number('marco_pulse_constant', 'Cosmological Constant', 50, 150, 75)

  for i = 1, 4 do
    params:add_group('marco_seq_'..i, 'MARCOVALDO > '..i, 8)
    params:add_trigger('marco_seq_random_'..i, 'Randomize Sequence '..i)
    params:set_action('marco_seq_random_'..i, function() print('TODO: Randomize') end)
    params:add_trigger('marco_seq_reset_'..i, 'Clear All Sequences')
    params:set_action('marco_seq_reset_'..i, function() print('TODO: Reset') end)
    params:add_separator('marco_seq_actions_foot_'..i, '')
    params:add_separator('marco_seq_settings_'..i, 'SEQUENCE '..i..' SETTINGS')
    -- TODO: These need to be able to correlate in terms of max where cannot exceed 100% in total
    params:add_number('marco_attack_'..i, 'Attack', 0, 100, 20, function(param) return ''..param:get()..'% of pulse' end)
    params:add_number('marco_decay_'..i, 'Decay', 0, 100, 25, function(param) return ''..param:get()..'% of pulse' end)
    params:add_number('marco_sustain_'..i, 'Release', 0, 100, 25, function(param) return ''..param:get()..'% of pulse' end)
    params:add_number('marco_release_'..i, 'Sustain', 0, 100, 35, function(param) return ''..param:get()..'% of pulse' end)
  end
end

function Parameters:_autoload_state()
  -- Load last state by default
end

function Parameters:_autosave_state()
  -- TODO
end

function Parameters:_load_state_from_file()
  -- TODO
end

function Parameters:_randomize_state()
  -- Maybe not
end

function Parameters:_reset_state()
  -- Back to one
end

function Parameters:_save_state_to_file()
  -- This one
end

return Parameters