local actions = include('lib/actions')
local CatPlan = include('lib/chart/plans/cat_plan')
local PathPlan = include('lib/chart/plans/path_plan')
local RadiationPlan = include('lib/chart/plans/radiation_plan')
local ReliefPlan = include('lib/chart/plans/relief_plan')
local Page = include('lib/chart/page')
local Pane = include('lib/chart/pane')
local count = 1

local PATH_PLAN = 'The City All to Himself'
local CAT_PLAN = 'The Garden of Stubborn Cats'
local RADIATION_PLAN = 'Moon and GNAC'
local RELIEF_PLAN ='Smoke, wind, and Soap Bubbles'

local Chart = {
  affect_arrangement = nil,
  affect_console = nil,
  affect_ensemble = nil,
  host = nil,
  lumen = 5,
  page = 1,
  pages = {},
  plans = {}
}

function Chart:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Chart:init(n)
  self.host = grid.connect(n)
  self:_init_plans()
  self:_init_pages()
end

function Chart:get(k)
  return self[k]
end

function Chart:set(k, v)
  self[k] = v
end

function Chart:press(x, y, z)
  self.pages[self.page]:press_to_page(x, y, z)
end

function Chart:refresh()
  self.host:all(0)
  self.pages[self.page]:refresh()
  self.host:refresh()
end

function Chart:step()
  for i = 1, #self.plans do
    self.plans[i]:step(count)
  end
  self:_step_count()
end


function Chart:affect_chart(action, index, values)
  if action == actions.emit_pulse then
    local sequencer = index
    local velocity = values.velocity
    local envelope_duration = values.envelope_duration
    -- TODO - cleanup: this is brittle
    self.plans[3]:emit_pulse(sequencer, velocity, envelope_duration)
  end
end

function Chart:_init_pages()
  local chart_height = self.host.rows
  local chart_width = self.host.cols
  local page_count = 1
  local pages = {}
  local panes_per_page = 4
  
  if chart_height == PANE_EDGE_LENGTH then
    if chart_width == PANE_EDGE_LENGTH then
      page_count = PLAN_COUNT
    else
      page_count = math.ceil(PLAN_COUNT * PANE_EDGE_LENGTH / chart_width)
    end
  else
    page_count = math.ceil((PLAN_COUNT * PANE_EDGE_LENGTH * PANE_EDGE_LENGTH) / (chart_width * chart_height))
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

function Chart:_init_plans()
  local function led(x, y, l)
    if self.host.cols == PANE_EDGE_LENGTH then
      -- Monobrite for 64s
      l = 15
    end
    self.host:led(x, y, l)
  end

  local panes = {}
  local plans = {
    PathPlan:new({
      led = led,
      name = PATH_PLAN,
      affect_ensemble = self.affect_ensemble
    }),
    CatPlan:new({
      led = led,
      name = CAT_PLAN,
      affect_ensemble = self.affect_ensemble
    }),
    RadiationPlan:new({
      led = led,
      name = RADIATION_PLAN,
      affect_arrangement = self.affect_arrangement,
      affect_ensemble = self.affect_ensemble
    }),
    ReliefPlan:new({
      led = led,
      name = RELIEF_PLAN
    })
  }

  self.plans = plans
end

function Chart:_layer_phenomena()
  -- The relief plan is an overlay of all other plan
  -- phenomena and must be initialized after the panes
  local ephemera = {}
  local plans = self.plans

  for i = 1, #plans - 1 do
    table.insert(ephemera, plans[i]:get('phenomena'))
  end

  self.plans[#plans]:set('ephemera', ephemera)
end

function Chart:_flip_page()
  self.page = util.wrap(self.page + 1, 1, #self.pages)
end

function Chart:_step_count()
  count = util.wrap(count + 1, 1, 2)
end

return Chart