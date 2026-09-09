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
_theme.Background = Color3.fromHex("F5F5F3")
_theme.BackgroundTransparency = 0
_theme.Text = Color3.fromHex("24282C")
_theme.SecondaryText = Color3.fromHex("666B6F")
_theme.Accent = Color3.fromHex("333B42")
_theme.Button = Color3.fromHex("E5E7E7")
_theme.ButtonHover = Color3.fromHex("D5D9D9")
_theme.ButtonText = Color3.fromHex("24282C")
_theme.SectionText = Color3.fromHex("666B6F")
_theme.ProgressTrack = Color3.fromHex("DCE0E0")
_theme.Stroke = Color3.fromHex("F5F5F3")
_theme.StrokeTransparency = 1
_theme.CornerRadius = 2
_theme.ButtonCornerRadius = 1
_theme.Padding = 7
_theme.Gap = 4
_theme.ButtonHeight = 24
_theme.ProgressHeight = 2
_theme.TitleSize = 13
_theme.StatGap = 16

return table.freeze(_theme)
