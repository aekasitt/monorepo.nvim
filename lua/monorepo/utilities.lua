-- ~~/lua/monorepo/utilities.lua --

local statemgmt = require('monorepo.statemgmt')
local M = {}

local MANIFEST_PRIORITY = {
  {
    filename = 'package.json',
    forbidden = { 'tsconfig.json' },
    type = 'js',
  },
  {
    filename = 'pyproject.toml',
    type = 'py',
  },
  {
    filename = 'package.json',
    required = { 'tsconfig.json' },
    type = 'ts',
  },
  {
    filename = 'Cargo.toml',
    type = 'rs',
  },
}

local MANIFEST_NAMES = {
  js = 'package.json',
  py = 'pyproject.toml',
  rs = 'Cargo.toml',
  ts = 'package.json + tsconfig.json',
}

function M.get_hidden_members_from_ignore()
  local cwd = vim.fn.getcwd()
  local ignore_file = cwd .. '/.ignore'
  local hidden = {}
  if vim.fn.filereadable(ignore_file) == 1 then
    local in_monorepo_section = false
    for _, line in ipairs(vim.fn.readfile(ignore_file)) do
      if line == '# monorepo-nvim: begin' then
        in_monorepo_section = true
      elseif line == '# monorepo-nvim: end' then
        in_monorepo_section = false
      elseif in_monorepo_section and line ~= '' then
        hidden[line] = true
      end
    end
  end
  return hidden
end

function M.detect_monorepo_type()
  local manifests = M.detect_monorepo_manifests()
  if #manifests ~= 0 then
    return manifests[1].type, manifests[1].path
  end
  return nil, nil
end

function M.detect_monorepo_manifests()
  local cwd = vim.fn.getcwd()
  local manifests = {}
  for _, manifest in ipairs(MANIFEST_PRIORITY) do
    local path = cwd .. '/' .. manifest.filename
    if vim.fn.filereadable(path) == 1 then
      local found_forbidden = false
      for _, forbidden_file in ipairs(manifest.forbidden or {}) do
        if vim.fn.filereadable(cwd .. '/' .. forbidden_file) == 1 then
          found_forbidden = true
        end
      end
      if not found_forbidden then
        local missing_required = false
        for _, required_file in ipairs(manifest.required or {}) do
          if vim.fn.filereadable(cwd .. '/' .. required_file) ~= 1 then
            missing_required = true
          end
        end
        if not missing_required then
          table.insert(manifests, {
            path = path,
            type = manifest.type,
          })
        end
      end
    end
  end
  return manifests
end

function M.get_manifest_name(monorepo_type)
  return MANIFEST_NAMES[monorepo_type]
end

-- Find [workspace] section (stop at next TOML section like [package] or [dependencies])
M.extract_cargo_workspace = function(content)
  local section = content:match('%[workspace%](.-)\n%[%w')
  if not section then
    section = content:match('%[workspace%](.*)')
  end
  return section
end

-- Extract all quoted strings from the members array (both single and double quotes)
M.extract_members = function(content)
  local cwd = vim.fn.getcwd()
  local members = {}
  local members_content = content:match('members%s*=%s*%[(.-)%]')
  if members_content then
    local hidden = M.get_hidden_members_from_ignore()
    for member_name in members_content:gmatch('["\']([^"\']+)["\']') do
      table.insert(members, {
        name = member_name,
        path = cwd .. '/' .. member_name,
        visible = not hidden[member_name],
      })
    end
  end
  if #members ~= 0 then
    return members
  end
end

M.extract_pyproject_uv_workspace = function(content)
  local section = content:match('%[tool%.uv%.workspace%](.-)\n%[%w')
  if not section then -- trailing section
    section = content:match('%[tool%.uv%.workspace%](.*)')
  end
  return section
end

M.parse_cargo_workspace = function(path)
  local content = table.concat(vim.fn.readfile(path), '\n')
  local workspace_section = M.extract_cargo_workspace(content)
  if workspace_section then
    return M.extract_members(workspace_section) or {}
  end
  return {}
end

-- Extract workspaces array from package.json content
-- Can be array: "workspaces": ["packages/*", "apps/*"]
-- Or object: "workspaces": { "packages": [...] }
M.extract_package_json_workspaces = function(content)
  local section = content:match('"workspaces"%s*:%s*(%[[^]]*%])')
  if not section then
    section = content:match('"workspaces"%s*:%s*{[^}]*"packages"%s*:%s*(%[[^]]*%])')
  end
  return section
end

-- Parse workspace patterns from npm workspaces array string
M.extract_package_json_members = function(section)
  local cwd = vim.fn.getcwd()
  local hidden = M.get_hidden_members_from_ignore()
  local members = {}
  for pattern in section:gmatch('"([^"]+)"') do -- Expand glob patterns
    if pattern:find('%*') then
      local base_path = pattern:gsub('/%*$', ''):gsub('/%*%*$', '')
      local glob_path = cwd .. '/' .. base_path
      local expanded = vim.fn.glob(glob_path .. '/*', false, true)
      for _, item in ipairs(expanded) do
        if vim.fn.isdirectory(item) == 1 then
          local item_name = vim.fn.fnamemodify(item, ':t')
          local item_package_json = item .. '/package.json'
          if vim.fn.filereadable(item_package_json) == 1 then
            table.insert(members, {
              name = base_path .. '/' .. item_name,
              path = item,
              visible = not hidden[base_path .. '/' .. item_name],
            })
          end
        end
      end
    else -- Direct path (no glob)
      local full_path = cwd .. '/' .. pattern
      if vim.fn.isdirectory(full_path) == 1 then
        table.insert(members, {
          name = pattern,
          path = full_path,
          visible = not hidden[pattern],
        })
      end
    end
  end
  return members
end

M.parse_package_json_workspace = function(path)
  local content = table.concat(vim.fn.readfile(path), '\n')
  local workspaces_section = M.extract_package_json_workspaces(content)
  if workspaces_section then
    local members = M.extract_package_json_members(workspaces_section)
    return members
  end
  return {}
end

-- Find [tool.uv.workspace] section (stop at next TOML section)
M.parse_pyproject_uv_workspace = function(path)
  local content = table.concat(vim.fn.readfile(path), '\n')
  local workspace_section = M.extract_pyproject_uv_workspace(content)
  if workspace_section then
    return M.extract_members(workspace_section) or {}
  end
  return {}
end

M.parse_workspace_members = function(monorepo_type, path)
  if monorepo_type == 'js' or monorepo_type == 'ts' then
    return M.parse_package_json_workspace(path)
  elseif monorepo_type == 'py' then
    return M.parse_pyproject_uv_workspace(path)
  elseif monorepo_type == 'rs' then
    return M.parse_cargo_workspace(path)
  end
  return {}
end

M.get_detected_manifest_names = function()
  local names = {}
  for _, manifest in ipairs(M.detect_monorepo_manifests()) do
    table.insert(names, M.get_manifest_name(manifest.type) or manifest.type)
  end
  return names
end

M.get_workspace_members = function()
  local config = statemgmt.get_config()
  local mode = config.mode == 'stereo' and 'stereo' or 'mono'
  local manifests = M.detect_monorepo_manifests()

  if #manifests == 0 then
    return {}
  end

  if mode == 'mono' then
    local manifest = manifests[1]
    return M.parse_workspace_members(manifest.type, manifest.path)
  end

  local members = {}
  local seen_paths = {}
  for _, manifest in ipairs(manifests) do
    local parsed_members = M.parse_workspace_members(manifest.type, manifest.path)
    for _, member in ipairs(parsed_members) do
      if not seen_paths[member.path] then
        seen_paths[member.path] = true
        table.insert(members, member)
      end
    end
  end
  return members
end

M.update_ignore_file = function(members)
  local cwd = vim.fn.getcwd()
  local ignore_file = cwd .. '/.ignore'

  -- Read existing .ignore file
  local existing_lines = {}
  local monorepo_begin_marker = '# monorepo-nvim: begin'
  local monorepo_end_marker = '# monorepo-nvim: end'
  local in_monorepo_section = false

  if vim.fn.filereadable(ignore_file) == 1 then
    for _, line in ipairs(vim.fn.readfile(ignore_file)) do
      if line == monorepo_begin_marker then
        in_monorepo_section = true
      elseif line == monorepo_end_marker then
        in_monorepo_section = false
      elseif not in_monorepo_section then
        table.insert(existing_lines, line)
      end
    end
  end

  -- Build new content with monorepo.nvim section
  local new_lines = {}
  for _, line in ipairs(existing_lines) do
    table.insert(new_lines, line)
  end

  -- Add monorepo-managed hidden workspace members
  local hidden_members = {}
  for _, member in ipairs(members) do
    if not member.visible then
      table.insert(hidden_members, member.name)
    end
  end

  if #hidden_members > 0 then
    table.insert(new_lines, monorepo_begin_marker)
    for _, member_name in ipairs(hidden_members) do
      table.insert(new_lines, member_name)
    end
    table.insert(new_lines, monorepo_end_marker)
  end

  -- Write back to .ignore file
  vim.fn.writefile(new_lines, ignore_file)
end

return M
