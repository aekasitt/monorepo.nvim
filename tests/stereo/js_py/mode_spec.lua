-- ~~/tests/stereo/js_py/mode_spec.lua --

-- imports --
local statemgmt = require('monorepo.statemgmt')
local utilities = require('monorepo.utilities')
local helpers = require('tests.stereo.test_helpers')

describe('Mono/stereo behavior for JS + Python manifests', function()
  before_each(function()
    helpers.enter_fixture('js_py')
  end)

  after_each(function()
    helpers.leave_fixture()
  end)

  it('should detect javascript then python manifests in stable order', function()
    local cwd = vim.fn.getcwd()
    local manifests = utilities.detect_monorepo_manifests()
    assert.are.same({
      {
        type = 'javascript',
        path = cwd .. '/package.json',
      },
      {
        type = 'python',
        path = cwd .. '/pyproject.toml',
      },
    }, manifests)
  end)

  it('should use javascript members in mono mode', function()
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

  it('should merge javascript and python members in stereo mode', function()
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
    }, members)
  end)
end)
