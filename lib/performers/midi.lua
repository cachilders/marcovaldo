local Performer = include('lib/performer')

local MidiPerformer = {
  name = 'MIDI',
  connections = {}
}

setmetatable(MidiPerformer, { __index = Performer })

function MidiPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function MidiPerformer:init()
  -- Initialize MIDI connections
  for id = 1, 4 do
    if params:get('midi_device_'..id..'_enabled') == 1 then
      table.insert(self.connections, midi.connect(id))
    end
  end
end

function MidiPerformer:play_note(voice, note, velocity, envelope_duration)
  for _, connection in ipairs(self.connections) do
    if connection.device then
      local ch = params:get('midi_device_'..connection.device.port..'_output_channel')
      clock.run(
        function()
          connection:note_on(note, velocity, ch)
          clock.sleep(envelope_duration)
          connection:note_off(note, 0, ch)
        end
      )
    end
  end
end

function MidiPerformer:apply_effect(index, data)
  local value = math.floor(data[1] * data[2] * 127)
  for _, connection in ipairs(self.connections) do
    if connection.device then
      local ch = params:get('midi_device_'..connection.device.port..'_output_channel')
      connection:cc(index, value, ch)
    end
  end
end

return MidiPerformer 