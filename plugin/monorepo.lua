-- ~~/plugin/monorepo.lua --

if vim.g.loaded_monorepo then
  return
end
vim.g.loaded_monorepo = true

vim.api.nvim_create_user_command('Monorepo', function()
  require('monorepo').toggle()
end, {})
