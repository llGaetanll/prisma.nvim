local convert = require("prisma.util.convert")
local array = require("prisma.util.array")

local M = {}

-- For a small circle B with center b = (x, y) and radius r_b. Returns all
-- intersection points with ray cast from the origin at an angle theta.
local coord = function(theta, b, r_b)
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
local line_point = function(hsv_bias, v)
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
local hsv_corrected = function(hsv)
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

function M.gen_hues(hsv_bias, n, m, vr)
	local hues = {}

	local thetas = array.linspace(0, 2 * math.pi, n + 1)
	thetas = { table.unpack(array, 1, #array - 1) } -- keep all but last value

	local lo = vr[1]
	local hi = vr[2]
	local vs = array.linspace(lo, hi, m)

	hsv_bias = hsv_corrected(hsv_bias)

	local ps = {}
	for i, v in ipairs(vs) do
		local p = line_point(hsv_bias, v)
		local x = p[1]
		local y = p[2]
		local z = p[3]

		-- all the hues at value v
		local v_hues = {}

		-- the radius of the cone
		-- equal to the height of the point
		local r_c = z

		-- bounds on the radius
		local min_r = math.sqrt(x ^ 2 + y ^ 2)
		local max_r = r_c - min_r

		-- we define the radius of the circle
		-- at that height to be halfway between
		-- the min and max
		-- TODO: make this a parameter
		local r = (min_r + max_r) / 2

		for j, t in ipairs(thetas) do
			local co = coord(t, { x, y }, r)
			local x_d = co[1]
			local y_d = co[2]

			local hex = convert.xyz_to_hex({ x_d, y_d, z })
			table.insert(v_hues, hex)
		end

		table.insert(hues, v_hues)
	end

	return hues
end

function M.gen_shades(hsv_bias, m, vr_lo, vr_hi)
	local shades = {}

	local lo = vr_lo[1]
	local hi = vr_lo[2]
	local vs_lo = array.linspace(lo, hi, m)

	local darks = {}
	for i, v in ipairs(vs_lo) do
		local p = line_point(hsv_bias, v)
		local dark = convert.xyz_to_hex(p)
		table.insert(darks, dark)
	end

	local lo = vr_hi[1]
	local hi = vr_hi[2]
	local vs_hi = array.linspace(lo, hi, m)

	local lights = {}
	for i, v in ipairs(vs_hi) do
		local p = line_point(hsv_bias, v)
		local light = convert.xyz_to_hex(p)
		table.insert(lights, light)
	end

	return { darks, lights }
end

return M
