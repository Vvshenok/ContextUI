--!strict

--------------------------------------------------------------------------------
-- Imports & Packages
--------------------------------------------------------------------------------
local Catalog = {
	Default = require(script.Parent.Default),
	Dark = require(script.Parent.Dark),
	Light = require(script.Parent.Light),
	Glass = require(script.Parent.Glass),
	Midnight = require(script.Parent.Midnight),
	Minimal = require(script.Parent.Minimal),
	Terminal = require(script.Parent.Terminal),
	Neon = require(script.Parent.Neon),
	Soft = require(script.Parent.Soft),
}

return table.freeze(Catalog)
