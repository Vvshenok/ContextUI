--!strict
local Animator = {}
Animator.__index = Animator

--------------------------------------------------------------------------------
-- Services
--------------------------------------------------------------------------------
local TweenService = game:GetService("TweenService")

--------------------------------------------------------------------------------
-- Types & Constants
--------------------------------------------------------------------------------
type Record = { Tween: Tween, Connection: RBXScriptConnection? }
type Fields = { _active: {[string]: Record}, _destroyed: boolean }
export type Animator = typeof(setmetatable({} :: Fields, Animator))

--------------------------------------------------------------------------------
-- Constructor
--------------------------------------------------------------------------------
function Animator.new(): Animator
	return setmetatable({ _active = {}, _destroyed = false }, Animator)
end

--------------------------------------------------------------------------------
-- Public Methods
--------------------------------------------------------------------------------
function Animator.Cancel(self: Animator, key: string)
	local record = self._active[key]
	if not record then return end
	self._active[key] = nil
	if record.Connection then record.Connection:Disconnect() end
	record.Tween:Cancel()
	record.Tween:Destroy()
end

function Animator.Play(self: Animator, key: string, object: Instance, duration: number, properties: {[string]: unknown}, completed: (() -> ())?)
	self:Cancel(key)
	if self._destroyed then return end
	if duration <= 0 then
		local writable = (object :: unknown) :: {[string]: unknown}
		for name, value in properties do writable[name] = value end
		if completed then completed() end
		return
	end
	local tween = TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties)
	local record: Record = { Tween = tween, Connection = nil }
	self._active[key] = record
	record.Connection = tween.Completed:Connect(function(state)
		if self._active[key] ~= record then return end
		self._active[key] = nil
		if record.Connection then record.Connection:Disconnect() end
		tween:Destroy()
		if state == Enum.PlaybackState.Completed and completed then completed() end
	end)
	tween:Play()
end

function Animator.Destroy(self: Animator)
	self._destroyed = true
	for key in self._active do self:Cancel(key) end
end

return Animator
