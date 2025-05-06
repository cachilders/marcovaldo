local Performer = include('lib/ensemble/performer')

local ER301Performer = {
  clocks = nil,
  name = 'ER-301'
}

setmetatable(ER301Performer, { __index = Performer })

function ER301Performer:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function ER301Performer:_get_available_mods()
  return {
    { mod = 'sample_start', id = 'er301_sample_start' },
    { mod = 'grain_size', id = 'er301_grain_size' }
  }
end

function ER301Performer:init()
  self.clocks = {}
  -- Initialize ER-301
  if cat_breed_registry and cat_breed_registry.register_breeds then
    cat_breed_registry:register_breeds(self, self:_get_available_mods())
  end
end

function ER301Performer:play_note(sequence, note, velocity, envelope_duration)
  crow.ii.er301.cv(params:get('marco_performer_er301_cv_port_'..sequence), note / 12)
  if self.clocks[sequence] then
    clock.cancel(self.clocks[sequence])
  end
  self.clocks[sequence] = clock.run(
    function()
      crow.ii.er301.tr(params:get('marco_performer_er301_tr_port_'..sequence), 1)
      clock.sleep(envelope_duration)
      crow.ii.er301.tr(params:get('marco_performer_er301_tr_port_'..sequence), 0)
    end
  )
end

function ER301Performer:apply_effect(index, data)
  local function log_data(label, idx, d)
    local parts = {}
    for k, v in pairs(d) do table.insert(parts, tostring(k)..'='..tostring(v)) end
    print(string.format('[%s] Applying effect on index: %s | data: {%s}', label, tostring(idx), table.concat(parts, ', ')))
  end
  if data.mod == 'sample_start' then
    log_data('ER301Performer', index, data)
    -- TODO: Implement sample start effect for ER-301
  elseif data.mod == 'grain_size' then
    log_data('ER301Performer', index, data)
    -- TODO: Implement grain size effect for ER-301
  end
end

return ER301Performer