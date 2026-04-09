-- ~~/tests/parse_package_json_spec.lua --

-- imports --
local utilities = require('monorepo.utilities')

describe('Parser with empty package.json', function()
  it('should parse an empty file', function()
    local test_package_json = [[]]
    local workspaces = utilities.extract_package_json_workspaces(test_package_json)
    assert.is_nil(workspaces)
  end)
end)

describe('Parser with package.json with no workspaces attribute', function()
  it('should parse a file with no workspaces attribute', function()
    local test_package_json = [[
{
    "name": "test",
    "version": "1.0.0"
}
]]
    local workspaces = utilities.extract_package_json_workspaces(test_package_json)
    assert.is_nil(workspaces)
  end)
end)

describe('Parser with package.json containing empty workspaces array', function()
  local root_dir = vim.fn.getcwd()

  after_each(function()
    vim.api.nvim_set_current_dir(root_dir)
  end)

  before_each(function()
    vim.api.nvim_set_current_dir(root_dir .. '/tests/mono/js')
  end)

  it('should parse a file containing empty workspaces', function()
    local test_package_json = [[
{
    "name": "test",
    "version": "1.0.0",
    "workspaces": []
}
]]
    local workspaces = utilities.extract_package_json_workspaces(test_package_json)
    assert.is_not_nil(workspaces)
    local members = utilities.extract_package_json_members(workspaces)
    assert.are.same({}, members)
  end)
end)

describe('Parser with package.json containing workspaces array format', function()
  local root_dir = vim.fn.getcwd()

  after_each(function()
    vim.api.nvim_set_current_dir(root_dir)
  end)

  before_each(function()
    vim.api.nvim_set_current_dir(root_dir .. '/tests/mono/js')
  end)

  it('should parse a file with workspaces as array', function()
    local test_package_json = [[
{
    "name": "test",
    "version": "1.0.0",
    "workspaces": ["*"]
}
]]
    local cwd = vim.fn.getcwd()
    local workspaces = utilities.extract_package_json_workspaces(test_package_json)
    assert.is_not_nil(workspaces)
    local members = utilities.extract_package_json_members(workspaces)
    assert.are.same({}, members) -- FIXME: glob pattern should detect "package1" and "package2"
  end)
end)

describe('Parser with package.json containing workspaces object format', function()
  local root_dir = vim.fn.getcwd()
  after_each(function()
    vim.api.nvim_set_current_dir(root_dir)
  end)

  before_each(function()
    vim.api.nvim_set_current_dir(root_dir .. '/tests/mono/js')
  end)

  it('should parse a file with workspaces as object with packages key', function()
    local test_package_json = [[
{
    "name": "test",
    "version": "1.0.0",
    "workspaces": {
        "packages": ["*"]
    }
}
]]
    local cwd = vim.fn.getcwd()
    local workspaces = utilities.extract_package_json_workspaces(test_package_json)
    assert.is_not_nil(workspaces)
    local members = utilities.extract_package_json_members(workspaces)
    assert.are.same({}, members) -- FIXME: should be able to detect inner "packages" field as array
  end)
end)

describe('Parser with package.json containing direct paths in workspaces', function()
  local root_dir = vim.fn.getcwd()

  after_each(function()
    vim.api.nvim_set_current_dir(root_dir)
  end)

  before_each(function()
    vim.api.nvim_set_current_dir(root_dir .. '/tests/mono/js')
  end)

  it('should parse a file with direct workspace paths', function()
    local test_package_json = [[
{
    "name": "test",
    "version": "1.0.0",
    "workspaces": [
        "package1",
        "package2"
    ]
}
]]
    local cwd = vim.fn.getcwd()
    local workspaces = utilities.extract_package_json_workspaces(test_package_json)
    assert.is_not_nil(workspaces)
    local members = utilities.extract_package_json_members(workspaces)
    assert.are.same({
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
    }, members)
  end)
end)
