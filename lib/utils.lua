function b_line(x1, y1, x2, y2)
  local x_diff = math.abs(x2 - x1)
  local x_inc = x1 < x2 and 1 or -1
  local y_diff = -math.abs(y2 - y1)
  local y_inc = y1 < y2 and 1 or -1
  local error = x_diff + y_diff
  local points = {}

  local function adjust_x()
    error = error + y_diff
    x1 = x1 + x_inc
  end

  local function adjust_y()
    error = error + x_diff
    y1 = y1 + y_inc
  end

  -- if x_diff > y_diff then
  --   adjust_x()
  -- else
  --   adjust_y()
  -- end

  while x1 ~= x2 and y1 ~= y2 do
    table.insert(points, {x1, y1})
    e2 = error * 2
    if e2 >= y_diff and x1 ~= x2 then
      adjust_x()
    elseif y1 ~= y2 then
      adjust_y()
    end
  end

  return points
end