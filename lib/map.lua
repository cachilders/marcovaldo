local CatPlan = include('lib/map/plans/cat_plan')
local PathPlan = include('lib/map/plans/path_plan')
local RadiationPlan = include('lib/map/plans/radiation_plan')
local ReliefPlan = include('lib/map/plans/relief_plan')
local Page = include('lib/map/page')
local Pane = include('lib/map/pane')
local count = 1

local Map = {
  host = nil,
  lumen = 5,
  page = 1,
  pages = {},
  plans = {}
}

function Map:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Map:init(n)
  self.host = grid.connect(n)
  self:_init_plans()
  self:_init_pages()
end

function Map:press(x, y, z)
  self.pages[self.page]:press_to_page(x, y, z)
end

function Map:refresh()
  self.host:all(0)
  self.pages[self.page]:refresh()
  self.host:refresh()
end

function Map:step()
  for i = 1, #self.plans do
    self.plans[i]:step(count)
  end
  self:_step_count()
end

function Map:_init_pages()
  local map_height = self.host.rows
  local map_width = self.host.cols
  local page_count = 1
  local pages = {}
  local panes_per_page = 4
  
  if map_height == PANE_EDGE_LENGTH then
    if map_width == PANE_EDGE_LENGTH then
      page_count = PLAN_COUNT
    else
      page_count = math.ceil(PLAN_COUNT * PANE_EDGE_LENGTH / map_width)
    end
  else
    page_count = math.ceil((PLAN_COUNT * PANE_EDGE_LENGTH * PANE_EDGE_LENGTH) / (map_width * map_height))
  end

  panes_per_page = math.ceil(PLAN_COUNT / page_count)

  for i = 1, page_count do
    local page = Page:new({id = i, flip_page = function() self:_flip_page() end})
    local panes = {}
    for j = 1, panes_per_page do
      local offset = 0
      if panes_per_page > 1 and i > 1 then
        offset = (i - 1) * panes_per_page
      elseif i > 1 then
        offset = i - 1
      end
      local pane = Pane:new({pane = j, plan = self.plans[j + offset]})
      pane:init(panes_per_page)
      table.insert(panes, pane)
    end
    
    page:set('panes', panes)
    table.insert(pages, page)
  end

  self:_layer_phenomena()
  self.pages = pages
end

function Map:_init_plans()
  local function led(x, y, l)
    if self.host.cols == PANE_EDGE_LENGTH then
      -- Monobrite for 64s
      l = 15
    end
    self.host:led(x, y, l)
  end

  local panes = {}
  local plans = {
    PathPlan:new({led = led, name = 'The City All to Himself'}),
    CatPlan:new({led = led, name = 'The Garden of Stubborn Cats'}),
    RadiationPlan:new({led = led, name = 'Moon and GNAC'}),
    ReliefPlan:new({led = led, name = 'Smoke, wind, and Soap Bubbles'})
  }

  self.plans = plans
end

function Map:_layer_phenomena()
  -- The relief plan is an overlay of all other plan
  -- phenomena and must be initialized after the panes
  local ephemera = {}
  local plans = self.plans

  for i = 1, #plans - 1 do
    table.insert(ephemera, plans[i]:get('phenomena'))
  end

  self.plans[#plans]:set('ephemera', ephemera)
end

function Map:_flip_page()
  self.page = util.wrap(self.page + 1, 1, #self.pages)
end

function Map:_step_count()
  count = util.wrap(count + 1, 1, 2)
end

return Map