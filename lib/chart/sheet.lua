local Sheet = {
  affect_arrangement = nil,
  led = nil,
  source = nil,
  values = nil,
  height = 8, -- WIP; solve for different sizes for this application
  width = 16
}

function Sheet:new(options)
  local instance = options or {}
  setmetatable(instance, self)
  self.__index = self
  return instance
end

function Sheet:get(k)
  return self[k]
end

function Sheet:set(k, v)
  self[k] = v
end

function Sheet:update(i, values)
  self.source = i
  self.values = values
end

function Sheet:press(x, y, z)
  -- Once the grid accurately reflects the state of the sequencer, we can
  -- we need to refactor https://vscode.dev/github/cachilders/marcovaldo/blob/feat-editor-charts/lib/arrangement.lua#L208-L209
  -- such that the transmission is hoisted and affected by both rings and sheets
  -- The complexity here increases with two two-way display/edit interfaces
  -- so updates must travel both was as should the editor state. The grid won't enter sequence
  -- mode, but its use will extend the timeout that dismisses the edit state.
  -- send update to arrangement
end

return Sheet
