-- ~~/tests/mono/py/parse_spec.lua --

-- imports --
local utilities = require('monorepo.utilities')

describe('Parser for pyproject.toml with empty content', function()
  it('should parse an empty file', function()
    local pyproject_toml = [[]]
    local workspace_section = utilities.extract_pyproject_uv_workspace(pyproject_toml)
    assert.is_nil(workspace_section)
  end)
end)

describe('Parser for pyproject.toml with no [tool.uv.workspace] attribute', function()
  it('should parse a file with no [workspace] attribute', function()
    local pyproject_toml = [[
[package]
description = "This is a test pyproject.toml"
name = "test"
version = "0.1.0"
]]
    local workspace_section = utilities.extract_pyproject_uv_workspace(pyproject_toml)
    assert.is_nil(workspace_section)
  end)
end)

describe('Parser for pyproject.toml containing empty [tool.uv.workspace]', function()
  it('should parse a file containing empty workspace', function()
    local pyproject_toml = [[
[package]
description = "This is a test pyproject.toml"
name = "test"
version = "0.1.0"
[tool.uv.workspace]
]]
    local workspace_section = utilities.extract_pyproject_uv_workspace(pyproject_toml)
    assert.is_not_nil(workspace_section)
    local members = utilities.extract_members(workspace_section) -- NOTE: member_type optional
    assert.is_nil(members)
  end)
end)

describe('Parser for pyproject.toml containing [tool.uv.workspace] with zero members', function()
  it('should parse a file with no [workspace] attribute', function()
    local pyproject_toml = [[
[package]
description = "This is a test pyproject.toml"
name = "test"
version = "0.1.0"
[tool.uv.workspace]
members = []
]]
    local workspace_section = utilities.extract_pyproject_uv_workspace(pyproject_toml)
    assert.is_not_nil(workspace_section)
    local members = utilities.extract_members(workspace_section) -- NOTE: member_type optional
    assert.is_nil(members)
  end)
end)

describe('Parser for pyproject.toml containing [tool.uv.workspace] with three members', function()
  it('should parse a file with no [workspace] attribute', function()
    local pyproject_toml = [[
[package]
description = "This is a test pyproject.toml"
name = "test"
version = "0.1.0"
[tool.uv.workspace]
members = [
  "package1",
  "package2",
  "package3",
]
]]
    local workspace_section = utilities.extract_pyproject_uv_workspace(pyproject_toml)
    assert.is_not_nil(workspace_section)
    local members = utilities.extract_members(workspace_section) -- NOTE: member_type optional
    assert.is_not_nil(members)
    local cwd = vim.fn.getcwd() -- NOTE: displays members from root
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
