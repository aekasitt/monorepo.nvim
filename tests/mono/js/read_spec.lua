-- ~~/tests/javascript/read_package_json_spec.lua --

-- imports --
local dirhelper = require('tests.mono.dirhelper')
local utilities = require('monorepo.utilities')

describe('Detect, read, parse and then autodetect & parse package.json in directory', function()
  local root_dir = vim.fn.getcwd()

  after_each(function()
    dirhelper.leave_fixture()
  end)

  before_each(function()
    dirhelper.enter_fixture('js')
  end)

  it('should detect package.json file from test directory', function()
    local package_json = vim.fn.getcwd() .. '/package.json'
    local file_detected = vim.fn.filereadable(package_json)
    assert.are.same(file_detected, 1)
  end)

  it('should read package.json file from test directory', function()
    local package_json = vim.fn.getcwd() .. '/package.json'
    local content = table.concat(vim.fn.readfile(package_json), '\n')
    assert.is_not_nil(content)
  end)

  it('should parse package.json file from test directory', function()
    local cwd = vim.fn.getcwd()
    local package_json = cwd .. '/package.json'
    local members = utilities.parse_package_json_workspace(package_json)
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

  it('should autodetect and parse parse package.json file from file directory', function()
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
