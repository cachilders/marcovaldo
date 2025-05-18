local Performer = include('lib/ensemble/performer')

local WTapePerformer = {
  name = WT
}

setmetatable(WTapePerformer, { __index = Performer })

function WTapePerformer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function WTapePerformer:configure(options)
  local device = params:get('marco_performer_w_device_'..WRONG_STOP_SEQ)
  local loop_length = params:get('marco_performer_w_loop_length_'..WRONG_STOP_SEQ)
  if not options then
    crow.ii.wtape[device].play(0)
    crow.ii.wtape[device].record(0)
    crow.ii.wtape[device].timestamp(5000)
    crow.ii.wtape[device].loop_start()
    crow.ii.wtape[device].seek(loop_length)
    crow.ii.wtape[device].loop_scale(0)
    crow.ii.wtape[device].loop_end()
    crow.ii.wtape[device].timestamp(5000)
    crow.ii.wtape[device].loop_active(1)
    crow.ii.wtape[device].echo_mode(0)
    crow.ii.wtape[device].freq(0)
    crow.ii.wtape[device].play(1)
  else
    for k,v in pairs(options) do
      crow.ii.wtape[device][k](v)
    end
  end
end

function WTapePerformer:_create_effect(effect_num)
  return function(data)
    local beat_time = 60 / params:get('clock_tempo')
    local device = params:get('marco_performer_w_device_'..WRONG_STOP_SEQ)
    local strength = params:get('marco_performer_w_erase_strength_'..WRONG_STOP_SEQ)
    local x = data.x
    local y = data.y
    local effect_clock = self:_get_next_clock('effect')
    if effect_clock then
      clock.cancel(effect_clock)
    end
    effect_clock = clock.run(
      function()
        if effect_num % 2 == 0 then
          crow.ii.wtape[device].erase_strength(strength)
          crow.ii.wtape[device].record(1)
          clock.sleep(beat_time * 5)
          crow.ii.wtape[device].record(0)
        else 
          local freq = (10 / 8 * y) - 5
          crow.ii.wtape[device].freq(freq)
          clock.sleep(beat_time * 5)
          crow.ii.wtape[device].freq(0)
        end
      end
    )
  end
end

function WTapePerformer:play_note(sequence, note, velocity, envelope_duration)
  -- nope
end

return WTapePerformer  