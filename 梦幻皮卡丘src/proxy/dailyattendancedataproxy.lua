--
-- Author: hapigames
-- Date: 2014-12-04 10:59:54
--
Dailyattendancedataproxy = class("Dailyattendancedataproxy",function()
	return Model:create("Dailyattendancedataproxy",{
		dailyattendance_num = 0,
		today_state = 0
		})
end)
local _allowNewInstance = false
local __instance = nil
Dailyattendancedataproxy.attendanceList = {}

function Dailyattendancedataproxy:ctor()
	print("Dailyattendancedataproxy constructor")
	if not _allowNewInstance then
		error("new instance is not allowed")
	end
end

function Dailyattendancedataproxy:getInstance()
	if (__instance == nil) then
		_allowNewInstance = true
		__instance = Dailyattendancedataproxy:new()
		-- silence update forever
		_allowNewInstance = false
	end
	return __instance
end
