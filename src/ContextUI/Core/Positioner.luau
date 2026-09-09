--!strict
local Positioner = {}

--------------------------------------------------------------------------------
-- Private Functions
--------------------------------------------------------------------------------
local function cross(a: Vector2, b: Vector2): number
	return a.X * b.Y - a.Y * b.X
end

--------------------------------------------------------------------------------
-- Public Methods
--------------------------------------------------------------------------------
function Positioner.inside(point: Vector2, position: Vector2, size: Vector2, padding: number?): boolean
	local extra = padding or 0
	return point.X >= position.X - extra and point.Y >= position.Y - extra
		and point.X <= position.X + size.X + extra and point.Y <= position.Y + size.Y + extra
end

function Positioner.clamp(position: Vector2, size: Vector2, minimum: Vector2, maximum: Vector2): Vector2
	return Vector2.new(
		math.clamp(position.X, minimum.X, math.max(minimum.X, maximum.X - size.X)),
		math.clamp(position.Y, minimum.Y, math.max(minimum.Y, maximum.Y - size.Y))
	)
end

function Positioner.place(pointer: Vector2, size: Vector2, offset: Vector2, minimum: Vector2, maximum: Vector2): Vector2
	local x, y = pointer.X + offset.X, pointer.Y + offset.Y
	if x + size.X > maximum.X then x = pointer.X - size.X - math.abs(offset.X) end
	if y + size.Y > maximum.Y then y = pointer.Y - size.Y - math.abs(offset.Y) end
	return Positioner.clamp(Vector2.new(x, y), size, minimum, maximum)
end

function Positioner.distance(point: Vector2, position: Vector2, size: Vector2): number
	local nearest = Vector2.new(math.clamp(point.X, position.X, position.X + size.X), math.clamp(point.Y, position.Y, position.Y + size.Y))
	return (nearest - point).Magnitude
end

function Positioner.safe(point: Vector2, origin: Vector2, position: Vector2, size: Vector2, padding: number): boolean
	if Positioner.inside(point, position, size, padding) then return true end
	local center = position + size / 2
	local delta = center - origin
	local first: Vector2
	local second: Vector2
	if math.abs(delta.X) > math.abs(delta.Y) then
		local x = if delta.X > 0 then position.X - padding else position.X + size.X + padding
		first = Vector2.new(x, position.Y - padding)
		second = Vector2.new(x, position.Y + size.Y + padding)
	else
		local y = if delta.Y > 0 then position.Y - padding else position.Y + size.Y + padding
		first = Vector2.new(position.X - padding, y)
		second = Vector2.new(position.X + size.X + padding, y)
	end
	local area = cross(first - origin, second - origin)
	if math.abs(area) < 0.001 then return (point - origin).Magnitude <= padding end
	local a = cross(first - point, second - point) / area
	local b = cross(second - point, origin - point) / area
	local c = 1 - a - b
	return a >= 0 and b >= 0 and c >= 0
end

return Positioner
