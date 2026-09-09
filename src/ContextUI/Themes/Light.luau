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
_theme.Background = Color3.fromHex("FFFFFF")
_theme.BackgroundTransparency = 0
_theme.Text = Color3.fromHex("172338")
_theme.SecondaryText = Color3.fromHex("536174")
_theme.Accent = Color3.fromHex("2563EB")
_theme.Button = Color3.fromHex("2563EB")
_theme.ButtonHover = Color3.fromHex("1D4ED8")
_theme.ButtonText = Color3.fromHex("FFFFFF")
_theme.SectionText = Color3.fromHex("2563EB")
_theme.ProgressTrack = Color3.fromHex("E4EAF4")
_theme.Stroke = Color3.fromHex("CAD4E2")
_theme.StrokeTransparency = 0.1
_theme.CornerRadius = 9
_theme.ButtonCornerRadius = 5
_theme.Padding = 12
_theme.Gap = 7
_theme.ButtonHeight = 30
_theme.TitleSize = 16

return table.freeze(_theme)
