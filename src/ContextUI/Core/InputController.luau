--!strict
local InputController = {}
InputController.__index = InputController

--------------------------------------------------------------------------------
-- Imports & Packages
--------------------------------------------------------------------------------
local Types = require(script.Parent.Parent.Types)
local Positioner = require(script.Parent.Positioner)

--------------------------------------------------------------------------------
-- Types & Constants
--------------------------------------------------------------------------------
type Fields = {
	State: Types.State, TargetInside: boolean, SurfaceInside: boolean, Interactive: boolean,
	Config: Types.ResolvedConfig, Previous: Vector2?, Origin: Vector2?,
	Deadline: number?, GraceDeadline: number?, Approach: number,
}
export type Controller = typeof(setmetatable({} :: Fields, InputController))

--------------------------------------------------------------------------------
-- Constructor
--------------------------------------------------------------------------------
function InputController.new(config: Types.ResolvedConfig): Controller
	return setmetatable({
		State = "Hidden", TargetInside = false, SurfaceInside = false, Interactive = false,
		Config = config, Previous = nil, Origin = nil, Deadline = nil, GraceDeadline = nil, Approach = 0,
	} :: Fields, InputController)
end

--------------------------------------------------------------------------------
-- Public Methods
--------------------------------------------------------------------------------
function InputController.Show(self: Controller, pointer: Vector2, docked: boolean?)
	if self.State == "Pinned" then return end
	self.State = if docked then "Docked" else "Following"
	self.Previous = pointer
	self.Deadline, self.GraceDeadline, self.Origin = nil, nil, nil
	self.Approach = 0
end

function InputController.Hide(self: Controller)
	self.State = "Hidden"
	self.TargetInside, self.SurfaceInside = false, false
	self.Deadline, self.GraceDeadline, self.Origin, self.Previous = nil, nil, nil, nil
end

function InputController.Enter(self: Controller)
	self.TargetInside = true
	self.Deadline, self.GraceDeadline = nil, nil
end

function InputController.Leave(self: Controller, pointer: Vector2, now: number)
	self.TargetInside = false
	self.Origin = pointer
	self.Deadline = now + self.Config.CloseDelay
	self.GraceDeadline = now + self.Config.TransitionGrace
	if self.Interactive and self.State == "Following" then self.State = "Docked" end
end

function InputController.Pin(self: Controller)
	self.State = "Pinned"
	self.Deadline, self.GraceDeadline = nil, nil
end

function InputController.Unpin(self: Controller, now: number)
	if self.State ~= "Pinned" then return end
	self.State = if self.Interactive then "Docked" else "Following"
	if not self.TargetInside and not self.SurfaceInside then self.Deadline = now + self.Config.CloseDelay end
end

function InputController.Step(self: Controller, pointer: Vector2, position: Vector2, size: Vector2, now: number): boolean
	if self.State == "Hidden" or self.State == "Destroyed" then return false end
	local wasInside = self.SurfaceInside
	self.SurfaceInside = (self.Interactive or self.State == "Pinned") and Positioner.inside(pointer, position, size)
	if self.State == "Pinned" then self.Previous = pointer; return false end
	if self.State == "Following" and self.Interactive and self.Previous then
		local improvement = Positioner.distance(self.Previous, position, size) - Positioner.distance(pointer, position, size)
		self.Approach = if improvement > 0 then self.Approach + improvement else 0
		if self.SurfaceInside or self.Approach >= self.Config.DockThreshold then self.State = "Docked" end
	end
	if self.SurfaceInside or self.TargetInside then
		self.Deadline = nil
	elseif wasInside then
		self.Deadline = now + self.Config.CloseDelay
		self.GraceDeadline = nil
	end
	self.Previous = pointer
	if self.Deadline and now >= self.Deadline then
		local safe = self.Interactive and self.Origin and self.GraceDeadline and now < self.GraceDeadline
			and Positioner.safe(pointer, self.Origin, position, size, self.Config.SafePadding)
		return not safe
	end
	return false
end

return InputController
