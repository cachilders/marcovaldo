local Map = {
  host = nil,
  lumen = 5,
  the_city_all_to_himself = nil,
  the_city_of_stubborn_cats = nil
}

function Map:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return self
end

function Map:init(n)
  self.host = grid.connect(n)
  self.the_city_all_to_himself = self._gesso(8, 8)
  self.the_city_of_stubborn_cats = self._gesso(8, 8)
end

function Map:paint()
  self:_paint_plan(self.the_city_all_to_himself, true)
  self:_paint_plan(self.the_city_of_stubborn_cats)
  self.host:refresh()
end

function Map:_paint_plan(plan, plan_left)
  for r = 1, #plan do
    for c = 1, #plan[r] do
      self.host:led(plan_left and c or c + #plan[r], r, plan[r][c] == 0 and 0 or self.lumen)
    end
  end
end

function Map._gesso(x, y)
  local plan = {}
  for r = 1, y do
    plan[r] = {}
    for c = 1, x do
      plan[r][c] = c % r == c and 1 or 0 -- temp
    end
  end
  return plan
end

return Map