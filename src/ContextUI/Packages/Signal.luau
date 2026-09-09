--!strict
local Signal = {}

--------------------------------------------------------------------------------
-- Imports & Packages
--------------------------------------------------------------------------------
local Types = require(script.Parent.Parent.Types)

--------------------------------------------------------------------------------
-- Public Methods
--------------------------------------------------------------------------------
function Signal.new<T>(): Types.Signal<T>
	local callbacks: {[Types.Connection]: (T) -> ()} = {}
	local destroyed = false
	local signal = {} :: Types.Signal<T>
	function signal:Connect(callback: (T) -> ()): Types.Connection
		assert(not destroyed, "ContextUI: signal is destroyed")
		local connection: Types.Connection = { Disconnect = function(self) callbacks[self] = nil end }
		callbacks[connection] = callback
		return connection
	end
	function signal:Once(callback: (T) -> ()): Types.Connection
		local connection: Types.Connection? = nil
		connection = self:Connect(function(value)
			if connection then connection:Disconnect() end
			callback(value)
		end)
		return connection :: Types.Connection
	end
	function signal:Fire(value: T)
		local snapshot = table.clone(callbacks)
		for connection, callback in snapshot do
			if callbacks[connection] then
				local ok, message = pcall(function() callback(value); return true end)
				if not ok then warn("ContextUI listener: " .. tostring(message)) end
			end
		end
	end
	function signal:Destroy()
		destroyed = true
		table.clear(callbacks)
	end
	return signal
end

return Signal
