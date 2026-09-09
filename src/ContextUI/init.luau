--!strict
local ContextUI = { Version = "1.0.0", Credits = "Interactive Studios" }
ContextUI.__index = ContextUI

--[[
MIT License

Copyright (c) 2026 Interactive Studios

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

--------------------------------------------------------------------------------
-- Services
--------------------------------------------------------------------------------
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")

--------------------------------------------------------------------------------
-- Imports & Packages
--------------------------------------------------------------------------------
local Types = require(script.Types)
local Config = require(script.Core.Config)
local Manager = require(script.Core.Manager)
local Renderer = require(script.Core.Renderer)
local Positioner = require(script.Core.Positioner)
local InputController = require(script.Core.InputController)
local Janitor = require(script.Packages.Janitor)
local Signal = require(script.Packages.Signal)
local Themes = require(script.Themes.Catalog)
ContextUI.Themes = Themes

--------------------------------------------------------------------------------
-- Types & Constants
--------------------------------------------------------------------------------
export type Context = Types.Context
export type Config = Types.Config
export type Theme = Types.Theme
export type ThemeName = Types.ThemeName
export type ThemeOverrides = Types.ThemeOverrides
export type Component = Types.Component
export type ButtonConfig = Types.ButtonConfig
export type StatConfig = Types.StatConfig
export type AnimationConfig = Types.AnimationConfig
export type Target = Types.Target
export type State = Types.State
export type Extension = Types.Extension


type Fields = {
	StateChanged: Types.Signal<Types.State>, ExpandedChanged: Types.Signal<boolean>,
	_target: Types.Target?, _config: Types.ResolvedConfig, _theme: Types.Theme,
	_components: {[string]: Types.Component}, _order: {string}, _nextId: number,
	_controller: InputController.Controller, _renderer: Renderer.Renderer?,
	_cleanup: Janitor.Janitor, _targetCleanup: Janitor.Janitor, _unbind: (() -> ())?,
	_handle: Manager.Handle, _expanded: boolean, _destroyed: boolean, _state: Types.State,
	_position: Vector2, _manual: boolean, _extensions: {[string]: boolean},
	_tasks: {[thread]: boolean}, _previousSelection: GuiObject?,
}
type Internal = typeof(setmetatable({} :: Fields, ContextUI))

--------------------------------------------------------------------------------
-- Private Functions
--------------------------------------------------------------------------------
local function alive(self: Internal)
	assert(not self._destroyed, "ContextUI: this context is destroyed")
end

local function emitState(self: Internal)
	local state: Types.State = self._controller.State :: Types.State
	if self._state == state then return end
	self._state = state
	self.StateChanged:Fire(state)
end

local function updateInteractive(self: Internal)
	local override = self._config.Interactive
	local interactive = override == true
	if override == nil then
		for _, component in self._components do
			if component.Interactive and (not component.ExpandedOnly or self._expanded) then interactive = true; break end
		end
	end
	self._controller.Interactive = interactive
	local renderer = self._renderer
	if renderer then renderer.Surface.Active = interactive or self._controller.State == "Pinned" end
end

local function layout(self: Internal)
	updateInteractive(self)
	if self._renderer then self._renderer:Layout() end
end

local function component(self: Internal, kind: Types.ComponentKind, text: string, options: Types.ComponentConfig?, defaultId: string?): Types.Component
	alive(self)
	self._nextId += 1
	local config: Types.ComponentConfig = options or {}
	local id = config.Id or defaultId or (kind .. tostring(self._nextId))
	assert(#id > 0, "ContextUI: component Id must not be empty")
	assert(not self._components[id], "ContextUI: duplicate component Id '" .. id .. "'")
	return {
		Id = id, Kind = kind, Text = text, Value = "", Progress = 0, Image = "",
		ExpandedOnly = config.ExpandedOnly == true, Color = nil, Disabled = false,
		KeyCode = nil, Callback = nil, Buttons = nil, Gui = nil, CustomSize = nil, Interactive = false,
	}
end

local function add(self: Internal, data: Types.Component): Internal
	self._components[data.Id] = data
	table.insert(self._order, data.Id)
	if self._renderer then self._renderer:Add(data) end
	updateInteractive(self)
	return self
end

local function get(self: Internal, id: string, kind: Types.ComponentKind?): Types.Component
	alive(self)
	local data = self._components[id]
	assert(data, "ContextUI: no component named '" .. id .. "'")
	assert(not kind or data.Kind == kind, "ContextUI: component '" .. id .. "' has the wrong kind")
	return data
end

local function runCallback(self: Internal, callback: (Types.Context) -> ())
	local worker: thread
	worker = coroutine.create(function()
		local ok, message = pcall(function() callback((self :: unknown) :: Types.Context); return true end)
		self._tasks[coroutine.running()] = nil
		if not ok then warn("ContextUI callback: " .. tostring(message)) end
	end)
	self._tasks[worker] = true
	task.spawn(worker)
end

local function activate(self: Internal, id: string, index: number?)
	if self._destroyed or self._controller.State == "Hidden" then return end
	local data = self._components[id]
	if not data or data.Disabled or (data.ExpandedOnly and not self._expanded) then return end
	if data.Buttons and index then
		local button = data.Buttons[index]
		if button and not button.Disabled then runCallback(self, button.Callback) end
	elseif data.Callback then runCallback(self, data.Callback) end
end

local function ensureRenderer(self: Internal): Renderer.Renderer
	if self._renderer then return self._renderer end
	local renderer = Renderer.new(Manager.root(self._config.DisplayOrder), self._config, self._theme, function(id, index) activate(self, id, index) end)
	self._renderer = renderer
	renderer.Expanded = self._expanded
	for _, id in self._order do renderer:Add(self._components[id]) end
	updateInteractive(self)
	return renderer
end

local function watchTarget(self: Internal)
	self._targetCleanup:Clean()
	local target = self._target
	if not target then return end
	local destroying = target.Destroying:Connect(function() self:Destroy() end)
	local ancestry = target.AncestryChanged:Connect(function()
		if not target:IsDescendantOf(game) then self:Hide() end
	end)
	self._targetCleanup:Add(function() destroying:Disconnect(); ancestry:Disconnect() end)
	if target:IsA("GuiObject") then
		local visible = target:GetPropertyChangedSignal("Visible"):Connect(function()
			if not target.Visible then self:Hide() end
		end)
		self._targetCleanup:Add(function() visible:Disconnect() end)
	end
end

local function step(self: Internal, dt: number, pointer: Vector2)
	local renderer = self._renderer
	if not renderer or self._destroyed then return end
	local controller = self._controller
	local selected = GuiService.SelectedObject
	local selectionInside = selected ~= nil and selected:IsDescendantOf(renderer.Surface)
	if selectionInside then controller.Deadline = nil end
	local _surfacePosition = Manager.screenPosition(renderer.Surface)
	local testPointer = if selectionInside then _surfacePosition + renderer.Surface.AbsoluteSize / 2 else pointer
	if controller:Step(testPointer, _surfacePosition, renderer.Surface.AbsoluteSize, os.clock()) then self:Hide(); return end
	local minimum, maximum = Manager.bounds(self._config.EdgePadding)
	renderer:SetLimit(Vector2.new(math.max(1, maximum.X - minimum.X), math.max(1, maximum.Y - minimum.Y)))
	local destination = self._position
	if controller.State == "Following" then destination = Positioner.place(pointer, renderer.Size, self._config.Offset, minimum, maximum) end
	destination = Positioner.clamp(destination, renderer.Size, minimum, maximum)
	local alpha = if self._config.Animation.ReducedMotion then 1 else 1 - math.exp(-self._config.Animation.FollowSpeed * dt)
	self._position = self._position:Lerp(destination, alpha)
	renderer.Surface.Position = UDim2.fromOffset(self._position.X, self._position.Y)
	emitState(self)
end

--------------------------------------------------------------------------------
-- Constructor
--------------------------------------------------------------------------------
function ContextUI.new(target: Types.Target?, options: Types.Config?): Types.Context
	assert(RunService:IsClient(), "ContextUI is client-only; create it from a LocalScript")
	if target then
		assert(target:IsA("GuiObject") or target:IsA("BasePart") or target:IsA("Model") or target:IsA("Attachment"), "ContextUI: unsupported target")
	end
	local config = Config.resolve(options)
	local self = setmetatable({
		StateChanged = Signal.new() :: Types.Signal<Types.State>, ExpandedChanged = Signal.new() :: Types.Signal<boolean>,
		_target = target, _config = config, _theme = Config.theme(if options then options.Theme else nil),
		_components = {}, _order = {}, _nextId = 0, _controller = InputController.new(config), _renderer = nil,
		_cleanup = Janitor.new(), _targetCleanup = Janitor.new(), _unbind = nil,
		_handle = {} :: Manager.Handle, _expanded = false, _destroyed = false, _state = "Hidden" :: Types.State,
		_position = Vector2.zero, _manual = target == nil, _extensions = {}, _tasks = {}, _previousSelection = nil,
	}, ContextUI) :: Internal
	self._handle = {
		WorldRayLength = config.WorldRayLength,
		Enter = function(pointer, docked)
			if self._destroyed then return end
			if self._controller.State == "Hidden" then self:Show(pointer) end
			self._controller:Enter()
			if docked and self._controller.State ~= "Pinned" then self._controller.State = "Docked" end
			if docked and GuiService.SelectedObject == self._target and self._renderer then
				self._previousSelection = GuiService.SelectedObject
				for _, id in self._order do
					local row = self._renderer.Rows[id]
					if row.Root.Visible then
						for _, button in row.Buttons do
							if button.Selectable then GuiService.SelectedObject = button; break end
						end
					end
					if GuiService.SelectedObject ~= self._previousSelection then break end
				end
			end
			emitState(self)
		end,
		Leave = function(pointer) if not self._destroyed then self._controller:Leave(pointer, os.clock()); emitState(self) end end,
		Step = function(dt, pointer) step(self, dt, pointer) end,
		Hide = function() self:Hide() end,
		IsPinned = function() return self._controller.State == "Pinned" end,
		Surface = function() return if self._renderer then self._renderer.Surface else nil end,
		Key = function(key)
			for _, id in self._order do
				local data = self._components[id]
				if data.Disabled or (data.ExpandedOnly and not self._expanded) then continue end
				if data.KeyCode == key and data.Callback then activate(self, id, nil); return true end
				if data.Buttons then
					for index, button in data.Buttons do
						if not button.Disabled and button.KeyCode == key then activate(self, id, index); return true end
					end
				end
			end
			return false
		end,
	}
	Manager.retain()
	watchTarget(self)
	return (self :: unknown) :: Types.Context
end

--------------------------------------------------------------------------------
-- Public Methods
--------------------------------------------------------------------------------
function ContextUI.GetTheme(_name: Types.ThemeName, _overrides: Types.ThemeOverrides?): Types.Theme
	return Config.theme(_name, nil, _overrides)
end

function ContextUI.SetTitle(self: Internal, text: string): Internal
	if self._components.Title then self:SetText("Title", text) else add(self, component(self, "Title", text, nil, "Title")) end
	return self
end

function ContextUI.SetDescription(self: Internal, text: string): Internal
	if self._components.Description then self:SetText("Description", text) else add(self, component(self, "Description", text, nil, "Description")) end
	return self
end

function ContextUI.AddText(self: Internal, text: string, options: Types.ComponentConfig?): Internal
	return add(self, component(self, "Text", text, options))
end

function ContextUI.AddImage(self: Internal, image: string, options: Types.ComponentConfig?): Internal
	local data = component(self, "Image", "", options)
	data.Image = image
	return add(self, data)
end

function ContextUI.SetIcon(self: Internal, image: string): Internal
	if self._components.Icon then self:SetImage("Icon", image) else self:AddImage(image, { Id = "Icon" }) end
	return self
end

function ContextUI.AddStat(self: Internal, label: string, value: string | number, options: Types.StatConfig?): Internal
	local data = component(self, "Stat", label, options, label)
	data.Value, data.Color = tostring(value), if options then options.Color else nil
	return add(self, data)
end

function ContextUI.SetStat(self: Internal, id: string, value: string | number): Internal
	get(self, id, "Stat").Value = tostring(value)
	layout(self)
	return self
end

function ContextUI.AddProgress(self: Internal, label: string, value: number, options: Types.ComponentConfig?): Internal
	assert(value == value, "ContextUI: progress cannot be NaN")
	local data = component(self, "Progress", label, options, label)
	data.Progress = math.clamp(value, 0, 1)
	return add(self, data)
end

function ContextUI.SetProgress(self: Internal, id: string, value: number): Internal
	assert(value == value, "ContextUI: progress cannot be NaN")
	get(self, id, "Progress").Progress = math.clamp(value, 0, 1)
	layout(self)
	return self
end

function ContextUI.AddDivider(self: Internal, options: Types.ComponentConfig?): Internal
	return add(self, component(self, "Divider", "", options))
end

function ContextUI.AddSection(self: Internal, text: string, options: Types.ComponentConfig?): Internal
	return add(self, component(self, "Section", text, options))
end

function ContextUI.AddKeybind(self: Internal, text: string, key: Enum.KeyCode, options: Types.ComponentConfig?): Internal
	local data = component(self, "Keybind", text, options)
	data.KeyCode = key
	return add(self, data)
end

function ContextUI.AddButton(self: Internal, text: string, callback: (Types.Context) -> (), options: Types.ButtonConfig?): Internal
	local data = component(self, "Button", text, options)
	data.Callback, data.Interactive = callback, true
	data.Disabled = options ~= nil and options.Disabled == true
	data.KeyCode = if options then options.KeyCode else nil
	return add(self, data)
end

function ContextUI.AddButtonGroup(self: Internal, buttons: {Types.ButtonSpec}, options: Types.ComponentConfig?): Internal
	assert(#buttons > 0, "ContextUI: button group must contain at least one button")
	local data = component(self, "ButtonGroup", "", options)
	local copy: {Types.ButtonSpec} = {}
	for _, button in buttons do table.insert(copy, table.clone(button)) end
	data.Buttons, data.Interactive = copy, true
	return add(self, data)
end

function ContextUI.AddCustom(self: Internal, gui: GuiObject, options: Types.CustomConfig?): Internal
	local data = component(self, "Custom", "", options)
	data.Gui = gui
	data.CustomSize = if options then options.Size else nil
	local interactive = gui:IsA("GuiButton") or gui:IsA("TextBox")
	for _, descendant in gui:GetDescendants() do
		if descendant:IsA("GuiButton") or descendant:IsA("TextBox") then interactive = true; break end
	end
	data.Interactive = if options and options.Interactive ~= nil then options.Interactive else interactive
	return add(self, data)
end

function ContextUI.SetText(self: Internal, id: string, text: string): Internal
	get(self, id).Text = text
	layout(self)
	return self
end

function ContextUI.SetImage(self: Internal, id: string, image: string): Internal
	get(self, id, "Image").Image = image
	layout(self)
	return self
end

function ContextUI.SetButtonEnabled(self: Internal, id: string, enabled: boolean): Internal
	local data = get(self, id)
	assert(data.Kind == "Button" or data.Kind == "ButtonGroup", "ContextUI: expected a button or button group")
	data.Disabled = not enabled
	layout(self)
	return self
end

function ContextUI.Remove(self: Internal, id: string): Internal
	alive(self)
	if not self._components[id] then return self end
	if self._renderer then self._renderer:Remove(id) end
	self._components[id] = nil
	local index = table.find(self._order, id)
	if index then table.remove(self._order, index) end
	updateInteractive(self)
	return self
end

function ContextUI.Clear(self: Internal): Internal
	alive(self)
	while #self._order > 0 do self:Remove(self._order[#self._order]) end
	return self
end

function ContextUI.SetExpandable(self: Internal, enabled: boolean, label: string?): Internal
	alive(self)
	if not enabled then self:Remove("__Expansion"); self:Collapse(); return self end
	if self._components.__Expansion then return self end
	local more = label or "More"
	self:AddButton(if self._expanded then "Less" else more, function() self:ToggleExpanded() end, { Id = "__Expansion" })
	get(self, "__Expansion").Value = more
	return self
end

function ContextUI.Expand(self: Internal): Internal
	alive(self)
	if self._expanded then return self end
	self._expanded = true
	if self._components.__Expansion then self._components.__Expansion.Text = "Less" end
	if self._renderer then self._renderer.Expanded = true end
	layout(self)
	self.ExpandedChanged:Fire(true)
	return self
end

function ContextUI.Collapse(self: Internal): Internal
	alive(self)
	if not self._expanded then return self end
	self._expanded = false
	if self._components.__Expansion then self._components.__Expansion.Text = self._components.__Expansion.Value end
	if self._renderer then self._renderer.Expanded = false end
	layout(self)
	self.ExpandedChanged:Fire(false)
	return self
end

function ContextUI.ToggleExpanded(self: Internal): Internal
	return if self._expanded then self:Collapse() else self:Expand()
end

function ContextUI.IsExpanded(self: Internal): boolean return self._expanded end

function ContextUI.SetInteractive(self: Internal, interactive: boolean?): Internal
	alive(self)
	self._config.Interactive = interactive
	updateInteractive(self)
	return self
end

function ContextUI.IsInteractive(self: Internal): boolean return self._controller.Interactive end

function ContextUI.SetTheme(self: Internal, theme: Types.ThemeName | Types.ThemeOverrides, overrides: Types.ThemeOverrides?): Internal
	alive(self)
	self._theme = Config.theme(theme, self._theme, overrides)
	if self._renderer then self._renderer:SetTheme(self._theme) end
	return self
end

function ContextUI.SetTarget(self: Internal, target: Types.Target?): Internal
	alive(self)
	if target then assert(target:IsA("GuiObject") or target:IsA("BasePart") or target:IsA("Model") or target:IsA("Attachment"), "ContextUI: unsupported target") end
	local bound = self._unbind ~= nil
	self:Unbind()
	self._target, self._manual = target, target == nil
	watchTarget(self)
	if bound and target then self:Bind() end
	return self
end

function ContextUI.Bind(self: Internal): Internal
	alive(self)
	if self._unbind then return self end
	local target = self._target
	if target then self._unbind = Manager.bind(target, self._handle) end
	return self
end

function ContextUI.Unbind(self: Internal): Internal
	if self._unbind then self._unbind(); self._unbind = nil end
	if not self._destroyed then self:Hide() end
	return self
end

function ContextUI.Show(self: Internal, position: Vector2?): Internal
	alive(self)
	if self._controller.State == "Pinned" then return self end
	local renderer = ensureRenderer(self)
	local pointer = position or Manager.pointer()
	local minimum, maximum = Manager.bounds(self._config.EdgePadding)
	renderer:SetLimit(Vector2.new(math.max(1, maximum.X - minimum.X), math.max(1, maximum.Y - minimum.Y)))
	self._position = Positioner.place(pointer, renderer.Size, self._config.Offset, minimum, maximum)
	renderer.Surface.Position = UDim2.fromOffset(self._position.X, self._position.Y)
	self._controller:Show(pointer, self._manual)
	Manager.activate(self._handle)
	renderer:Show()
	updateInteractive(self)
	emitState(self)
	return self
end

function ContextUI.Hide(self: Internal): Internal
	if self._destroyed then return self end
	local renderer = self._renderer
	if renderer then
		local selected = GuiService.SelectedObject
		if selected and selected:IsDescendantOf(renderer.Surface) then
			local previous = self._previousSelection
			GuiService.SelectedObject = if previous and previous.Parent then previous else nil
		end
		renderer:Hide()
	end
	self._controller:Hide()
	Manager.deactivate(self._handle)
	emitState(self)
	return self
end

function ContextUI.Pin(self: Internal): Internal
	alive(self)
	if self._controller.State == "Hidden" then self:Show() end
	self._controller:Pin()
	updateInteractive(self)
	emitState(self)
	return self
end

function ContextUI.Unpin(self: Internal): Internal
	alive(self)
	self._controller:Unpin(os.clock())
	updateInteractive(self)
	emitState(self)
	return self
end

function ContextUI.GetState(self: Internal): Types.State return self._controller.State end

function ContextUI.GetSurface(self: Internal): CanvasGroup?
	return if self._renderer then self._renderer.Surface else nil
end

function ContextUI.Use(self: Internal, extension: Types.Extension): Internal
	alive(self)
	assert(not self._extensions[extension.Name], "ContextUI: extension already installed: " .. extension.Name)
	local cleanup = extension.Install((self :: unknown) :: Types.Context)
	self._extensions[extension.Name] = true
	if cleanup then self._cleanup:Add(cleanup) end
	return self
end

function ContextUI.Destroy(self: Internal)
	if self._destroyed then return end
	self._destroyed = true
	local _surface = if self._renderer then self._renderer.Surface else nil
	local _selected = GuiService.SelectedObject
	if _surface and _selected and _selected:IsDescendantOf(_surface) then GuiService.SelectedObject = nil end
	if self._unbind then self._unbind(); self._unbind = nil end
	Manager.deactivate(self._handle)
	self._controller.State = "Destroyed"
	emitState(self)
	for worker in self._tasks do
		if worker ~= coroutine.running() and coroutine.status(worker) ~= "dead" then pcall(task.cancel, worker) end
	end
	table.clear(self._tasks)
	self._targetCleanup:Destroy()
	self._cleanup:Destroy()
	if self._renderer then self._renderer:Destroy(); self._renderer = nil end
	self.StateChanged:Destroy()
	self.ExpandedChanged:Destroy()
	table.clear(self._components)
	table.clear(self._order)
	table.clear(self._extensions)
	Manager.release()
end

return ContextUI
