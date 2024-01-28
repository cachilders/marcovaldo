local test = require('test/luaunit')
local Ring = include('lib/arrangement/ring')

function test_extents_in_radians()
  -- Background: Radians should range from 0 to 2*math.pi
  local full_range = 2 * math.pi
  -- Given a range of 4
  local _, b = Ring._extents_in_radians(1, 4, 'Expected 2 * math.pi')
  test.assertEquals(full_range, b * 4)
  -- Given a range of 127
  local _, b = Ring._extents_in_radians(1, 127, 'Expected 2 * math.pi')
  test.assertEquals(full_range, b * 127)
end