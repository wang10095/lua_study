--
-- Author: hapigames
-- Date: 2014-12-03 22:15:10
--
require "view/tagMap/Tag_popup_sweep"

SweepPopup = class("SweepPopup",function()
	return Popup:create()
end)

SweepPopup.__index = SweepPopup
local __instance = nil

function SweepPopup:create()
	local ret = SweepPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function SweepPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function SweepPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_sweep.PANEL_POPUP_SWEEP then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function SweepPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_sweep",PATH_POPUP_SWEEP)
	local btnClose = self:getControl(Tag_popup_sweep.PANEL_POPUP_SWEEP,Tag_popup_sweep.BTN_CLOSE)

	local function judgelevelup()
		Player:getInstance():isPlayerLevelUp()
	end
	btnClose:setOnClickScriptHandler(function() 
		Utils.popUIScene(self,judgelevelup)
	end)
	
	local stageRecord = StageRecord:getInstance()
	local currentType = stageRecord:get("dungeonType")  --当前副本类型
	local currentChapter = stageRecord:get("chapter")  --当期章节
	local currentStage = stageRecord:get("stage")      --当前关卡
	local currentStarNum = stageRecord:get("starNum")   --当前星数
	local sweeptimes = stageRecord:get("sweeptimes")  --本次扫荡次数 
	local tmpTable = Stagedataproxy:getInstance().StageList
	-- local add_gold_num = math.abs(tmpTable["gold"] - Player:getInstance():get("gold"))
	-- local add_exp_num = math.abs(tmpTable["exp"] - Player:getInstance():get("exp"))

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

	Player:getInstance():set("level",tmpTable["level"])
	Player:getInstance():set("exp",tmpTable["exp"])
	Player:getInstance():set("diamond",tmpTable["diamond"])
	Player:getInstance():set("gold",tmpTable["gold"])
	Player:getInstance():set("energy",tmpTable["energy"])

	if NormalDataProxy:getInstance().updateEnergy  then
		NormalDataProxy:getInstance().updateEnergy()
	end

	local itemTable = {}  --存放物品
	local petTable = {}  --存放宠物

	if #tmpTable["items"] ~= 0 then
	    for k,v in ipairs(tmpTable["items"]) do
	    	local midtable = {}
	    	for i,va in ipairs(v) do
	    		-- local itemAmount = ItemManager.getItemAmount(va[1], va[2])
		    	ItemManager.addItem(va[1], va[2], va[3]) --添加物品
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

	local list = self:getControl(Tag_popup_sweep.PANEL_POPUP_SWEEP,Tag_popup_sweep.LIST_SWEEP)
	list:removeAllNodes()
	local count = list:getNodeCount()
	local amount = #itemTable
	
	while count < sweeptimes  do
		local pCell = CGridViewCell:new()
		TuiManager:getInstance():parseCell(pCell, "cell_sweep", PATH_POPUP_SWEEP)
		list:insertNodeAtLast(pCell)
		count = list:getNodeCount()
	end
	list:reloadData()

	if sweeptimes <=3  then
		list:setDragable(false)
	else
		list:setDragable(true)
	end

	for i=1,sweeptimes do
		local node = list:getNodeAtIndex(i-1)
		node:setVisible(false)
		local delay = cc.DelayTime:create(i*0.3)
		local callfunc = cc.CallFunc:create(function() node:setVisible(true)  end)
		node:runAction(cc.Sequence:create(delay,callfunc,nil))
		
		local labTips = node:getChildByTag(Tag_popup_sweep.LAB_ITEM_TIPS)
		local labExp = node:getChildByTag(Tag_popup_sweep.LAB_PLAYER_EXP)
		labExp:setString(exp_reward)
		local labGold = node:getChildByTag(Tag_popup_sweep.LAB_GETGOLD_NUM)
		labGold:setString(gold_reward)
		local numTable = {'一','二','三','四','五'}
		local lab_number =  node:getChildByTag(Tag_popup_sweep.LAB_NUMBER)
		lab_number:setString(numTable[i])

		if #itemTable[i] == 0 then
			for k = 1,4 do
				local itemLayout = node:getChildByTag(Tag_popup_sweep["LAYOUT_REWARD_ITEM"..k])
				local lab_reward_num = node:getChildByTag(Tag_popup_sweep["LAB_REWARD_NUM" .. k])
				lab_reward_num:setString("")
				itemLayout:setVisible(false)
			end
			labTips:setVisible(true)
		elseif #itemTable[i] < 4 then
			labTips:setVisible(false)  
			for j = 1,#itemTable[i] do
				local itemLayout = node:getChildByTag(Tag_popup_sweep["LAYOUT_REWARD_ITEM"..j])
				local lab_reward_num = node:getChildByTag(Tag_popup_sweep["LAB_REWARD_NUM" .. j])
				lab_reward_num:setString(itemTable[i][j][3])
				local item = ItemManager.createItem(itemTable[i][j][1],itemTable[i][j][2])
				local itemCell =ItemCell:create(itemTable[i][j][1],item)
				Utils.addCellToParent(itemCell,itemLayout,true)
				Utils.showItemInfoTips(itemLayout, item)
			end
			for k = #itemTable[i]+1,4 do
				local itemLayout = node:getChildByTag(Tag_popup_sweep["LAYOUT_REWARD_ITEM"..k])
				itemLayout:setVisible(false)
				local lab_reward_num = node:getChildByTag(Tag_popup_sweep["LAB_REWARD_NUM" .. k])
				lab_reward_num:setString("")
			end
		else
			labTips:setVisible(false)
			for j=1,4  do
				local itemLayout = node:getChildByTag(Tag_popup_sweep["LAYOUT_REWARD_ITEM"..j])
				local lab_reward_num = node:getChildByTag(Tag_popup_sweep["LAB_REWARD_NUM" .. j])
				lab_reward_num:setString(itemTable[i][j][3])
				local item = ItemManager.createItem(itemTable[i][j][1],itemTable[i][j][2])
				local itemCell =ItemCell:create(itemTable[i][j][1],item)
				Utils.addCellToParent(itemCell,itemLayout,true)
				Utils.showItemInfoTips(itemLayout, item)
			end
		end
	end	

	TouchEffect.addTouchEffect(self)
	local function onNodeEvent(event)
		if "enter" == event then
			self:show()
		end

		if "enterTransitionFinish"  == event then
			Stagedataproxy:getInstance():set("isPopup",true)
		end

		if "exit" == event then
	    	-- Stagedataproxy:getInstance():set("isPopup",false)
		end
	end
	self:registerScriptHandler(onNodeEvent)

end