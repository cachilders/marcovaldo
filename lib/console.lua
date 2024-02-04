local actions = include('lib/actions')

local ANIMATION = 'animation'
local CONSOLE_HEIGHT = 64
local CONSOLE_WIDTH = 128
local INFO = 'info'
local KEY_FRAME = 15
local SEQUENCE_EDITOR = 'sequencer'
local SPRITE_PATH = '/home/we/dust/code/marcovaldo/assets/sprites/'
local STEP_EDITOR = 'step'
local TIMEOUT_DELAY = 30

local count = 1
local default_mode_timeout = nil

local Console = {
  affect_arrangement = nil,
  affect_chart = nil,
  affect_ensemble = nil,
  current_mode = 1,
  dirty = true,
  modes = {ANIMATION, SEQUENCER, STEP, INFO},
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
  -- self.sprite_sheet = screen.load_png(SPRITE_PATH..'mushroom.png')
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
    if self.modes[self.current_mode] == ANIMATION then
      -- TODO Sprite sheet is not very performant. need to investigate
      -- local left_edge = self.sprite_frame * CONSOLE_WIDTH - CONSOLE_WIDTH
      -- screen.display_image_region(self.sprite_sheet, left_edge, 0, CONSOLE_WIDTH, CONSOLE_HEIGHT, 0, 0)
      screen.display_png(SPRITE_PATH..'mushroom/'..self.sprite_frame..'.png', 0, 0)
    end
    screen.update()
    self:_toggle_dirty()
  end
end

function Console:step()
  if parameters.animations_enabled() then
    count = util.wrap(count + 1, 1, KEY_FRAME)
    if self.modes[self.current_mode] == ANIMATION and count == KEY_FRAME then
      self:_advance_sprite_frame()
      self:_toggle_dirty()
    end
  end
end

function Console:affect(action, index, values)
  if action == actions.edit_sequence then
    --
  elseif action == actions.edit_step then
    --
  end
end

function Console:_advance_sprite_frame()
  self.sprite_frame = util.wrap(self.sprite_frame + 1, 1, self.sprite_frames)
end

function Console:_cancel_default_mode_timeout()
  if default_mode_timeout then
    clock.cancel(default_mode_timeout)
    default_mode_timeout = nil
  end
end

function Console:_extend_default_mode_timeout()
  self:_cancel_default_mode_timeout()
  self:_new_default_mode_timeout()
end

function Console:_init_observers()
  parameters.animations_enabled:register('console', function() self:_toggle_default_mode() end)
end

function Console:_new_default_mode_timeout()
  default_mode_timeout = clock.run(
    function()
      clock.sleep(TIMEOUT_DELAY)
      default_mode_timeout = nil
      self:_toggle_default_mode()
    end
  )
end

function Console:_toggle_default_mode()
  local animations_enabled = parameters.animations_enabled()
  local animation_mode = tab.key(self.modes, ANIMATION)
  local info_mode = tab.key(self.modes, INFO)

  if self.modes[self.current_mode] == ANIMATION and animations_enabled then
    self.current_mode = info_mode
  elseif self.modes[self.current_mode] == INFO and animations_enabled then
    self.current_mode = animation_mode
  elseif animations_enabled then
    self.current_mode = animation_mode
  else
    self.current_mode = info_mode
  end

  self:_cancel_default_mode_timeout()
  self:_toggle_dirty()
end

function Console:_toggle_dirty()
  self.dirty = not self.dirty
end

return Console