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
_theme.Background = Color3.fromHex("101914")
_theme.BackgroundTransparency = 0
_theme.Text = Color3.fromHex("CBF0D6")
_theme.SecondaryText = Color3.fromHex("8FAB98")
_theme.Accent = Color3.fromHex("7CDA9C")
_theme.Button = Color3.fromHex("1F3528")
_theme.ButtonHover = Color3.fromHex("2C4937")
_theme.ButtonText = Color3.fromHex("BCEAC9")
_theme.SectionText = Color3.fromHex("7CDA9C")
_theme.ProgressTrack = Color3.fromHex("26372C")
_theme.Stroke = Color3.fromHex("5C9370")
_theme.StrokeTransparency = 0.32
_theme.Font = Enum.Font.Code
_theme.TitleFont = Enum.Font.Code
_theme.CornerRadius = 0
_theme.ButtonCornerRadius = 0
_theme.Padding = 10
_theme.Gap = 6
_theme.TextSize = 14
_theme.TitleSize = 15
_theme.ProgressHeight = 3
_theme.ButtonHeight = 28

return table.freeze(_theme)
