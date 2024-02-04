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
  params:add_group('marcovaldo', 'MARCOVALDO', 4)
  -- Load State From File
  -- Save State To File
  --
  -- Randomize State
  -- Reset State
  -- 
  params:add_option('marco_animations', 'Animations', ENABLED_STATES, 1)
  params:set_action('marco_animations', function(i) parameters.animations_enabled:set(i == 1) end)
  params:add_option('marco_scale', 'Scale Type', parameters.scale_names, 1)
  params:set_action('marco_scale', function(i) parameters.scale:set(parameters.scale_names[i]) end)
  params:add_number('marco_root', 'Root Note', 0, 127, 48, function(param) return music_util.note_num_to_name(param:get(), true) end)
  params:set_action('marco_root', function(i) parameters.root:set(i) end)
  params:add_number('marco_pulse_constant', 'Cosmological Constant', 50, 150, 75)
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