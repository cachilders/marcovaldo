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

function MidiPerformer:get_effects()
  return {
    { effect = "channel", id = "midi_channel" },
    { effect = "velocity_curve", id = "midi_velocity_curve" }
  }
end

function MidiPerformer:init()
  print('[MidiPerformer:init] Starting initialization')
  local connections = {}
  for id, _ in pairs(parameters:get('midi_device_identifiers')) do
    table.insert(connections, midi.connect(id))
  end
  self.connections = connections
  self.clocks = {}
  for i = 1, 4 do
    self.clocks[i] = {}
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

function MidiPerformer:apply_effect(effect, data)
  print('[MidiPerformer:apply_effect] Received:')
  print('  effect:', effect)
  print('  data:', data)
  if effect.effect == "channel" then
    -- TODO: Implement channel effect for MIDI
    print('[MidiPerformer] Applying channel effect')
  elseif effect.effect == "velocity_curve" then
    -- TODO: Implement velocity curve effect for MIDI
    print('[MidiPerformer] Applying velocity curve effect')
  end
end

return MidiPerformer