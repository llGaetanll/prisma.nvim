local M = {}

function M.hex_to_str(hex)
	return "#" .. string.format("%x", hex)
end

function M.str_to_hex(str)
	return tonumber(str:sub(2), 16)
end

function M.rgb_to_str(rgb)
	local _rgb = {}

	for _, v in ipairs(rgb) do
		table.insert(v * 0xff, v)
	end

	return "RGB(" .. table.concat(_rgb, ", ") .. ")"
end

function M.hsv_to_str(hsv)
	local h = hsv[1] * 360
	local s = hsv[2]
	local v = hsv[3]

	local _hsv = { h, s, v }

	return "HSV(" .. table.concat(_hsv, ", ") .. ")"
end

function M.xyz_to_str(xyz)
	return "XYZ(" .. table.concat(xyz, ", ") .. ")"
end

return M
