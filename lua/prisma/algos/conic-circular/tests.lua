local alg = require("prisma.algos.conic-circular")
local util = require("prisma.algos.conic-circular.util")
local fmt = require("prisma.util.fmt")

local test_data = require("prisma.algos.conic-circular.test-data")

describe("Util", function()
	local ERROR = 1e-16
	local close_enough = function(a, b)
		local passed = true
		for i = 1, #a do
			if math.abs(a[i] - b[i]) >= ERROR then
				passed = false
			end
		end
		return passed
	end

	it("test coord", function()
		for _, v in ipairs(test_data.coord_tests) do
			local input = v.input
			local expected = v.output

			local theta = input[1]
			local b = input[2]
			local r_b = input[3]

			local res = util.coord(theta, b, r_b)

			assert.True(close_enough(expected, res))
		end
	end)

	it("test line point", function()
		for _, val in ipairs(test_data.line_point_tests) do
			local input = val.input
			local expected = val.output

			local hsv_bias = input[1]
			local v = input[2]

			local res = util.line_point(hsv_bias, v)

			assert.True(close_enough(expected, res))
		end
	end)

	it("test hsv corrected", function()
		for _, val in ipairs(test_data.hsv_corrected_tests) do
			local input = val.input
			local expected = val.output

			local res = util.hsv_corrected(input)

			assert.True(close_enough(expected, res))
		end
	end)
end)

describe("Algo tests", function()
	-- it("test gen_colors", function()
	-- 	local vals = alg.gen_colors({
	-- 		-- the base color of the colorscheme
	-- 		bias = "#769294",
	-- 		hue_value = 0.8,
	-- 		shade_value_range = { 0.1, 1 },
	-- 	})
	--
	-- 	local lights = vals.lights
	-- 	local darks = vals.darks
	-- 	local hues = vals.hues
	--
	-- 	print(fmt.table_to_str(darks))
	-- end)
end)
