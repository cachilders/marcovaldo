local Performer = include('lib/ensemble/performer')
VELOCITY_CONSTANT = 5 / 127

local JustFriendsPerformer = {
  name = JF
}

setmetatable(JustFriendsPerformer, { __index = Performer })

function JustFriendsPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function JustFriendsPerformer:init()
  self.clocks = {}
  self:init_effects()
  crow.ii.jf.mode(1)
end

function JustFriendsPerformer:_create_effect(effect_num)
  return function(data)
    local beat_time = 60 / params:get('clock_tempo')
    clock.run(
      function()
        self.divisions = data.x
        self.repeats = data.y
        clock.sleep(beat_time)
        self.divisions = 1
        self.repeats = 1
      end
    )
  end
end

function JustFriendsPerformer:init_effects()
  self.effects = {
    self:_create_effect(1),
    self:_create_effect(2),
    self:_create_effect(3),
    self:_create_effect(4)
  }
end

function JustFriendsPerformer:play_note(sequence, note, velocity, envelope_duration)
  local divided_duration = envelope_duration / (self.divisions or 1)
  local repeats = (self.repeats or 1) <= (self.divisions or 1) and (self.repeats or 1) or (self.divisions or 1)
  local division_gap = repeats > 1 and (envelope_duration - (divided_duration * repeats)) / (repeats - 1) or 0
  for i = 1, repeats do
    if self.clocks[sequence] then
      clock.cancel(self.clocks[sequence])
    end
    self.clocks[sequence] = clock.run(
      function()
        local adj_note = note - params:get('marco_root')
        local pitch = (adj_note >= 0 and adj_note or 0) / 12
        local device = params:get('marco_performer_jf_device_'..sequence)
        crow.ii.jf[device].play_note(pitch, velocity * VELOCITY_CONSTANT)
        if self.repeats > 1 then
          clock.sleep(division_gap)
        end
      end
    )
  end
end

return JustFriendsPerformer
