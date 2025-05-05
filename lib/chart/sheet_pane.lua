local Pane = include('lib/chart/pane')
local keys_halt = false
local keys_held = {}

local SheetPane = {
  sheet = nil,
  page = 1,
  total_pages = 2,  -- For 64-key grid
  rows_per_page = PANE_EDGE_LENGTH,  -- Use existing constant
  is_64_key = false  -- Track if we're on a 64-key grid
}

function SheetPane:new(options)
  local instance = Pane:new(options)
  setmetatable(self, {__index = Pane})
  setmetatable(instance, self)
  self.__index = self
  self.is_64_key = options.is_64_key or false
  return instance
end

function SheetPane:init(led)
  self.sheet:set('led', led)
  self:update_offsets()
end

function SheetPane:update_offsets()
  -- For 64-key grid, offset by 8 rows per page
  local y_offset = (self.page - 1) * self.rows_per_page
  self.sheet:set('y_offset', y_offset)
end

function SheetPane:get_offsets()
  return 0, self.sheet:get('y_offset')
end

function SheetPane:contains(x, y)
  -- Check if x is within sheet width
  if x < 1 or x > SHEET_WIDTH then
    return false
  end
  
  -- Check if y is within the current page's bounds
  local y_offset = self.sheet:get('y_offset')
  if y < 1 or y > PANE_EDGE_LENGTH then
    return false
  end
  
  -- Check if the adjusted y (with offset) is within total sheet height
  local adjusted_y = y + y_offset
  if adjusted_y < 1 or adjusted_y > SHEET_HEIGHT then
    return false
  end
  
  return true
end

function SheetPane:pass(x, y, z)
  if z == 1 then
    self:_update_held_keys(x, y)
    self:_check_for_held_key_gestures()
  else
    self:_clear_held_keys()
  end
  
  if not keys_halt then
    -- Pass through to sheet with adjusted y coordinate
    self.sheet:press(x, y - self.sheet:get('y_offset'), z)
  end
end

function SheetPane:_update_held_keys(x, y)
  if z == 1 then
    table.insert(keys_held, x..y)
  else
    local next_keys = {}
    for i = 1, #keys_held do
      if keys_held[i] ~= x..y then
        table.insert(next_keys, keys_held[i])
      end
    end
    keys_held = next_keys
  end
end

function SheetPane:_check_for_held_key_gestures()
  -- Only enable page turning on 64-key grids
  if self.is_64_key then
    if tab.contains(keys_held, '87') and tab.contains(keys_held, '88') and tab.contains(keys_held, '78') then
      -- Bottom right corner is page flip gesture
      self.page = self.page % self.total_pages + 1
      self:update_offsets()
      self:_clear_held_keys()
    end
  end
end

function SheetPane:_clear_held_keys()
  self:_pause_keys()
  keys_held = {}
end

function SheetPane:_pause_keys()
  keys_halt = true
  clock.run(function() 
    clock.sleep(0.4)
    keys_halt = false 
  end)
end

function SheetPane:refresh()
  self.sheet:refresh()
end

return SheetPane 