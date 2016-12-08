--
-- Author: hapigames
-- Date: 2014-12-03 22:15:10
--
require "view/tagMap/Tag_popup_sweep_once"

SweepOncePopup = class("SweepOncePopup",function()
	return Popup:create()
end)

SweepOncePopup.__index = SweepOncePopup
local __instance = nil

function SweepOncePopup:create()
	local ret = SweepOncePopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function SweepOncePopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function SweepOncePopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_sweep_once.PANEL_SWEEP_ONCE then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function SweepOncePopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_sweep_once",PATH_POPUP_SWEEP_ONCE)
	local btnClose = self:getControl(Tag_popup_sweep_once.PANEL_SWEEP_ONCE,Tag_popup_sweep_once.BTN_ONCE_SURE)
	
	local stageRecord = StageRecord:getInstance()
	local currentType = stageRecord:get("dungeonType") --当前副本类型
	local currentChapter = stageRecord:get("chapter")  --当期章节
	local currentStage = stageRecord:get("stage")      --当前关卡
	local currentStarNum = stageRecord:get("starNum")  --当前星数
	local sweeptimes = stageRecord:get("sweeptimes")   --本次扫荡次数 
	
	local tmpTable = Stagedataproxy:getInstance().StageList
	local gold_reward,exp_reward 
	if currentType == Constants.DUNGEON_TYPE.NORMAL then
		local stage_normal_reward = ConfigManager.getStageNormalConfig(currentChapter, currentStage)
		gold_reward = stage_normal_reward.gold_reward
		exp_reward = stage_normal_reward.player_exp_reward
	else
		local stage_normal_reward = ConfigManager.getStageEliteConfig(currentChapter, currentStage)
		gold_reward = stage_normal_reward.gold_reward
		exp_reward = stage_normal_reward.player_exp_reward
	end
	local lab_sweep_once_exp = self:getControl(Tag_popup_sweep_once.PANEL_SWEEP_ONCE, Tag_popup_sweep_once.LAB_SWEEP_ONCE_EXP)
	local lab_sweep_once_gold = self:getControl(Tag_popup_sweep_once.PANEL_SWEEP_ONCE, Tag_popup_sweep_once.LAB_SWEEP_ONCE_GOLD)
	lab_sweep_once_exp:setString(exp_reward)
	lab_sweep_once_gold:setString(gold_reward)
	
	Player:getInstance():set("level",tmpTable["level"])
	Player:getInstance():set("exp",tmpTable["exp"])
	Player:getInstance():set("diamond",tmpTable["diamond"])
	Player:getInstance():set("gold",tmpTable["gold"])
	Player:getInstance():set("energy",tmpTable["energy"])

	if NormalDataProxy:getInstance().updateEnergy  then
		NormalDataProxy:getInstance().updateEnergy()
	end
	local function judgePlayerLevelUp()
		Player:getInstance():isPlayerLevelUp()
	end
	btnClose:setOnClickScriptHandler(function()
		Utils.popUIScene(self,judgePlayerLevelUp)
	end)

	local itemTable = {}  --存放物品
	local petTable = {}  --存放宠物

	if #tmpTable["items"] ~= 0 then
	    for k,v in ipairs(tmpTable["items"]) do
	    	local midtable = {}
	    	for i,va in ipairs(v) do
	    		-- local itemAmount = ItemManager.getItemAmount(va[1], va[2])
		    	ItemManager.addItem(va[1], va[2], va[3]) --更新物品
		   		table.insert(midtable,{va[1],va[2],va[3]})
	    	end
	   		table.insert(itemTable,midtable)
	    end
	end

	if #tmpTable["pets"] ~= 0 then   
		for k,v in ipairs(tmpTable["pets"]) do
			table.insert(petTable,v)
		end
	end

	for i=1,#itemTable[1] do
		local layoutItem = self:getControl(Tag_popup_sweep_once.PANEL_SWEEP_ONCE, Tag_popup_sweep_once["LAYOUT_ONCE_ITEM" .. i])
		local lab_item_num = self:getControl(Tag_popup_sweep_once.PANEL_SWEEP_ONCE, Tag_popup_sweep_once["LAB_ITEM_NUM" .. i])
		lab_item_num:setString(itemTable[1][i][3])
		local item = ItemManager.createItem(itemTable[1][i][1],itemTable[1][i][2])
		local cell = ItemCell:create(itemTable[1][i][1], item)
		Utils.addCellToParent(cell, layoutItem, true)
		Utils.showItemInfoTips(layoutItem, item)
	end
	for i=#itemTable[1]+1,4 do
		local lab_item_num = self:getControl(Tag_popup_sweep_once.PANEL_SWEEP_ONCE, Tag_popup_sweep_once["LAB_ITEM_NUM" .. i])
		lab_item_num:setString("")
	end

	TouchEffect.addTouchEffect(self)
end