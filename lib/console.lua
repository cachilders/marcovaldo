local actions = include('lib/actions')

local MUSHROOM= 'mushroom' -- ANIMATION SCENES
local DEFAULT_CONSOLE_MODES = {MUSHROOM, INFO}
local CONSOLE_HEIGHT = 64
local CONSOLE_WIDTH = 128
local INFO = 'info'
local KEY_FRAME = 15
local SPRITE_PATH = '/home/we/dust/code/marcovaldo/assets/sprites/'

local count = 1

local Console = {
  affect_arrangement = nil,
  affect_chart = nil,
  affect_ensemble = nil,
  default_mode = 1,
  dirty = true,
  sprite_frame = 1,
  sprite_frames = 1,
  sprite_sheet = nil
}

function Console:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Console:init()
  self.sprite_frames = 9 -- TODO Calculate
  self:_init_observers()
end

function Console:get(k)
  return self[k]
end

function Console:set(k, v)
  self[k] = v
end

function Console:refresh()
  if self.dirty then
    screen.clear()
    if parameters.animations_enabled() and
      MODES[current_mode()] == DEFAULT and
      DEFAULT_CONSOLE_MODES[self.default_mode] ~= INFO then
      local filepath = SPRITE_PATH..DEFAULT_CONSOLE_MODES[self.default_mode]..'/'..self.sprite_frame..'.png'
      screen.display_png(filepath, 0, 0)
    end
    screen.update()
    self:_toggle_dirty()
  end
end

function Console:step()
  if parameters.animations_enabled() then
    count = util.wrap(count + 1, 1, KEY_FRAME)
    if MODES[current_mode()] == DEFAULT and
      DEFAULT_CONSOLE_MODES[self.default_mode] ~= INFO and 
      count == KEY_FRAME then
      self:_advance_sprite_frame()
      self:_toggle_dirty()
    end
  end
end

function Console:affect(action, index, values)
  if action == actions.edit_sequence then
    -- Send values to edit screen for render
  elseif action == actions.edit_step then
    -- Send values to edit screen for render
  end
end

function Console:_advance_sprite_frame()
  self.sprite_frame = util.wrap(self.sprite_frame + 1, 1, self.sprite_frames)
end

function Console:_init_observers()
  current_mode:register('console', function() self:_switch_mode() end)
  parameters.animations_enabled:register('console', function() self:_toggle_default_mode() end)
end

function Console:_switch_mode()
  self.dirty = true
end

function Console:_toggle_default_mode()
  if animations_enabled then
    self.default_mode = util.wrap(self.default_mode + 1, 1, #DEFAULT_CONSOLE_MODES)
  else
    self.default_mode = tab.key(DEFAULT_CONSOLE_MODES, INFO)
  end

  default_mode_timeout_cancel()
  self:_toggle_dirty()
end

function Console:_toggle_dirty()
  self.dirty = not self.dirty
end

return Console