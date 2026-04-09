-- ~~/tests/mono/helpers.lua --

local statemgmt = require('monorepo.statemgmt')

local M = {}
M.root_dir = vim.fn.getcwd()

function M.enter_fixture(name)
  vim.api.nvim_set_current_dir(M.root_dir .. '/tests/mono/' .. name)
end

function M.leave_fixture()
  vim.api.nvim_set_current_dir(M.root_dir)
end

return M
