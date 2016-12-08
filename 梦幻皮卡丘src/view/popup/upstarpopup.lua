require "view/tagMap/Tag_popup_upstar"
UpStarPopup = class("UpStarPopup", function()
	return Popup:create()
end)

UpStarPopup.__index = UpStarPopup
local __instance = nil
local currentPet = nil

function UpStarPopup:create()
	local ret = UpStarPopup.new()
	__instance = ret
	if ItemManager.currentPet ~= nil then
		currentPet = ItemManager.currentPet
		ItemManager.currentPet = nil
	end
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function UpStarPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function UpStarPopup:getPanel(tagPanel)
	local ret = nil
	if  tagPanel == Tag_popup_upstar.PANEL_POPUP_UPSTAR then
		ret = self:getChildByTag(tagPanel)
	end
	return ret 
end

local function event_close()
	Utils.popUIScene(__instance)
end

function UpStarPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_upstar",PATH_POPUP_UPSTAR)
	local btn_close   = self:getControl(Tag_popup_upstar.PANEL_POPUP_UPSTAR, Tag_popup_upstar.BTN_CLOSE_UPSTAR)
	btn_close:setOnClickScriptHandler(event_close)
	local img_bg = self:getControl(Tag_popup_upstar.PANEL_POPUP_UPSTAR, Tag_popup_upstar.IMG9_UPSTAR_BG)
	-- self:setCloseTouchNode(img_bg)
	local petFormConfig = ConfigManager.getPetFormConfig(currentPet:get("mid"), currentPet:get("form"))
	local  petGrowAttributes = PetAttributeDataProxy:getInstance():get("growAttributes")

	local maxStar = ConfigManager.getPetCommonConfig('star_limit')
	for i = 1, maxStar do
		local starOld = self:getControl(Tag_popup_upstar.PANEL_POPUP_UPSTAR, Tag_popup_upstar["IMG_OLD_STAR" .. i])
		local starNow = self:getControl(Tag_popup_upstar.PANEL_POPUP_UPSTAR, Tag_popup_upstar["IMG_NOW_STAR" .. i])
		if i > currentPet:get("star")-1 then
			starOld:setVisible(false)
		else
			starOld:setVisible(true)
		end
		if i>currentPet:get("star") then
			starNow:setVisible(false)
		else
			starNow:setVisible(true)
		end
	end

	local layout_petupstar_old = self:getControl(Tag_popup_upstar.PANEL_POPUP_UPSTAR, Tag_popup_upstar.LAYOUT_PETUPSTAR_OLD)
	local layout_petupstar_now = self:getControl(Tag_popup_upstar.PANEL_POPUP_UPSTAR, Tag_popup_upstar.LAYOUT_PETUPSTAR_NOW)
	local petOld = TextureManager.createImg(TextureManager.RES_PATH.PET_LIST,petGrowAttributes[3]) 
	Utils.addCellToParent(petOld,layout_petupstar_old,true)
	local petNow = TextureManager.createImg(TextureManager.RES_PATH.PET_LIST,petFormConfig.model) 
	Utils.addCellToParent(petNow,layout_petupstar_now,true)
	
	local labels = {
		{tag =Tag_popup_upstar.LAB_LIFE_GROW_OLD ,text = petGrowAttributes[1]},
		{tag =Tag_popup_upstar.LAB_ATTACK_GROW_OLD ,text = petGrowAttributes[2]},
		{tag =Tag_popup_upstar.LAB_LIFE_GROW_NOW ,text = currentPet:GetgrowAttribute(1)},
		{tag =Tag_popup_upstar.LAB_ATTACK_GROW_NOW ,text = currentPet:GetgrowAttribute(2)}
	}
	for i,v in ipairs(labels) do
		local label = self:getControl(Tag_popup_upstar.PANEL_POPUP_UPSTAR,v.tag)
		label:setString(Utils.roundingOff(v.text))
	end
	TouchEffect.addTouchEffect(self)
end












