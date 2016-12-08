
require "view/tagMap/Tag_ui_wild"

PetIntroducePopup = class("PetIntroducePopup",function()
	return Popup:create()
end)

PetIntroducePopup.__index = PetIntroducePopup
local __instance = nil
local currentPet = nil

function PetIntroducePopup:create()
	local ret = PetIntroducePopup.new()
	__instance = ret
	print("ItemManager.currentPet ")
	print(ItemManager.currentPet )
	if ItemManager.currentPet ~= nil then
		print(ItemManager.currentPet )
		currentPet = ItemManager.currentPet
		ItemManager.currentPet = nil
	end
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function PetIntroducePopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function PetIntroducePopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_wild.PANEL_PET_INTRODUCE then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_close()
	Utils.popUIScene(__instance)
end


function PetIntroducePopup:onLoadScene()
	-- print("=====" .. currentPet["mid"],currentPet["form"])
	TuiManager:getInstance():parseScene(self,"panel_pet_introduce",PATH_UI_WILD)
	local btnClose = self:getControl(Tag_ui_wild.PANEL_PET_INTRODUCE, Tag_ui_wild.BTN_CLOSE_PET_INFO)
	btnClose:setOnClickScriptHandler(event_close)
	local layout_pet = self:getControl(Tag_ui_wild.PANEL_PET_INTRODUCE, Tag_ui_wild.LAYOUT_PET_BIG_IMAGE)
	local petFormConfig = ConfigManager.getPetFormConfig(currentPet["mid"], currentPet["form"])
	local pet = TextureManager.createImg(TextureManager.RES_PATH.PET_PORTRAIT,petFormConfig.model)
	Utils.addCellToParent(pet,layout_pet)
	local petIntroduce =  self:getControl(Tag_ui_wild.PANEL_PET_INTRODUCE, Tag_ui_wild.LAB_PET_INTRODUCE)
	local petInfo = TextManager.getPetDesc(currentPet["mid"], currentPet["form"])
	petIntroduce:setString(petInfo)
	local layoutPetItem =   self:getControl(Tag_ui_wild.PANEL_PET_INTRODUCE, Tag_ui_wild.LAYOUT_ITEM_INFO)
	for i=1,3 do
		local layoutItem = layoutPetItem:getChildByTag(Tag_ui_wild["LAYOUT_ITEM" .. i])
		local item = TextureManager.createImg(TextureManager.RES_PATH.ITEM_IMAGE,4,4)
		Utils.addCellToParent(item,layoutItem,true)
	end

	local function  onTouchNode(event)
		if event == "enter" then
			self:show()
		end
	end
	self:registerScriptHandler(onTouchNode)
end
