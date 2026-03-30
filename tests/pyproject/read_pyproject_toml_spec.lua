-- ~~/tests/cargo/read_pyproject_toml_spec.lua --

-- imports --
local utilities = require('monorepo.utilities')

describe('Detect, read, parse and then autodetect & parse pyproject.toml in directory', function()
  local root_dir = vim.fn.getcwd()

  after_each(function()
    vim.api.nvim_set_current_dir(root_dir)
  end)

  before_each(function()
    vim.api.nvim_set_current_dir(root_dir .. '/tests/pyproject')
  end)

  it('should detect pyproject.toml file from test directory', function()
    local pyproject_toml = vim.fn.getcwd() .. '/pyproject.toml'
    local file_detected = vim.fn.filereadable(pyproject_toml)
    assert.are.same(file_detected, 1)
  end)

  it('should read pyproject.toml file from test directory', function()
    local pyproject_toml = vim.fn.getcwd() .. '/pyproject.toml'
    local content = table.concat(vim.fn.readfile(pyproject_toml), '\n')
    assert.is_not_nil(content)
  end)

  it('should parse pyproject.toml file from test directory', function()
    local cwd = vim.fn.getcwd()
    local pyproject_toml = cwd .. '/pyproject.toml'
    local members = utilities.parse_pyproject_uv_workspace(pyproject_toml)
    assert.are.same(members, {
      {
        name = 'package1',
        path = cwd .. '/package1',
        visible = true,
      },
      {
        name = 'package2',
        path = cwd .. '/package2',
        visible = true,
      },
      {
        name = 'package3',
        path = cwd .. '/package3',
        visible = true,
      },
    })
  end)

  it('should autodetect and parse parse pyproject.toml file from test directory', function()
    local cwd = vim.fn.getcwd()
    local members = utilities.get_workspace_members()
    assert.are.same(members, {
      {
        name = 'package1',
        path = cwd .. '/package1',
        visible = true,
      },
      {
        name = 'package2',
        path = cwd .. '/package2',
        visible = true,
      },
      {
        name = 'package3',
        path = cwd .. '/package3',
        visible = true,
      },
    })
  end)
end)
