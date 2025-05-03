local actions = include('lib/actions')
local ErrorScreen = include('lib/console/error_screen')
local InfoScreen = include('lib/console/info_screen')
local SequenceScreen = include('lib/console/sequence_screen')
local StepScreen = include('lib/console/step_screen')

local ANIMATION = 'animation'
local MUSHROOMS = 'mushrooms'
local WASPS = 'wasps'
local WOODCOCK = 'woodcock'
local INFO = 'info'
local ANIMATION_SCENES = {MUSHROOMS, WASPS, WOODCOCK}
local DEFAULT_CONSOLE_MODES = {ANIMATION, INFO}
local KEY_FRAME = 15
local SPRITE_PATH = '/home/we/dust/code/marcovaldo/assets/cells/'

local count = 1

local Console = {
  affect_arrangement = nil,
  affect_chart = nil,
  affect_ensemble = nil,
  animation_cell = 1,
  animation_cells = 1,
  animation_scene = 1,
  default_mode = 1,
  dirty = true,
  screens = nil
}

function Console:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Console:hydrate(console)
  self.default_mode = console.default_mode
end

function Console:init()
  self.animation_cells = 9 -- TODO Calculate
  self:_init_observers()
  self:_init_screens()
end

function Console:get(k)
  return self[k]
end

function Console:set(k, v)
  self[k] = v
end

function Console:refresh()
  if self.dirty then
    local mode = MODES[current_mode()]
    screen.clear()
    if mode == ERROR then
      self.screens[ERROR]:draw()
    elseif mode == DEFAULT then
      local default_console_mode = DEFAULT_CONSOLE_MODES[self.default_mode]
      if parameters.animations_enabled() and default_console_mode == ANIMATION then
        local filepath = SPRITE_PATH..ANIMATION_SCENES[self.animation_scene]..'/'..self.animation_cell..'.png'
        screen.display_png(filepath, 0, 0)
      else
        self.screens[INFO]:draw()
      end
    elseif mode == SEQUENCE then
      self.screens[SEQUENCE]:draw()
    elseif mode == STEP then
      self.screens[STEP]:draw()
    end
    screen.stroke()
    screen.update()
    self:_scuff()
  end
end

function Console:step()
  if parameters.animations_enabled() then
    count = util.wrap(count + 1, 1, KEY_FRAME)
    if get_current_mode() == DEFAULT and
      DEFAULT_CONSOLE_MODES[self.default_mode] ~= INFO and 
      count == KEY_FRAME then
      self:_advance_animation_cell()
      self:_scuff()
    end
  end
end

function Console:affect(action, index, values)
  if action == actions.display_note then
    self.screens[INFO]:update(index, values)
  elseif action == actions.edit_sequence or action == actions.edit_step then
    self.screens[SEQUENCE]:update(index, values[SEQUENCE])
    self.screens[STEP]:update(index, values[STEP])
  elseif action == actions.set_error_message then
    if DEFAULT_CONSOLE_MODES[self.default_mode] == INFO then
      self.screens[ERROR]:update(index)
    end
  end

  self.dirty = true
end

function Console:twist(e, delta)
  if e == 1 and not shift_depressed then
    self:_scroll_default_mode(delta)
  end
end

function Console:_advance_animation_cell()
  self.animation_cell = util.wrap(self.animation_cell + 1, 1, self.animation_cells)
end

function Console:_init_observers()
  current_mode:register('console', function() self:_switch_mode() end)
  parameters.animations_enabled:register('console', function() self:_update_default_mode() end)
end

function Console:_init_screens()
  self.screens = {
    [ERROR] = ErrorScreen:new(),
    [INFO] = InfoScreen:new(),
    [SEQUENCE] = SequenceScreen:new(),
    [STEP] = StepScreen:new()
  }
end

function Console:_polish()
  self.dirty = false
end

function Console:_switch_mode()
  if get_current_mode() == DEFAULT then
    self:_step_animation_scene()
  end
  self.dirty = true
end

function Console:_scuff()
  self.dirty = true
end

function Console:_scroll_default_mode(delta)
  self.default_mode = util.clamp(self.default_mode + delta, 1, #DEFAULT_CONSOLE_MODES)
end

function Console:_step_animation_scene()
  self.animation_scene = util.wrap(self.animation_scene + 1, 1, #ANIMATION_SCENES)
end

function Console:_update_default_mode()
  if animations_enabled then
    self.default_mode = tab.key(DEFAULT_CONSOLE_MODES, ANIMATION)
  else
    self.default_mode = tab.key(DEFAULT_CONSOLE_MODES, INFO)
  end

  default_mode_timeout_cancel()
  self:_scuff()
end

return Console