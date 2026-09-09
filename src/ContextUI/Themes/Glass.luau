--!strict

--------------------------------------------------------------------------------
-- Imports & Packages
--------------------------------------------------------------------------------
local Types = require(script.Parent.Parent.Types)
local Default = require(script.Parent.Default)

--------------------------------------------------------------------------------
-- Types & Constants
--------------------------------------------------------------------------------
local _theme: Types.Theme = table.clone(Default)
_theme.Background = Color3.fromHex("233448")
_theme.BackgroundTransparency = 0.28
_theme.Text = Color3.fromHex("F3F9FF")
_theme.SecondaryText = Color3.fromHex("C5D9E8")
_theme.Accent = Color3.fromHex("8EDCF5")
_theme.Button = Color3.fromHex("3C586F")
_theme.ButtonHover = Color3.fromHex("4C7089")
_theme.ButtonText = Color3.fromHex("FFFFFF")
_theme.SectionText = Color3.fromHex("A8DEED")
_theme.ProgressTrack = Color3.fromHex("364E63")
_theme.Stroke = Color3.fromHex("C0E4F4")
_theme.StrokeTransparency = 0.55
_theme.CornerRadius = 12
_theme.ButtonCornerRadius = 7
_theme.Padding = 12
_theme.Gap = 7
_theme.ButtonHeight = 30
_theme.TitleSize = 16

return table.freeze(_theme)
