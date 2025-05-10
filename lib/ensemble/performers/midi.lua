local Performer = include('lib/ensemble/performer')

local MidiPerformer = {
  clocks = nil,
  connections = nil,
  name = MIDI,
  effects = nil
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
  self.clocks = {}
  for i = 1, 4 do
    self.clocks[i] = {}
  end
  self:init_effects()
end

function MidiPerformer:_create_effect(effect_num)
  return function(data)
    print('[MidiPerformer] Effect '..effect_num..' not implemented')
  end
end

function MidiPerformer:init_effects()
  self.effects = {
    self:_create_effect(1),
    self:_create_effect(2),
    self:_create_effect(3),
    self:_create_effect(4)
  }
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

return MidiPerformer
