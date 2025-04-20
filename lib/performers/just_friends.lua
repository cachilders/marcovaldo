local Performer = include('lib/performer')

local JustFriendsPerformer = {
  name = 'Just Friends'
}

setmetatable(JustFriendsPerformer, { __index = Performer })

function JustFriendsPerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function JustFriendsPerformer:init()
  -- Initialize Just Friends
end

function JustFriendsPerformer:play_note(voice, note, velocity, envelope_duration)
  -- Send note to Just Friends
end

function JustFriendsPerformer:apply_effect(index, data)
  -- no-op
end

return JustFriendsPerformer 