require "view/tagMap/Tag_ui_weekgift"

ChoosePetPopup = class("ChoosePetPopup",function()
	return Popup:create()
end)

ChoosePetPopup.__index = ChoosePetPopup
local __instance = nil
local current = 1
local layout_petchose
local loadPets = {}
local btn_leftArraw,btn_rightArraw

function ChoosePetPopup:create()
	local ret = ChoosePetPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function ChoosePetPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function ChoosePetPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_weekgift.PANEL_POPUP_PETCHOSE then
		ret = self:getChildByTag(tagPanel)
	end
	return ret 
end

local function event_close()
	Utils.popUIScene(__instance)
end

local function event_leftpet()
	current = current - 1
	layout_petchose:removeAllChildren()
	local petMid = ConfigManager.getSevenCommonConfig('pet' .. current)
	local petModel = ConfigManager.getPetFormConfig(petMid, 1).model
	local petList = TextureManager.createImg(TextureManager.RES_PATH.PET_LIST,petModel)
	Utils.addCellToParent(petList,layout_petchose)
	if current == 1 then
		btn_leftArraw:setVisible(false)
		btn_rightArraw:setVisible(true)
	elseif current == 4 then
		btn_leftArraw:setVisible(true)
		btn_rightArraw:setVisible(false)
	else
		btn_leftArraw:setVisible(true)
		btn_rightArraw:setVisible(true)
	end
end

local function event_rightpet()
	current = current + 1 
	layout_petchose:removeAllChildren()
	local petMid = ConfigManager.getSevenCommonConfig('pet' .. current)
	local petModel = ConfigManager.getPetFormConfig(petMid, 1).model
	local petList = TextureManager.createImg(TextureManager.RES_PATH.PET_LIST,petModel)
	Utils.addCellToParent(petList,layout_petchose)
	if current == 1 then
		btn_leftArraw:setVisible(false)
		btn_rightArraw:setVisible(true)
	elseif current == 4 then
		btn_leftArraw:setVisible(true)
		btn_rightArraw:setVisible(false)
	else
		btn_leftArraw:setVisible(true)
		btn_rightArraw:setVisible(true)
	end
end

local function callback_choose_pet(result)
	local pet = {}
	for k,v in pairs(loadPets[current]) do
		if k == "id" then
			pet["id"] = result["id"]
		else
			pet[k] = v
		end
	end
	ItemManager.addPet(pet)
	Utils.popUIScene(__instance)
	TipManager.showTip("领取宠物成功")
end

local function callback_load_pets(result)
	if result["mid"] == 0 then
		current = 1
	else
		for i,v in ipairs(result["pets"]) do
			if v["mid"] == result["mid"] then
				current = i
			end
		end
	end
	loadPets = result["pets"]	
	local petMid = ConfigManager.getSevenCommonConfig('pet' .. current)
	local petModel = ConfigManager.getPetFormConfig(petMid, 1).model
	local petList = TextureManager.createImg(TextureManager.RES_PATH.PET_LIST,petModel)
	Utils.addCellToParent(petList,layout_petchose)
	if current == 1 then
		btn_leftArraw:setVisible(false)
		btn_rightArraw:setVisible(true)
	elseif current == 4 then
		btn_leftArraw:setVisible(true)
		btn_rightArraw:setVisible(false)
	else
		btn_leftArraw:setVisible(true)
		btn_rightArraw:setVisible(true)
	end
end

function ChoosePetPopup:onLoadScene() 	
	loadPets = {}  
	TuiManager:getInstance():parseScene(self,"panel_popup_petchose",PATH_UI_WEEKGIFT)
	local btnClose = self:getControl(Tag_ui_weekgift.PANEL_POPUP_PETCHOSE, Tag_ui_weekgift.BTN_PETCHOSE_CLOSE)
	btnClose:setOnClickScriptHandler(event_close)

	layout_petchose = self:getControl(Tag_ui_weekgift.PANEL_POPUP_PETCHOSE, Tag_ui_weekgift.LAYOUT_PETCHOSE)
	btn_leftArraw = self:getControl(Tag_ui_weekgift.PANEL_POPUP_PETCHOSE, Tag_ui_weekgift.BTN_LEFTARROW)
	btn_rightArraw = self:getControl(Tag_ui_weekgift.PANEL_POPUP_PETCHOSE, Tag_ui_weekgift.BTN_RIGHTARROW)
	btn_leftArraw:setOnClickScriptHandler(event_leftpet)
	btn_rightArraw:setOnClickScriptHandler(event_rightpet)

	local btn_common_chose = self:getControl(Tag_ui_weekgift.PANEL_POPUP_PETCHOSE, Tag_ui_weekgift.BTN_COMMON_CHOSE)
	btn_common_chose:setOnClickScriptHandler(function() 
		NetManager.sendCmd("choosepet",callback_choose_pet,loadPets[current]["mid"])
	end)

	local function onTouchNode(event)
		if "enter" == event then
			self:show()
			NetManager.sendCmd("loadseventhpet",callback_load_pets)
		end
	end
	self:registerScriptHandler(onTouchNode)
end





