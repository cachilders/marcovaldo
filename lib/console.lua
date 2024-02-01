-- I show animations and useful data
-- I provide takeover callbacks with input timeouts
-- for sequencer editing and whatnot

local ANIMATION = 'animation'
local CONSOLE_HEIGHT = 64
local CONSOLE_WIDTH = 128
local KEY_FRAME = 15
local SPRITE_PATH = '/home/we/dust/code/marcovaldo/assets/sprites/'

local count = 1

local Console = {
  affect_arrangement = function() end,
  affect_chart = function() end,
  affect_ensemble = function() end,
  current_mode = 1,
  dirty = true,
  modes = {ANIMATION},
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
  self.sprite_frames = 9
  -- self.sprite_sheet = screen.load_png(SPRITE_PATH..'mushroom.png')
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
    self.dirty = false
  end
end

function Console:step()
  count = util.wrap(count + 1, 1, KEY_FRAME)
  if self.modes[self.current_mode] == ANIMATION and count == KEY_FRAME then
    self:_advance_sprite_frame()
    self.dirty = true
  end
end

function Console:_advance_sprite_frame()
  self.sprite_frame = util.wrap(self.sprite_frame + 1, 1, self.sprite_frames)
end

return Console