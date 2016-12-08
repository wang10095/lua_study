
require "view/tagMap/Tag_popup_pvp_defeat"

PvpDefeatPopup = class("PvpDefeatPopup",function()
	return Popup:create()
end)

PvpDefeatPopup.__index = PvpDefeatPopup
local __instance = nil

function PvpDefeatPopup:create()
	local ret = PvpDefeatPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function PvpDefeatPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function PvpDefeatPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_pvp_defeat.PANEL_PVP_DEFEAT then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function PvpDefeatPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_pvp_defeat",PATH_POPUP_PVP_DEFEAT)
	local layoutLoseSpine = self:getControl(Tag_popup_pvp_defeat.PANEL_PVP_DEFEAT,Tag_popup_pvp_defeat.LAYOUT_LOSE)
	local function runSpine(  )
		Spine.addSpine(layoutLoseSpine,"battle","lose","part1",false)
	end
	layoutLoseSpine:runAction(cc.Sequence:create(cc.DelayTime:create(0.4),cc.CallFunc:create(runSpine)))

	local img9Bg = self:getControl(Tag_popup_pvp_defeat.PANEL_PVP_DEFEAT,Tag_popup_pvp_defeat.IMG9_POPUP_DEFEAT_BG)
	local img9Content = self:getControl(Tag_popup_pvp_defeat.PANEL_PVP_DEFEAT,Tag_popup_pvp_defeat.IMG9_POPUP_CONTENT_DEFEAT)
	local imgWoodTop1 = self:getControl(Tag_popup_pvp_defeat.PANEL_PVP_DEFEAT,Tag_popup_pvp_defeat.IMG_WOOD_TOP1)
	local imgBottom1 = self:getControl(Tag_popup_pvp_defeat.PANEL_PVP_DEFEAT,Tag_popup_pvp_defeat.IMG_WOOD_BOTTOM1)
	local imgWoodTop2 = self:getControl(Tag_popup_pvp_defeat.PANEL_PVP_DEFEAT,Tag_popup_pvp_defeat.IMG_WOOD_TOP2)
	local imgBottom2 = self:getControl(Tag_popup_pvp_defeat.PANEL_PVP_DEFEAT,Tag_popup_pvp_defeat.IMG_WOOD_BOTTOM2)
	imgWoodTop1:setVisible(false)
	imgBottom1:setVisible(false)
	imgWoodTop2:setVisible(false)
	imgBottom2:setVisible(false)
	img9Bg:setVisible(false)
	img9Content:setVisible(false)
	img9Bg:setScale(0.1)
	img9Content:setScale(0.1)
	imgWoodTop1:setScale(0.1)
	imgBottom1:setScale(0.1)
	imgWoodTop2:setScale(0.1)
	imgBottom2:setScale(0.1)
	local function loadbg()
		img9Bg:setVisible(true)
		img9Content:setVisible(true)
		imgWoodTop1:setVisible(true)
		imgBottom1:setVisible(true)
		imgWoodTop2:setVisible(true)
		imgBottom2:setVisible(true)
		img9Bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5,1.2),cc.ScaleTo:create(0.2,1)))
		img9Content:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5,1.2),cc.ScaleTo:create(0.2,1)))
		imgWoodTop1:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5,1.2),cc.ScaleTo:create(0.2,1)))
		imgBottom1:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5,1.2),cc.ScaleTo:create(0.2,1)))
		imgWoodTop2:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5,1.2),cc.ScaleTo:create(0.2,1)))
		imgBottom2:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5,1.2),cc.ScaleTo:create(0.2,1)))
	end
	img9Bg:runAction(cc.Sequence:create(cc.DelayTime:create(0.7),cc.CallFunc:create(loadbg)))

	local team = Player:getInstance():get("pvp1_battle_team")
	-- local team  = BattleUI:getUserDefaultKey()
	local petGvContent = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
	local petTable = {}
	if team ~= nil and team ~= "" then
		local battle_team = Utils.stringToTable(team)
		for i,v in ipairs(battle_team) do
            if v ~= 0 then
                for j,pet in ipairs(petGvContent) do
                    if pet:get("id") == v then
                        print("id = "..v)
                        local skill_level = pet:get("skillLevels")
                        table.insert(petTable,pet)
                    end
                end
            end
        end
	end
	
	table.sort( petTable,function( a,b )
		return a:get("rank")<b:get("rank")
	end)

	--训练  技能
	local layoutTrain = self:getControl(Tag_popup_pvp_defeat.PANEL_PVP_DEFEAT,Tag_popup_pvp_defeat.LAYOUT_TRAIN)
	layoutTrain:setVisible(false)
	local function loadtrainBtn()
		layoutTrain:setVisible(true)
	end
	layoutTrain:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(loadtrainBtn)))
	
	local layoutTrainPet = layoutTrain:getChildByTag(Tag_popup_pvp_defeat.LAYOUT_PET_TRAIN)
	local pet1 = petTable[1]
	local petCell1 = PetCell:create(pet1)
	Utils.addCellToParent(petCell1,layoutTrainPet)
	local btnTrain = layoutTrain:getChildByTag(Tag_popup_pvp_defeat.BTN_TRAIN)
	btnTrain:setOnClickScriptHandler(function( )
		ItemManager.currentPet = pet1
		Utils.popUIScene(self)
		Utils.replaceScene("PetAttributeUI")
	end)

	table.sort( petTable,function( a,b )
		return a:get("level") < b:get("level")
	end)
	local layoutSkill = self:getControl(Tag_popup_pvp_defeat.PANEL_PVP_DEFEAT,Tag_popup_pvp_defeat.LAYOUT_SKILL)
	layoutSkill:setVisible(false)
	local function loadskillBtn()
		layoutSkill:setVisible(true)
	end
	layoutSkill:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(loadskillBtn)))

	local layoutSkillPet = layoutSkill:getChildByTag(Tag_popup_pvp_defeat.LAYOUT_PET_SKILL)
	local pet2 = petTable[1]
	local petCell2 = PetCell:create(pet2)
	Utils.addCellToParent(petCell2,layoutSkillPet)
	local btnSkill = layoutSkill:getChildByTag(Tag_popup_pvp_defeat.BTN_SKILL)
	btnSkill:setOnClickScriptHandler(function( )
		ItemManager.currentPet = pet2
		Utils.popUIScene(self)
		Utils.replaceScene("PetAttributeUI")
	end)
	
	--提示
	local lab_defeat_tips = self:getControl(Tag_popup_pvp_defeat.PANEL_PVP_DEFEAT,Tag_popup_pvp_defeat.LAB_DEFEAT_TIPS)
	lab_defeat_tips:setVisible(false)
	lab_defeat_tips:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function() lab_defeat_tips:setVisible(true) end)))
	--按钮操作
	local function event_close( p_sender )
		Utils.popUIScene(__instance)
		Utils.replaceScene("SilverChampionshipUI")
	end

	local labClose = self:getControl(Tag_popup_pvp_defeat.PANEL_PVP_DEFEAT,Tag_popup_pvp_defeat.LAB_CLOSE)
	local btnClose = self:getControl(Tag_popup_pvp_defeat.PANEL_PVP_DEFEAT,Tag_popup_pvp_defeat.BTN_CLOSE)
	btnClose:setOnClickScriptHandler(event_close)
	btnClose:setVisible(false)
	labClose:setVisible(false)
	local function loadnextBtn()
		btnClose:setVisible(true)
		labClose:setVisible(true)
	end
	btnClose:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(loadnextBtn)))

end







