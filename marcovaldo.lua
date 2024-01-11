-- Marcovaldo
-- a spatial sequencer with cats

shift_depressed = false

local Ring = require('lib/ring')
local Rings = require('lib/rings')

include('lib/utils')

function init()
  init_rings()
end

function init_rings()
  rings = Rings:new()
  rings:add(Ring:new({id = 1, range = 16, x = 5}))
  rings:add(Ring:new({id = 2, range = 8, x = 5}))
  rings:add(Ring:new({id = 3, range = 32, x = 5}))
  rings:add(Ring:new({id = 4, range = 1, x = 5}))
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

function redraw()
  screen.clear()

  rings:paint()
  
  screen.update()
end

function refresh()
  redraw()
end