local Pane = {
  pane = 1,
  plan = nil
}

function Pane:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Pane:init(panes_per_page)
  if not self.plan:get('features') then
    self.plan:init()
  end
  self:update_offsets(panes_per_page)
end

function Pane:get(k)
  return self[k]
end

function Pane:set(k, v)
  self[k] = v
end

function Pane:pass(x, y, z, keys_held, clear_held_keys)
  local x_offset, y_offset = self:get_offsets()

  if z == 1 then
    self:_check_for_held_key_gestures(keys_held, clear_held_keys)
  end

  self.plan:mark(x - x_offset, y - y_offset, z, keys_held, clear_held_keys)
end

function Pane:update_offsets(panes_per_page)
  local x_offset, y_offset = self:_determine_offsets(panes_per_page)
  self.plan:set('x_offset', x_offset)
  self.plan:set('y_offset', y_offset)
end

function Pane:get_offsets()
  return self.plan:get('x_offset'), self.plan:get('y_offset')
end

function Pane:refresh()
  self.plan:refresh()
end

function Pane:step(count)
  self.plan:step(count)
end

function Pane:_determine_offsets(panes_per_page)
  local x_offset = 0
  local y_offset = 0

  if panes_per_page > 2 and self.pane > 2 then
    y_offset = PANE_EDGE_LENGTH
  end

  if self.pane % 2 == 0 then
    x_offset = PANE_EDGE_LENGTH
  end

  return x_offset, y_offset
end

function Pane:_check_for_held_key_gestures(keys_held, clear_held_keys)
  if tab.contains(keys_held, '17') and tab.contains(keys_held, '18') and tab.contains(keys_held, '28') then
    -- Bottom left corner of panel is reset gesture
    self.plan:reset()
    clear_held_keys()
  end
end

return Pane