-- ~~/tests/stereo/config/setup_mode_spec.lua --

-- imports --
local monorepo = require('monorepo')
local statemgmt = require('monorepo.statemgmt')
local dirhelper = require('tests.stereo.dirhelper')

describe('Mono/stereo setup mode configuration', function()
  before_each(function()
    dirhelper.enter_fixture('js_py_rs')
  end)

  after_each(function()
    dirhelper.leave_fixture()
  end)

  it('should default to mono mode in config', function()
    local config = statemgmt.get_config()
    assert.are.same('mono', config.mode)
  end)

  it('should fallback invalid mode value to mono during setup', function()
    monorepo.setup({ mode = 'invalid-mode' })
    local config = statemgmt.get_config()
    assert.are.same('mono', config.mode)
  end)

  it('should accept mode from second setup argument', function()
    monorepo.setup({ plugin_name = 'monorepo.nvim' }, { mode = 'stereo' })
    local config = statemgmt.get_config()
    assert.are.same('stereo', config.mode)
  end)
end)
