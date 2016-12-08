require "view/tagMap/Tag_popup_rank_promote"

PetRankPromotePopup = class("PetRankPromotePopup", function()
    return Popup:create()
end)

PetRankPromotePopup.__index = PetRankPromotePopup
local __instance = nil
local currentPet = nil

function PetRankPromotePopup:create()
	print("create breakthrough popup")
	local ret = PetRankPromotePopup.new()
	__instance = ret
	if (ItemManager.currentPet ~= nil) then
		currentPet = ItemManager.currentPet
		ItemManager.currentPet = nil
	end
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)	
	return ret
end

function PetRankPromotePopup:getControl(tagPanel, tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function PetRankPromotePopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_rank_promote.PANEL_RANK_PROMOTE then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_popup_close()
	Utils.popUIScene(__instance)
end

function PetRankPromotePopup:onLoadScene()
    TuiManager:getInstance():parseScene(self,"panel_rank_promote",PATH_POPUP_RANK_PROMOTE)
    -- local imgBg = self:getControl(Tag_popup_rank_promote.PANEL_RANK_PROMOTE, Tag_popup_rank_promote.IMG9_RANK_PROMOTE_BG)
    -- self:setCloseTouchNode(imgBg)
    local btnClosePopup = self:getControl(Tag_popup_rank_promote.PANEL_RANK_PROMOTE,Tag_popup_rank_promote.BTN_RANK_GROW_CLOSE)
	btnClosePopup:setOnClickScriptHandler(event_popup_close)
    local layoutPet = self:getControl(Tag_popup_rank_promote.PANEL_RANK_PROMOTE, Tag_popup_rank_promote.LAYOUT_PET_UPRANK)
    local petFormConfig = ConfigManager.getPetFormConfig(currentPet:get("mid"),currentPet:get("form"))
	local petImg = TextureManager.createImg(TextureManager.RES_PATH.PET_LIST,petFormConfig.model)
	Utils.addCellToParent(petImg,layoutPet,true)
	local petConfig = ConfigManager.getPetConfig(currentPet:get("mid"))
   	local petTrainConfig = ConfigManager.getPetTrainConfig(petConfig.train_id, currentPet:get("rank"),currentPet:get("rankPoint"))
   	local oldRankAttributes = PetAttributeDataProxy:getInstance():get("rankAttributes")
	local labels = {
		{tag = Tag_popup_rank_promote.LAB_OLD_RANK, text = currentPet:get("rank")-1},
		{tag = Tag_popup_rank_promote.LAB_NEW_RANK, text = currentPet:get("rank")},
		{tag = Tag_popup_rank_promote.LAB_LIFE_RANK_NUM, text = "+" .. petTrainConfig.attributeAddition[1]-oldRankAttributes[1]},
		{tag = Tag_popup_rank_promote.LAB_COMMON_ATTACK_RANK_NUM, text = "+" .. petTrainConfig.attributeAddition[2]-oldRankAttributes[2]}
	}
	for i,v in ipairs(labels) do
		local label = self:getControl(Tag_popup_rank_promote.PANEL_RANK_PROMOTE,v.tag)
		label:setString(v.text)
	end

	TouchEffect.addTouchEffect(self)
end




