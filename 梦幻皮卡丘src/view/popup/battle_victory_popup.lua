
require "view/tagMap/Tag_popup_battle_victory"

BattleVictoryPopup = class("BattleVictoryPopup",function()
	return Popup:create()
end)

BattleVictoryPopup.__index = BattleVictoryPopup
local __instance = nil
local value = nil

local function event_adapt_rewards(p_convertview, idx)
	local avatarCell = p_convertview
	if avatarCell == nil then
		avatarCell = CPageViewCell:new()
		TuiManager:getInstance():parseCell(avatarCell, "cell_reward", PATH_POPUP_BATTLE_VICTORY)
		local layout_items = avatarCell:getChildByTag(Tag_popup_battle_victory.LAYOUT_ITEMS)
		local lab_item_num = avatarCell:getChildByTag(Tag_popup_battle_victory.LAB_ITEM_NUM)
		lab_item_num:setString("")
 		local reward = StageRecord:getInstance():get("rewards")[idx + 1]
	 	if idx +1 <= #StageRecord:getInstance():get("rewards") then
	 		local item = Item:create(reward.itemType, reward.mid)
	 		local itemCell = ItemCell:create(reward.itemType,item)
	 		Utils.addCellToParent(itemCell,layout_items,true)
	 		print("addItem  "..reward.itemType, reward.mid, reward.amount)
			ItemManager.addItem(reward.itemType, reward.mid, reward.amount)
			Utils.showItemInfoTips(layout_items, item)
			lab_item_num:setString(reward.amount)
		else
			local pets = StageRecord:getInstance():get("pets")
			local pet = Pet:create()
			pet:set("id",pets[1].id)
			pet:set("mid",pets[1].mid)
			pet:set("form",pets[1].form)
			pet:set("aptitude",pets[1].aptitude)
			local petCell = PetCell:create(pet)
			Utils.addCellToParent(petCell,layout_items,true)
			Utils.showPetInfoTips(layout_items, pet:get("mid"), pet:get("form"))
			ItemManager.addPet(pets[1])
		end
		
	 	table.insert(__instance.celltable,avatarCell)
	 end
    return avatarCell
end

function BattleVictoryPopup:create()
	local ret = BattleVictoryPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function BattleVictoryPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function BattleVictoryPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_battle_victory.PANEL_POPUP_BATTLE_VICTORY then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function BattleVictoryPopup:onloadPlayerInfoAction()  --加载玩家信息
	local playerLevelLab = __instance:getControl(Tag_popup_battle_victory.PANEL_POPUP_BATTLE_VICTORY,Tag_popup_battle_victory.LAB_LEVELNUM)

	playerLevelLab:retain()
	local playerExpLab = __instance:getControl(Tag_popup_battle_victory.PANEL_POPUP_BATTLE_VICTORY,Tag_popup_battle_victory.LAB_ADDEXP)
	playerExpLab:retain()

	local playerGoldLab = __instance:getControl(Tag_popup_battle_victory.PANEL_POPUP_BATTLE_VICTORY,Tag_popup_battle_victory.LAB_ADDGOLD)

	playerGoldLab:retain()
	local layoutPlayerInfo = __instance:getControl(Tag_popup_battle_victory.PANEL_POPUP_BATTLE_VICTORY,Tag_popup_battle_victory.LAYOUT_PLAYERINFO)

	local addlevel = StageRecord:getInstance():get("level")
	local addexp = StageRecord:getInstance():get("exp")
	local addgold = StageRecord:getInstance():get("gold")

	playerLevelLab:setString(Player:getInstance():get("level"))

	playerExpLab:setString(math.abs(addexp))
	playerGoldLab:setString(addgold)
	Player:getInstance():isPlayerLevelUp()
end

function BattleVictoryPopup:onloadRewardItemAction()--奖励物品
	__instance.celltable = {}
	local layoutReward = __instance:getControl(Tag_popup_battle_victory.PANEL_POPUP_BATTLE_VICTORY,Tag_popup_battle_victory.LAYOUT_REWARD)

	local gvRewards = layoutReward:getChildByTag(Tag_popup_battle_victory.GV_REWARDS)
	local gvCotent = StageRecord:getInstance():get("rewards")
	local pets = StageRecord:getInstance():get("pets")
	
	if pets[1] ~= nil then
   		gvRewards:setCountOfCell(#gvCotent + #pets)
   	else
   		gvRewards:setCountOfCell(#gvCotent)
   	end
    gvRewards:setDataSourceAdapterScriptHandler(event_adapt_rewards)
    gvRewards:setSizeOfCell(cc.size(105, 120))
    gvRewards:reloadData()
end

function BattleVictoryPopup:onloadPetExpHandler() --宠物经验
	local petExps = StageRecord:getInstance():get("petExps") --宠物经验
	local index_ = 1
	local petExpsConfig
	local activityType = {
        activity1 = 1,
        activity2 = 2,
        activity3 = 3,
    }

	if StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.NORMAL then
		petExpsConfig = ConfigManager.getStageNormalConfig(StageRecord:getInstance():get("chapter"),StageRecord:getInstance():get("stage"))
	elseif StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ELITE then
		petExpsConfig = ConfigManager.getStageEliteConfig(StageRecord:getInstance():get("chapter"),StageRecord:getInstance():get("stage"))
	elseif StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY1 then
		petExpsConfig = ConfigManager.getActivityStageConfig(activityType.activity1,StageRecord:getInstance():get("stage"))
	elseif StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY2 then
		petExpsConfig = ConfigManager.getActivityStageConfig(activityType.activity2,StageRecord:getInstance():get("stage"))
	elseif StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY3 then
		petExpsConfig = ConfigManager.getActivityStageConfig(activityType.activity3,StageRecord:getInstance():get("stage"))
	end
	for i=1,5 do
		local addExp = petExps[i]
		local layoutPetInfo = __instance:getControl(Tag_popup_battle_victory.PANEL_POPUP_BATTLE_VICTORY,Tag_popup_battle_victory["LAYOUT_PETINFO".. i])
		local pet = ItemManager.getPetById(addExp.id)
		local petCell = PetCell:create(pet)
		local petCellContainer = layoutPetInfo:getChildByTag(Tag_popup_battle_victory["LAYOUT_PET".. i])
		Utils.addCellToParent(petCell, petCellContainer, true)
		Utils.showPetInfoTips(petCellContainer, pet:get("mid"), pet:get("form"))
		local petExp = pet:get("exp")
		local progExp = layoutPetInfo:getChildByTag(Tag_popup_battle_victory["PROG_PET_".. i .."_EXP"])
		local fullExp = ConfigManager.getUserConfig(pet:get("level")).max_pet_exp
			-- progExp:setMaxValue(fullExp)
		progExp:setScale(0.8)
		progExp:setValue(100*(petExp - addExp.exp) / fullExp) --设置初始value 
		-- local function loadpet1prog()
		if petExp - addExp.exp <= 0 and pet:get("level")>1 then 
			local oldFullExp = ConfigManager.getUserConfig(pet:get("level")-1).max_pet_exp
			local oldPetExp = oldFullExp - (addExp.exp - petExp) --升级前宠物的经验
			local oldTime = (addExp.exp - petExp)/oldFullExp*0.5
			progExp:startProgressFromTo(100*oldPetExp/oldFullExp,100, oldTime)
			__instance:runAction(cc.Sequence:create(cc.DelayTime:create(oldTime),cc.CallFunc:create(function()
				progExp:startProgressFromTo(0,100*petExp/fullExp,petExp/fullExp*0.5)
			end),nil))
		else
			progExp:startProgressFromTo(100*(petExp-addExp.exp)/fullExp,100*petExp/fullExp,(petExp-addExp.exp)/fullExp*0.5)
		end

		local labPetExp = layoutPetInfo:getChildByTag(Tag_popup_battle_victory["LAB_PET_".. i .."_EXP"])
		labPetExp:setString(petExpsConfig.pet_exp_reward)
	end

end
function BattleVictoryPopup:onloadGuidePetHandler( )
	local petExps = StageRecord:getInstance():get("petExps")
	addExp = petExps[1]
	local layoutPetInfo = __instance:getControl(Tag_popup_battle_victory.PANEL_POPUP_BATTLE_VICTORY,Tag_popup_battle_victory.LAYOUT_PETINFO1)

	layoutPetInfo:setVisible(true)
	local petContent = ItemManager.getItemsByType(1)
	local petCell = PetCell:create(petContent[1])
	local petCellContainer = layoutPetInfo:getChildByTag(Tag_popup_battle_victory.LAYOUT_PET1)
	Utils.addCellToParent(petCell, petCellContainer, true)
	local prog = 0
	local petExp = petContent[1]:get("exp")
	local progExp = layoutPetInfo:getChildByTag(Tag_popup_battle_victory.PROG_PET_1_EXP)
	progExp:retain()
	local fullExp = ConfigManager.getUserConfig(petContent[1]:get("level")).max_pet_exp

	progExp:setValue(100*(petExp - addExp.exp) / fullExp) --设置初始value 

	if petExp - addExp.exp <= 0 and petContent[1]:get("level")>1 then 
		local oldFullExp = ConfigManager.getUserConfig(petContent[1]:get("level")-1).max_pet_exp
		local oldPetExp = oldFullExp - (addExp.exp - petExp) --升级前宠物的经验
		local oldTime = (addExp.exp - petExp)/oldFullExp*0.5
		progExp:startProgressFromTo(100*oldPetExp/oldFullExp,100, oldTime)
		__instance:runAction(cc.Sequence:create(cc.DelayTime:create(oldTime),cc.CallFunc:create(function()
			progExp:startProgressFromTo(0,100*petExp/fullExp,petExp/fullExp*0.5)
		end),nil))
	else
		progExp:startProgressFromTo(100*(petExp-addExp.exp)/fullExp,100*petExp/fullExp,(petExp-addExp.exp)/fullExp*0.5)
	end

	local exp = 0
	local labPetExp = layoutPetInfo:getChildByTag(Tag_popup_battle_victory.LAB_PET_1_EXP)
	labPetExp:setString(math.abs(addExp.exp))
end

local function event_close( p_sender )
	local stageRecord = StageRecord:getInstance()
	local petCommonConfig = ConfigManager.getPetCommonConfig('skill_openlevel')
	if GuideManager.getMainGuidePhase() == GuideManager.MAIN_GUIDE_PHASES.WILD then
		Utils.popUIScene(__instance)
		Utils.replaceScene("MainUI")
	elseif GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.PET_TRAIN) == false and Player.getInstance():get("normalStageId") == 4 then
		NormalDataProxy:getInstance():set("currentHoom",1)
		Utils.popUIScene(__instance)
		Utils.replaceScene("MainUI")
	elseif GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.PET_SKILL) == false and Player:getInstance():get("level") == petCommonConfig then
		Utils.popUIScene(__instance)
		Utils.replaceScene("MainUI")
	else
		if stageRecord:get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY1 then 
			Utils.popUIScene(__instance)
			Utils.replaceScene("BattlePalaceUI")
			local difficulty = Activity1StatusProxy:getInstance():get("difficulty")
            local score = ConfigManager.getActivty1CommonConfig('event2_' .. difficulty .. '_score') 
           	local diacecount =  Activity1StatusProxy:getInstance():get("diceCount")
           	if diacecount > 0 then
           		TipManager.showTip("恭喜您闯关成功 +" .. score .. "分")
           	end
		elseif stageRecord:get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY2 then
			Utils.popUIScene(__instance)
			Utils.replaceScene("RouletteUI")
		else
			Utils.popUIScene(__instance)
			Utils.replaceScene("PveUI")
		end
	end
end

function BattleVictoryPopup:onLoadScene()
	value = {scheduleID2_2_1,scheduleID2_2_2,scheduleID2_2_3,scheduleID2_2_4,scheduleID2_2_5}
	TuiManager:getInstance():parseScene(self,"panel_popup_battle_victory",PATH_POPUP_BATTLE_VICTORY)

	local layoutWinSpine = self:getControl(Tag_popup_battle_victory.PANEL_POPUP_BATTLE_VICTORY,Tag_popup_battle_victory.LAYOUT_WIN)

	Spine.addSpine(layoutWinSpine,"battle","win","part1",false)

	local layoutbg = self:getControl(Tag_popup_battle_victory.PANEL_POPUP_BATTLE_VICTORY,Tag_popup_battle_victory.LAYOUT_BG)
	local imgPopup = self:getControl(Tag_popup_battle_victory.PANEL_POPUP_BATTLE_VICTORY,Tag_popup_battle_victory.IMG9_POPUP_VICTORY_BG)
	local imgWood = self:getControl(Tag_popup_battle_victory.PANEL_POPUP_BATTLE_VICTORY,Tag_popup_battle_victory.LAYOUT_WOOD_BG)
	local btnClose = self:getControl(Tag_popup_battle_victory.PANEL_POPUP_BATTLE_VICTORY,Tag_popup_battle_victory.BTN_CLOSE_VICTORY)

	local winStar = StageRecord:getInstance():get("winStar")
	for i=1,winStar do
		local layoutStarSpine = self:getControl(Tag_popup_battle_victory.PANEL_POPUP_BATTLE_VICTORY,Tag_popup_battle_victory["LAYOUT_STAR"..i])
   		Spine.addSpine(layoutStarSpine,"battle","star","part1",false)
	end
	
	self:onloadPlayerInfoAction()

	if GuideManager.getMainGuidePhase() ==GuideManager.MAIN_GUIDE_PHASES.STAGE_1_END or GuideManager.getMainGuidePhase() == GuideManager.MAIN_GUIDE_PHASES.PVE_STAGE3 then
		for i=2,5 do
			local layoutPet = self:getControl(Tag_popup_battle_victory.PANEL_POPUP_BATTLE_VICTORY,Tag_popup_battle_victory["LAYOUT_PETINFO"..i])
			layoutPet:setVisible(false)
		end
		self.onloadGuidePetHandler()
	else
		self:onloadPetExpHandler()
	end
	
	self:onloadRewardItemAction()

	local function event_againchallenge( p_sender )
		Utils.popUIScene(self)
		local event = cc.EventCustom:new("event_restart_battle")
		self:getEventDispatcher():dispatchEvent(event)
	end
	local btnAgain = self:getControl(Tag_popup_battle_victory.PANEL_POPUP_BATTLE_VICTORY,Tag_popup_battle_victory.BTN_AGAIN)
	btnAgain:setOnClickScriptHandler(event_againchallenge)

	if StageRecord:getInstance():get("dungeonType") > Constants.DUNGEON_TYPE.ELITE then

		btnAgain:setEnabled(false)
	elseif GuideManager.getMainGuidePhase() == GuideManager.MAIN_GUIDE_PHASES.WILD or GuideManager.getMainGuidePhase() == GuideManager.MAIN_GUIDE_PHASES.PVE_STAGE3 then

		btnAgain:setEnabled(false)
	else
		btnAgain:setEnabled(true)
	end

	local btnNext = self:getControl(Tag_popup_battle_victory.PANEL_POPUP_BATTLE_VICTORY,Tag_popup_battle_victory.BTN_NEXT)
	btnNext:setOnClickScriptHandler(event_close)
	
	btnClose:setOnClickScriptHandler(event_close)

	local function onNodeEvent( event )
		if event == "enter" then
			self:show()
			TouchEffect.addTouchEffect(self)
			MusicManager.subMusicVolume(1)
			self:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function( )
				MusicManager.addMusicVolume(1)
			end)))
			-- MusicManager.battle_victory()
		end
		if event =="enterTransitionFinish" then
			if GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.STAGE_1_END then
			    Utils.dispatchCustomEvent("event_enter_view",{view = "BattleUI",phase = GuideManager.MAIN_GUIDE_PHASES.STAGE_1_END,scene = self})
			end
			if GuideManager.main_guide_phase_ < GuideManager.MAIN_GUIDE_PHASES.START_BATTLE then
				local btnClose = self:getControl(Tag_popup_battle_victory.PANEL_POPUP_BATTLE_VICTORY,Tag_popup_battle_victory.BTN_CLOSE_VICTORY)
				btnClose:setEnabled(false)
				local btnAgain = self:getControl(Tag_popup_battle_victory.PANEL_POPUP_BATTLE_VICTORY,Tag_popup_battle_victory.BTN_AGAIN)
				btnAgain:setEnabled(false)
			end
		end
	    if "exit" == event then
	    	-- 
        end
    end
    self:registerScriptHandler(onNodeEvent)
end
