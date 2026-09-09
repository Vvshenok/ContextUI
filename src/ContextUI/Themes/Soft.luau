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
_theme.Background = Color3.fromHex("F5EEE6")
_theme.BackgroundTransparency = 0
_theme.Text = Color3.fromHex("493A37")
_theme.SecondaryText = Color3.fromHex("7F6861")
_theme.Accent = Color3.fromHex("AD6655")
_theme.Button = Color3.fromHex("E9CEBF")
_theme.ButtonHover = Color3.fromHex("DEBBAA")
_theme.ButtonText = Color3.fromHex("51372F")
_theme.SectionText = Color3.fromHex("9C5D4D")
_theme.ProgressTrack = Color3.fromHex("E6DAD0")
_theme.Stroke = Color3.fromHex("D5BDB0")
_theme.StrokeTransparency = 0.55
_theme.CornerRadius = 14
_theme.ButtonCornerRadius = 9
_theme.Padding = 13
_theme.Gap = 8
_theme.ButtonHeight = 32
_theme.TitleSize = 16
_theme.ProgressHeight = 5

return table.freeze(_theme)
