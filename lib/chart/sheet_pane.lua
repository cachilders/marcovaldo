local Pane = include('lib/chart/pane')

local SheetPane = {
  sheet = nil,
  page = 1,
  total_pages = 2,  -- For 64-key grid
  steps_per_page = 64  -- 64 steps per page for 64-key grid
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
  if self.is_64_key then
    -- For 64-key grid, offset by 64 steps per page
    local step_offset = (self.page - 1) * self.steps_per_page
    self.sheet:set('step_offset', step_offset)
  else
    -- For 128-key grid, no offset needed
    self.sheet:set('step_offset', 0)
  end
end

function SheetPane:get_offsets()
  return 0, 0  -- No y-offset needed as we're using step_offset
end

-- Convert coordinates to step number, handling grid size differences
function SheetPane:coords_to_step(x, y)
  if self.is_64_key then
    -- For 64-key grid, each row is 8 steps
    local base_step = (y - 1) * PANE_EDGE_LENGTH + x
    return base_step
  else
    -- For 128-key grid, use base sheet mapping
    return self.sheet:coords_to_step(x, y)
  end
end

-- Convert step number to coordinates, handling grid size differences
function SheetPane:step_to_coords(step)
  if self.is_64_key then
    -- For 64-key grid, each row is 8 steps
    local y = math.floor((step - 1) / PANE_EDGE_LENGTH) + 1
    local x = ((step - 1) % PANE_EDGE_LENGTH) + 1
    return x, y
  else
    -- For 128-key grid, use base sheet mapping
    return self.sheet:step_to_coords(step)
  end
end

function SheetPane:contains(x, y)
  -- Check if x is within bounds for 64-key grid
  if self.is_64_key and (x < 1 or x > PANE_EDGE_LENGTH) then
    return false
  end
  
  -- Check if y is within bounds for 64-key grid
  if self.is_64_key and (y < 1 or y > PANE_EDGE_LENGTH) then
    return false
  end
  
  return true
end

function SheetPane:pass(x, y, z)
  if self:contains(x, y) then
    self.sheet:press(x, y, z)
  end
end

function SheetPane:refresh()
  self.sheet:refresh()
end

return SheetPane 