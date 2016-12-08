--
-- Author: hapigames
-- Date: 2014-12-05 16:06:24
--
Maildataproxy = class("Maildataproxy",function()
	return Model:create("Maildataproxy",{
		id = 0,
		mailid = 0,
		mail_name = 0,
		mail_type= 0,
		mail_times = 0,
		diamondnum = 0,
		goldnum = 0,
		arenanum = 0,
		pavilionnum = 0,
		itemlist = {},
		maildesc = 0,
		mail_index = 0,
		mail_state = {},
		item = {},
		param = {},
		})
end)
local _allowNewInstance = true
local __instance = nil
Maildataproxy.mailList = {}

function Maildataproxy:ctor()
	print("Maildataproxy constructor")
	if not _allowNewInstance then
		error("new instance is not allowed")
	end
end

function Maildataproxy:getInstance()
	if (__instance == nil) then
		_allowNewInstance = true
		__instance = Maildataproxy:new()
		-- silence update forever
		_allowNewInstance = false
	end
	return __instance
end

