--!strict
--------------------------------------------------------------------------------
-- Imports & Packages
--------------------------------------------------------------------------------
local Types = require(script.Parent.Parent.Types)

--------------------------------------------------------------------------------
-- Types & Constants
--------------------------------------------------------------------------------
local theme: Types.Theme = {
	Background = Color3.fromRGB(23, 25, 31), BackgroundTransparency = 0.08,
	Text = Color3.fromRGB(244, 245, 248), SecondaryText = Color3.fromRGB(174, 180, 193),
	Accent = Color3.fromRGB(129, 168, 255), Button = Color3.fromRGB(43, 48, 60),
	ButtonHover = Color3.fromRGB(57, 65, 82), Stroke = Color3.fromRGB(110, 123, 150),
	StrokeTransparency = 0.72, Font = Enum.Font.BuilderSans, TitleFont = Enum.Font.BuilderSansBold,
	ButtonText = Color3.fromRGB(244, 245, 248), SectionText = Color3.fromRGB(174, 180, 193),
	ProgressTrack = Color3.fromRGB(43, 48, 60), ButtonCornerRadius = 3, StrokeThickness = 1,
	TextSize = 13, TitleSize = 14, Padding = 8, Gap = 5, CornerRadius = 6,
	ButtonPadding = 9, ButtonHeight = 26, ProgressHeight = 4, IconSize = 32, StatGap = 22,
}

return table.freeze(theme)
