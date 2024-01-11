function wrap_ccw(n, inc)
  n = n - inc

  if n < 1 then
    return 64 + n
  end

  return n
end

function wrap_cw(n, inc)
  n = n + inc

  if n > 64 then
    return n - 64
  end

  return n
end
