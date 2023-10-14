local convert = require("prisma.util.convert")
local array = require("prisma.util.array")

describe("Conversion tests", function()
	-- generated from python. Used for tests
	local colors = {
		hex = { 0x779294, 0xc9f6fa, 0x14221e, 0x472423, 0x10232b, 0xd97069, 0x483f5d, 0x1f1e3c, 0xca8b5a },
		hsv = {
			{ 0.5114942528735633, 0.195945945945946, 0.5803921568627451 },
			{ 0.5136054421768708, 0.19599999999999998, 0.9803921568627451 },
			{ 0.4523809523809524, 0.4117647058823529, 0.13333333333333333 },
			{ 0.004629629629629613, 0.5070422535211268, 0.2784313725490196 },
			{ 0.5493827160493826, 0.627906976744186, 0.16862745098039217 },
			{ 0.010416666666666666, 0.5161290322580645, 0.8509803921568627 },
			{ 0.7166666666666667, 0.32258064516129026, 0.36470588235294116 },
			{ 0.6722222222222222, 0.5, 0.23529411764705882 },
			{ 0.07291666666666664, 0.5544554455445544, 0.792156862745098 },
		},
		rgb = {
			{ 0.4666666666666666, 0.5725490196078431, 0.5803921568627451 },
			{ 0.788235294117647, 0.9647058823529411, 0.9803921568627451 },
			{ 0.0784313725490196, 0.13333333333333333, 0.11764705882352942 },
			{ 0.2784313725490196, 0.1411764705882353, 0.13725490196078433 },
			{ 0.06274509803921569, 0.13725490196078438, 0.16862745098039217 },
			{ 0.8509803921568627, 0.4392156862745098, 0.4117647058823529 },
			{ 0.2823529411764706, 0.24705882352941178, 0.36470588235294116 },
			{ 0.12156862745098038, 0.11764705882352941, 0.23529411764705882 },
			{ 0.792156862745098, 0.5450980392156862, 0.35294117647058826 },
		},
		xyz = {
			{ -0.11342903417262962, -0.008206176149874045, 0.5803921568627451 },
			{ -0.19145517083544758, -0.016406628550924653, 0.9803921568627451 },
			{ -0.052462820709827336, 0.016182637026481015, 0.13333333333333333 },
			{ 0.14111674589395773, 0.004106077940203948, 0.2784313725490196 },
			{ -0.10082624668289109, -0.032328635050070706, 0.16862745098039217 },
			{ 0.4382752917753866, 0.028726080289317737, 0.8509803921568627 },
			{ -0.02446019891973644, -0.11507618832162415, 0.36470588235294116 },
			{ -0.055231948563046064, -0.10387618739516782, 0.23529411764705882 },
			{ 0.3939205766731807, 0.19426013060599262, 0.792156862745098 },
		},
	}

	-- our maximum allowed error for each test. smaller is better
	-- if colors are this close to each other, it's good enough
	local ERROR = 1e-8

	-- checks if two tuples are close enough
	local close_enough = function(a, b)
		local passed = true
		if type(a) == "number" then
			-- in case of hex
			passed = math.abs(a - b) < ERROR

			if not passed then
				a = string.format("%x", a)
				b = string.format("%x", b)
				print(a, b, "failed")
			end
		else
			-- in case of tuples
			for i = 1, #a do
				if math.abs(a[i] - b[i]) >= ERROR then
					passed = false
				end
			end

			if not passed then
				for i = 1, #a do
					print(a[i], b[i])
				end
				print("failed")
			end
		end

		return passed
	end

	local test_all = function(lst1, lst2, fn)
		local all_passed = true
		for i = 1, #lst1 do
			local a = lst1[i]
			local b = fn(lst2[i])

			all_passed = all_passed and close_enough(a, b)
		end

		assert.True(all_passed)
	end

	it("hex->rgb", function()
		test_all(colors.rgb, colors.hex, convert.hex_to_rgb)
	end)

	it("hex->hsv", function()
		test_all(colors.hsv, colors.hex, convert.hex_to_hsv)
	end)

	it("hex->xyz", function()
		test_all(colors.xyz, colors.hex, convert.hex_to_xyz)
	end)

	it("rgb->hex", function()
		test_all(colors.hex, colors.rgb, convert.rgb_to_hex)
	end)

	it("rgb->xyz", function()
		test_all(colors.xyz, colors.rgb, convert.rgb_to_xyz)
	end)

	it("rgb->hsv", function()
		test_all(colors.hsv, colors.rgb, convert.rgb_to_hsv)
	end)

	it("xyz->rgb", function()
		test_all(colors.rgb, colors.xyz, convert.xyz_to_rgb)
	end)

	it("xyz->hex", function()
		test_all(colors.hex, colors.xyz, convert.xyz_to_hex)
	end)

	it("xyz->hsv", function()
		test_all(colors.hsv, colors.xyz, convert.xyz_to_hsv)
	end)

	it("hsv->rgb", function()
		test_all(colors.rgb, colors.hsv, convert.hsv_to_rgb)
	end)

	it("hsv->hex", function()
		test_all(colors.hex, colors.hsv, convert.hsv_to_hex)
	end)

	it("hsv->xyz", function()
		test_all(colors.xyz, colors.hsv, convert.hsv_to_xyz)
	end)
end)

describe("Array tests", function()
	local cmp_lists = function(lst1, lst2)
		assert.equals(#lst1, #lst2)

		for i = 1, #lst1 do
			local a = lst1[i]
			local b = lst2[i]

			assert.equals(a, b)
		end
	end

	it("linspace 1", function()
		cmp_lists({ 0 }, array.linspace(0, 1, 1))
	end)

	it("linspace 2", function()
		cmp_lists({ 1, 2, 3, 4, 5 }, array.linspace(1, 5, 5))
	end)

	it("linspace 3", function()
		cmp_lists({ -2, -1, 0, 1, 2 }, array.linspace(-2, 2, 5))
	end)
end)
