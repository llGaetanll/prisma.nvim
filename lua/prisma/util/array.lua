local M = {}

-- Returns `n` evenly spaced numbers over the interval [lo, hi]
function M.linspace(lo, hi, n)
	if n == 1 then
		return { lo }
	end

	local range = hi - lo
	local d = range / (n - 1)

	local vals = {}
	for i = 0, n - 1 do
		table.insert(vals, lo + (i * d))
	end

	return vals
end

-- Rotates the list `lst` `n` elements to the right
function M.rotate(lst, n)
	local new_lst = {}

	for i = 1, #lst do
		table.insert(new_lst, lst[(i - n - 1) % #lst + 1])
	end

	return new_lst
end

return M
