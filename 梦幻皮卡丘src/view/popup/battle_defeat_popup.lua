
require "view/tagMap/Tag_popup_battle_defeat"

BattleDefeatPopup = class("BattleDefeatPopup",function()
	return Popup:create()
end)

BattleDefeatPopup.__index = BattleDefeatPopup
local __instance = nil

function BattleDefeatPopup:create()
	local ret = BattleDefeatPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function BattleDefeatPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function BattleDefeatPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_battle_defeat.PANEL_POPUP_BATTLE_DEFEAT then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function BattleDefeatPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_battle_defeat",PATH_POPUP_BATTLE_DEFEAT)
	local layoutLoseSpine = self:getControl(Tag_popup_battle_defeat.PANEL_POPUP_BATTLE_DEFEAT,Tag_popup_battle_defeat.LAYOUT_LOSE)
	-- local function runSpine(  )
		Spine.addSpine(layoutLoseSpine,"battle","lose","part1",false)
	-- end
	-- layoutLoseSpine:runAction(cc.Sequence:create(cc.DelayTime:create(0.4),cc.CallFunc:create(runSpine)))

	local img9Bg = self:getControl(Tag_popup_battle_defeat.PANEL_POPUP_BATTLE_DEFEAT,Tag_popup_battle_defeat.IMG9_POPUP_DEFEAT_BG)
	local img9Content = self:getControl(Tag_popup_battle_defeat.PANEL_POPUP_BATTLE_DEFEAT,Tag_popup_battle_defeat.IMG9_POPUP_CONTENT_DEFEAT)
	local imgWoodTop = self:getControl(Tag_popup_battle_defeat.PANEL_POPUP_BATTLE_DEFEAT,Tag_popup_battle_defeat.LAYOUT_WOOD_UP2)
	local imgBottom = self:getControl(Tag_popup_battle_defeat.PANEL_POPUP_BATTLE_DEFEAT,Tag_popup_battle_defeat.LAYOUT_WOOD_DOWN2)
	local btnClose = self:getControl(Tag_popup_battle_defeat.PANEL_POPUP_BATTLE_DEFEAT,Tag_popup_battle_defeat.BTN_CLOSE_DEFEAT)

	local petContent = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)

	-- local trainConfig = ConfigManager.getPetTrainConfig()
	local layoutTrain = self:getControl(Tag_popup_battle_defeat.PANEL_POPUP_BATTLE_DEFEAT,Tag_popup_battle_defeat.LAYOUT_TRAIN)
	local layoutPetTrain = layoutTrain:getChildByTag(Tag_popup_battle_defeat.LAYOUT_PET_TRAIN)
	local trainPet = petContent[1]
	local trainpetCell = PetCell:create(trainPet)
	Utils.addCellToParent(trainpetCell,layoutPetTrain)
	local btntrain = layoutTrain:getChildByTag(Tag_popup_battle_defeat.BTN_TRAIN)
	btntrain:setOnClickScriptHandler(function ( )
		ItemManager.currentPet = petContent[1]
		Utils.popUIScene(self)
		Utils.replaceScene("PetAttributeUI")
	end)

	local layoutSkill = self:getControl(Tag_popup_battle_defeat.PANEL_POPUP_BATTLE_DEFEAT,Tag_popup_battle_defeat.LAYOUT_SKILL)
	local layoutPetSkill = layoutSkill:getChildByTag(Tag_popup_battle_defeat.LAYOUT_PET_SKILL)
	local skillPet = petContent[1]
	local skillpetCell = PetCell:create(skillPet)
	Utils.addCellToParent(skillpetCell,layoutPetSkill)
	local btnSkill = layoutSkill:getChildByTag(Tag_popup_battle_defeat.BTN_SKILL)
	btnSkill:setOnClickScriptHandler(function ( )
		ItemManager.currentPet = petContent[1]
		Utils.popUIScene(self)
		Utils.replaceScene("PetAttributeUI")
	end)

	local btnAgain = self:getControl(Tag_popup_battle_defeat.PANEL_POPUP_BATTLE_DEFEAT,Tag_popup_battle_defeat.BTN_AGAIN_DEFEAT)
	btnAgain:setOnClickScriptHandler(function(p_sender)
		Utils.popUIScene(self)
		local event = cc.EventCustom:new("event_restart_battle")
		self:getEventDispatcher():dispatchEvent(event)
	end)

	if StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY3 then
		btnAgain:setEnabled(false)
	end

	
	local function event_close( p_sender )
		if StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY1 then
			Utils.popUIScene(self)
			Utils.replaceScene("BattlePalaceUI")
		elseif StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY2 then
			Utils.popUIScene(self)
			Utils.replaceScene("RouletteUI")
		elseif StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY3 then
			Utils.popUIScene(self)
			Utils.replaceScene("PyramidUI")
		elseif GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.PET_TRAIN) == false then
			Utils.popUIScene(self)
			Utils.replaceScene("MainUI")
		else
			Utils.popUIScene(self)
			Utils.replaceScene("PveUI")
		end
	end
	local btnNext = self:getControl(Tag_popup_battle_defeat.PANEL_POPUP_BATTLE_DEFEAT,Tag_popup_battle_defeat.BTN_NEXT_DEFEAT)
	btnNext:setOnClickScriptHandler(event_close)
	btnClose:setOnClickScriptHandler(event_close)

	local function onNodeEvent( event )
		if event == "enter" then
			self:show()
			TouchEffect.addTouchEffect(self)
			MusicManager.subMusicVolume(1)
			-- MusicManager.battle_victory()
		end
		if event =="enterTransitionFinish" then
			
		end
	    if "exit" == event then
	    	MusicManager.addMusicVolume(1)
        end
    end
    self:registerScriptHandler(onNodeEvent)

end