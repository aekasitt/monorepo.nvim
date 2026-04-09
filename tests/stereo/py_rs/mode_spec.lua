-- ~~/tests/stereo/py_rs/mode_spec.lua --

-- imports --
local dirhelper = require('tests.stereo.dirhelper')
local statemgmt = require('monorepo.statemgmt')
local utilities = require('monorepo.utilities')

describe('Mono/stereo behavior for Python + Cargo manifests', function()
  before_each(function()
    dirhelper.enter_fixture('py_rs')
  end)

  after_each(function()
    dirhelper.leave_fixture()
  end)

  it('should detect cargo then python manifests in stable order', function()
    local cwd = vim.fn.getcwd()
    local manifests = utilities.detect_monorepo_manifests()
    assert.are.same({
      {
        path = cwd .. '/pyproject.toml',
        type = 'py',
      },
      {
        path = cwd .. '/Cargo.toml',
        type = 'rs',
      },
    }, manifests)
  end)

  it('should use cargo members in mono mode', function()
    statemgmt.set_config({ mode = 'mono' })
    local cwd = vim.fn.getcwd()
    local members = utilities.get_workspace_members()
    assert.are.same({
      {
        name = 'package_py',
        path = cwd .. '/package_py',
        type = 'py',
        visible = true,
      },
      {
        name = 'shared',
        path = cwd .. '/shared',
        type = 'py',
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
        name = 'package_py',
        path = cwd .. '/package_py',
        type = 'py',
        visible = true,
      },
      {
        name = 'shared',
        path = cwd .. '/shared',
        type = 'py',
        visible = true,
      },
      {
        name = 'crate_rs',
        path = cwd .. '/crate_rs',
        type = 'rs',
        visible = true,
      },
    }, members)
  end)
end)
