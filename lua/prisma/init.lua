local gen_groups = require("prisma.groups")

local Prisma = {}

Prisma.config = {
	variant = "light", -- "light" | "dark"
	algorithm = "conic-circular",
	params = {
		-- the base color of the colorscheme
		bias = "#769294",
		hue_value = 0.8,
		shade_value_range = { 0.1, 1 },
	},
}

local algos_dir = "prisma.algos"

Prisma.setup = function(config)
	Prisma.config = vim.tbl_deep_extend("force", Prisma.config, config or {})
end

Prisma.load = function()
	if vim.version().minor < 8 then
		vim.notify_once("prisma.nvim: you must use neovim 0.8 or higher")
		return
	end

	-- reset colors
	if vim.g.colors_name then
		vim.cmd.hi("clear")
	end
	vim.g.colors_name = "prisma"
	vim.o.termguicolors = true

	-- generate colors
	local algo_dir = algos_dir .. "." .. Prisma.config.algorithm
	local algo_ok, algo = pcall(require, algo_dir)
	if not algo_ok then
		vim.notify_once("prisma.nvim: algorithm " .. Prisma.config.algorithm .. " not found.")
		return
	end
	local colors = algo.gen_colors(Prisma.config.params)
	local groups = gen_groups(Prisma.config, colors)

	-- add highlights
	for group, settings in pairs(groups) do
		vim.api.nvim_set_hl(0, group, settings)
	end
end

return Prisma
