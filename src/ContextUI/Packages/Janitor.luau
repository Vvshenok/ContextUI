--!strict
local Janitor = {}
Janitor.__index = Janitor

--------------------------------------------------------------------------------
-- Types & Constants
--------------------------------------------------------------------------------
type Fields = { _items: {() -> ()}, _destroyed: boolean }
export type Janitor = typeof(setmetatable({} :: Fields, Janitor))

--------------------------------------------------------------------------------
-- Constructor
--------------------------------------------------------------------------------
function Janitor.new(): Janitor
	return setmetatable({ _items = {}, _destroyed = false }, Janitor)
end

--------------------------------------------------------------------------------
-- Public Methods
--------------------------------------------------------------------------------
function Janitor.Add(self: Janitor, cleanup: () -> ())
	if self._destroyed then cleanup() else table.insert(self._items, cleanup) end
end

function Janitor.Clean(self: Janitor)
	local items = self._items
	self._items = {}
	for index = #items, 1, -1 do
		local ok, message = pcall(function() items[index](); return true end)
		if not ok then warn("ContextUI cleanup: " .. tostring(message)) end
	end
end

function Janitor.Destroy(self: Janitor)
	if self._destroyed then return end
	self._destroyed = true
	self:Clean()
end

return Janitor
