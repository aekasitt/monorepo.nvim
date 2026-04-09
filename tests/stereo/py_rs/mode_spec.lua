-- ~~/tests/stereo/py_rs/mode_spec.lua --

-- imports --
local statemgmt = require('monorepo.statemgmt')
local utilities = require('monorepo.utilities')
local helpers = require('tests.stereo.test_helpers')

describe('Mono/stereo behavior for Python + Cargo manifests', function()
  before_each(function()
    helpers.enter_fixture('py_rs')
  end)

  after_each(function()
    helpers.leave_fixture()
  end)

  it('should detect cargo then python manifests in stable order', function()
    local cwd = vim.fn.getcwd()
    local manifests = utilities.detect_monorepo_manifests()
    assert.are.same({
      {
        type = 'cargo',
        path = cwd .. '/Cargo.toml',
      },
      {
        type = 'python',
        path = cwd .. '/pyproject.toml',
      },
    }, manifests)
  end)

  it('should use cargo members in mono mode', function()
    statemgmt.set_config({ mode = 'mono' })
    local cwd = vim.fn.getcwd()
    local members = utilities.get_workspace_members()
    assert.are.same({
      {
        name = 'crate_rs',
        path = cwd .. '/crate_rs',
        visible = true,
      },
      {
        name = 'shared',
        path = cwd .. '/shared',
        visible = true,
      },
    }, members)
  end)

  it('should merge cargo and python members in stereo mode', function()
    statemgmt.set_config({ mode = 'stereo' })
    local cwd = vim.fn.getcwd()
    local members = utilities.get_workspace_members()
    assert.are.same({
      {
        name = 'crate_rs',
        path = cwd .. '/crate_rs',
        visible = true,
      },
      {
        name = 'shared',
        path = cwd .. '/shared',
        visible = true,
      },
      {
        name = 'package_py',
        path = cwd .. '/package_py',
        visible = true,
      },
    }, members)
  end)
end)
