local PANE_COUNT = 4
local PANE_EDGE_LENGTH = 8
local CatPlan = include('lib/plans/cat_plan')
local PathPlan = include('lib/plans/path_plan')
local RadiationPlan = include('lib/plans/radiation_plan')
local ReliefPlan = include('lib/plans/relief_plan')
local Pane = include('lib/pane')

local Map = {
  host = nil,
  lumen = 5,
  page = 1,
  pages = 2,
  panes = {}
}

function Map:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return self
end

function Map:init(n)
  self.host = grid.connect(n)
  self:_init_pages()
  self:_init_panes()
end

function Map:press(x, y, z)
  local pane = self:_select_pane(x, y)
  self.panes[pane + self:_page_offset()]:pass(x, y, z, self:_panes_per_page())
end

function Map:refresh()
  local page_offset = self:_page_offset()

  self.host:all(0)
  for i = 1, self:_panes_per_page() do
    self.panes[i + page_offset]:refresh()
  end
  self.host:refresh()
end

function Map:step()
  for i = 1, #self.panes do
    self.panes[i]:step()
  end
end

function Map:_init_pages()
  local map_height = self.host.rows
  local map_width = self.host.cols
  
  if map_height == PANE_EDGE_LENGTH then
    if map_width == PANE_EDGE_LENGTH then
      self.pages = PANE_COUNT
    else
      self.pages = math.ceil(PANE_COUNT * PANE_EDGE_LENGTH / map_width)
    end
  else
    self.pages = math.ceil((PANE_COUNT * PANE_EDGE_LENGTH * PANE_EDGE_LENGTH) / (map_width * map_height))
  end
end

function Map:_init_panes()
  local function led(x, y, l) self.host:led(x, y, l) end
  local panes = {
    Pane:new({
      plan = PathPlan:new({led = led})
    }), -- the_city_all_to_himself
    Pane:new({
      plan = CatPlan:new({led = led})
    }), -- the_garden_of_stubborn_cats
    Pane:new({
      plan = RadiationPlan:new({led = led})
    }), -- moon_and_gnac
    Pane:new({
      plan = ReliefPlan:new({led = led})
    }), -- the_city_lost_in_the_snow?? Think this one overlays the others
  }

  for i = 1, #panes do
    panes[i]:set('pane', i)
    panes[i]:set('flip_page', function() self:_flip_page() end)
    panes[i]:init(self:_panes_per_page())
  end

  self.panes = panes
end

function Map:_select_pane(x, y)
  local panes = PANE_COUNT / self.pages
  local pane = 1

  if panes == 2 then
    pane = pane + (x > PANE_EDGE_LENGTH and 1 or 0)
  end

  if panes == 4 then
    pane = pane + (x > PANE_EDGE_LENGTH and 1 or 0)
    pane = pane + (y > PANE_EDGE_LENGTH and 2 or 0)
  end

  return pane
end

function Map:_panes_per_page()
  return math.ceil(PANE_COUNT / self.pages)
end

function Map:_page_offset()
  return (self.page - 1) * self:_panes_per_page()
end

function Map:_flip_page()
  self.page = util.wrap(self.page + 1, 1, self.pages)
end

return Map