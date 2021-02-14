-- window management
local application = require "hs.application"
local hotkey = require "hs.hotkey"
local window = require "hs.window"
local layout = require "hs.layout"
local grid = require "hs.grid"
local hints = require "hs.hints"
local screen = require "hs.screen"
local alert = require "hs.alert"
local fnutils = require "hs.fnutils"
local geometry = require "hs.geometry"
local mouse = require "hs.mouse"

-- default 0.2
window.animationDuration = 0

-- left half
hotkey.bind(hyperSimpleCtrl, "H", function()
  if window.focusedWindow() then
    window.focusedWindow():moveToUnit(layout.left50)
  else
    alert.show("No active window")
  end
end)

-- right half
hotkey.bind(hyperSimpleCtrl, "L", function()
  window.focusedWindow():moveToUnit(layout.right50)
end)

-- top half
hotkey.bind(hyperSimpleCtrl, "K", function()
  window.focusedWindow():moveToUnit'[0,0,100,50]'
end)

-- bottom half
hotkey.bind(hyperSimpleCtrl, "J", function()
  window.focusedWindow():moveToUnit'[0,50,100,100]'
end)

-- left top quarter
hotkey.bind(hyperSimpleCtrl, "Y", function()
  window.focusedWindow():moveToUnit'[0,0,50,50]'
end)

-- right bottom quarter
hotkey.bind(hyperSimpleCtrl, "O", function()
  window.focusedWindow():moveToUnit'[50,50,100,100]'
end)

-- right top quarter
hotkey.bind(hyperSimpleCtrl, "U", function()
  window.focusedWindow():moveToUnit'[50,0,100,50]'
end)

-- left bottom quarter
hotkey.bind(hyperSimpleCtrl, "I", function()
  window.focusedWindow():moveToUnit'[0,50,50,100]'
end)

-- full screen
hotkey.bind(hyperSimpleCtrl, 'F', function() 
  window.focusedWindow():toggleFullScreen()
end)

-- center window
hotkey.bind(hyperSimpleCtrl, 'C', function() 
  window.focusedWindow():centerOnScreen()
end)

-- maximize window
hotkey.bind(hyperSimpleCtrl, 'M', function() toggle_maximize() end)

-- defines for window maximize toggler
local frameCache = {}
-- toggle a window between its normal size, and being maximized
function toggle_maximize()
    local win = window.focusedWindow()
    if frameCache[win:id()] then
        win:setFrame(frameCache[win:id()])
        frameCache[win:id()] = nil
    else
        frameCache[win:id()] = win:frame()
        win:maximize()
    end
end

-- display a keyboard hint for switching focus to each window
hotkey.bind(hyperShift, '/', function()
    hints.windowHints()
    -- Display current application window
    -- hints.windowHints(hs.window.focusedWindow():application():allWindows())
end)

-- switch active window
hotkey.bind(hyperShift, "H", function()
  window.switcher.nextWindow()
end)

-- move active window to previous monitor
hotkey.bind(hyperShift, "Left", function()
  window.focusedWindow():moveOneScreenWest()
end)

-- move active window to next monitor
hotkey.bind(hyperShift, "Right", function()
  window.focusedWindow():moveOneScreenEast()
end)

-- move cursor to previous monitor
hotkey.bind(hyperCtrl, "Left", function ()
  focusScreen(window.focusedWindow():screen():previous())
end)

-- move cursor to next monitor
hotkey.bind(hyperCtrl, "Right", function ()
  focusScreen(window.focusedWindow():screen():next())
end)


--Predicate that checks if a window belongs to a screen
function isInScreen(screen, win)
  return win:screen() == screen
end

function focusScreen(screen)
  --Get windows within screen, ordered from front to back.
  --If no windows exist, bring focus to desktop. Otherwise, set focus on
  --front-most application window.
  local windows = fnutils.filter(
      window.orderedWindows(),
      fnutils.partial(isInScreen, screen))
  local windowToFocus = #windows > 0 and windows[1] or window.desktop()
  windowToFocus:focus()

  -- move cursor to center of screen
  local pt = geometry.rectMidPoint(screen:fullFrame())
  mouse.setAbsolutePosition(pt)
end

-- maximized active window and move to selected monitor
moveto = function(win, n)
  local screens = screen.allScreens()
  if n > #screens then
    alert.show("Only " .. #screens .. " monitors ")
  else
    local toWin = screen.allScreens()[n]:name()
    alert.show("Move " .. win:application():name() .. " to " .. toWin)

    layout.apply({{nil, win:title(), toWin, layout.maximized, nil, nil}})
    
  end
end

-- move cursor to monitor 1 and maximize the window
hotkey.bind(hyperShift, "1", function()
  local win = window.focusedWindow()
  moveto(win, 1)
end)

hotkey.bind(hyperShift, "2", function()
  local win = window.focusedWindow()
  moveto(win, 2)
end)

hotkey.bind(hyperShift, "3", function()
  local win = window.focusedWindow()
  moveto(win, 3)
end)

local maximizeApps = {
    "/Applications/iTerm.app",
    "/Applications/Google Chrome.app",
    "/System/Library/CoreServices/Finder.app",
}
local windowCreateFilter = hs.window.filter.new():setDefaultFilter()
windowCreateFilter:subscribe(
    hs.window.filter.windowCreated,
    function (win, ttl, last)
        for index, value in ipairs(maximizeApps) do
            if win:application():path() == value then
                win:maximize()
                return true
            end
        end
end)


-- Power operation.
caffeinateOnIcon = [[ASCII:
.....1a..........AC..........E
..............................
......4.......................
1..........aA..........CE.....
e.2......4.3...........h......
..............................
..............................
.......................h......
e.2......6.3..........t..q....
5..........c..........s.......
......6..................q....
......................s..t....
.....5c.......................
]]

caffeinateOffIcon = [[ASCII:
.....1a.....x....AC.y.......zE
..............................
......4.......................
1..........aA..........CE.....
e.2......4.3...........h......
..............................
..............................
.......................h......
e.2......6.3..........t..q....
5..........c..........s.......
......6..................q....
......................s..t....
...x.5c....y.......z..........
]]
local caffeinateTrayIcon = hs.menubar.new()

local function caffeinateSetIcon(state)
    caffeinateTrayIcon:setIcon(state and caffeinateOnIcon or caffeinateOffIcon)

    if state then
        caffeinateTrayIcon:setTooltip("Sleep never sleep")
    else
        caffeinateTrayIcon:setTooltip("System will sleep when idle")
    end
end

local function toggleCaffeinate()
    local sleepStatus = hs.caffeinate.toggle("displayIdle")
    if sleepStatus then
        hs.notify.new({title="HammerSpoon", informativeText="System never sleep"}):send()
    else
        hs.notify.new({title="HammerSpoon", informativeText="System will sleep when idle"}):send()
    end

    caffeinateSetIcon(sleepStatus)
end

hs.hotkey.bind(hyperSimpleCtrl, "[", toggleCaffeinate)
caffeinateTrayIcon:setClickCallback(toggleCaffeinate)
caffeinateSetIcon(sleepStatus)

