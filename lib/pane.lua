local Pane = {
  edge_length = 8,
  keys_held = nil,
  page = 1,
  pane = 1,
  plan = nil
}

function Pane:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Pane:init()
  self.plan:init()
  self.keys_held = {}
  self:update_offsets()
  self.plan:set('pause_marks', function(s) self:_pause_keys(s) end)
end

function Pane:get(k)
  return self[k]
end

function Pane:set(k, v)
  self[k] = v
end

function Pane:pass(x, y, z, panes_per_page)
  local x_offset, y_offset = self:_determine_offsets()
  local offset_x = x - x_offset
  local offset_y = y - y_offset

  self:_update_held_keys(offset_x, offset_y, z)

  if z == 1 then
    self:_check_for_held_key_gestures(panes_per_page)
  end

  if not self.keys_halt then 
    self.plan:mark(offset_x, offset_y, z, self.keys_held)
  end
end

function Pane:update_offsets()
  local x_offset, y_offset = self:_determine_offsets()

  self.plan:set('x_offset', x_offset)
  self.plan:set('y_offset', y_offset)
end

function Pane:refresh()
  self.plan:refresh()
end

function Pane:step()
  self.plan:step()
end

function Pane:_determine_offsets()
  local x_offset = 0
  local y_offset = 0

  if self.pane > 2 then
    y_offset = self.edge_length
  elseif self.pane % 2 == 0 then
    x_offset = self.edge_length
  end

  return x_offset, y_offset
end

function Pane:_update_held_keys(x, y, z)
  -- This will need to change if we deviate from 64 key plans
  -- So, you know, if a bug pops up...
  if z == 1 then
    table.insert(self.keys_held, x..y)
  else
    local next_keys = {}
    for i = 1, #self.keys_held do
      if self.keys_held[i] ~= x..y then
        table.insert(next_keys, self.keys_held[i])
      end
    end
    self.keys_held = next_keys
  end
end

function Pane:_check_for_held_key_gestures(panes_per_page)
  local rightmost_pane = self.pane % panes_per_page == 0

  if tab.contains(self.keys_held, '17') and tab.contains(self.keys_held, '18') and tab.contains(self.keys_held, '28') then
    -- Bottom left corner of panel is reset gesture
    self.plan:reset()
    self:_flush_keys()
  elseif rightmost_pane and tab.contains(self.keys_held, '87') and tab.contains(self.keys_held, '88') and tab.contains(self.keys_held, '78') then
    print('Turn page')
    self:_flush_keys()
  end
end

function Pane:_flush_keys()
  self.keys_held = {}
  self:_pause_keys()
end

function Pane:_pause_keys(s)
  self.keys_halt = true
  clock.run(function() 
    clock.sleep(s or .4)
    self.keys_halt = false 
  end)
end

return Pane