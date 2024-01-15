local Plan = include('lib/plan')
local PathSymbol = include('lib/path_symbol')

local PathPlan = {}
PathPlan.__index = PathPlan

function PathPlan:new(options)
  local instance = Plan:new(options or {})
  setmetatable(PathPlan, {__index = Plan})
  setmetatable(instance, PathPlan)
  return instance
end

function PathPlan:mark(x, y, z)
  -- We have to know if there is a head yet
  -- and if this is an insert or deletion
  -- within the path (a key is held) or just
  -- an addition. Another case is when the
  -- key pressed is the head. That could
  -- express an intent to connect the tail
  -- and head or just to remove the head.
  -- Have to decide. I don't think the tail
  -- and head should connect since the result
  -- is the same. But maybe to delete the
  -- head you should hold the next node.
  -- Maybe also we can add a gesture for 
  -- holding the three bottom left corner
  -- keys to clear the path. If it's easy
  -- we can add more gestures.
  if z == 1 then
    print('Marking '..x, y, z)
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
