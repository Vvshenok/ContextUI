--!strict
--[[
MIT License | Copyright (c) 2026 Interactive Studios
Credits: Interactive Studios | ContextUI example: Custom component
Documentation: https://vvshenok.github.io/ContextUI/examples/
Usage: require(path.CustomComponent)(slot, yourExistingGui)
]]

--------------------------------------------------------------------------------
-- Imports & Packages
--------------------------------------------------------------------------------
local ContextUI = require(game.ReplicatedStorage.ContextUI)

--------------------------------------------------------------------------------
-- Public Methods
--------------------------------------------------------------------------------
return function(slot: GuiObject, customGui: GuiObject): ContextUI.Context
	return ContextUI.new(slot)
		:SetTitle("Your interface")
		:AddCustom(customGui, { Id = "DeveloperContent", Size = Vector2.new(180, 60) })
		:Bind()
end
