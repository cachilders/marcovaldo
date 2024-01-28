parameters = {
  scale = '',
  scale_names = get_musicutil_scale_names()
}

function init_params()
  params:add_group('marcovaldo', 'Marcovaldo', 2)
  params:add_option('scale', 'Scale Type', parameters.scale_names, 1)
  params:set_action('scale', function(i) parameters.scale = parameters.scale_names[i]; params:bang() end)
  params:add_number('root', 'Root Note', 0, 127, 48, function(param) return musicutil.note_num_to_name(param:get(), true) end)
  params:set_action('root', function() params:bang() end)
end