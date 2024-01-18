-- Marcovaldo
-- a spatial sequencer with cats

shift_depressed = false

local Map = include('lib/map')
local Ring = include('lib/ring')
local Rings = include('lib/rings')

include('lib/utils')
include('lib/test/ring')

util = require('util')
tab = require('tabutil')

function init()
  math.randomseed(os.time())

  run_tests()
  init_rings()
  init_map()
  init_clocks()
  
end

function run_tests()
  test_extents_in_radians()
end

function init_rings()
  rings = Rings:new()
  rings:init()
  rings:add(Ring:new({id = 1, range = 16, x = 1}))
  rings:add(Ring:new({id = 2, range = 8, x = 1}))
  rings:add(Ring:new({id = 3, range = 32, x = 1}))
  rings:add(Ring:new({id = 4, range = 64, x = 1}))
end

function init_clocks()
  local bpm = 60 / params:get('clock_tempo')
  dev_plan_timer = metro.init(refresh_peripherals, bpm)
  dev_plan_timer:start()
end

function init_map()
  map = Map:new()
  map:init()
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
  rings:turn(n, delta)
end

function grid.key(x, y, z)
  map:press(x, y, z)
end

function refresh_peripherals()
  map:refresh()
  rings:refresh()
end

function redraw()
  -- refresh_peripherals() -- Moved to clock for dev
  screen.clear()
  screen.update()
end

function refresh()
  redraw()
end
