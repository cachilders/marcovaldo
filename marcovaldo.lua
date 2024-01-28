-- Marcovaldo
-- a spatial sequencer with cats

PLAN_COUNT = 4
PANE_EDGE_LENGTH = 8

shift_depressed = false

local Arrangement = include('lib/arrangement')
local Map = include('lib/map')

include('lib/utils')

music_util = require('musicutil')
util = require('util')
tab = require('tabutil')

function init()
  math.randomseed(os.time())
  run_tests()
  init_arrangement()
  init_map()
  init_clocks()
end

function init_arrangement()
  arrangement = Arrangement:new()
  arrangement:init()
end

function init_clocks()
  local bpm = 60 / params:get('clock_tempo')
  podium_time = metro.init(step_arrangement)
  world_time = metro.init(step_map, bpm / 2)
  podium_time:start()
  world_time:start()
end

function init_map()
  map = Map:new()
  map:init()
end

function run_tests()
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
  map:press(x, y, z)
end

function refresh_peripherals()
  arrangement:refresh()
  map:refresh()
end

function step_map()
  map:step()
end

function step_arrangement()
  arrangement:step()
end

function redraw()
  refresh_peripherals() 
  screen.clear()
  screen.update()
end

function refresh()
  redraw()
end
