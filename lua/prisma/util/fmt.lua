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
		table.insert(_rgb, v * 0xff)
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

local function map(tbl, fn)
	local res = {}
	for k, v in ipairs(tbl) do
		table.insert(res, fn(k, v))
	end
	return res
end

local function fold(tbl, fn, base)
	local res = base
	for k, v in ipairs(tbl) do
		res = fn(res, k, v)
	end
	return res
end

function M.table_to_str(tbl)
	local sep = ","
	local indent = "  "
	local max_width = 50

	local function rec(tbl, depth)
		local parse_entry = function(k, v)
			if type(v) ~= "table" then
				return tostring(k) .. " = " .. tostring(v)
			else
				return tostring(k) .. " = " .. rec(v, depth + 1)
			end
		end

		local entries = map(tbl, parse_entry)

		local s2 = " "
		local pad = ""
		local total_len = fold(entries, function(len, _, s)
			return len + #s
		end, 0)
		if total_len > max_width then
			s2 = "\n"
			pad = string.rep(indent, depth)
		end

		entries = map(entries, function(_, v)
			return pad .. v
		end)

		local strs = { "{", table.concat(entries, sep .. s2), "}" }

		return table.concat(strs, s2)
	end

	return rec(tbl, 1)
end

return M
