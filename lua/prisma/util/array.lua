local M = {}

function M.linspace(lo, hi, n)
	local range = hi - lo
	local d = range / n

	local vals = {}
	for i = 1, n do
		table.insert(vals, i * d)
	end

	return vals
end

return M
