local M = {}

-- DOMAINS
--
-- R, G, B \in [0, 1]
--
-- H, S, V \in [0, 1]
--
-- X, Y, Z \in [0, 1]
-- assumed to be hsv space
--
-- hex is a number

-- used to avoid floating point errors
local EPSILON = 1e-10

function M.hex_to_rgb(hex)
	local b = hex % 0x100
	local g = math.floor(hex / 0x100) % 0x100
	local r = math.floor(hex / 0x10000)

	-- normalize
	r = r / 0xff
	g = g / 0xff
	b = b / 0xff

	return { r, g, b }
end

function M.hex_to_hsv(hex)
	local rgb = M.hex_to_rgb(hex)
	return M.rgb_to_hsv(rgb)
end

function M.hex_to_xyz(hex)
	local hsv = M.hex_to_hsv(hex)
	return M.hsv_to_xyz(hsv)
end

function M.rgb_to_hex(rgb)
	local r = rgb[1] * 0xff -- [0, 255]
	local g = rgb[2] * 0xff
	local b = rgb[3] * 0xff

	return r * 0x10000 + g * 0x100 + b
end

function M.rgb_to_xyz(rgb)
	local hsv = M.rgb_to_hsv(rgb)
	return M.hsv_to_xyz(hsv)
end

function M.rgb_to_hsv(rgb)
	local r = rgb[1] -- [0, 1]
	local g = rgb[2]
	local b = rgb[3]

	local x_min = math.min(r, g, b)
	local x_max = math.max(r, g, b)
	local c = x_max - x_min

	local v = x_max

	local h_ = 0
	if math.abs(c) < EPSILON then
		h_ = 0
	elseif v == r then
		h_ = ((g - b) / c) % 6
	elseif v == g then
		h_ = ((b - r) / c) + 2
	else
		h_ = ((r - g) / c) + 4
	end

	-- h \in [0, 1]
	local h = h_ / 6

	local s = 0
	if v > EPSILON then
		s = c / v
	end

	return { h, s, v }
end

function M.xyz_to_rgb(xyz)
	local hsv = M.xyz_to_hsv(xyz)
	return M.hsv_to_rgb(hsv)
end

function M.xyz_to_hex(xyz)
	local hsv = M.xyz_to_hsv(xyz)
	return M.hsv_to_hex(hsv)
end

function M.xyz_to_hsv(xyz)
	local x = xyz[1] -- [0, 1]
	local y = xyz[2]
	local z = xyz[3]

	local v = z

	local s = 0
	if math.abs(z) > EPSILON then
		s = math.min(math.sqrt(x ^ 2 + y ^ 2) / z, 1)
	end

	-- bounds a value in [-1, 1]
	-- used to avoid floating point errors
	local bd = function(x)
		return math.max(math.min(x, 1), -1)
	end

	local h = 0
	if math.abs(s) >= EPSILON then
		local ac = math.acos(bd(x / (z * s))) / (2 * math.pi)
		if y > 0 then
			h = ac
		else
			h = 1 - ac
		end
	end

	return { h, s, v }
end

function M.hsv_to_rgb(hsv)
	local h = hsv[1] -- [0, 1)
	local s = hsv[2] -- [0, 1]
	local v = hsv[3] -- [0, 1]

	local c = v * s
	local h_ = h * 6
	local x = c * (1 - math.abs((h_ % 2) - 1))

	local r = 0
	local g = 0
	local b = 0

	if h_ < 1 then
		r = c
		g = x
		b = 0
	elseif h_ < 2 then
		r = x
		g = c
		b = 0
	elseif h_ < 3 then
		r = 0
		g = c
		b = x
	elseif h_ < 4 then
		r = 0
		g = x
		b = c
	elseif h_ < 5 then
		r = x
		g = 0
		b = c
	else
		r = c
		g = 0
		b = x
	end

	local m = v - c
	r = r + m
	g = g + m
	b = b + m

	return { r, g, b }
end

function M.hsv_to_hex(hsv)
	local rgb = M.hsv_to_rgb(hsv)
	return M.rgb_to_hex(rgb)
end

function M.hsv_to_xyz(hsv)
	local h = hsv[1] -- [0, 1)
	local s = hsv[2] -- [0, 1]
	local v = hsv[3] -- [0, 1]

	local x = s * v * math.cos(2 * math.pi * h)
	local y = s * v * math.sin(2 * math.pi * h)
	local z = v

	return { x, y, z }
end

return M
