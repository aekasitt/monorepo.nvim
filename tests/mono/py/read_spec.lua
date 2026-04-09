-- ~~/tests/mono/py/read_spec.lua --

-- imports --
local dirhelper = require('tests.mono.dirhelper')
local utilities = require('monorepo.utilities')

describe('Detect, read, parse and then autodetect & parse pyproject.toml in directory', function()
  local root_dir = vim.fn.getcwd()

  after_each(function()
    dirhelper.leave_fixture()
  end)

  before_each(function()
    dirhelper.enter_fixture('py')
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
        type = 'py',
        visible = true,
      },
      {
        name = 'package2',
        path = cwd .. '/package2',
        type = 'py',
        visible = true,
      },
      {
        name = 'package3',
        path = cwd .. '/package3',
        type = 'py',
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
        type = 'py',
        visible = true,
      },
      {
        name = 'package2',
        path = cwd .. '/package2',
        type = 'py',
        visible = true,
      },
      {
        name = 'package3',
        path = cwd .. '/package3',
        type = 'py',
        visible = true,
      },
    })
  end)
end)
