local observable = require('container.observable')

local CatBreedRegistry = {}
CatBreedRegistry.__index = CatBreedRegistry

function CatBreedRegistry:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  instance.breeds = observable.new({})
  instance.breeds:register('cat_breed_registry', function(breeds)
    print('[CatBreedRegistry] Observable updated:')
    for i, breed in ipairs(breeds) do
      print('  Breed', i, ':')
      print('    performer:', breed.performer.name)
      print('    mod:', breed.mod)
      print('    id:', breed.id)
    end
  end)
  return instance
end

function CatBreedRegistry:register_breeds(performer, breeds)
  print('[CatBreedRegistry:register_breeds] Registering breeds for performer:', performer.name)
  local registry = self.breeds()
  for _, breed in ipairs(breeds) do
    print('[CatBreedRegistry:register_breeds] Adding breed:')
    print('  performer:', performer.name)
    print('  mod:', breed.mod)
    print('  id:', breed.id)
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
  local breeds = self.breeds()
  print('[CatBreedRegistry:get] Retrieved breeds:')
  for i, breed in ipairs(breeds) do
    print('  Breed', i, ':')
    print('    performer:', breed.performer.name)
    print('    mod:', breed.mod)
    print('    id:', breed.id)
  end
  return breeds
end

function CatBreedRegistry:subscribe(key, fn)
  self.breeds:register(key, fn)
end

return CatBreedRegistry
