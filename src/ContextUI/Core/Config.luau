--!strict
local Config = {}

--------------------------------------------------------------------------------
-- Imports & Packages
--------------------------------------------------------------------------------
local Types = require(script.Parent.Parent.Types)
local Themes = require(script.Parent.Parent.Themes.Catalog)

--------------------------------------------------------------------------------
-- Private Functions
--------------------------------------------------------------------------------
local function numberOption(value: number?, fallback: number, minimum: number): number
	local result = if value == nil then fallback else value
	assert(result == result and result < math.huge and result >= minimum, "ContextUI: invalid numeric option")
	return result
end

local function _applyTheme(_result: Types.Theme, _overrides: Types.ThemeOverrides)
	local _destination = (_result :: unknown) :: {[string]: unknown}
	for _key, _value in (_overrides :: unknown) :: {[string]: unknown} do
		assert(_destination[_key] ~= nil, "ContextUI: unknown theme field " .. _key)
		assert(typeof(_destination[_key]) == typeof(_value), "ContextUI: wrong type for theme field " .. _key)
		_destination[_key] = _value
	end
	if _overrides.Text and not _overrides.ButtonText then _result.ButtonText = _overrides.Text end
	if _overrides.SecondaryText and not _overrides.SectionText then _result.SectionText = _overrides.SecondaryText end
	if _overrides.Button and not _overrides.ProgressTrack then _result.ProgressTrack = _overrides.Button end
	if _overrides.CornerRadius and _overrides.ButtonCornerRadius == nil then _result.ButtonCornerRadius = _overrides.CornerRadius / 2 end
end

--------------------------------------------------------------------------------
-- Public Methods
--------------------------------------------------------------------------------
function Config.resolve(options: Types.Config?): Types.ResolvedConfig
	local input: Types.Config = options or {}
	local animation: Types.AnimationConfig = input.Animation or {}
	local maxWidth = numberOption(input.MaxWidth, 320, 32)
	local minWidth = numberOption(input.MinWidth, 0, 0)
	assert(minWidth <= maxWidth, "ContextUI: MinWidth must not exceed MaxWidth")
	return {
		MaxWidth = maxWidth, MinWidth = minWidth, MaxHeight = numberOption(input.MaxHeight, 480, 32),
		Offset = input.Offset or Vector2.new(14, 16), EdgePadding = numberOption(input.EdgePadding, 8, 0),
		CloseDelay = numberOption(input.CloseDelay, 0.18, 0),
		TransitionGrace = numberOption(input.TransitionGrace, 0.6, 0),
		SafePadding = numberOption(input.SafePadding, 10, 0),
		DockThreshold = numberOption(input.DockThreshold, 3, 0),
		DisplayOrder = input.DisplayOrder or 50, WorldRayLength = numberOption(input.WorldRayLength, 2048, 1), Interactive = input.Interactive,
		Animation = {
			ShowDuration = numberOption(animation.ShowDuration, 0.14, 0),
			HideDuration = numberOption(animation.HideDuration, 0.1, 0),
			ResizeDuration = numberOption(animation.ResizeDuration, 0.16, 0),
			FollowSpeed = numberOption(animation.FollowSpeed, 24, 0.01),
			ReducedMotion = animation.ReducedMotion == true,
		},
	}
end

function Config.theme(_selection: (Types.ThemeName | Types.ThemeOverrides)?, _base: Types.Theme?, _overrides: Types.ThemeOverrides?): Types.Theme
	local _result: Types.Theme
	if typeof(_selection) == "string" then
		local _catalog = (Themes :: unknown) :: {[string]: Types.Theme}
		local _preset = _catalog[_selection]
		assert(_preset, "ContextUI: unknown theme '" .. _selection .. "'")
		_result = table.clone(_preset)
	else
		_result = table.clone(_base or Themes.Default)
		if _selection then _applyTheme(_result, _selection) end
	end
	if _overrides then _applyTheme(_result, _overrides) end
	for _key, _value in (_result :: unknown) :: {[string]: unknown} do
		if typeof(_value) == "number" then
			assert(_value == _value and _value < math.huge and _value >= 0, "ContextUI: invalid theme field " .. _key)
		end
	end
	assert(_result.BackgroundTransparency <= 1 and _result.StrokeTransparency <= 1, "ContextUI: theme transparency must be between 0 and 1")
	assert(_result.TextSize > 0 and _result.TitleSize > 0, "ContextUI: text sizes must be positive")
	assert(_result.ButtonHeight > 0 and _result.IconSize > 0 and _result.ProgressHeight > 0, "ContextUI: component sizes must be positive")
	assert(_result.Font.EnumType == Enum.Font and _result.TitleFont.EnumType == Enum.Font, "ContextUI: theme fonts must be Enum.Font values")
	return _result
end

return Config
