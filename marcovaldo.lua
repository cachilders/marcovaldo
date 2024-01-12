-- Marcovaldo
-- a spatial sequencer with cats

shift_depressed = false

local Map = include('lib/map')
local Ring = include('lib/ring')
local Rings = include('lib/rings')

include('lib/utils')
include('lib/test/ring')

function init()
  run_tests()
  init_rings()
  init_map()
end

function run_tests()
  test_extents_in_radians()
end

function init_rings()
  rings = Rings:new()
  rings:init()
  rings:add(Ring:new({id = 1, range = 16, x = 1}))
  rings:add(Ring:new({id = 2, range = 8, x = 2}))
  rings:add(Ring:new({id = 3, range = 4, x = 3}))
  rings:add(Ring:new({id = 4, range = 64, x = 32}))
end

function init_map()
  map = Map:new()
  map:init()
end

function enc(e, d)
  if e == 1 and not shift then
    -- do stuff
  elseif e == 2 and not shift then
    -- do stuff
  elseif e == 3 and not shift then
    -- do stuff
  elseif e == 1 and shift then
    -- do stuff
  elseif e == 2 and shift then
    -- do stuff
  elseif e == 3 and shift then
    -- do stuff
  end
end

function key(k, z)
  if k == 1 and z == 1 then
    shift_depressed = true
  elseif k == 1 and z == 0 then
    shift_depressed = false
  end

  if k == 2 and z == 0 and not shift_depressed then
    -- do stuff
  elseif k == 2 and z == 0 and shift_depressed then
    -- do stuff
  elseif k == 3 and z == 0 and not shift_depressed then
    -- do stuff
  elseif k == 3 and z == 0 and shift_depressed  then
    -- do stuff
  end
end

function arc.delta(n, delta)
  print(n, delta)
end

function grid.key(x, y, z)
  print(x, y, z)
end

function redraw()
  screen.clear()

  rings:paint()
  map:paint()
  
  screen.update()
end

function refresh()
  redraw()
end