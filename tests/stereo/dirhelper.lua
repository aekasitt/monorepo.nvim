-- ~~/tests/stereo/dirhelper.lua --

-- imports --
local statemgmt = require('monorepo.statemgmt')

local M = {}

M.root_dir = vim.fn.getcwd()
M.default_config = {
  fff_integration = true,
  keybinding = '<leader>mn',
  mode = 'mono',
  window = {
    border = 'rounded',
    height = 15,
    width = 60,
  },
}

function M.reset_config()
  statemgmt.config = vim.deepcopy(M.default_config)
end

function M.enter_fixture(name)
  M.reset_config()
  vim.api.nvim_set_current_dir(M.root_dir .. '/tests/stereo/' .. name)
end

function M.leave_fixture()
  M.reset_config()
  vim.api.nvim_set_current_dir(M.root_dir)
end

return M
