require "view/tagMap/Tag_ui_pet_list"

SiftPetPopup = class("SiftPetPopup", function()
	return Popup:create()
end)

SiftPetPopup.__index = SiftPetPopup
local __instance = nil
function SiftPetPopup:create()
	local ret = SiftPetPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function SiftPetPopup:getControl(tagPanel, tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function SiftPetPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_pet_list.PANEL_POPUP_SIFT then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_close(pSender)
	local tag = pSender:getTag()
	local k = {
		Tag_ui_pet_list.BTN_SIFT_1,
		Tag_ui_pet_list.BTN_SIFT_2,
		Tag_ui_pet_list.BTN_SIFT_3,
		Tag_ui_pet_list.BTN_SIFT_4,
		Tag_ui_pet_list.BTN_SIFT_5,
		Tag_ui_pet_list.BTN_SIFT_6
	}

	for i = 1 , #k do
		if tag == k[i] then
			PetAttributeDataProxy:getInstance():set("sift",i-1)
		end
	end
	local proxy = NormalDataProxy:getInstance()
	if proxy.confirmHandler then
		proxy.confirmHandler()
	end
	proxy.confirmHandler  = nil
	proxy.cancelHandler = nil
	Utils.popUIScene(__instance)
end

function SiftPetPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_sift",PATH_UI_PET_LIST)

	for i = 1,6 do
		local btn_sift = self:getControl(Tag_ui_pet_list.PANEL_POPUP_SIFT, Tag_ui_pet_list["BTN_SIFT_" .. i])
		btn_sift:setOnClickScriptHandler(event_close)
	end

	local function onNodeEvent(event)
		if "enter" == event then
			self:show()
			PetAttributeDataProxy:getInstance():set("isPopup",true)
		end
		if "exit" == event then
			PetAttributeDataProxy:getInstance():set("isPopup",false)
		end
	end
	self:registerScriptHandler(onNodeEvent)
	TouchEffect.addTouchEffect(self)

end