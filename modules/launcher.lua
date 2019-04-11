local hotkey = require "hs.hotkey"
local grid = require "hs.grid"
local window = require "hs.window"
local application = require "hs.application"
local appfinder = require "hs.appfinder"
local fnutils = require "hs.fnutils"

grid.setMargins({0, 0})

applist = {
    {shortcut = 'M',appname = 'mweb'},
    {shortcut = 'C',appname = 'Google Chrome'},
    {shortcut = 'T',appname = 'iTerm'},
    {shortcut = 'F',appname = 'Finder'},
    {shortcut = 'V',appname = 'Visual Studio Code'},
    {shortcut = 'P',appname = 'Pycharm'},
    {shortcut = 'W',appname = 'Wechat'},
    {shortcut = 'D',appname = 'DataGrip'},
    {shortcut = 'Y',appname = 'Activity Monitor'},
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
