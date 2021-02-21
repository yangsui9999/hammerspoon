local hotkey = require "hs.hotkey"
local grid = require "hs.grid"
local window = require "hs.window"
local application = require "hs.application"
local appfinder = require "hs.appfinder"
local fnutils = require "hs.fnutils"

grid.setMargins({0, 0})

applist = {
    {shortcut = '1',appname = 'Pycharm'},
    {shortcut = '2',appname = 'TickTick'},
    {shortcut = '3',appname = 'wpsoffice'},
    {shortcut = '4',appname = 'Typora'},
    {shortcut = 'G',appname = 'GoLand'},
    {shortcut = 'M',appname = 'mweb'},
    {shortcut = 'C',appname = 'Google Chrome'},
    {shortcut = 'T',appname = 'iTerm'},
    {shortcut = 'F',appname = 'Finder'},
    {shortcut = 'V',appname = 'Visual Studio Code'},
    {shortcut = 'W',appname = 'Wechat'},
    {shortcut = 'D',appname = 'TablePlus'},
    {shortcut = 'Y',appname = 'Activity Monitor'},
    {shortcut = 'E',appname = '企业微信'},
    {shortcut = 'Q',appname = 'QQ'},
    {shortcut = 'S',appname = 'SmartGit'},
}

fnutils.each(applist, function(entry)
    hotkey.bind({'alt'}, entry.shortcut, entry.appname, function()
        application.launchOrFocus(entry.appname)
        -- toggle_application(applist[i].appname)
    end)
end)

-- Toggle an application between being the frontmost app, and being hidden
function toggle_application(_app)
    local app = appfinder.appFromName(_app)
    if not app then
        application.launchOrFocus(_app)
        return
    end
    local mainwin = app:mainWindow()
    if mainwin then
        if mainwin == window.focusedWindow() then
            mainwin:application():hide()
        else
            mainwin:application():activate(true)
            mainwin:application():unhide()
            mainwin:focus()
        end
    end
end

-- https://github.com/kkamdooong/hammerspoon-control-hjkl-to-arrow
-- for hhkb just remapping control+hjkl to arrow keys.
local function pressFn(mods, key)
	if key == nil then
		key = mods
		mods = {}
	end

	return function() hs.eventtap.keyStroke(mods, key, 1000) end
end

local function remap(mods, key, pressFn)
	hs.hotkey.bind(mods, key, pressFn, nil, pressFn)	
end

remap({'ctrl'}, 'h', pressFn('left'))
remap({'ctrl'}, 'j', pressFn('down'))
remap({'ctrl'}, 'k', pressFn('up'))
remap({'ctrl'}, 'l', pressFn('right'))

