local utils = require("jqscratch.utils")

local M = {}

M.opts = {
	data_dir = vim.fn.stdpath("data") .. "/jqscratch",
}

Scratch_win_id = nil
Results_win_id = nil

M.open = function()
	M.is_open = true
	local scratch_file_path = utils.create_data_file(M.opts)
	M.json_file_path = vim.fn.expand("%")
	print(M.json_file_path)
	-- TODO handle failure to create file

	-- Create results buf
	Results_buf = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_set_option_value("filetype", "jq", { buf = Results_buf })
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = Results_buf })

	Results_win_id = vim.api.nvim_open_win(Results_buf, false, { split = "right" })

	M.json_buf = vim.api.nvim_win_get_buf(0)

	-- Create scratch buf
	-- Scratch_buf = vim.api.nvim_create_buf(true, true)
	Scratch_win_id = vim.api.nvim_open_win(0, true, { split = "above" })
	vim.cmd.edit(scratch_file_path)
	Scratch_buf = vim.api.nvim_win_get_buf(Scratch_win_id)

	vim.api.nvim_set_option_value("filetype", "jq", { buf = Scratch_buf })
	vim.api.nvim_set_option_value("buftype", "", { buf = Scratch_buf })

	vim.api.nvim_buf_set_keymap(Scratch_buf, "n", "<CR>", "", {
		noremap = true,
		callback = function()
			Run()
		end,
	})

	vim.api.nvim_create_augroup("jqscratch", { clear = true })
	Command_ids = {}
	vim.api.nvim_create_autocmd("TextChangedI", {
		group = vim.api.nvim_create_augroup("jqscratch", { clear = false }),
		buffer = Scratch_buf,
		callback = function()
			Run()
		end,
	})

	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("jqscratch", { clear = false }),
		callback = function()
			if vim.bo.filetype == "json" then
				M.json_file_path = vim.fn.expand("%")
			end
		end,
	})

	for _, buf in pairs({ Scratch_buf, Results_buf }) do
		vim.api.nvim_create_autocmd("WinClosed", {
			group = vim.api.nvim_create_augroup("jqscratch", { clear = false }),
			buffer = buf,
			callback = function()
				M.close()
			end,
		})
	end
end

M.close = function()
	vim.api.nvim_del_augroup_by_name("jqscratch")

	if Scratch_win_id ~= nil and vim.api.nvim_win_is_valid(Scratch_win_id) then
		vim.api.nvim_win_close(Scratch_win_id, false)
	end
	if Results_win_id ~= nil and vim.api.nvim_win_is_valid(Results_win_id) then
		vim.api.nvim_win_close(Results_win_id, false)
	end
end

M.toggle = function()
	if
		Scratch_win_id ~= nil
		and vim.api.nvim_win_is_valid(Scratch_win_id)
		and Results_win_id ~= nil
		and vim.api.nvim_win_is_valid(Results_win_id)
	then
		M.close()
	else
		M.open()
	end
end

Run = function()
	local cursor = vim.api.nvim_win_get_cursor(0)[1]
	local query = vim.api.nvim_buf_get_lines(Scratch_buf, cursor - 1, cursor, true)[1]

	if string.len(query) > 0 and string.sub(query, 1, 1) == "#" then
		return
	end

	local result = vim.fn.system({ "jq", query, M.json_file_path })

	if result == nil then
		return
	end

	local lines = vim.fn.split(result, "\n")

	vim.api.nvim_buf_set_lines(Results_buf, 0, -1, false, lines)
end

M.setup = function(config)
	M.opts = vim.tbl_extend("force", M.opts, config or {})
end

return M
