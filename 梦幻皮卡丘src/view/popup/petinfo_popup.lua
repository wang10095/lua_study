--
-- Author: hapigames
-- Date: 2014-12-11 18:20:10
--
require "view/tagMap/Tag_popup_petinfo"

PetInfoPopup = class("PetInfoPopup",function()
	return Popup:create()
end)

PetInfoPopup.__index = PetInfoPopup
local __instance = nil


function PetInfoPopup:create()
	local ret = PetInfoPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function PetInfoPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function PetInfoPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_petinfo.PANEL_POPUP_PETINFO then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function PetInfoPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_petinfo",PATH_POPUP_PETINFO)
	local btn_return = self:getControl(Tag_popup_petinfo.PANEL_POPUP_PETINFO,Tag_popup_petinfo.BTN_CLOSE)
    btn_return:setOnClickScriptHandler(function() 
    	Utils.popUIScene(self)
    end)

	local mid = AtlasDataProxy:getInstance():get("mid")
	local form = AtlasDataProxy:getInstance():get("form")
	local isCollected = AtlasDataProxy:getInstance():get("isCollected")

	local petformConfig = ConfigManager.getPetFormConfig(mid,form)
	local petimgLayout = self:getControl(Tag_popup_petinfo.PANEL_POPUP_PETINFO,Tag_popup_petinfo.LAYOUT_PET_IMG)
	local img = TextureManager.createImg(string.format(TextureManager.RES_PATH.PET_PORTRAIT,petformConfig.model))
	Utils.addCellToParent(img,petimgLayout)
	
	local lab_petinfo = self:getControl(Tag_popup_petinfo.PANEL_POPUP_PETINFO,Tag_popup_petinfo.LAB_PETINFO)
	lab_petinfo:setString(TextManager.getPetName(mid, form))
	local lab_petinfo_desc = self:getControl(Tag_popup_petinfo.PANEL_POPUP_PETINFO,Tag_popup_petinfo.LAB_PETINFO_DESC)
	lab_petinfo_desc:setString(TextManager.getPetDesc(mid, form))

	local layout_pet1 = self:getControl(Tag_popup_petinfo.PANEL_POPUP_PETINFO,Tag_popup_petinfo.LAYOUT_PETINFO_1)
	local layout_pet2 = self:getControl(Tag_popup_petinfo.PANEL_POPUP_PETINFO,Tag_popup_petinfo.LAYOUT_PETINFO_2)
	local layout_pet3 = self:getControl(Tag_popup_petinfo.PANEL_POPUP_PETINFO,Tag_popup_petinfo.LAYOUT_PETINFO_3)
	local pet1 = Pet:create()
	pet1:set("id",1)
	pet1:set("mid",mid)
	pet1:set("form",1)
	pet1:set("star",1)
	pet1:set("aptitude",5)
	local petCell = PetCell:create(pet1)
	Utils.addCellToParent(petCell,layout_pet1)
	layout_pet2:setVisible(false)
	layout_pet3:setVisible(false)

	if ConfigManager.getPetFormConfig(mid, 2) then
		local pet2 = Pet:create()
		pet2:set("id",1)
		pet2:set("mid",mid)
		pet2:set("form",2)
		pet2:set("aptitude",5)
		pet2:set("star",3)
		local petCell = PetCell:create(pet2)
		Utils.addCellToParent(petCell,layout_pet2)
		layout_pet2:setVisible(true)
	end
	
	if ConfigManager.getPetFormConfig(mid, 3) then
		local pet3 = Pet:create()
		pet3:set("id",1)
		pet3:set("mid",mid)
		pet3:set("form",3)
		pet3:set("aptitude",5)
		pet3:set("star",5)
		local petCell = PetCell:create(pet3)
		Utils.addCellToParent(petCell,layout_pet3)
		layout_pet3:setVisible(true)
	end

    -- local img_pet_iscollect = self:getControl(Tag_popup_petinfo.PANEL_POPUP_PETINFO,Tag_popup_petinfo.IMG_PET_ISCOLLECT)
   	-- img_pet_iscollect:setVisible(isCollected)
	local function onNodeEvent(event)
		if "enter" == event then
			self:show()
			WildDataProxy:getInstance():set("isPopup",true)
		end
		if "exit" == event then
			WildDataProxy:getInstance():set("isPopup",false)
		end
	end
	self:registerScriptHandler(onNodeEvent)
    TouchEffect.addTouchEffect(self)
end