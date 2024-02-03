include('lib/utils')

parameters = {
  scale = '',
  scale_names = get_musicutil_scale_names()
}

function init_params()
  params:add_group('marcovaldo', 'MARCOVALDO', 3)
  -- Save
  -- Load
  -- New
  -- ---
  -- Synth Voice
  params:add_option('marco_scale', 'Scale Type', parameters.scale_names, 1)
  params:set_action('marco_scale', function(i) parameters.scale = parameters.scale_names[i] end)
  params:add_number('marco_root', 'Root Note', 0, 127, 48, function(param) return music_util.note_num_to_name(param:get(), true) end)
  -- params:set_action('marco_root', function() end)
  params:add_number('marco_pulse_constant', 'Cosmological Constant', 50, 150, 75)
  -- params:set_action('marco_pulse_constant', function() end)
  params:bang()
end