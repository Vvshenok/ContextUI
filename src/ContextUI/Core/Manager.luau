--!strict
local Manager = {}

--------------------------------------------------------------------------------
-- Services
--------------------------------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

--------------------------------------------------------------------------------
-- Imports & Packages
--------------------------------------------------------------------------------
local Types = require(script.Parent.Parent.Types)
local Janitor = require(script.Parent.Parent.Packages.Janitor)
local Positioner = require(script.Parent.Positioner)

--------------------------------------------------------------------------------
-- Types & Constants
--------------------------------------------------------------------------------
export type Handle = {
	WorldRayLength: number,
	Enter: (Vector2, boolean?) -> (), Leave: (Vector2) -> (), Step: (number, Vector2) -> (),
	Hide: () -> (), IsPinned: () -> boolean, Surface: () -> CanvasGroup?,
	Key: (Enum.KeyCode) -> boolean,
}

local roots: {[number]: ScreenGui} = {}
local active: {[Handle]: boolean} = {}
local guiTargets: {[Instance]: Handle?} = {}
local worldTargets: {[Instance]: Handle?} = {}
local inputCleanup = Janitor.new()
local worldCleanup = Janitor.new()
local renderConnection: RBXScriptConnection? = nil
local inputConnected, worldConnected = false, false
local references, bindings, worldBindings = 0, 0, 0
local focused: Handle? = nil
local hoveredWorld: Handle? = nil
local selectedHandle: Handle? = nil
local lastTouch: Vector2? = nil

--------------------------------------------------------------------------------
-- Private Functions
--------------------------------------------------------------------------------
local function findHandle(target: Instance?, registry: {[Instance]: Handle?}): Handle?
	local current = target
	while current do
		if registry[current] then return registry[current] end
		current = current.Parent
	end
	return nil
end

local function insideSurface(handle: Handle, pointer: Vector2): boolean
	local surface = handle.Surface()
	return surface ~= nil and surface.Visible and Positioner.inside(pointer, Manager.screenPosition(surface), surface.AbsoluteSize)
end

local function refreshWorld()
	if not worldConnected then return end
	local player = Players.LocalPlayer
	if not player then return end
	local pointer = Manager.pointer()
	for handle in active do
		if insideSurface(handle, pointer) then return end
	end
	local nextHandle = findHandle(player:GetMouse().Target, worldTargets)
	if nextHandle == hoveredWorld then return end
	local previous = hoveredWorld
	hoveredWorld = nextHandle
	if previous then previous.Leave(pointer) end
	if nextHandle then nextHandle.Enter(pointer, false) end
end

local function _surfaceAt(_pointer: Vector2): Handle?
	local _player = Players.LocalPlayer
	local _playerGui = if _player then _player:FindFirstChildOfClass("PlayerGui") else nil
	if not _playerGui then return nil end
	local _inset = GuiService:GetGuiInset()
	local _position = _pointer - _inset
	local _objects = _playerGui:GetGuiObjectsAtPosition(_position.X, _position.Y)
	local _top = _objects[1]
	if not _top then return nil end
	for _handle in active do
		local _surface = _handle.Surface()
		if _surface and (_top == _surface or _top:IsDescendantOf(_surface)) then return _handle end
	end
	return nil
end

local function syncInput()
	local needed = bindings > 0 or next(active) ~= nil
	if needed and not inputConnected then
		inputConnected = true
		local changed = UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then lastTouch = nil end
		end)
		inputCleanup:Add(function() changed:Disconnect() end)
		local began = UserInputService.InputBegan:Connect(function(input, processed)
			if input.UserInputType == Enum.UserInputType.Touch then lastTouch = Vector2.new(input.Position.X, input.Position.Y) end
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				local _pointer = Manager.pointer()
				local _hit = _surfaceAt(_pointer)
				if _hit then focused = _hit end
				for _handle in active do
					if _handle ~= _hit and not _handle.IsPinned() then _handle.Leave(_pointer) end
				end
			end
			if processed or UserInputService:GetFocusedTextBox() then return end
			if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB then
				if focused then focused.Hide() end
				return
			end
			if focused and focused.Key(input.KeyCode) then return end
		end)
		inputCleanup:Add(function() began:Disconnect() end)
		local selection = GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
			local selected = GuiService.SelectedObject
			if selected then
				for handle in active do
					local surface = handle.Surface()
					if surface and selected:IsDescendantOf(surface) then focused = handle; return end
				end
			end
			local nextHandle = findHandle(selected, guiTargets)
			if selectedHandle == nextHandle then return end
			if selectedHandle then selectedHandle.Leave(Manager.pointer()) end
			selectedHandle = nextHandle
			if nextHandle and selected then nextHandle.Enter(Manager.screenPosition(selected) + selected.AbsoluteSize / 2, true) end
		end)
		inputCleanup:Add(function() selection:Disconnect() end)
	elseif not needed and inputConnected then
		inputConnected = false
		inputCleanup:Clean()
		selectedHandle, lastTouch = nil, nil
	end
	if next(active) and not renderConnection then
		renderConnection = RunService.RenderStepped:Connect(function(dt)
			local pointer = Manager.pointer()
			for handle in active do handle.Step(dt, pointer) end
		end)
	elseif not next(active) and renderConnection then
		renderConnection:Disconnect()
		renderConnection = nil
	end
end

local function syncWorld()
	if worldBindings > 0 and not worldConnected then
		worldConnected = true
		local player = Players.LocalPlayer
		assert(player, "ContextUI requires LocalPlayer")
		local movement = player:GetMouse().Move:Connect(refreshWorld)
		worldCleanup:Add(function() movement:Disconnect() end)
		local cameraConnection: RBXScriptConnection? = nil
		local function connectCamera()
			if cameraConnection then cameraConnection:Disconnect() end
			local camera = workspace.CurrentCamera
			if camera then cameraConnection = camera:GetPropertyChangedSignal("CFrame"):Connect(refreshWorld) end
			refreshWorld()
		end
		local cameraChanged = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(connectCamera)
		worldCleanup:Add(function() cameraChanged:Disconnect(); if cameraConnection then cameraConnection:Disconnect() end end)
		connectCamera()
		local touch = UserInputService.TouchTapInWorld:Connect(function(position: Vector2, processed: boolean)
			if processed or not position then return end
			local camera = workspace.CurrentCamera
			if not camera then return end
			lastTouch = position
			local ray = camera:ViewportPointToRay(position.X, position.Y)
			local parameters = RaycastParams.new()
			parameters.FilterType = Enum.RaycastFilterType.Exclude
			parameters.FilterDescendantsInstances = if player.Character then { player.Character } else {}
			local distance = 0
			for _, entry in worldTargets do if entry then distance = math.max(distance, entry.WorldRayLength) end end
			local hit = workspace:Raycast(ray.Origin, ray.Direction * distance, parameters)
			local handle = if hit then findHandle(hit.Instance, worldTargets) else nil
			if handle and hit and hit.Distance <= handle.WorldRayLength then handle.Enter(position, true) end
		end)
		worldCleanup:Add(function() touch:Disconnect() end)
	elseif worldBindings == 0 and worldConnected then
		worldConnected = false
		worldCleanup:Clean()
		hoveredWorld = nil
	end
end

--------------------------------------------------------------------------------
-- Public Methods
--------------------------------------------------------------------------------
function Manager.screenPosition(_object: GuiObject): Vector2
	local _inset = GuiService:GetGuiInset()
	return _object.AbsolutePosition + _inset
end

function Manager.pointer(): Vector2
	return lastTouch or UserInputService:GetMouseLocation()
end

function Manager.bounds(padding: number): (Vector2, Vector2)
	local camera = workspace.CurrentCamera
	local viewport = if camera then camera.ViewportSize else Vector2.new(800, 600)
	local topLeft, bottomRight = GuiService:GetGuiInset()
	local extra = Vector2.new(padding, padding)
	return topLeft + extra, viewport - bottomRight - extra
end

function Manager.root(displayOrder: number): ScreenGui
	local existing = roots[displayOrder]
	if existing and existing.Parent then return existing end
	local player = Players.LocalPlayer
	assert(player, "ContextUI must be created from a LocalScript")
	local root = Instance.new("ScreenGui")
	root.Name = "ContextUI_" .. tostring(displayOrder)
	root.ResetOnSpawn = false
	root.IgnoreGuiInset = true
	root.ScreenInsets = Enum.ScreenInsets.None
	root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	root.DisplayOrder = displayOrder
	root.Parent = player:WaitForChild("PlayerGui")
	roots[displayOrder] = root
	return root
end

function Manager.retain()
	references += 1
end

function Manager.release()
	references -= 1
	if references > 0 then return end
	for _, root in roots do root:Destroy() end
	table.clear(roots)
end

function Manager.activate(handle: Handle)
	for other in active do
		if other ~= handle and not other.IsPinned() then other.Hide() end
	end
	active[handle] = true
	focused = handle
	syncInput()
end

function Manager.deactivate(handle: Handle)
	active[handle] = nil
	if focused == handle then focused = next(active) end
	syncInput()
end

function Manager.bind(target: Types.Target, handle: Handle): () -> ()
	local cleanup = Janitor.new()
	local key: Instance = target
	local isGui = target:IsA("GuiObject")
	if target:IsA("Attachment") then
		local part = target:FindFirstAncestorWhichIsA("BasePart")
		assert(part, "ContextUI: an Attachment must belong to a BasePart")
		key = part
	end
	local registry = if isGui then guiTargets else worldTargets
	assert(not registry[key], "ContextUI: this target already has a bound context")
	registry[key] = handle
	bindings += 1
	if isGui then
		local gui = target :: GuiObject
		local enter = gui.MouseEnter:Connect(function() handle.Enter(UserInputService:GetMouseLocation(), false) end)
		local leave = gui.MouseLeave:Connect(function() handle.Leave(Manager.pointer()) end)
		local touch = gui.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch then
				local position = Vector2.new(input.Position.X, input.Position.Y)
				lastTouch = position
				handle.Enter(position, true)
			end
		end)
		cleanup:Add(function() enter:Disconnect(); leave:Disconnect(); touch:Disconnect() end)
	else
		worldBindings += 1
	end
	syncInput()
	syncWorld()
	local disconnected = false
	return function()
		if disconnected then return end
		disconnected = true
		cleanup:Destroy()
		registry[key] = nil
		bindings -= 1
		if not isGui then worldBindings -= 1 end
		if hoveredWorld == handle then hoveredWorld = nil end
		if selectedHandle == handle then selectedHandle = nil end
		syncWorld()
		syncInput()
	end
end

function Manager.diagnostics(): { Contexts: number, Bound: number, Visible: number, RenderConnections: number, WorldBindings: number }
	local visible = 0
	for _ in active do visible += 1 end
	return { Contexts = references, Bound = bindings, Visible = visible, RenderConnections = if renderConnection then 1 else 0, WorldBindings = worldBindings }
end

return Manager
