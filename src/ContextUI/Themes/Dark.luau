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
_theme.Background = Color3.fromHex("191919")
_theme.BackgroundTransparency = 0
_theme.Text = Color3.fromHex("F2F0EB")
_theme.SecondaryText = Color3.fromHex("ACA9A2")
_theme.Accent = Color3.fromHex("E7BE78")
_theme.Button = Color3.fromHex("30302F")
_theme.ButtonHover = Color3.fromHex("41413F")
_theme.ButtonText = Color3.fromHex("F4E8CD")
_theme.SectionText = Color3.fromHex("C2B9A6")
_theme.ProgressTrack = Color3.fromHex("343430")
_theme.Stroke = Color3.fromHex("64625B")
_theme.StrokeTransparency = 0.55
_theme.CornerRadius = 5
_theme.ButtonCornerRadius = 3
_theme.Padding = 10
_theme.Gap = 6

return table.freeze(_theme)
