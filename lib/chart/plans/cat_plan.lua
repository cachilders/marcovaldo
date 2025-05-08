local actions = include('lib/actions')
local CatSymbol = include('lib/chart/symbols/cat_symbol')
local EphemeralSymbol = include('lib/chart/symbols/ephemeral_symbol')
local Plan = include('lib/chart/plan')

local CatPlan = {}

function CatPlan:new(options)
  local instance = Plan:new(options or {})
  setmetatable(self, {__index = Plan})
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function CatPlan:_add(x, y)
  print('[CatPlan:_add] Starting _add at', x, y)
  local cat_breeds = cat_breed_registry:get()
  if #cat_breeds == 0 then 
    print('[CatPlan:_add] No breeds available')
    return 
  end
  local breed = cat_breeds[math.random(1, #cat_breeds)]
  print('[CatPlan:_add] Selected breed:')
  for k,v in pairs(breed) do
    print('  '..k..':', v)
  end
  local act = function(x, y)
    print('[CatPlan:_add] Act function called at', x, y)
    local phenomenon = EphemeralSymbol:new({
      led = self.led,
      source_type = 'cat',
      x = x,
      x_offset = self.x_offset,
      y = y,
      y_offset = self.y_offset
    })
    self.phenomena[x][y] = phenomenon
    print('[CatPlan:_add] Calling affect_ensemble with:')
    print('  action:', actions.apply_effect)
    print('  sequence:', breed.sequence)
    print('  effect:', breed.effect)
    print('  data:', {x = x, y = y})
    self.affect_ensemble(actions.apply_effect, breed.sequence, {effect = breed.effect, data = {x = x, y = y}})
    clock.run(function()
      clock.sleep(self._get_bpm())
      self:_nullify_phenomenon(phenomenon)
    end)
  end
  local symbol = {
    act = act,
    breed = breed,
    led = self.led,
    lumen = 5,
    x = x,
    x_offset = self.x_offset,
    y = y,
    y_offset = self.y_offset,
    shift = function(x, y, to_x, to_y) self:_shift_symbol(x, y, to_x, to_y) end
  }
  self.features[x][y] = CatSymbol:new(symbol)
end

return CatPlan