-- ~~/tests/mono/rs/parse_spec.lua --

-- imports --
local utilities = require('monorepo.utilities')

describe('Parser with empty Cargo.toml', function()
  it('should parse an empty file', function()
    local test_cargo_toml = [[]]
    local workspace_section = utilities.extract_cargo_workspace(test_cargo_toml)
    assert.is_nil(workspace_section)
  end)
end)

describe('Parser with Cargo.toml with no [workspace] attribute', function()
  it('should parse a file with no [workspace] attribute', function()
    local test_cargo_toml = [[
[package]
edition = "2024"
name = "test"
version = "0.1.0"
]]
    local workspace_section = utilities.extract_cargo_workspace(test_cargo_toml)
    assert.is_nil(workspace_section)
  end)
end)

describe('Parser with Cargo.toml containing empty workspace', function()
  it('should parse a file containing empty workspace', function()
    local test_cargo_toml = [[
[package]
edition = "2024"
name = "test"
version = 0.1.0
[workspace]
]]
    local workspace_section = utilities.extract_cargo_workspace(test_cargo_toml)
    assert.is_not_nil(workspace_section)
    local members = utilities.extract_members(workspace_section) -- NOTE: member_type optional
    assert.is_nil(members)
  end)
end)

describe('Parser with Cargo.toml containing workspace with zero members', function()
  it('should parse a file with no [workspace] attribute', function()
    local test_cargo_toml = [[
[package]
edition = "2024"
name = "test"
version = 0.1.0
[workspace]
members = []
]]
    local workspace_section = utilities.extract_cargo_workspace(test_cargo_toml)
    assert.is_not_nil(workspace_section)
    local members = utilities.extract_members(workspace_section) -- NOTE: member_type optional
    assert.is_nil(members)
  end)
end)

describe('Parser with empty Cargo.toml workspace', function()
  it('should parse a file with no [workspace] attribute', function()
    local test_cargo_toml = [[
[package]
edition = "2024"
name = "test"
version = 0.1.0
[workspace]
members = [
  "crate1",
  "crate2",
  "crate3",
]

[workspace.dependencies]
serde = "1.0"
]]
    local workspace_section = utilities.extract_cargo_workspace(test_cargo_toml)
    assert.is_not_nil(workspace_section)
    local members = utilities.extract_members(workspace_section) -- NOTE: member_type optional
    assert.is_not_nil(members)
    local cwd = vim.fn.getcwd() -- NOTE: displays members from root
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
