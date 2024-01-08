-- Marcovaldo
-- a spatial sequencer with cats

shift_depressed = false

function init()
  -- do stuff
end

function enc(e, d)
  if e == 1 then
    -- do stuff
  elseif e == 2 then
    -- do stuff
  elseif e == 3 then
    -- do stuff
  elseif shift and e == 1 then
    -- do stuff
  elseif shift and e == 2 then
    -- do stuff
  elseif shift and e == 3 then
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

  screen.update()
end

function refresh()
  redraw()
end