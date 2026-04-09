-- ~~/lua/monorepo/interface.lua --

local statemgmt = require('monorepo.statemgmt')
local utilities = require('monorepo.utilities')

local M = {}

function M.create_window()
  local config = statemgmt.get_config()
  local state = statemgmt.get_state()

  -- Check if in a supported monorepo
  local manifests = utilities.detect_monorepo_manifests()
  if #manifests == 0 then
    vim.notify(
      'No monorepo detected: Cargo.toml, package.json or pyproject.toml not found',
      vim.log.levels.WARN
    )
    return
  end

  -- Check if workspace has members
  local members = utilities.get_workspace_members()
  if #members == 0 then
    if config.mode == 'stereo' then
      local manifest_names = utilities.get_detected_manifest_names()
      vim.notify(
        'No workspace members found across detected manifests: '
          .. table.concat(manifest_names, ', '),
        vim.log.levels.WARN
      )
    else
      local type_name = utilities.get_manifest_name(manifests[1].type) or manifests[1].type
      vim.notify('No workspace members found in ' .. type_name, vim.log.levels.WARN)
    end
    return
  end

  local width = config.window.width
  local height = config.window.height

  local ui = vim.api.nvim_list_uis()[1]
  local win_width = ui.width
  local win_height = ui.height

  local row = math.floor((win_height - height) / 2)
  local col = math.floor((win_width - width) / 2)

  state.buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_option(state.buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(state.buf, 'filetype', 'monorepo')

  local opts = {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = config.window.border,
    title = ' Workspace Members ',
    title_pos = 'center',
    noautocmd = false,
  }

  state.win = vim.api.nvim_open_win(state.buf, true, opts)

  vim.api.nvim_win_set_option(state.win, 'cursorline', true)
  vim.api.nvim_win_set_option(state.win, 'cursorlineopt', 'both')
  vim.api.nvim_win_set_option(
    state.win,
    'winhighlight',
    'Normal:NormalFloat,CursorLine:Visual,CursorLineNr:NormalFloat'
  )
  vim.api.nvim_win_set_option(state.win, 'number', false)
  vim.api.nvim_win_set_option(state.win, 'relativenumber', false)
  vim.api.nvim_win_set_option(state.win, 'signcolumn', 'no')

  M.render_members()
  M.setup_keymaps()

  -- Position cursor on first member line
  if #state.members > 0 then
    vim.api.nvim_win_set_cursor(state.win, { 6, 0 })
  end
end

function M.render_members()
  local config = statemgmt.get_config()
  local state = statemgmt.get_state()

  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then
    return
  end
  state.members = utilities.get_workspace_members()

  -- Check if nvim-web-devicons is available
  local has_devicons, devicons = pcall(require, 'nvim-web-devicons')
  local eye_icon = has_devicons and '  ' or '[✓]' -- nf-fa-eye
  local eye_slash_icon = has_devicons and '  ' or '[ ]' -- nf-fa-eye_slash

  local lines = {}
  table.insert(lines, '')
  table.insert(lines, ' Space: toggle visibility  |  Enter: open in fff  |  q/Esc: close')
  table.insert(lines, '')
  table.insert(lines, string.rep('─', config.window.width - 2))
  table.insert(lines, '')
  for i, member in ipairs(state.members) do
    local icon = member.visible and eye_icon or eye_slash_icon
    local line = string.format(' %s %s', icon, member.name)
    table.insert(lines, line)
  end

  vim.api.nvim_buf_set_option(state.buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(state.buf, 'modifiable', false)
end

function M.toggle_member()
  local state = statemgmt.get_state()
  local line = vim.api.nvim_win_get_cursor(state.win)[1]
  local member_index = line - 5 -- Account for header lines (3 header + 1 separator + 1 blank = 5)

  if member_index > 0 and member_index <= #state.members then
    state.members[member_index].visible = not state.members[member_index].visible

    -- Update .ignore file to reflect visibility changes
    utilities.update_ignore_file(state.members)

    M.render_members()
    vim.api.nvim_win_set_cursor(state.win, { line, 0 })
  end
end

function M.open_in_fff()
  local config = statemgmt.get_config()
  local state = statemgmt.get_state()
  local line = vim.api.nvim_win_get_cursor(state.win)[1]
  local member_index = line - 5 -- Account for header lines

  if member_index > 0 and member_index <= #state.members then
    local member = state.members[member_index]
    M.close()

    if config.fff_integration then
      local fff_ok, fff = pcall(require, 'fff')
      if fff_ok and fff.find_files then
        -- Open fff in the member directory
        vim.cmd('cd ' .. member.path)
        fff.find_files()
      else
        vim.cmd('edit ' .. member.path)
      end
    else
      vim.cmd('edit ' .. member.path)
    end
  end
end

function M.setup_keymaps()
  local state = statemgmt.get_state()
  local opts = { buffer = state.buf, nowait = true, silent = true }

  -- Action keys
  vim.keymap.set('n', '<Space>', M.toggle_member, opts)
  vim.keymap.set('n', '<CR>', M.open_in_fff, opts)
  vim.keymap.set('n', 'q', M.close, opts)
  vim.keymap.set('n', '<Esc>', M.close, opts)

  -- Restricted movement keys
  local first_member_line = 6
  local last_member_line = 5 + #state.members

  vim.keymap.set('n', 'j', function()
    local line = vim.api.nvim_win_get_cursor(state.win)[1]
    if line < last_member_line then
      vim.cmd('normal! j')
    end
  end, opts)

  vim.keymap.set('n', 'k', function()
    local line = vim.api.nvim_win_get_cursor(state.win)[1]
    if line > first_member_line then
      vim.cmd('normal! k')
    end
  end, opts)

  vim.keymap.set('n', '<Down>', function()
    local line = vim.api.nvim_win_get_cursor(state.win)[1]
    if line < last_member_line then
      vim.cmd('normal! j')
    end
  end, opts)

  vim.keymap.set('n', '<Up>', function()
    local line = vim.api.nvim_win_get_cursor(state.win)[1]
    if line > first_member_line then
      vim.cmd('normal! k')
    end
  end, opts)

  -- Jump to first / last member
  vim.keymap.set('n', 'gg', function()
    vim.api.nvim_win_set_cursor(state.win, { first_member_line, 0 })
  end, opts)

  vim.keymap.set('n', 'G', function()
    vim.api.nvim_win_set_cursor(state.win, { last_member_line, 0 })
  end, opts)

  -- Restrict cursor movement with autocmd (catches all other movement attempts)
  vim.api.nvim_create_autocmd('CursorMoved', {
    buffer = state.buf,
    callback = function()
      if not state.win or not vim.api.nvim_win_is_valid(state.win) then
        return
      end

      local line = vim.api.nvim_win_get_cursor(state.win)[1]
      local first_line = 6
      local last_line = 5 + #state.members

      -- Ensure we don't try to set cursor beyond buffer bounds
      local buf_line_count = vim.api.nvim_buf_line_count(state.buf)
      if last_line > buf_line_count then
        last_line = buf_line_count
      end

      if line < first_line and first_line <= buf_line_count then
        vim.api.nvim_win_set_cursor(state.win, { first_line, 0 })
      elseif line > last_line and last_line > 0 then
        vim.api.nvim_win_set_cursor(state.win, { last_line, 0 })
      end
    end,
  })
end

function M.close()
  local state = statemgmt.get_state()
  if state.win and vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_close(state.win, true)
  end
  state.win = nil
  state.buf = nil
end

return M
