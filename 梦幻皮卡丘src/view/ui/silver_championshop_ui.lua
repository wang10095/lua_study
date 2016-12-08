require "view/tagMap/Tag_ui_pvp1"

SilverChampionshipUI = class("SilverChampionshipUI",function()
	return TuiBase:create()
end)

SilverChampionshipUI.__index = SilverChampionshipUI
local __instance = nil
local scheduleID1,scheduleID2
local labRemainNum,labCd,labRank,labWin,labChestTimes,lab_not_snatch,labChestType,labRewardNum,btnGetReward,gvTips,lab_lengque
local lab_chest1,lab_chest2
local layoutFunction
local lab_no_open,layout_tip,layout_tip2
local isopen = true
local img_treasure_chest,img_treasure_chest_open --宝箱
local oldheight = 0

function SilverChampionshipUI:create()
	local ret = SilverChampionshipUI.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function SilverChampionshipUI:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function SilverChampionshipUI:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_pvp1.PANEL_PVP1 then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_return( p_sender )
	if NormalDataProxy:getInstance():get("isDaliyPursue") then
		Utils.popScene()
		Utils.runUIScene("DailyPopup")
		return
	end
	Utils.replaceScene("DungeonUI", __instance)
end

local function event_rank( p_sender )
	RankDataProxy:getInstance():set("rank_type",Constants.RANK_TYPE.PVP1)
	Utils.replaceScene("RankUI",__instance)
end

local function event_team( p_sender)
	Utils.replaceScene("DefenseTeamUI",__instance)  --防守阵容
end

local function event_CD_countdown(time) --冷却时间倒计时
	local hh,mm,ss = Utils.parseTime(time)
	hh,mm,ss = string.format("%.2d",hh),string.format("%.2d",mm),string.format("%.2d",ss)
	labCd:setString(hh .. ":" .. mm .. ":" .. ss)
	if time <=0 then
		labCd:setVisible(false)
		lab_lengque:setVisible(false)
		return
	end
	local btnChallenge = layoutFunction:getChildByTag(Tag_ui_pvp1.BTN_CHALLENGE)
	btnChallenge:setEnabled(false)
	scheduleID1 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function() 
		time = time - 1
		NormalDataProxy:getInstance():set("pvpCD",time)
		local hh,mm,ss = Utils.parseTime(time)
		hh,mm,ss = string.format("%.2d",hh),string.format("%.2d",mm),string.format("%.2d",ss)
		labCd:setString(hh .. ":" .. mm .. ":" .. ss)
		if time <= 0 then
			if scheduleID1 then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID1)
			end
			btnChallenge:setEnabled(true)
			labCd:setVisible(false)
			lab_lengque:setVisible(false)
		end
	end, 1, false)
end

local function event_chest_countdown(time) --宝箱倒计时
	local hh,mm,ss = Utils.parseTime(time)
	hh,mm,ss = string.format("%.2d",hh),string.format("%.2d",mm),string.format("%.2d",ss)
	labChestTimes:setString(hh .. ":" .. mm .. ":" .. ss)
	if time <=0 then
		img_treasure_chest_open:setVisible(true)
		img_treasure_chest:setVisible(false)
		labChestTimes:setVisible(false)
		lab_chest1:setVisible(false)
		lab_not_snatch:setVisible(false)
		lab_chest2:setString("当前可领取")
		layout_tip2:setPositionY(oldheight+20)
		if isopen == true then
			labGetReward:setVisible(true)
			btnGetReward:setVisible(true)
		else
			labGetReward:setVisible(false)
			btnGetReward:setVisible(false)
		end
	
		return
	end
	labGetReward:setVisible(false)
	btnGetReward:setVisible(false)
	img_treasure_chest_open:setVisible(false)
	img_treasure_chest:setVisible(true)
	scheduleID2 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function() 
		time = time - 1
		local hh,mm,ss = Utils.parseTime(time)
		hh,mm,ss = string.format("%.2d",hh),string.format("%.2d",mm),string.format("%.2d",ss)
		labChestTimes:setString(hh .. ":" .. mm .. ":" .. ss)
		if time <= 0 then
			if scheduleID2 then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID2)			
			end
			labChestTimes:setVisible(false)
			lab_chest1:setVisible(false)
			lab_not_snatch:setVisible(false)
			lab_chest2:setString("当前可领取")
			layout_tip2:setPositionY(oldheight+20)
			img_treasure_chest_open:setVisible(true)
			img_treasure_chest:setVisible(false)
			if isopen == true then
				labGetReward:setVisible(true)
				btnGetReward:setVisible(true)
			else
				labGetReward:setVisible(false)
				btnGetReward:setVisible(false)
			end
		end
	end, 1, false)
end

local function event_callback_get_reward(result) --奖励	
	img_treasure_chest_open:setVisible(false)
	img_treasure_chest:setVisible(true)
	local player = Player:getInstance()
	local reward = "获得 "
	local rid = result["reward"].rid
	local amount = result["reward"].amount
	
	local rewardType = TextManager.getPvp1RewardType(rid) --奖品类型
	if rid == 1 then --钻石
		player:set("diamond",player:get("diamond")+amount)
	elseif rid == 2 then --金币
		player:set("gold",player:get("gold")+amount)
	elseif rid == 3 then  --声望
		player:set("fame",player:get("fame")+amount)
    elseif rid == 4 then --小瓶经验药水
    	ItemManager.addItem(5, 1, amount)
	end
	reward = reward .. rewardType.reward_type .. "x" .. amount
	TipManager.showTip(reward)

	labChestTimes:setVisible(true)
	lab_chest1:setVisible(true)
	lab_not_snatch:setVisible(true)
	lab_chest2:setString("即可领取")
	layout_tip2:setPositionY(oldheight)
	__instance:update() --更新信息
end

local function event_get_reward() --领取奖励
	NetManager.sendCmd("getchestreward",event_callback_get_reward)
end

function SilverChampionshipUI:update()
	if scheduleID1 then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID1)
	end
	if scheduleID2 then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID2)
	end

	local function event_load_pvp1_status( result )
		Player:getInstance():set("buyPvp1Times",result["buytimes"])
	    Player:getInstance():set("rootPvpTimes",result["rootPvpTimes"])--清除pvp冷却时间次数
		SilverChampionShipproxy:getInstance():set("remaintime",result["remainNum"])
		if result["rank"]==-1 then
			isopen = false
			lab_no_open:setVisible(true)
			layout_tip:setVisible(false)
		else
			isopen = true
			lab_no_open:setVisible(false)
			layout_tip:setVisible(true)
		end
		labRemainNum:setString(result["remainNum"])
		local function confirmHandler()
			labRemainNum:setString(SilverChampionShipproxy:getInstance():get("remaintime"))		
		end
		SilverChampionShipproxy:getInstance().confirmHandler = confirmHandler
		
		event_CD_countdown(result["cd"])
		labRank:setString((result["rank"] == -1) and "未上榜" or result["rank"])
		labWin:setString(result["win_num"])
		event_chest_countdown(result["chest"].remaintimes)
		
		local btnChallenge = layoutFunction:getChildByTag(Tag_ui_pvp1.BTN_CHALLENGE)
		btnChallenge:setEnabled(result["rank"] ~= -1)
		print(" aptitude = "..result["chest"].qid)
		local rewardType = TextManager.getPvp1RewardType(result["chest"].rid)
		labChestType:setString(rewardType.reward_type)
		
		labRewardNum:setString(result["chest"].amount)
		labChestType:setColor(Constants.APTITUDE_COLOR[result["chest"].qid+1])
		labRewardNum:setColor(Constants.APTITUDE_COLOR[result["chest"].qid+1])

		local atlas = "spine/spine_pve/spine_chest_open.atlas"
		local json  = "spine/spine_pve/spine_chest_open.json"
		local spine1 = sp.SkeletonAnimation:create(json, atlas)
		spine1:setAnimation(0, "part1", true)
		Utils.addCellToParent(spine1,img_treasure_chest_open)

	 	local atlas = "spine/spine_pvp1/spine_pvp_chest.atlas"
		local json  = "spine/spine_pvp1/spine_pvp_chest.json"
		local spine2 = sp.SkeletonAnimation:create(json, atlas)
		if spine2 then
			spine2:removeFromParent()
			spine2:addAnimation(0, "part"..result["chest"].qid+1, true)
		else
			spine2:removeFromParent()
			spine2:addAnimation(0, "part"..result["chest"].qid+1, true)
		end
		Utils.addCellToParent(spine2,img_treasure_chest)

		local function event_adapt_rewards( p_convertview, idx )
			local rewardCell = p_convertview
			if rewardCell == nil then
				rewardCell = CGridViewCell:new()
				TuiManager:getInstance():parseCell(rewardCell,"cell_tips",PATH_UI_PVP1)
				local labName1 = rewardCell:getChildByTag(Tag_ui_pvp1.LAB_PLAYER1_NAME)
				labName1:setString(result["tips"][idx+1].name1)
				local labName2 = rewardCell:getChildByTag(Tag_ui_pvp1.LAB_PLAYER2_NAME)
				labName2:setString(result["tips"][idx+1].name2)
				local labTips = rewardCell:getChildByTag(Tag_ui_pvp1.LAB_FINALTIPS)
				labTips:setString(result["tips"][idx+1].tips)
			end
			return rewardCell
		end
		local num = 1
		gvTips:setCountOfCell(num)
	    gvTips:setDataSourceAdapterScriptHandler(event_adapt_rewards)
	    gvTips:reloadData()
	    gvTips:setDragable(false)
	end
	NetManager.sendCmd("loadpvp1status",event_load_pvp1_status)
end

local function event_challenge( p_sender )
	local function loadenemy( result )
		SilverChampionShipproxy:getInstance():set("ranking",tonumber(labRank:getString()))
		SilverChampionShipproxy:getInstance():set("win_num",tonumber(labWin:getString()))
		SilverChampionShipproxy.pvp1List = result["enemy"]
		local function updatePvp1CD(result)
			if scheduleID1 then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID1)
			end
			NormalDataProxy:getInstance():set("pvpCD",0)
			labCd:setVisible(false)
			lab_lengque:setVisible(false)
		end
		NormalDataProxy:getInstance().updatePvp1CD = updatePvp1CD
		Utils.runUIScene("ChallengePopup")
	end
	NetManager.sendCmd("loadenemy",loadenemy)
end

function SilverChampionshipUI:onLoadScene()
    NormalDataProxy:getInstance():set("pvpCD",0)
	TuiManager:getInstance():parseScene(self,"panel_pvp1",PATH_UI_PVP1)
	local layoutTop	= self:getControl(Tag_ui_pvp1.PANEL_PVP1,Tag_ui_pvp1.LAYOUT_TOP_PVP1)
	Utils.floatToTop(layoutTop)
	local btnRank = layoutTop:getChildByTag(Tag_ui_pvp1.BTN_RANK) --排行
	btnRank:setOnClickScriptHandler(event_rank)
	local layoutPlayer = self:getControl(Tag_ui_pvp1.PANEL_PVP1,Tag_ui_pvp1.LAYOUT_PLAYER)
	Spine.addSpine(layoutPlayer,"playersex","boy","part1",true)

	local labTalk = layoutTop:getChildByTag(Tag_ui_pvp1.LAB_PVP_TALK)
	
 	labTalk:setString("")
    NpcTalkManager.initTalk(labTalk,NpcTalkManager.SCENE.Pvp)
    NpcTalkManager.setNPCTouch(self,layoutPlayer,labTalk,NpcTalkManager.SCENE.Pvp)

	layoutFunction = self:getControl(Tag_ui_pvp1.PANEL_PVP1, Tag_ui_pvp1.LAYOUT_FUNCTION)
	Utils.floatToBottom(layoutFunction)
	local layoutBottom = layoutFunction:getChildByTag(Tag_ui_pvp1.LAYOUT_BOTTOM)
	local btnReturn = layoutBottom:getChildByTag(Tag_ui_pvp1.BTN_RETURN_PVP1)
	btnReturn:setOnClickScriptHandler(event_return)
	local btnTeam = layoutBottom:getChildByTag(Tag_ui_pvp1.BTN_TEAM)--防守阵容
	btnTeam:setOnClickScriptHandler(event_team)
	local btnChallenge = layoutFunction:getChildByTag(Tag_ui_pvp1.BTN_CHALLENGE)
	btnChallenge:setOnClickScriptHandler(event_challenge)


	layout_tip = layoutFunction:getChildByTag(Tag_ui_pvp1.LAYOUT_TIP)
	layout_tip2 = layout_tip:getChildByTag(Tag_ui_pvp1.LAYOUT_TIP2)
	oldheight = layout_tip2:getPositionY()
	lab_chest1 = layout_tip:getChildByTag(Tag_ui_pvp1.LAB_CHEST1)
	lab_chest2 = layout_tip2:getChildByTag(Tag_ui_pvp1.LAB_CHEST2)
	labRemainNum = layoutTop:getChildByTag(Tag_ui_pvp1.LAB_REMAINTIME) --剩余次数
	lab_lengque = layoutTop:getChildByTag(Tag_ui_pvp1.LAB_LENGQUE)
	labCd = layoutTop:getChildByTag(Tag_ui_pvp1.LAB_CD) --冷却时间
	labRank = layoutFunction:getChildByTag(Tag_ui_pvp1.LAB_RANKIMG) --我的排名
	labWin = layoutFunction:getChildByTag(Tag_ui_pvp1.LAB_WIN_NUM) --连胜次数
	labChestTimes = layout_tip:getChildByTag(Tag_ui_pvp1.LAB_CHEST_TIMES) -- 剩余需要保持的时间
	labChestType = layout_tip2:getChildByTag(Tag_ui_pvp1.LAB_CHEST_TYPE) -- 宝箱奖励类型
	labRewardNum = layout_tip2:getChildByTag(Tag_ui_pvp1.LAB_CHEST_NUM) --奖励数量
	labGetReward = layoutFunction:getChildByTag(Tag_ui_pvp1.LAB_GETREWARD)
	btnGetReward = layoutFunction:getChildByTag(Tag_ui_pvp1.BTN_GETREWARD) --时间到 领取奖励按钮
	gvTips = layoutFunction:getChildByTag(Tag_ui_pvp1.GV_TIPS)
	lab_not_snatch = layout_tip:getChildByTag(Tag_ui_pvp1.LAB_NOT_SNATCH)
    labGetReward:setVisible(false)
	btnGetReward:setVisible(false)
	btnGetReward:setOnClickScriptHandler(event_get_reward)
	lab_no_open = layoutFunction:getChildByTag(Tag_ui_pvp1.LAB_NO_OPEN) 
	lab_no_open:setVisible(false)

	img_treasure_chest = layoutFunction:getChildByTag(Tag_ui_pvp1.IMG_TREASURE_CHEST)
	img_treasure_chest_open = layoutFunction:getChildByTag(Tag_ui_pvp1.IMG_TREASURE_CHEST_OPEN)
  

	self:update()

	local function onNodeEvent(event)
		if "enterTransitionFinish"  == event then
			local showStory = GoldhandDataProxy:getInstance():get("isborrow")
			if GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.CHAMPION)
				and GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.PVP1) == false then
				Utils.dispatchCustomEvent("enter_view",{callback = function ( )
					Utils.dispatchCustomEvent("event_champion",{view = "SilverChampionshipUI",phase = GuideManager.FUNC_GUIDE_PHASES.PVP1,scene = self})
				end, params = {view = "func", phase = GuideManager.FUNC_GUIDE_PHASES.PVP1}})
			end
			if showStory == 1 and GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.DEFANCE_TEAM) and  Player:getInstance():get("level") == ConfigManager.getPvp1CommonConfig('openlevel') then
				Utils.dispatchCustomEvent("enter_view",{callback = nil, params = {view = "func", phase = 1}})
				GoldhandDataProxy:getInstance():set("isborrow",0)
			end
		elseif "exit" == event then
			if scheduleID1 then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID1)
			end
			if scheduleID2 then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID2)
			end
		end
	end
	self:registerScriptHandler(onNodeEvent)
	TouchEffect.addTouchEffect(self)
end




