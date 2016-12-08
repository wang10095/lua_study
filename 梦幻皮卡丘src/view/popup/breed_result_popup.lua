require "view/tagMap/Tag_popup_breed_result"

BreedResultPopup = class("BreedResultPopup",function()
	return Popup:create()
end)

BreedResultPopup.__index = BreedResultPopup
local __instance = nil
local currentPet = nil

function BreedResultPopup:create()
	local ret = BreedResultPopup.new()
	__instance = ret
	if ItemManager.currentPet ~= nil then
		currentPet = ItemManager.currentPet
		ItemManager.currentPet = nil
	end
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function BreedResultPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function BreedResultPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_breed_result.PANEL_BREED_RESULT then
		ret = self:getChildByTag(tagPanel)
	end
	return ret 
end
local function event_close()
	Utils.popUIScene(__instance)
end

function BreedResultPopup:onLoadScene() 
	local petConfig = ConfigManager.getPetConfig(currentPet:get("mid"))
	TuiManager:getInstance():parseScene(self,"panel_breed_result",PATH_POPUP_BREED_RESULT)
	-- local imgBg = self:getControl(Tag_popup_breed_result.PANEL_BREED_RESULT, Tag_popup_breed_result.IMG9_BREED_RESULT_BG)
	-- self:setCloseTouchNode(imgBg)
	local layoutPet = self:getControl(Tag_popup_breed_result.PANEL_BREED_RESULT, Tag_popup_breed_result.LAYOUT_GET_PET)
	local petCell = PetCell:create(currentPet)
	Utils.addCellToParent(petCell,layoutPet,true)

	local labPetName = self:getControl(Tag_popup_breed_result.PANEL_BREED_RESULT, Tag_popup_breed_result.LAB_GET_PET_NAME)
	labPetName:setString(TextManager.getPetName(currentPet:get("mid"),currentPet:get("form")))
	local imgPetAptitude = self:getControl(Tag_popup_breed_result.PANEL_BREED_RESULT, Tag_popup_breed_result.IMG_PET_APTITUDE)
	-- local filename = Utils.getFileTexture()
	imgPetAptitude:setSpriteFrame("ui_pet_list/img_aptitude" .. currentPet:get("aptitude") .. ".png")
	local labPetCharacter = self:getControl(Tag_popup_breed_result.PANEL_BREED_RESULT, Tag_popup_breed_result.LAB_GET_PET_CHARACTER)
	labPetCharacter:setString(TextManager.getPetCharacterName(currentPet:get("character")))
	
	local labLifeGrowNum = self:getControl(Tag_popup_breed_result.PANEL_BREED_RESULT, Tag_popup_breed_result.LAB_GET_PET_LIFE_GROW_NUM)
	labLifeGrowNum:setString(Utils.roundingOff(currentPet:GetgrowAttribute(1)))
	local labAttackGrowNum = self:getControl(Tag_popup_breed_result.PANEL_BREED_RESULT, Tag_popup_breed_result.LAB_GET_PET_ATTACK_GROW_NUM)
	labAttackGrowNum:setString(Utils.roundingOff(currentPet:GetgrowAttribute(2)))
	
	local btnClose = self:getControl(Tag_popup_breed_result.PANEL_BREED_RESULT, Tag_popup_breed_result.BTN_POPUP_CLOSE)
	btnClose:setOnClickScriptHandler(event_close)
	TouchEffect.addTouchEffect(self)
end