-- ~~/lua/monorepo/init.lua --

local interface = require('monorepo.interface')
local statemgmt = require('monorepo.statemgmt')
local utilities = require('monorepo.utilities')

local M = {}

function M.setup(opts)
  statemgmt.set_config(opts)
  local config = statemgmt.get_config()

  if config.keybinding then
    vim.keymap.set('n', config.keybinding, function()
      M.toggle()
    end, { desc = 'Toggle Monorepo workspace members' })
  end
end

function M.toggle()
  local state = statemgmt.get_state()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    interface.close()
  else
    interface.create_window()
  end
end

function M.get_visible_members()
  local state = statemgmt.get_state()
  local visible = {}
  for _, member in ipairs(state.members) do
    if member.visible then
      table.insert(visible, member)
    end
  end
  return visible
end

return M
