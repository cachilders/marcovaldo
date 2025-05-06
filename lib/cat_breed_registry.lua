local observable = require('container.observable')

local CatBreedRegistry = {}
CatBreedRegistry.__index = CatBreedRegistry

function CatBreedRegistry:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  instance.breeds = observable.new({})
  return instance
end

function CatBreedRegistry:register_breeds(performer, breeds)
  local registry = self.breeds()
  for _, breed in ipairs(breeds) do
    table.insert(registry, { performer = performer, mod = breed, id = breed.id or (util and util.generate_id and util.generate_id()) or math.random() })
  end
  self.breeds:set(registry)
end

function CatBreedRegistry:deregister_breeds(performer)
  local registry = self.breeds()
  for i = #registry, 1, -1 do
    if registry[i].performer == performer then
      table.remove(registry, i)
    end
  end
  self.breeds:set(registry)
end

function CatBreedRegistry:get()
  return self.breeds()
end

function CatBreedRegistry:subscribe(key, fn)
  self.breeds:register(key, fn)
end

return CatBreedRegistry
