function wrap_ccw(n, inc, max)
  n = n - inc
  if n < 1 then
    return max + n
  end
  return n
end

function wrap_cw(n, inc, max)
  n = n + inc
  if n > max then
    return n - max
  end
  return n
end
