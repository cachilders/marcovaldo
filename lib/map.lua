local CatPlan = include('lib/plans/cat_plan')
local PathPlan = include('lib/plans/path_plan')
local RadiationPlan = include('lib/plans/radiation_plan')
local ReliefPlan = include('lib/plans/relief_plan')
local Page = include('lib/page')
local Pane = include('lib/pane')

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
    self.plans[i]:step()
  end
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

  self.pages = pages
end

function Map:_init_plans()
  local function led(x, y, l) self.host:led(x, y, l) end
  local panes = {}
  local plans = {
    PathPlan:new({led = led, name = 'The City All to Himself'}),
    CatPlan:new({led = led, name = 'The Garden of Stubborn Cats'}),
    RadiationPlan:new({led = led, name = 'Moon anf GNAC'})
  }
  local layers = {}

  for i = 1, #plans do
    table.insert(layers, plans[i]:get('features'))
  end

  -- The relief plan is an overlay of all activity plans
  table.insert(plans, ReliefPlan:new({
    led = led,
    layers = layers, 
    name = 'Smoke, wind, and Soap Bubbles'
  }))

  self.plans = plans
end

function Map:_flip_page()
  self.page = util.wrap(self.page + 1, 1, #self.pages)
end

return Map