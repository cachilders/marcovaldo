local Performer = include('lib/ensemble/performer')

local MidiPerformer = {
  connections = nil,
  max_clock_indices = {effect = 4, voice = 8},
  name = MIDI
}

setmetatable(MidiPerformer, { __index = Performer })

function MidiPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function MidiPerformer:init()
  local connections = {}
  for id, _ in pairs(parameters:get('midi_device_identifiers')) do
    table.insert(connections, midi.connect(id))
  end
  self.connections = connections
  self:_init_clocks({voice = 8})
  self:_init_effects()
end

function MidiPerformer:_create_effect(effect_num)
  return function(data, sequence)
    if effect_clock then
      clock.cancel(effect_clock)
    end
    effect_clock = clock.run(
      function()
        local beat_time = 60 / params:get('clock_tempo')
        local connection = self.connections[params:get('marco_performer_midi_device_'..sequence)]
        local channel = params:get('marco_performer_midi_channel_'..sequence)
        local effect_clock = self:_get_next_clock('effect')
        local cc_reset_value = params:get('marco_performer_midi_cc_'..effect_num..'_value_'..sequence)
        local x = data.x
        local y = data.y
        local cc_new_value = (x * y * (x > 4 and 2 or 1)) - 1
        params:set('marco_performer_midi_cc_'..effect_num..'_value_'..sequence, cc_new_value)
        clock.sleep(beat_time)
        params:set('marco_performer_midi_cc_'..effect_num..'_value_'..sequence, cc_reset_value)
      end
    )
  end
end

function MidiPerformer:play_note(sequence, note, velocity, envelope_duration)
  local connection = self.connections[params:get('marco_performer_midi_device_'..sequence)]
  local channel = params:get('marco_performer_midi_channel_'..sequence)
  local voice_clock = self:_get_next_clock('voice')
  
  if voice_clock then
    clock.cancel(voice_clock)
  end
  voice_clock = clock.run(
    function()
      connection:note_on(note, velocity, channel)
      clock.sleep(envelope_duration)
      connection:note_off(note, velocity, channel)
    end
  )
end

function MidiPerformer:transmit_cc(sequence)
  local connection = self.connections[params:get('marco_performer_midi_device_'..sequence)]
  local channel = params:get('marco_performer_midi_channel_'..sequence)
  for i = 1, 4 do
    local cc_id = params:get('marco_performer_midi_cc_'..i..'_id_'..sequence)
    local cc_value = params:get('marco_performer_midi_cc_'..i..'_value_'..sequence)
    if cc_id > 0 then
      connection:cc(cc_id, cc_value, channel)
    end
  end
end

function MidiPerformer:panic()
  for note = 0, 127 do
    for ch = 1, 16 do
      for i = 1, #self.connections do
        local connection = self.connections[i]
        connection:note_off(note, 0, ch)
      end
    end
  end
end

function MidiPerformer:cc_reset()
  for cc = 1, 127 do
    for ch = 1, 16 do
      for i = 1, #self.connections do
        local connection = self.connections[i]
        connection:cc(cc, 0, ch)
      end
    end
  end
end

return MidiPerformer
