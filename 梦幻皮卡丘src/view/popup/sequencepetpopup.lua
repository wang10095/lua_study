require "view/tagMap/Tag_popup_pet_sequence"

SequencePetPopup = class("SequencePetPopup", function()
	return Popup:create()
end)

SequencePetPopup.__index = SequencePetPopup
local __instance = nil
function SequencePetPopup:create()
	local ret = SequencePetPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function SequencePetPopup:getControl(tagPanel, tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function SequencePetPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_pet_sequence.PANEL_POPUP_SEQUENCE then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_close(pSender)
	local tag = pSender:getTag()
	local k = {
		Tag_popup_pet_sequence.BTN_SEQUENCE_1,
		Tag_popup_pet_sequence.BTN_SEQUENCE_2,
		Tag_popup_pet_sequence.BTN_SEQUENCE_3,
		Tag_popup_pet_sequence.BTN_SEQUENCE_4
	}

	local value = {
		'level',
		'star',
		'rank',
		'aptitude'
	}

	for i = 1 , #k do
		if tag == k[i] then
			PetAttributeDataProxy:getInstance():set("sequence",value[i])
			PetAttributeDataProxy:getInstance():set("sift",0)
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

function SequencePetPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_sequence",PATH_POPUP_PET_SEQUENCE)
	local btn_sequence_1 = self:getControl(Tag_popup_pet_sequence.PANEL_POPUP_SEQUENCE, Tag_popup_pet_sequence.BTN_SEQUENCE_1)
	btn_sequence_1:setOnClickScriptHandler(event_close)
	local label1 = btn_sequence_1:getLabel()
	local btn_sequence_2 = self:getControl(Tag_popup_pet_sequence.PANEL_POPUP_SEQUENCE, Tag_popup_pet_sequence.BTN_SEQUENCE_2)
	btn_sequence_2:setOnClickScriptHandler(event_close)
	local btn_sequence_3 = self:getControl(Tag_popup_pet_sequence.PANEL_POPUP_SEQUENCE, Tag_popup_pet_sequence.BTN_SEQUENCE_3)
	btn_sequence_3:setOnClickScriptHandler(event_close)
	local btn_sequence_4 = self:getControl(Tag_popup_pet_sequence.PANEL_POPUP_SEQUENCE, Tag_popup_pet_sequence.BTN_SEQUENCE_4)
	btn_sequence_4:setOnClickScriptHandler(event_close)

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