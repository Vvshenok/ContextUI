--!strict
local Renderer = {}
Renderer.__index = Renderer

--------------------------------------------------------------------------------
-- Imports & Packages
--------------------------------------------------------------------------------
local Types = require(script.Parent.Parent.Types)
local Factory = require(script.Parent.Parent.Components.Factory)
local Animator = require(script.Parent.Animator)

--------------------------------------------------------------------------------
-- Types & Constants
--------------------------------------------------------------------------------
type Fields = {
	Surface: CanvasGroup, Scroll: ScrollingFrame, Corner: UICorner, Stroke: UIStroke,
	Rows: {[string]: Factory.Row}, Order: {string}, Size: Vector2, Limit: Vector2,
	Theme: Types.Theme, Config: Types.ResolvedConfig, Animation: Animator.Animator,
	Expanded: boolean, Visible: boolean, _layout: boolean,
	Activate: (string, number?) -> (),
}
export type Renderer = typeof(setmetatable({} :: Fields, Renderer))

--------------------------------------------------------------------------------
-- Constructor
--------------------------------------------------------------------------------
function Renderer.new(parent: Instance, config: Types.ResolvedConfig, theme: Types.Theme, activate: (string, number?) -> ()): Renderer
	local surface = Instance.new("CanvasGroup")
	surface.Name = "ContextSurface"
	surface.BorderSizePixel = 0
	surface.GroupTransparency = 1
	surface.Visible = false
	surface.ClipsDescendants = true
	surface.Parent = parent
	local corner = Instance.new("UICorner")
	corner.Parent = surface
	local stroke = Instance.new("UIStroke")
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = surface
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "Content"
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.ScrollBarThickness = 2
	scroll.ScrollBarImageTransparency = 0.5
	scroll.CanvasSize = UDim2.fromOffset(0, 0)
	scroll.Parent = surface
	local self: Renderer = setmetatable({
		Surface = surface, Scroll = scroll, Corner = corner, Stroke = stroke,
		Rows = {}, Order = {}, Size = Vector2.zero, Limit = Vector2.new(config.MaxWidth, config.MaxHeight),
		Theme = theme, Config = config, Animation = Animator.new(), Expanded = false,
		Visible = false, _layout = false, Activate = activate,
	}, Renderer)
	self:SetTheme(theme)
	return self
end

--------------------------------------------------------------------------------
-- Public Methods
--------------------------------------------------------------------------------
function Renderer.SetTheme(self: Renderer, theme: Types.Theme)
	self.Theme = theme
	self.Surface.BackgroundColor3, self.Surface.BackgroundTransparency = theme.Background, theme.BackgroundTransparency
	self.Corner.CornerRadius = UDim.new(0, theme.CornerRadius)
	self.Stroke.Color, self.Stroke.Transparency = theme.Stroke, theme.StrokeTransparency
	self.Stroke.Thickness = theme.StrokeThickness
	self.Scroll.ScrollBarImageColor3 = theme.SecondaryText
	self:Layout()
end

function Renderer.Add(self: Renderer, component: Types.Component)
	assert(not self.Rows[component.Id], "ContextUI: duplicate rendered component")
	self.Rows[component.Id] = Factory.create(component, self.Scroll, function(index) self.Activate(component.Id, index) end, function() self:Layout() end)
	table.insert(self.Order, component.Id)
	self:Layout()
end

function Renderer.Remove(self: Renderer, id: string)
	local row = self.Rows[id]
	if not row then return end
	row:Destroy()
	self.Rows[id] = nil
	local index = table.find(self.Order, id)
	if index then table.remove(self.Order, index) end
	self:Layout()
end

function Renderer.Layout(self: Renderer)
	if self._layout then return end
	self._layout = true
	local theme = self.Theme
	local padding = math.min(theme.Padding, self.Limit.X / 4, self.Limit.Y / 4)
	local maximum = math.max(1, math.min(self.Config.MaxWidth, self.Limit.X) - padding * 2)
	local width = math.min(maximum, math.max(0, self.Config.MinWidth - padding * 2))
	for _, id in self.Order do
		local row = self.Rows[id]
		row.Root.Visible = not row.Data.ExpandedOnly or self.Expanded
		if row.Root.Visible then width = math.max(width, row:Measure(maximum, theme, false).X) end
	end
	width = math.clamp(width, 1, maximum)
	local height, count = 0, 0
	for _, id in self.Order do
		local row = self.Rows[id]
		if not row.Root.Visible then continue end
		if count > 0 then height += theme.Gap end
		local measured = row:Measure(width, theme, true)
		row.Root.Position = UDim2.fromOffset(0, height)
		height += measured.Y
		count += 1
	end
	local surfaceHeight = math.min(height + padding * 2, self.Config.MaxHeight, self.Limit.Y)
	local newSize = Vector2.new(width + padding * 2, surfaceHeight)
	self.Scroll.Position = UDim2.fromOffset(padding, padding)
	self.Scroll.Size = UDim2.new(1, -padding * 2, 1, -padding * 2)
	self.Scroll.CanvasSize = UDim2.fromOffset(0, height)
	self.Scroll.ScrollingEnabled = height > surfaceHeight - padding * 2
	if newSize ~= self.Size then
		self.Size = newSize
		local animation = self.Config.Animation
		local duration = if self.Visible and not animation.ReducedMotion then animation.ResizeDuration else 0
		self.Animation:Play("size", self.Surface, duration, { Size = UDim2.fromOffset(newSize.X, newSize.Y) })
	end
	self._layout = false
end

function Renderer.SetLimit(self: Renderer, limit: Vector2)
	if self.Limit == limit then return end
	self.Limit = limit
	self:Layout()
end

function Renderer.Show(self: Renderer)
	self.Visible = true
	self.Surface.Visible = true
	local animation = self.Config.Animation
	self.Animation:Play("visibility", self.Surface, if animation.ReducedMotion then 0 else animation.ShowDuration, { GroupTransparency = 0 })
end

function Renderer.Hide(self: Renderer)
	self.Visible = false
	self.Surface.Active = false
	local animation = self.Config.Animation
	self.Animation:Play("visibility", self.Surface, if animation.ReducedMotion then 0 else animation.HideDuration, { GroupTransparency = 1 }, function()
		if not self.Visible then self.Surface.Visible = false end
	end)
end

function Renderer.Destroy(self: Renderer)
	self.Animation:Destroy()
	for _, row in self.Rows do row:Destroy() end
	table.clear(self.Rows)
	table.clear(self.Order)
	self.Surface:Destroy()
end

return Renderer
