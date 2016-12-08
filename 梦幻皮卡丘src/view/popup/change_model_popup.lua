require "view/tagMap/Tag_ui_pet_attribute"

ChangeModelPopup = class("ChangeModelPopup",function()
	return Popup:create()
end)

ChangeModelPopup.__index = ChangeModelPopup
local __instance = nil
local currentPet = nil

function ChangeModelPopup:create()
	local ret = ChangeModelPopup.new()
	__instance = ret
	if ItemManager.currentPet ~= nil then
		currentPet = ItemManager.currentPet
		ItemManager.currentPet = nil
	end
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function ChangeModelPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function ChangeModelPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_pet_breedhouse.PANEL_CHANGE_MODEL then
		ret = self:getChildByTag(tagPanel)
	end
	return ret 
end
local function event_close()
	Utils.popUIScene(__instance)
end

function ChangeModelPopup:onLoadScene() 
	local petConfig = ConfigManager.getPetConfig(currentPet:get("mid"))
	TuiManager:getInstance():parseScene(self,"panel_change_model",PATH_UI_PET_ATTRIBUTE)

	local btnClose = self:getControl(Tag_ui_pet_attribute.PANEL_CHANGE_MODEL, Tag_ui_pet_attribute.BTN_CLOSE_CHANGE_MODEL)
	btnClose:setOnClickScriptHandler(event_close)

	local petFormConfig = ConfigManager.getPetFormConfig(currentPet:get("mid"), currentPet:get("form"))

	for i=1, 3 do
		local layoutModel = self:getControl(Tag_ui_pet_attribute.PANEL_CHANGE_MODEL, Tag_ui_pet_attribute["LAYOUT_MODEL" .. i])
		local petModel = TextureManager.createImg(TextureManager.RES_PATH.PET_PORTRAIT , petFormConfig.model)
		Utils.addCellToParent(petModel,layoutModel,true)
	end
	TouchEffect.addTouchEffect(self)
end








