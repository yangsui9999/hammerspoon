local hotkey = require "hs.hotkey"
local caffeinate = require "hs.caffeinate"
local audiodevice = require "hs.audiodevice"

-- lock screen
hotkey.bind(hyperSimpleAlt, "L", function()
  caffeinate.lockScreen()
  -- caffeinate.startScreensaver()
end)

-- mute on sleep
function muteOnWake(eventType)
  if (eventType == caffeinate.watcher.systemDidWake) then
    local output = audiodevice.defaultOutputDevice()
    output:setMuted(true)
  end
end
caffeinateWatcher = caffeinate.watcher.new(muteOnWake)
caffeinateWatcher:start()

hs.hotkey.bind({'ctrl', 'cmd'}, ".", function()
		  hs.alert.show("App path:        "
				..hs.window.focusedWindow():application():path()
				.."\n"
				.."App name:      "
				..hs.window.focusedWindow():application():name()
				.."\n"
				.."IM source id:  "
				..hs.keycodes.currentSourceID())
end)

-- setup input method
local function Chinese()
  hs.keycodes.currentSourceID("com.apple.inputmethod.SCIM.ITABC")
end

local function English()
  hs.keycodes.currentSourceID("com.apple.keylayout.ABC")
end

local function set_app_input_method(app_name, set_input_method_function, event)
  event = event or hs.window.filter.windowFocused

  hs.window.filter.new(app_name)
    :subscribe(event, function()
                 set_input_method_function()
              end)
end

-- switch input method
set_app_input_method('微信', Chinese)
set_app_input_method('企业微信', Chinese)
set_app_input_method('滴答清单', Chinese)
set_app_input_method('WPS Office', Chinese)
set_app_input_method('iTerm2', English)
set_app_input_method('TablePlus', English)
set_app_input_method('PyCharm', English)
set_app_input_method('GoLand', English)
set_app_input_method('Typora', Chinese)

