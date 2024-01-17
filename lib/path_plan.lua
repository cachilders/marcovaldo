local Plan = include('lib/plan')
local PathSymbol = include('lib/path_symbol')

local PathPlan = {
  head = nil,
  tail = nil
}
PathPlan.__index = PathPlan

function PathPlan:new(options)
  local instance = Plan:new(options or {})
  setmetatable(PathPlan, {__index = Plan})
  setmetatable(instance, PathPlan)
  return instance
end

function Plan:init()
  self.features = self:_gesso()
  self.keys_held = {}
  self.head = nil
  self.tail = nil
end

function PathPlan:mark(x, y, z)
  if z == 1 then
    self:_update_held_keys(x, y, z)
    self:_check_for_held_key_gestures()
  end

  if z == 0 then
    self:_update_held_keys(x, y, z)
    if not self.keys_halt then 
      if #self.keys_held == 0 and self.features[y][x] then
        self:_remove(x, y)
      elseif #self.keys_held == 0 then
        self:_add(x, y)
      elseif #self.keys_held == 1 and not self.features[y][x] then
        self:_add(x, y, self:_symbol_from_held_key(self.keys_held[1]))
      end
    end
  end
end

-- function PathPlan:update()
--   -- This plan needs to understand what the
--   -- active node is and pass appropriate data
--   -- for the update. Draw a weakly lit line
--   -- between the points (5?) with inactive
--   -- points at mid (10?) and active point
--   -- brightest (15? These may need to slide
--   -- down a lot). Path follows to tail then
--   -- back to head
-- end

function PathPlan:_add(x, y, insert_from_symbol)
  local symbol = PathSymbol:new({
    active = false,
    led = self.led,
    x = x,
    x_offset = self.x_offset,
    y = y,
    y_offset = self.y_offset
  })

  if not insert_from_symbol then
    if not self.head then
      self.head = symbol
      self.tail = symbol
    else
      self.tail:set('next', symbol)
      symbol:set('prev', self.tail)
      self.tail = symbol
    end
  else
    if not insert_from_symbol.next then
      insert_from_symbol:set('next', symbol)
      symbol:set('prev', self.tail)
      self.tail = symbol
    elseif insert_from_symbol and symbol.x == self.head.x and symbol.y == self.head.y then
      symbol = self.head
    else
      symbol:set('prev', insert_from_symbol)
      symbol:set('next', insert_from_symbol.next)
      insert_from_symbol.next:set('prev', symbol)
      insert_from_symbol:set('next', symbol)
    end
    self.keys_held = {}
    self:_sleep_grid_input(.5)
  end
  self.features[y][x] = symbol
end

function PathPlan:_remove(x, y)
  -- join the nodes before and after the
  -- removed node if mid path, move the tail
  -- if not (or head)
end

function PathPlan:_symbol_from_held_key(label)
  local x = tonumber(label:sub(1,1))
  local y = tonumber(label:sub(2,2))
  return self.features[y][x]
end

return PathPlan
