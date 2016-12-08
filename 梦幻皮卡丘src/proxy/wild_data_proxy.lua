
WildDataProxy = class("WildDataProxy",function()
	return Model:create("WildDataProxy",{
		buyNum = 0, --购买一个是1 购买十个是10 
		isPopup = false,
		newPet_mid = 0,
		newPet_form = 0,
		isPopup = false
		})
end)
local _allowNewInstance = false
local __instance = nil

WildDataProxy.itemsList = {}

function WildDataProxy:ctor()
	print("WildDataProxy constructor")
	if not _allowNewInstance then
		error("new instance is not allowed")
	end
end

function WildDataProxy:getInstance()
	if (__instance == nil) then
		_allowNewInstance = true
		__instance = WildDataProxy:new()
		-- silence update forever
		_allowNewInstance = false
	end
	return __instance
end
