local pathwatcher = require "hs.pathwatcher"
local alert = require "hs.alert"

-- http://www.hammerspoon.org/go/#fancyreload
-- add test comments
function reloadConfig(files)
	doReload = false
	for _, file in pairs(files) do
		if file:sub(-4) == ".lua" then
			doReload = true
		end
	end
	if doReload then
		hs.reload()
	end
end

pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon", reloadConfig):start()
-- alert.show("Hammerspoon Config Reloaded")
hs.notify.new({title="Hammerspoon", informativeText="YangSui, All the config reloaded!"}):send()
