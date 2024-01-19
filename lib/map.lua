local PANE_EDGE_LENGTH = 8
local CatPlan = include('lib/cat_plan')
local PathPlan = include('lib/path_plan')

local Map = {
  host = nil,
  lumen = 5,
  -- Panes might have an API for swapping contents and
  -- should probably only know their quadrant to pass
  -- offsets to loaded plans
  panes = {},
  panes_per_page = 2 -- TODO
}

function Map:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return self
end

function Map:init(n)
  self.host = grid.connect(n)
  -- Just keeping these names to placehold the ideas before 
  -- moving them to the panel templates
  local function led(x, y, l) self.host:led(x, y, l) end
  local the_city_all_to_himself = PathPlan:new({led = led})
  local the_garden_of_stubborn_cats = CatPlan:new({
    led = led,
    x_offset = 8
  })
  self.panes = {
    the_city_all_to_himself,
    the_garden_of_stubborn_cats
  }

  for i = 1, #self.panes do
    self.panes[i]:init()
  end
end

function Map:press(x, y, z)
  if x <= PANE_EDGE_LENGTH and y <= PANE_EDGE_LENGTH then
    self.panes[1]:mark(x, y, z)
  elseif x > PANE_EDGE_LENGTH and y <= PANE_EDGE_LENGTH then
    self.panes[2]:mark(x - PANE_EDGE_LENGTH, y, z)
  elseif x <= PANE_EDGE_LENGTH and y > PANE_EDGE_LENGTH then
    self.panes[3]:mark(x, y - PANE_EDGE_LENGTH, z)
  elseif x > PANE_EDGE_LENGTH and y > PANE_EDGE_LENGTH then
    self.panes[4]:mark(x - PANE_EDGE_LENGTH, y - PANE_EDGE_LENGTH, z)
  end
end

function Map:refresh()
  self.host:all(0)
  for i = 1, #self.panes do
    self.panes[i]:refresh()
  end
  self.host:refresh()
end

return Map