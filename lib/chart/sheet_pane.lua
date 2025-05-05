local Pane = include('lib/chart/pane')

local SheetPane = {
  sheet = nil,
  page = 1,
  total_pages = 2,  -- For 64-key grid
  rows_per_page = PANE_EDGE_LENGTH  -- Use existing constant
}

function SheetPane:new(options)
  local instance = Pane:new(options)
  setmetatable(self, {__index = Pane})
  setmetatable(instance, self)
  self.__index = self
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

function SheetPane:pass(x, y, z)
  -- Pass through to sheet with adjusted y coordinate
  self.sheet:press(x, y - self.sheet:get('y_offset'), z)
end

function SheetPane:refresh()
  self.sheet:refresh()
end

return SheetPane 