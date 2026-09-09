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
_theme.Background = Color3.fromHex("1B1429")
_theme.BackgroundTransparency = 0
_theme.Text = Color3.fromHex("F5EDFF")
_theme.SecondaryText = Color3.fromHex("BBB0D1")
_theme.Accent = Color3.fromHex("69E4DB")
_theme.Button = Color3.fromHex("432752")
_theme.ButtonHover = Color3.fromHex("5B356B")
_theme.ButtonText = Color3.fromHex("F9DFFF")
_theme.SectionText = Color3.fromHex("D69BF0")
_theme.ProgressTrack = Color3.fromHex("342740")
_theme.Stroke = Color3.fromHex("A269BB")
_theme.StrokeTransparency = 0.22
_theme.CornerRadius = 7
_theme.ButtonCornerRadius = 4
_theme.Padding = 11
_theme.Gap = 7
_theme.TitleSize = 16
_theme.ButtonHeight = 30
_theme.ProgressHeight = 5

return table.freeze(_theme)
