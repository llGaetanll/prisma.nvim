local convert = require("prisma.util.convert")

local M = {}

-- For a small circle B with center b = (x, y) and radius r_b. Returns all
-- intersection points with ray cast from the origin at an angle theta.
function M.coord(theta, b, r_b)
	local x_b = b[1]
	local y_b = b[2]

	-- NOTE: due to the bounds on the circle and its center, this square root
	-- will always be positive
	local s = math.sqrt(
		-x_b ^ 2
			- y_b ^ 2
			+ 2 * r_b ^ 2
			+ (x_b ^ 2 - y_b ^ 2) * math.cos(2 * theta)
			+ 2 * x_b * y_b * math.sin(2 * theta)
	) / math.sqrt(2)

	-- NOTE: switching s to -s switches from positive colors to negative colors
	local r = x_b * math.cos(theta) + y_b * math.sin(theta) + s

	local x = r * math.cos(theta)
	local y = r * math.sin(theta)

	return { x, y }
end

-- Given an hsv_bias point, finds the line going from the bottom of the cone
-- through that point, and returns the point on the line with the value v.
function M.line_point(hsv_bias, v)
	local xyz = convert.hsv_to_xyz(hsv_bias)

	local x = xyz[1]
	local y = xyz[2]
	local z = xyz[3]

	local t = v / math.sqrt(x ^ 2 + z ^ 2)

	return { x * t, y * t, z * t }
end

-- Given an hsv color, if the point is closer to the edge of the cone than its
-- center, returns the point halfway to the center and the edge of the cone
-- with the same hue and value.
--
-- Used so that coord doesn't fail.
function M.hsv_corrected(hsv)
	local xyz = convert.hsv_to_xyz(hsv)

	local x = xyz[1]
	local y = xyz[2]
	local z = xyz[3]

	-- sqrt(x^2 + y^2) is how far the point is from
	-- the center of the cone # z is the radius of
	-- the cone at that point
	local d = 2 * math.sqrt(x ^ 2 + y ^ 2) - z

	-- if d is positive, it means that the point is
	-- closer to the outside of the cone than to
	-- its center, but the minimum possible value is 1/2
	if d >= 0 then
		-- As a heuristic, we shift it back to one fourth
		-- of the way from the edge to # the center of the cone.
		-- TODO: make this a parameter
		x = x * z / (4 * math.sqrt(2) * math.abs(x))
		y = y * z / (4 * math.sqrt(2) * math.abs(y))
	end

	return convert.xyz_to_hsv({ x, y, z })
end

return M
