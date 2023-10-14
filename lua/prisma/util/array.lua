local M = {}

-- Returns `n` evenly spaced numbers over the interval [lo, hi]
function M.linspace(lo, hi, n)
	local range = hi - lo + 1
	local d = range / n

	local vals = {}
	for i = 0, n - 1 do
		table.insert(vals, lo + (i * d))
	end

	return vals
end

return M
