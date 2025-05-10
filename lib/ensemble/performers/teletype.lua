local Performer = include('lib/ensemble/performer')

local TeletypePerformer = {
  name = 'Teletype',
  effects = nil
}

setmetatable(TeletypePerformer, { __index = Performer })

function TeletypePerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function TeletypePerformer:init()
  print('[TeletypePerformer:init] Starting initialization')
  self:init_effects()
end

function TeletypePerformer:_create_effect(effect_num)
  return function(data)
    print('[TeletypePerformer] Effect '..effect_num..' not implemented')
  end
end

function TeletypePerformer:init_effects()
  self.effects = {
    self:_create_effect(1),
    self:_create_effect(2),
    self:_create_effect(3),
    self:_create_effect(4)
  }
end

function TeletypePerformer:play_note(sequence, note, velocity, envelope_duration)
end

return TeletypePerformer 