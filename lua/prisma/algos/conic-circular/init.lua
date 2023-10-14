local util = require("prisma.algos.conic-circular.util")
local convert = require("prisma.util.convert")
local array = require("prisma.util.array")

local M = {}

---
-- Generates a colorscheme with specified parameters.
--
-- @param hsv_bias (table) The bias color of the colorscheme represented as a table with three entries:
--                      - `hue` (number): The hue component of the color [0-1).
--                      - `saturation` (number): The saturation component of the color [0-1].
--                      - `value` (number): The value component of the color [0-1].
-- @param n (number) The number of distinct hues to generate.
-- @param m (number) The number of shades of hues to generate.
-- @param vr (number) The lightness range of the values to generate.
--
-- @return (table) An array where each value is a list of hues for a value `v` in hex color codes.
--
function M.gen_hues(hsv_bias, n, m, vr)
	local hues = {}

	local thetas = array.linspace(0, 2 * math.pi, n + 1)
	thetas = { table.unpack(array, 1, #array - 1) } -- keep all but last value

	local lo = vr[1]
	local hi = vr[2]
	local vs = array.linspace(lo, hi, m)

	hsv_bias = util.hsv_corrected(hsv_bias)

	for _, v in ipairs(vs) do
		local p = util.line_point(hsv_bias, v)
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

		for _, t in ipairs(thetas) do
			local co = util.coord(t, { x, y }, r)
			local x_d = co[1]
			local y_d = co[2]

			local hex = convert.xyz_to_hex({ x_d, y_d, z })
			table.insert(v_hues, hex)
		end

		table.insert(hues, v_hues)
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
		table.insert(darks, dark)
	end

	local lo = vr_hi[1]
	local hi = vr_hi[2]
	local vs_hi = array.linspace(lo, hi, m)

	local lights = {}
	for _, v in ipairs(vs_hi) do
		local p = util.line_point(hsv_bias, v)
		local light = convert.xyz_to_hex(p)
		table.insert(lights, light)
	end

	return { darks, lights }
end

return M
