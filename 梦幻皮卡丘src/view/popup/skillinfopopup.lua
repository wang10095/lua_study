require "view/tagMap/Tag_popup_skilinfo"

SkillInfoPopup = class("SkillInfoPopup", function()
	return Popup:create()
end)

SkillInfoPopup.__index = SkillInfoPopup
local __instance = nil
function SkillInfoPopup:create()
	local ret = SkillInfoPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end


function SkillInfoPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function SkillInfoPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_skilinfo.PANEL_SKILL_INFO then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function SkillInfoPopup:onLoadScene()
	local skillType = PetAttributeDataProxy:getInstance():get("skillType")
	local skillLevel = PetAttributeDataProxy:getInstance():get("skillLevel")
	local skillName ,skillDesc,skillNumDesc
	print("====dad==" .. skillLevel)
	if PetAttributeDataProxy:getInstance():get("isPassiveSkill")==false then
		skillName = TextManager.getPetSkillName(skillType)
		skillDesc = TextManager.getPetSkillDesc(skillType)
		skillNumDesc = TextManager.getPetSkillNumDesc(skillType)
	else
		skillName = TextManager.getPassiveSkillName(skillType)
		skillDesc = TextManager.getPassiveSkillDesc(skillType)
		skillNumDesc = TextManager.getPassiveSkillNumDesc(skillType)
	end

	TuiManager:getInstance():parseScene(self,"panel_skill_info",PATH_POPUP_SKILINFO)
	local img_bg = self:getControl(Tag_popup_skilinfo.PANEL_SKILL_INFO, Tag_popup_skilinfo.IMG9_SKILL_POPUP_BG)
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(function(touch,event) 
		return true
	end,cc.Handler.EVENT_TOUCH_BEGAN )   
    listener:registerScriptHandler(function(touch,event)
    	Utils.popUIScene(self)
    end,cc.Handler.EVENT_TOUCH_ENDED)  
    local eventDispatcher = self:getEventDispatcher() -- 时间派发器 
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self) 

	local lab_skill_name = self:getControl(Tag_popup_skilinfo.PANEL_SKILL_INFO, Tag_popup_skilinfo.LAB_POPUP_SKILL_NAME2)
	lab_skill_name:setString(skillName) 
	local lab_skill_description = self:getControl(Tag_popup_skilinfo.PANEL_SKILL_INFO, Tag_popup_skilinfo.LAB_SKILL_DESCRIPTION2)
	lab_skill_description:setVerticalAlignment(1)
	lab_skill_description:setString(skillDesc)  
	local lab_skill_uplevel = self:getControl(Tag_popup_skilinfo.PANEL_SKILL_INFO, Tag_popup_skilinfo.LAB_SKILL_DESCRIPTION_NUM2)
	lab_skill_uplevel:setString(Utils.parseFormula(skillNumDesc,{skillLevel}))
	TouchEffect.addTouchEffect(self)
end
