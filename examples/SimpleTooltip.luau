--!strict
--[[
MIT License | Copyright (c) 2026 Interactive Studios
Credits: Interactive Studios | ContextUI example: Simple tooltip
Documentation: https://vvshenok.github.io/ContextUI/examples/
Usage: require(path.SimpleTooltip)(button)
]]

--------------------------------------------------------------------------------
-- Imports & Packages
--------------------------------------------------------------------------------
local ContextUI = require(game.ReplicatedStorage.ContextUI)

--------------------------------------------------------------------------------
-- Public Methods
--------------------------------------------------------------------------------
return function(button: GuiObject): ContextUI.Context
	return ContextUI.new(button):SetTitle("Open Shop"):Bind()
end
