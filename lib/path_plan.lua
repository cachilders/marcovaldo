local Plan = include('lib/plan')
local PathSymbol = include('lib/path_symbol')

local PathPlan = {
  head = nil,
  tail = nil
}
PathPlan.__index = PathPlan

local keys_held = {}

function PathPlan:new(options)
  local instance = Plan:new(options or {})
  setmetatable(PathPlan, {__index = Plan})
  setmetatable(instance, PathPlan)
  return instance
end

function PathPlan:mark(x, y, z)
  local held_key_label = ''..x..y
  if z == 1 then
    keys_held[held_key_label] = {x, y}
    for _, coordinate in pairs(keys_held) do
      if coordinate then
        print('Holding', coordinate[1], coordinate[2])
      end
    end

    if keys_held['17'] and keys_held ['18'] and keys_held ['28'] then
      print('Resetting path')
    end
  end

  if z == 0 then
    keys_held[held_key_label] = nil

    for _, coordinate in pairs(keys_held) do
      if coordinate then
        print('holding', coordinate[1], coordinate[2])
      end
    end
    print('Marking '..x, y, z)
    -- if head is nil new node is head and tail
    -- if no other key is held standard add and remove
    -- if single key is held and contains a node with a next node
    --     insert between
    -- if single held key is node and is tail
    --     regular new tail node
    -- if single held key is tail and key pressed is head do nothing
    -- if multiple keys held do nothing on simultaneous release
    -- this will need some kind of debounce and optimization
    -- like maybe we only care about long press or the reset gesture
    -- like long press enables insert mode and is exited with a short
    -- press on the same node
  end
end

function PathPlan:_add(x, y)
  -- This can be inserted between points by
  -- selecting the preceding point. Insertion
  -- is always between held and next point.
  -- Otherwise it's just added to the tail.
end

function PathPlan:_remove(x, y)
  -- join the nodes before and after the
  -- removed node if mid path, move the tail
  -- if not (or head)
end

function PathPlan:update()
  -- This plan needs to understand what the
  -- active node is and pass appropriate data
  -- for the update. Draw a weakly lit line
  -- between the points (5?) with inactive
  -- points at mid (10?) and active point
  -- brightest (15? These may need to slide
  -- down a lot). Path follows to tail then
  -- back to head
end

return PathPlan
