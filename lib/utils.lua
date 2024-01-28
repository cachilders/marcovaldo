local music_util = require('musicutil')

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

  while true do
    table.insert(points, {x1, y1})
    if x1 == x2 and y1 == y2 then break end
    e2 = error * 2
    if e2 >= y_diff and x1 ~= x2 then
      if x1 == x2 then break end
      adjust_x()
    elseif y1 ~= y2 then
      if y1 == y2 then break end
      adjust_y()
    end
  end

  return points
end

function midpoint_circle(mid_x, mid_y, r)
  local points = {}
  local d = r
  local x = 0
  local y = r

  local function plot_points(x, y)
    table.insert(points, { mid_x + x, mid_y + y })
    table.insert(points, { mid_x - x, mid_y + y })
    table.insert(points, { mid_x + x, mid_y - y })
    table.insert(points, { mid_x - x, mid_y - y })
    table.insert(points, { mid_x + y, mid_y + x })
    table.insert(points, { mid_x - y, mid_y + x })
    table.insert(points, { mid_x + y, mid_y - x })
    table.insert(points, { mid_x - y, mid_y - x })
  end

  while x <= y do
    if d < 0 then
      d = d + 2 * x + 1
    else
      y = y - 1
      d = d + 2 * (x - y) + 1
    end
    x = x + 1
    plot_points(x, y)
  end
  return points
end

function get_musicutil_scale_names()
  local scales = {}
  for i = 1, #music_util.SCALES do
    scales[i] = music_util.SCALES[i].name
  end

  return scales
end