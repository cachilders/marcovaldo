local Pane = include('lib/chart/pane')
local keys_halt = false
local keys_held = {}

local Page = {
  flip_page = nil,
  id = 1,
  panes = nil
}

function Page:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Page:get(k)
  return self[k]
end

function Page:set(k, v)
  self[k] = v
end

function Page:press_to_page(x, y, z)
  local pane = self:_select_pane(x, y)
  local x_offset, y_offset = self.panes[pane]:get_offsets()
  local offset_x = x - x_offset
  local offset_y = y - y_offset
  local function clear_held_keys() self:_clear_held_keys() end
  
  self:_update_held_keys(offset_x, offset_y, z)

  if z == 1 then
    self:_check_for_held_key_gestures(pane)
  end

  if not keys_halt then
    self.panes[pane]:pass(x, y, z, keys_held, clear_held_keys)
  end
end

function Page:refresh()
  for i = 1, #self.panes do
    self.panes[i]:refresh()
  end
end

function Page:_select_pane(x, y)
  local panes = #self.panes
  local pane = 1

  if panes == 2 then
    pane = pane + (x > PANE_EDGE_LENGTH and 1 or 0)
  end

  if panes == 4 then
    pane = pane + (x > PANE_EDGE_LENGTH and 1 or 0)
    pane = pane + (y > PANE_EDGE_LENGTH and 2 or 0)
  end

  return pane
end

function Page:_page_offset()
  return (self.id - 1) * #self.panes
end

function Page:_update_held_keys(x, y, z)
  -- This will need to change if we deviate from 64 key plans
  -- So, you know, if a bug pops up...
  if z == 1 then
    table.insert(keys_held, x..y)
  else
    local next_keys = {}
    for i = 1, #keys_held do
      if keys_held[i] ~= x..y then
        table.insert(next_keys, keys_held[i])
      end
    end
    keys_held = next_keys
  end
end

function Page:_check_for_held_key_gestures(pane)
  local rightmost_pane = self.panes[#self.panes] == self.panes[pane]

  if rightmost_pane and tab.contains(keys_held, '87') and tab.contains(keys_held, '88') and tab.contains(keys_held, '78') then
    -- Rightmost bottom corner is page flip gesture
    self.flip_page()
    self:_clear_held_keys()
  end
end

function Page:_clear_held_keys(s)
  self:_pause_keys(s)
  keys_held = {}
end

function Page:_pause_keys(s)
  keys_halt = true
  clock.run(function() 
    clock.sleep(s or .4)
    keys_halt = false 
  end)
end

return Page
