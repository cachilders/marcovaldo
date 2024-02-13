-- Marcovaldo
-- a spatial sequencer with cats

DEFAULT = 'default'
ERROR = 'error'
MODE_TIMEOUT_DELAY = 10
PLAN_COUNT = 4
PANE_EDGE_LENGTH = 8
SEQUENCE = 'sequence'
STEP = 'step'

MODES = {DEFAULT, ERROR, SEQUENCE, STEP}

shift_depressed = false
current_mode = nil

local Arrangement = include('lib/arrangement')
local Chart = include('lib/chart')
local Console = include('lib/console')
local Ensemble = include('lib/ensemble')
local Parameters = include('lib/parameters')

local default_mode_timeout = nil

observable = require('container.observable')
er = require('er')
tab = require('tabutil')
util = require('util')
music_util = require('musicutil')

include('lib/utils')

function init()
  math.randomseed(os.time())
  run_tests()
  init_params()
  create_metaphors()
  init_events()
  init_metaphors()
  init_clocks()
end

function run_tests()
end

function create_metaphors()
  arrangement = Arrangement:new()
  chart = Chart:new()
  console = Console:new()
  ensemble = Ensemble:new()
end

function init_clocks()
  local bpm = 60 / params:get('clock_tempo')
  atomic_time = metro.init(refresh_peripherals, 1 / 60)
  podium_time = metro.init(step_arrangement, bpm / 3)
  screen_time = metro.init(step_console, 1 / 24)
  world_time = metro.init(step_chart, bpm / 2)
  atomic_time:start()
  podium_time:start()
  screen_time:start()
  world_time:start()
end

function init_events()
  local function affect_arrangement(action, index, values)
    arrangement:affect(action, index, values)
  end
  local function affect_chart(action, index, values)
    chart:affect(action, index, values)
  end
  local function affect_console(action, index, values)
    console:affect(action, index, values)
  end
  local function affect_ensemble(action, index, values)
    ensemble:affect(action, index, values)
  end

  arrangement:set('affect_chart', affect_chart)
  arrangement:set('affect_console', affect_console)
  arrangement:set('affect_ensemble', affect_ensemble)
  chart:set('affect_arrangement', affect_arrangement)
  chart:set('affect_console', affect_console)
  chart:set('affect_ensemble', affect_ensemble)
  console:set('affect_arrangement', affect_arrangement)
  console:set('affect_chart', affect_chart)
  console:set('affect_ensemble', affect_ensemble)
  ensemble:set('affect_arrangement', affect_arrangement)
  ensemble:set('affect_chart', affect_chart)
  ensemble:set('affect_console', affect_console)

  current_mode = observable.new(1)
end

function init_metaphors()
  arrangement:init()
  console:init()
  chart:init()
  ensemble:init()
end

function init_params()
  parameters = Parameters:new()
  parameters:init()
end

function enc(e, delta)
  if e == 1 and not shift_depressed and get_current_mode() == DEFAULT then
    console:twist(e, delta)
  else
    arrangement:twist(e, delta)
  end
end

function key(k, z)
  local mode = get_current_mode()
  if k == 1 and z == 1 then
    shift_depressed = true
  elseif k == 1 and z == 0 then
    shift_depressed = false
  end

  if k == 2 and z == 0 and not shift_depressed then
    if mode == SEQUENCE then
      set_current_mode(DEFAULT)
    else
      arrangement:press(k, z)
    end
  elseif k == 2 and z == 0 and shift_depressed then
    -- TBD
  elseif k == 3 and z == 0 and not shift_depressed then
    arrangement:press(k, z)
  elseif k == 3 and z == 0 and shift_depressed  then
  end
end

function arc_delta(n, delta)
  arrangement:turn(n, delta)
end

function grid_key(x, y, z)
  chart:press(x, y, z)
end

function grid.add(added)
  if self.host.cols == 0 then
    chart:set_grid(added.port)
    chart:refresh_pages()
    set_current_mode(DEFAULT)
  end
end

function grid.remove(removed)
  if self.host.port == removed.port then
    chart:set_grid()
    set_current_mode(ERROR)
    self.affect_console(actions.toggle_error_takeover, 1)
  end
end

function default_mode_timeout_cancel()
  if default_mode_timeout then
    clock.cancel(default_mode_timeout)
    default_mode_timeout = nil
  end
end

function default_mode_timeout_extend()
  default_mode_timeout_cancel()
  default_mode_timeout_new()
end

function default_mode_timeout_new()
  default_mode_timeout = clock.run(
    function()
      clock.sleep(MODE_TIMEOUT_DELAY)
      set_current_mode(DEFAULT)
      default_mode_timeout = nil
    end
  )
end

function get_current_mode()
  return MODES[current_mode()]
end

function get_mode_index(mode)
  return tab.key(MODES, mode)
end

function set_current_mode(mode)
  local edit_mode = mode ~= DEFAULT and mode ~= ERROR
  if edit_mode and get_current_mode() == DEFAULT then
    default_mode_timeout_new()
  elseif edit_mode then
    default_mode_timeout_extend()
  elseif mode == DEFAULT then
    clock.cancel(default_mode_timeout)
  end
  current_mode:set(get_mode_index(mode))
end

function state_load(path)
  local state = tab.load(path)
  if state then
    arrangement:hydrate(state.arrangement)
    chart:hydrate(state.chart)
    console:hydrate(state.console)
    ensemble:hydrate(state.ensemble)
    parameters:hydrate(state.parameters)
  end
end

function state_save(path)
  local state = {
    arrangement = arrangement,
    chart = chart,
    console = console,
    ensemble = ensemble,
    parameters = parameters
  }
  tab.save(state, path)
end

function step_arrangement()
  arrangement:step()
end

function step_chart()
  chart:step()
end

function step_console()
  console:step()
end

function refresh_peripherals()
  arrangement:refresh()
  chart:refresh()
end

function refresh()
  console:refresh()
end
