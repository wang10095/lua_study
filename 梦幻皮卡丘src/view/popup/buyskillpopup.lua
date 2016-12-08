require "view/tagMap/Tag_ui_pet_attribute"

BuySkillPopup = class("BuySkillPopup", function ()
	return Popup:create()
end)

BuySkillPopup.__index = BuySkillPopup
local __instance = nil

function BuySkillPopup:create()
	local ret = BuySkillPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function BuySkillPopup:getControl(tagPanel, tagControl)
    local ret = nil
    ret = self:getPanel(tagPanel):getChildByTag(tagControl)
    return ret
end

function BuySkillPopup:getPanel(tagPanel)
	local ret = nil
	if  tagPanel == Tag_ui_pet_attribute.PANEL_BUYSKILL then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_buyskill()
	if tonumber(Player:getInstance():get("diamond")) < tonumber(lab_value:getString()) then
		TipManager.showTip("钻石不足")
		return
	end

	local proxy = NormalDataProxy:getInstance()
	if proxy.confirmHandler ~= nil then
		proxy.confirmHandler()
	end
	proxy.confirmHandler = nil
	proxy:set("buyskillpoints",numStep_num:getValue())
	Utils.popUIScene(__instance)
end
local function event_close()
	Utils.popUIScene(__instance)
end

local function event_click_change(p_sender,p_value)
	local proxy = PetAttributeDataProxy:getInstance()
	remainPoint = 10 - proxy:get("skill_points")
	if p_value > remainPoint then
		p_value = p_value -1
		numStep_num:setValue(p_value)
	end
	lab_value:setString(p_value)
end

function BuySkillPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_buyskill",PATH_UI_PET_ATTRIBUTE)
	
	-- local img_bg = self:getControl(Tag_ui_pet_attribute.PANEL_BUYSKILL, Tag_ui_pet_attribute.IMG9_BUYSKILL_BG)
	-- self:setCloseTouchNode(img_bg)
	local btn_sure_buyskill = self:getControl(Tag_ui_pet_attribute.PANEL_BUYSKILL, Tag_ui_pet_attribute.BTN_SURE_BUYSKILL)
	btn_sure_buyskill:setOnClickScriptHandler(event_buyskill)
	local btn_cancel_buyskill = self:getControl(Tag_ui_pet_attribute.PANEL_BUYSKILL, Tag_ui_pet_attribute.BTN_CANCEL_BUYSKILL)
	btn_cancel_buyskill:setOnClickScriptHandler(event_close)

	numStep_num = self:getControl(Tag_ui_pet_attribute.PANEL_BUYSKILL, Tag_ui_pet_attribute.NUMSTEP_NUM)
	numStep_num:setOnValueChangedScriptHandler(event_click_change)
	numStep_num:setScale(0.8)

	lab_value = self:getControl(Tag_ui_pet_attribute.PANEL_BUYSKILL,Tag_ui_pet_attribute.LAB_COST_DIAMOND)
	lab_value:setString("1")
	TouchEffect.addTouchEffect(self)
end

