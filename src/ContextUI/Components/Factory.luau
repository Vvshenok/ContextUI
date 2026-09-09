--!strict
local Factory = {}

--------------------------------------------------------------------------------
-- Services
--------------------------------------------------------------------------------
local TextService = game:GetService("TextService")

--------------------------------------------------------------------------------
-- Imports & Packages
--------------------------------------------------------------------------------
local Types = require(script.Parent.Parent.Types)
local Janitor = require(script.Parent.Parent.Packages.Janitor)

--------------------------------------------------------------------------------
-- Types & Constants
--------------------------------------------------------------------------------
export type Row = {
	Root: Frame, Data: Types.Component, Labels: {TextLabel}, Buttons: {TextButton},
	Image: ImageLabel?, Track: Frame?, Fill: Frame?, Cleanup: Janitor.Janitor,
	Measure: (self: Row, width: number, theme: Types.Theme, apply: boolean) -> Vector2,
	Destroy: (self: Row) -> (),
}

--------------------------------------------------------------------------------
-- Private Functions
--------------------------------------------------------------------------------
local function frame(name: string, parent: Instance): Frame
	local object = Instance.new("Frame")
	object.Name = name
	object.BackgroundTransparency = 1
	object.BorderSizePixel = 0
	object.Parent = parent
	return object
end

local function label(parent: Instance): TextLabel
	local object = Instance.new("TextLabel")
	object.BackgroundTransparency = 1
	object.TextXAlignment = Enum.TextXAlignment.Left
	object.TextYAlignment = Enum.TextYAlignment.Top
	object.TextWrapped = true
	object.RichText = false
	object.BorderSizePixel = 0
	object.Parent = parent
	return object
end

local function textSize(text: string, font: Enum.Font, size: number, width: number): Vector2
	local bounds = TextService:GetTextSize(text, size, font, Vector2.new(math.max(1, width), math.huge))
	return Vector2.new(math.ceil(bounds.X), math.ceil(bounds.Y))
end

local function styleLabel(object: TextLabel, text: string, font: Enum.Font, size: number, color: Color3, x: number, y: number, width: number, height: number)
	object.Text, object.Font, object.TextSize, object.TextColor3 = text, font, size, color
	object.Position = UDim2.fromOffset(x, y)
	object.Size = UDim2.fromOffset(width, height)
end

--------------------------------------------------------------------------------
-- Public Methods
--------------------------------------------------------------------------------
function Factory.create(data: Types.Component, parent: Instance, activate: (number?) -> (), changed: () -> ()): Row
	local root = frame(data.Id, parent)
	local cleanup = Janitor.new()
	local row: Row = {
		Root = root, Data = data, Labels = {}, Buttons = {}, Image = nil, Track = nil, Fill = nil,
		Cleanup = cleanup, Measure = function() return Vector2.zero end, Destroy = function() end,
	}
	local kind = data.Kind
	local currentTheme: Types.Theme? = nil
	local _hovered: {[TextButton]: boolean} = {}
	if kind == "Image" then
		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.BackgroundTransparency = 1
		icon.ScaleType = Enum.ScaleType.Fit
		icon.Parent = root
		row.Image = icon
	elseif kind == "Custom" then
		local gui = data.Gui :: GuiObject
		local originalParent, originalPosition, originalAnchor, originalSize = gui.Parent, gui.Position, gui.AnchorPoint, gui.Size
		if not data.CustomSize then
			local width = if originalSize.X.Scale == 0 then originalSize.X.Offset else gui.AbsoluteSize.X
			local height = if originalSize.Y.Scale == 0 then originalSize.Y.Offset else gui.AbsoluteSize.Y
			data.CustomSize = Vector2.new(math.max(1, width), math.max(1, height))
		end
		gui.AnchorPoint, gui.Position = Vector2.zero, UDim2.fromOffset(0, 0)
		gui.Parent = root
		cleanup:Add(function()
			if gui.Parent == root then
				gui.Position, gui.AnchorPoint, gui.Size = originalPosition, originalAnchor, originalSize
				local ok = pcall(function() gui.Parent = originalParent end)
				if not ok then gui.Parent = nil end
			end
		end)
		local connection = gui:GetPropertyChangedSignal("Size"):Connect(function()
			if gui.Size.X.Scale == 0 and gui.Size.Y.Scale == 0 then
				data.CustomSize = Vector2.new(gui.Size.X.Offset, gui.Size.Y.Offset)
				changed()
			end
		end)
		cleanup:Add(function() connection:Disconnect() end)
	elseif kind == "Button" or kind == "ButtonGroup" then
		local count = if data.Buttons then #data.Buttons else 1
		for index = 1, count do
			local button = Instance.new("TextButton")
			button.Name = "Action" .. tostring(index)
			button.BorderSizePixel = 0
			button.AutoButtonColor = false
			button.TextWrapped = true
			button.Selectable = true
			button.Parent = root
			local corner = Instance.new("UICorner")
			corner.Parent = button
			local connection = button.Activated:Connect(function() activate(if kind == "ButtonGroup" then index else nil) end)
			local enter = button.MouseEnter:Connect(function()
				_hovered[button] = true
				if currentTheme and button.Active then button.BackgroundColor3 = currentTheme.ButtonHover end
			end)
			local leave = button.MouseLeave:Connect(function()
				_hovered[button] = nil
				if currentTheme then button.BackgroundColor3 = currentTheme.Button end
			end)
			cleanup:Add(function() connection:Disconnect(); enter:Disconnect(); leave:Disconnect() end)
			table.insert(row.Buttons, button)
		end
	elseif kind ~= "Divider" then
		table.insert(row.Labels, label(root))
		if kind == "Stat" or kind == "Keybind" then table.insert(row.Labels, label(root)) end
		if kind == "Progress" then
			local track = frame("Track", root)
			track.BackgroundTransparency = 0
			local fill = frame("Fill", track)
			fill.BackgroundTransparency = 0
			row.Track, row.Fill = track, fill
			for _, object in { track, fill } do
				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(1, 0)
				corner.Parent = object
			end
		end
	end

	function row:Measure(width: number, theme: Types.Theme, apply: boolean): Vector2
		if apply then currentTheme = theme end
		local content = self.Data
		local componentKind = content.Kind
		local font = if componentKind == "Title" or componentKind == "Section" then theme.TitleFont else theme.Font
		local size = if componentKind == "Title" then theme.TitleSize else theme.TextSize
		local natural = textSize(content.Text, font, size, width)
		local measured = natural
		if componentKind == "Divider" then
			measured = Vector2.new(0, 1)
			if apply then self.Root.BackgroundColor3 = theme.Stroke; self.Root.BackgroundTransparency = theme.StrokeTransparency end
		elseif componentKind == "Image" then
			local side = math.min(width, theme.IconSize)
			measured = Vector2.new(side, side)
			if apply and self.Image then self.Image.Image = content.Image; self.Image.Size = UDim2.fromOffset(side, side) end
		elseif componentKind == "Custom" then
			local customSize = content.CustomSize or Vector2.new(theme.IconSize, theme.IconSize)
			measured = Vector2.new(math.min(width, customSize.X), customSize.Y)
			if apply and content.Gui then content.Gui.Size = UDim2.fromOffset(measured.X, measured.Y) end
		elseif componentKind == "Stat" or componentKind == "Keybind" then
			local value = if componentKind == "Keybind" and content.KeyCode then content.KeyCode.Name else content.Value
			local leftNatural = textSize(content.Text, font, size, math.huge)
			local rightNatural = textSize(value, font, size, math.huge)
			local gap = math.min(theme.StatGap, width / 4)
			local available = math.max(2, width - gap)
			local rightWidth = math.min(rightNatural.X, math.max(available / 2, available - leftNatural.X))
			local leftWidth = math.max(1, available - rightWidth)
			local left = textSize(content.Text, font, size, leftWidth)
			local right = textSize(value, font, size, math.max(1, rightWidth))
			measured = Vector2.new(math.min(width, leftNatural.X + gap + rightNatural.X), math.max(left.Y, right.Y))
			if apply then
				styleLabel(self.Labels[1], content.Text, font, size, theme.SecondaryText, 0, 0, leftWidth, measured.Y)
				styleLabel(self.Labels[2], value, font, size, content.Color or theme.Text, width - rightWidth, 0, rightWidth, measured.Y)
				self.Labels[2].TextXAlignment = Enum.TextXAlignment.Right
			end
		elseif componentKind == "Button" or componentKind == "ButtonGroup" then
			local x, y, lineHeight, usedWidth = 0, 0, 0, 0
			for index, button in self.Buttons do
				local spec = if content.Buttons then content.Buttons[index] else nil
				local caption = if spec then spec.Text else content.Text
				local key = if spec then spec.KeyCode else content.KeyCode
				if key then caption ..= "  [" .. key.Name .. "]" end
				local bounds = textSize(caption, theme.Font, theme.TextSize, math.max(1, width - theme.ButtonPadding * 2))
				local buttonWidth = math.min(width, bounds.X + theme.ButtonPadding * 2)
				if componentKind == "Button" and apply then buttonWidth = width end
				local buttonHeight = math.max(theme.ButtonHeight, bounds.Y + theme.Gap * 2)
				if x > 0 and x + buttonWidth > width then x = 0; y += lineHeight + theme.Gap; lineHeight = 0 end
				if apply then
					local disabled = content.Disabled or (spec ~= nil and spec.Disabled == true)
					button.Text, button.Font, button.TextSize = caption, theme.Font, theme.TextSize
					button.TextColor3 = if disabled then theme.SecondaryText else theme.ButtonText
					button.BackgroundColor3 = if _hovered[button] and not disabled then theme.ButtonHover else theme.Button
					button.BackgroundTransparency = if disabled then 0.45 else 0
					button.Active, button.Selectable, button.AutoButtonColor = not disabled, not disabled, false
					button.Position, button.Size = UDim2.fromOffset(x, y), UDim2.fromOffset(buttonWidth, buttonHeight)
					local corner = button:FindFirstChildOfClass("UICorner")
					if corner then corner.CornerRadius = UDim.new(0, theme.ButtonCornerRadius) end
				end
				usedWidth = math.max(usedWidth, x + buttonWidth)
				x += buttonWidth + theme.Gap
				lineHeight = math.max(lineHeight, buttonHeight)
			end
			measured = Vector2.new(usedWidth, y + lineHeight)
		else
			if apply then
				local color = if componentKind == "Description" then theme.SecondaryText elseif componentKind == "Section" then theme.SectionText else theme.Text
				styleLabel(self.Labels[1], content.Text, font, size, content.Color or color, 0, 0, width, natural.Y)
			end
			if componentKind == "Progress" then
				measured = Vector2.new(natural.X, natural.Y + theme.Gap + theme.ProgressHeight)
				if apply and self.Track and self.Fill then
					self.Track.BackgroundColor3, self.Fill.BackgroundColor3 = theme.ProgressTrack, content.Color or theme.Accent
					self.Track.Position, self.Track.Size = UDim2.fromOffset(0, natural.Y + theme.Gap), UDim2.fromOffset(width, theme.ProgressHeight)
					self.Fill.Size = UDim2.fromScale(content.Progress, 1)
				end
			end
		end
		if apply then self.Root.Size = UDim2.fromOffset(width, measured.Y) end
		return measured
	end

	function row:Destroy()
		self.Cleanup:Destroy()
		self.Root:Destroy()
	end
	return row
end

return Factory
