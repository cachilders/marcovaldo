local Performer = include('lib/ensemble/performer')

local MidiPerformer = {
  clocks = nil,
  connections = nil,
  name = 'Midi'
}

setmetatable(MidiPerformer, { __index = Performer })

function MidiPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function MidiPerformer:_get_available_mods()
  return {
    { mod = 'channel', id = 'midi_channel' },
    { mod = 'velocity_curve', id = 'midi_velocity_curve' }
  }
end

function MidiPerformer:init()
  local connections = {}
  for id, _ in pairs(parameters:get('midi_device_identifiers')) do
    table.insert(connections, midi.connect(id))
  end
  self.connections = connections
  self.clocks = {}
  for i = 1, 4 do
    self.clocks[i] = {}
  end

  -- Initialize MIDI
  if cat_breed_registry and cat_breed_registry.register_breeds then
    cat_breed_registry:register_breeds(self, self:_get_available_mods())
  end
end

function MidiPerformer:play_note(sequence, note, velocity, envelope_duration)
  local connection = self.connections[params:get('marco_performer_midi_device_'..sequence)]
  local channel = params:get('marco_performer_midi_channel_'..sequence)
  
  if self.clocks[sequence][note] then
    clock.cancel(self.clocks[sequence][note])
  end

  self.clocks[sequence][note] = clock.run(
    function()
      connection:note_on(note, velocity, channel)
      clock.sleep(envelope_duration)
      connection:note_off(note, velocity, channel)
    end
  )
end

function MidiPerformer:apply_effect(index, data)
  local function log_data(label, idx, d)
    local parts = {}
    for k, v in pairs(d) do table.insert(parts, tostring(k)..'='..tostring(v)) end
    print(string.format('[%s] Applying effect on index: %s | data: {%s}', label, tostring(idx), table.concat(parts, ', ')))
  end
  if data.mod == 'channel' then
    log_data('MidiPerformer', index, data)
    -- TODO: Implement channel effect for MIDI
  elseif data.mod == 'velocity_curve' then
    log_data('MidiPerformer', index, data)
    -- TODO: Implement velocity curve effect for MIDI
  end
end

return MidiPerformer