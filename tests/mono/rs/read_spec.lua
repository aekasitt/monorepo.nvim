-- ~~/tests/cargo/read_cargo_toml_spec.lua --

-- imports --
local dirhelper = require('tests.mono.dirhelper')
local utilities = require('monorepo.utilities')

describe('Detect, read, parse and then autodetect & parse Cargo.toml in directory', function()
  local root_dir = vim.fn.getcwd()

  after_each(function()
    dirhelper.leave_fixture()
  end)

  before_each(function()
    dirhelper.enter_fixture('rs')
  end)

  it('should detect Cargo.toml file from test directory', function()
    local cargo_toml = vim.fn.getcwd() .. '/Cargo.toml'
    local file_detected = vim.fn.filereadable(cargo_toml)
    assert.are.same(file_detected, 1)
  end)

  it('should read Cargo.toml file from test directory', function()
    local cargo_toml = vim.fn.getcwd() .. '/Cargo.toml'
    local content = table.concat(vim.fn.readfile(cargo_toml), '\n')
    assert.is_not_nil(content)
  end)

  it('should parse Cargo.toml file from test directory', function()
    local cwd = vim.fn.getcwd()
    local cargo_toml = cwd .. '/Cargo.toml'
    local members = utilities.parse_cargo_workspace(cargo_toml)
    assert.are.same(members, {
      {
        name = 'crate1',
        path = cwd .. '/crate1',
        visible = true,
      },
      {
        name = 'crate2',
        path = cwd .. '/crate2',
        visible = true,
      },
      {
        name = 'crate3',
        path = cwd .. '/crate3',
        visible = true,
      },
    })
  end)

  it('should autodetect and parse parse Cargo.toml file from file directory', function()
    local cwd = vim.fn.getcwd()
    local members = utilities.get_workspace_members()
    assert.are.same(members, {
      {
        name = 'crate1',
        path = cwd .. '/crate1',
        visible = true,
      },
      {
        name = 'crate2',
        path = cwd .. '/crate2',
        visible = true,
      },
      {
        name = 'crate3',
        path = cwd .. '/crate3',
        visible = true,
      },
    })
  end)
end)
