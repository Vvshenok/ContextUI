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
_theme.Background = Color3.fromHex("15192D")
_theme.BackgroundTransparency = 0.02
_theme.Text = Color3.fromHex("EEEFFF")
_theme.SecondaryText = Color3.fromHex("ABB0D0")
_theme.Accent = Color3.fromHex("B2A1F5")
_theme.Button = Color3.fromHex("343051")
_theme.ButtonHover = Color3.fromHex("484166")
_theme.ButtonText = Color3.fromHex("F3ECFF")
_theme.SectionText = Color3.fromHex("B2A1F5")
_theme.ProgressTrack = Color3.fromHex("292C48")
_theme.Stroke = Color3.fromHex("77729F")
_theme.StrokeTransparency = 0.55
_theme.CornerRadius = 8
_theme.ButtonCornerRadius = 5
_theme.Padding = 11
_theme.Gap = 7
_theme.ButtonHeight = 30
_theme.TitleSize = 16

return table.freeze(_theme)
