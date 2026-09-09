--!strict
--[[
MIT License | Copyright (c) 2026 Interactive Studios
Credits: Interactive Studios | ContextUI example: World object
Documentation: https://vvshenok.github.io/ContextUI/examples/
Usage: require(path.WorldObject)(workspace.Shop, function() print("Open store") end)
]]

--------------------------------------------------------------------------------
-- Imports & Packages
--------------------------------------------------------------------------------
local ContextUI = require(game.ReplicatedStorage.ContextUI)

--------------------------------------------------------------------------------
-- Public Methods
--------------------------------------------------------------------------------
return function(target: BasePart | Model | Attachment, openShop: () -> ()): ContextUI.Context
	return ContextUI.new(target)
		:SetTitle("Shop")
		:SetDescription("Browse the latest supplies.")
		:AddButton("Open", function(context) openShop(); context:Hide() end, { KeyCode = Enum.KeyCode.E })
		:Bind()
end
