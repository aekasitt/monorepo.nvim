-- ~~/tests/stereo/js_py_rs/mode_spec.lua --

-- imports --
local dirhelper = require('tests.stereo.dirhelper')
local statemgmt = require('monorepo.statemgmt')
local utilities = require('monorepo.utilities')

describe('Mono/stereo behavior for JS + Python + Cargo manifests', function()
  before_each(function()
    dirhelper.enter_fixture('js_py_rs')
  end)

  after_each(function()
    dirhelper.leave_fixture()
  end)

  it('should detect all manifests in stable priority order', function()
    local cwd = vim.fn.getcwd()
    local manifests = utilities.detect_monorepo_manifests()
    assert.are.same({
      {
        path = cwd .. '/package.json',
        type = 'js',
      },
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
        name = 'package_js',
        path = cwd .. '/package_js',
        visible = true,
      },
      {
        name = 'shared',
        path = cwd .. '/shared',
        visible = true,
      },
    }, members)
  end)

  it('should merge all members in stereo mode with shared path dedupe', function()
    statemgmt.set_config({ mode = 'stereo' })
    local cwd = vim.fn.getcwd()
    local members = utilities.get_workspace_members()
    assert.are.same({
      {
        name = 'package_js',
        path = cwd .. '/package_js',
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
      {
        name = 'crate_rs',
        path = cwd .. '/crate_rs',
        visible = true,
      },
    }, members)
  end)
end)
