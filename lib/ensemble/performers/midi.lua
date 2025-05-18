local Performer = include('lib/ensemble/performer')

local MidiPerformer = {
  connections = nil,
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

function Performer:_init_clocks()
  local effect_clocks = {}
  local voice_clocks = {}
  for i = 1, 8 do
    voice_clocks[i] = nil
  end
  for i = 1, 4 do
    effect_clocks[i] = nil
  end
  self.clocks = {
    effect = effect_clocks,
    voice = voice_clocks
  }
end

function MidiPerformer:_create_effect(effect_num)
  return function(data, sequence)
    local beat_time = 60 / params:get('clock_tempo')
    local connection = self.connections[params:get('marco_performer_midi_device_'..sequence)]
    local channel = params:get('marco_performer_midi_channel_'..sequence)
    local effect_clock = self:_get_next_clock('effect')
    if effect_clock then
      clock.cancel(effect_clock)
    end
    effect_clock = clock.run(
      function()
        local cc_reset_value = params:get('marco_performer_midi_cc_'..effect_num..'_value_'..sequence)
        local x = data.x
        local y = data.y
        local cc_new_value = (x * y * (x > 4 and 2 or 1)) - 1
        connection:cc(
          params:get('marco_performer_midi_cc_'..effect_num..'_id_'..sequence),
          cc_new_value,
          channel
        )
        clock.sleep(beat_time)
        connection:cc(
          params:get('marco_performer_midi_cc_'..effect_num..'_id_'..sequence),
          cc_reset_value,
          channel
        )
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

return MidiPerformer
