local util = require("prisma.algos.conic-circular.util")
local convert = require("prisma.util.convert")
local array = require("prisma.util.array")
local fmt = require("prisma.util.fmt")

local M = {}

---
-- Generates a colorscheme with specified parameters.
--
-- @param hsv_bias (table) The bias color of the colorscheme represented
-- as a table with three entries:
--    - `hue` (number): The hue component of the color [0-1).
--    - `saturation` (number): The saturation component of the color [0-1].
--    - `value` (number): The value component of the color [0-1].
-- @param n (number) The number of distinct hues to generate.
-- @param value (number) The value to generate the hues at
-- @param b (number) The angular bias. Defaults to 0
-- @return (table) An array where each value is a list of hues for a
-- value `v` in hex color codes.
--
function M.gen_hues(hsv_bias, n, value, b)
	local hues = {}

	local tau = 2 * math.pi
	local thetas = array.linspace(0 + tau * b, tau * (1 + b), n + 1)

	table.remove(thetas, #thetas) -- keep all but last value

	-- retain all values in [0, 2 * pi)
	for i, v in ipairs(thetas) do
		thetas[i] = v % tau
	end

	hsv_bias = util.hsv_corrected(hsv_bias)

	local p = util.line_point(hsv_bias, value)
	local x = p[1]
	local y = p[2]
	local z = p[3]

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

	for _, t in ipairs(thetas) do
		local co = util.coord(t, { x, y }, r)
		local x_d = co[1]
		local y_d = co[2]

		local hex = convert.xyz_to_hex({ x_d, y_d, z })
		local hex_str = fmt.hex_to_str(hex)
		table.insert(hues, hex_str)
	end

	return hues
end

---
-- Generates an array of shades based on a bias color for a colorscheme.
--
-- @param hsv_bias (table) The bias color of the colorscheme represented as a table with three entries:
--                      - `hue` (number): The hue component of the color [0-1).
--                      - `saturation` (number): The saturation component of the color [0-1].
--                      - `value` (number): The value component of the color [0-1].
-- @param m (number) The number of shades to generate.
-- @param vr_lo (number) The lightness range of the dark values.
-- @param vr_hi (number) The lightness range of the light values.
--
-- Note: `hsv_bias` is left uncorrected here.
--
-- @return (table) An array where each value is a shade of `hsv_bias` in hex color codes.
--
function M.gen_shades(hsv_bias, m, vr_lo, vr_hi)
	local lo = vr_lo[1]
	local hi = vr_lo[2]
	local vs_lo = array.linspace(lo, hi, m)

	local darks = {}
	for _, v in ipairs(vs_lo) do
		local p = util.line_point(hsv_bias, v)
		local dark = convert.xyz_to_hex(p)
		local dark_str = fmt.hex_to_str(dark)

		local hsv = convert.xyz_to_hsv(p)
		local rgb = convert.hsv_to_rgb(hsv)
		local hex = convert.rgb_to_hex(rgb)

		-- local tbl = {
		-- 	xyz = fmt.xyz_to_str(p),
		-- 	hsv = fmt.hsv_to_str(hsv),
		-- 	rgb = fmt.rgb_to_str(rgb),
		-- 	hex = fmt.hex_to_str(hex),
		-- }

		table.insert(darks, dark_str)
	end

	local lo = vr_hi[1]
	local hi = vr_hi[2]
	local vs_hi = array.linspace(lo, hi, m)

	local lights = {}
	for _, v in ipairs(vs_hi) do
		local p = util.line_point(hsv_bias, v)
		local light = convert.xyz_to_hex(p)
		local light_str = fmt.hex_to_str(light)
		table.insert(lights, light_str)
	end

	return { darks, lights }
end

function M.gen_colors(params)
	local bias = params.bias
	local hue_value = params.hue_value
	local angular_bias = params.angular_bias
	local hue_rot = params.hue_rot
	local dark_range = params.dark_range
	local light_range = params.light_range

	local hex = fmt.str_to_hex(bias)
	local hsv_bias = convert.hex_to_hsv(hex)

	local n = 7 -- number of distinct hues to generate
	local m_shades = 7 -- number of shades to generate

	-- generate from darkest first to lightest last
	local vr_lo = { dark_range[1], dark_range[2] }

	-- we reverse it here because we want to generate lightest (first) to darkest (last)
	local vr_hi = { light_range[2], light_range[1] }

	local hues = M.gen_hues(hsv_bias, n, hue_value, angular_bias)
	hues = array.rotate(hues, hue_rot)

	local shades = M.gen_shades(hsv_bias, m_shades, vr_lo, vr_hi)
	local darks = shades[1]
	local lights = shades[2]

	return {
		lights = lights,
		darks = darks,
		hues = hues,
	}
end

return M
