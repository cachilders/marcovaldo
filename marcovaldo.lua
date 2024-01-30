-- Marcovaldo
-- a spatial sequencer with cats

PLAN_COUNT = 4
PANE_EDGE_LENGTH = 8

shift_depressed = false

local Arrangement = include('lib/arrangement')
local Chart = include('lib/chart')
local Console = include('lib/console')
local Ensemble = include('lib/ensemble')

include('lib/params')
include('lib/utils')

er = require('er')
tab = require('tabutil')
util = require('util')
music_util = require('musicutil')

function init()
  math.randomseed(os.time())
  run_tests()
  init_params()
  init_arrangement()
  init_chart()
  init_console()
  init_clocks()
  init_ensemble()
end

function run_tests()
end

function init_arrangement()
  arrangement = Arrangement:new({
    play_note = function(sequencer, note, velocity) ensemble:play_note(sequencer, note, velocity) end
  })
  arrangement:init()
end

function init_clocks()
  local bpm = 60 / params:get('clock_tempo')
  atomic_time = metro.init(refresh_peripherals, 1 / 60)
  podium_time = metro.init(step_arrangement, bpm)
  screen_time = metro.init(step_console, 1 / 30) -- TODO TBD
  world_time = metro.init(step_chart, bpm / 2)
  atomic_time:start()
  podium_time:start()
  screen_time:start()
  world_time:start()
end

function init_chart()
  chart = Chart:new()
  chart:init()
end

function init_console()
  console = Console:new()
  console:init()
  -- changes with each context, maybe
  -- turn a ring, see seq pulses and steps
  -- and the notes on the steps
  -- ...x..x..x...x
  --    c  d  g   c
  -- when not touch it animates pigeons
  -- or whatever. weather. cats. probably
  -- just display_png, but i still want to
  -- mess with p8
end

function init_ensemble()
  ensemble = Ensemble:new()
  ensemble:init()
end

function enc(e, d)
  if e == 1 and not shift then
  elseif e == 2 and not shift then
  elseif e == 3 and not shift then
  elseif e == 1 and shift then
  elseif e == 2 and shift then
  elseif e == 3 and shift then
  end
end

function key(k, z)
  if k == 1 and z == 1 then
    shift_depressed = true
  elseif k == 1 and z == 0 then
    shift_depressed = false
  end

  if k == 2 and z == 0 and not shift_depressed then
  elseif k == 2 and z == 0 and shift_depressed then
  elseif k == 3 and z == 0 and not shift_depressed then
  elseif k == 3 and z == 0 and shift_depressed  then
  end
end

function arc.delta(n, delta)
  arrangement:turn(n, delta)
end

function grid.key(x, y, z)
  chart:press(x, y, z)
end

function refresh_peripherals()
  arrangement:refresh()
  chart:refresh()
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

function refresh()
  console:refresh()
end
