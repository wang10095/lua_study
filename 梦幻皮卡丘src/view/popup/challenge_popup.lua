require "view/tagMap/Tag_popup_challenge"

ChallengePopup = class("ChallengePopup",function()
	return Popup:create()
end)

ChallengePopup.__index = ChallengePopup
local __instance = nil
local value = nil
local countdown = 0
local scheduleCD 

function ChallengePopup:create()
	local ret = ChallengePopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function ChallengePopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function ChallengePopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_challenge.PANEL_POPUP_CHALLENGE then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end
function ChallengePopup:dtor( )
	for i=1,4 do
		if value[i] then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(value[i])
		end
	end
	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleCD)
end
function ChallengePopup:battleStart(uid)
	-- uid = Player:getInstance():get("uid")
	local function onBattleStart(result)
		self:onBattleStart(uid, result)
	end
	NetManager.sendCmd("loadenemyteam", onBattleStart, uid)
end

function ChallengePopup:onBattleStart(uid, result)
	StageRecord:getInstance():set("dungeonType", Constants.DUNGEON_TYPE.PVP1)
	PvPBattleUI.setEnemy(uid, result.pets)
	Utils.popUIScene(self)
	Utils.replaceScene("PvPBattleUI")
end

function ChallengePopup:loadenemylist( )--展示对手列表
	for i=1,#value do
		if value[i] then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(value[i])
		end
	end
	local result = SilverChampionShipproxy.pvp1List  --所有挑战对手的信息 
	local list = __instance:getControl(Tag_popup_challenge.PANEL_POPUP_CHALLENGE,Tag_popup_challenge.LIST_TEAM)
	list:removeAllNodes()
	list:setDragable(true)
	local count = list:getNodeCount()
	while count < #result do
		local pCell = CGridViewCell:new()
		TuiManager:getInstance():parseCell(pCell, "cell_team", PATH_POPUP_CHALLENGE)
		list:insertNodeAtLast(pCell)
		count = list:getNodeCount()
	end
	list:reloadData()
	if #result<=4 then
		list:setDragable(false)
	end

	local function event_sort(a,b)
		return  a["rank"] < b["rank"]
	end
	table.sort(result,event_sort)

	for k = 1,#result do
		local node = list:getNodeAtIndex(k-1)
		local labRank = node:getChildByTag(Tag_popup_challenge.LAB_RANK_ENEMY)
		labRank:setString(result[k].rank)

		local playerName = node:getChildByTag(Tag_popup_challenge.LAB_TEAM_NAME)
		playerName:setString(result[k].name)

		local labLevel = node:getChildByTag(Tag_popup_challenge.LAB_LEVEL)
		labLevel:setString(result[k].level)
		
		local labRewardType = node:getChildByTag(Tag_popup_challenge.LAB_ENEMY_REWARDTYPE)
		local rewardType = TextManager.getPvp1RewardType(result[k]["chest"][1])
		labRewardType:setColor(Constants.APTITUDE_COLOR[result[k]["chest"][2]+1])

		local labRemainNum = node:getChildByTag(Tag_popup_challenge.LAB_TIME)
		-- labRemainNum:setColor(Constants.APTITUDE_COLOR[result[k]["chest"][2]+1])
		local sum_time = ConfigManager.getPvp1ChestQuality(result[k]["chest"][2]).need_time
		local function event_countdown(time) --冷却时间倒计时
			local hh,mm,ss = Utils.parseTime(time)
			hh,mm,ss = string.format("%.2d",hh),string.format("%.2d",mm),string.format("%.2d",ss)
			labRemainNum:setString(hh .. ":" .. mm .. ":" .. ss)
			labRewardType:setString(rewardType.reward_type .. " " .. math.floor(result[k]["chest"][3]*(sum_time-time)/sum_time))
			if time <=0 then
				return
			end
			value[k] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function() 
				time = time - 1
				local hh,mm,ss = Utils.parseTime(time)
				hh,mm,ss = string.format("%.2d",hh),string.format("%.2d",mm),string.format("%.2d",ss)
				labRemainNum:setString(hh .. ":" .. mm .. ":" .. ss)
				labRewardType:setString(rewardType.reward_type .. " " .. math.floor(result[k]["chest"][3]*(sum_time-time)/sum_time))
				if time <= 0 then
					if value[k] then
						cc.Director:getInstance():getScheduler():unscheduleScriptEntry(value[k])
					end
				end
			end, 1, false)
		end
		event_countdown(result[k]["chest"][4])

		local layoutIcon = node:getChildByTag(Tag_popup_challenge.LAYOUT_TEAM_ICON)
		local img = TextureManager.createImg(TextureManager.RES_PATH.PET_AVATAR,k)
		Utils.addCellToParent(img,layoutIcon)

		local function event_player_info()
			if countdown > 0 then
				local costDiamondTable = ConfigManager.getPvp1CommonConfig('refreshcdcost')
				local rootPvpTimes = Player:getInstance():get("rootPvpTimes")
				local cost
				if rootPvpTimes>=#costDiamondTable then
					cost = costDiamondTable[#costDiamondTable]
				else
					cost = costDiamondTable[rootPvpTimes+1]
				end
				local proxy = NormalDataProxy:getInstance()
			    proxy:set("title","清除冷却时间")
			    proxy:set("content","是否消耗" ..cost .."钻石清除冷却时间? 今天已清除了" .. rootPvpTimes .."次")
			    local function confirmHandler()
			        if Player:getInstance():get("diamond") < cost then
			            Utils.useRechargeDiamond()
			        else
			        	NetManager.sendCmd("refreshpvp1cd",function(result)
  							Player:getInstance():get("diamond",result["diamond"])
  							Player:getInstance():get("rootPvpTimes",result["rootpvp1times"])
  							-- TipManager.showTip("清除冷却时间成功")
  							countdown = 0
  							if scheduleCD then
	  							cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleCD)
  							end
  							if NormalDataProxy:getInstance().updatePvp1CD then
  								NormalDataProxy:getInstance().updatePvp1CD()
  							end
  							NormalDataProxy:getInstance().updatePvp1CD = nil
			        	end)
			        end
			    end
			    proxy.confirmHandler = confirmHandler
			    Utils.runUIScene("NormalPopup")
				return
			end
			local remainTimes = SilverChampionShipproxy:getInstance():get("remaintime")
			if remainTimes<=0 then
				Utils.runUIScene("PvpBuyPopup")
				return
			end
			self:battleStart(result[k].uid)
		end
		local btnStart = node:getChildByTag(Tag_popup_challenge.BTN_START)
		btnStart:setOnClickScriptHandler(event_player_info)
	end
end

function ChallengePopup:refreshEnemyList()
	local function loadenemy( result )
		SilverChampionShipproxy.pvp1List = result["enemy"]
		for i=1,#value do
			if value[i] then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(value[i])
			end
		end
		__instance:loadenemylist()
	end
	NetManager.sendCmd("loadenemy",loadenemy)
end

local function event_close( p_sender )
	Utils.popUIScene(__instance)
end

function ChallengePopup:onLoadScene()
	value = { scheduleID1,scheduleID2,scheduleID3,scheduleID4}
	TuiManager:getInstance():parseScene(self,"panel_popup_challenge",PATH_POPUP_CHALLENGE)
	
	local btnClose = self:getControl(Tag_popup_challenge.PANEL_POPUP_CHALLENGE,Tag_popup_challenge.BTN_CLOSE)
	btnClose:setOnClickScriptHandler(event_close)
	self:loadenemylist()
	local btnRefresh = self:getControl(Tag_popup_challenge.PANEL_POPUP_CHALLENGE,Tag_popup_challenge.BTN_REFRESH)
	btnRefresh:setOnClickScriptHandler(self.refreshEnemyList)

	local lab_wode = self:getControl(Tag_popup_challenge.PANEL_POPUP_CHALLENGE, Tag_popup_challenge.LAB_WODE)
	local proxy = SilverChampionShipproxy:getInstance()
	lab_wode:setString("我的排名:" .. proxy:get("ranking") .. "  连胜:" .. proxy:get("win_num"))

	countdown = NormalDataProxy:getInstance():get("pvpCD")
	scheduleCD = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function() 
		countdown = countdown - 1
		if countdown<=0 then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleCD)
		end
	end, 1, false)

	local function onNodeEvent(event)
		if "enter" == event then
			self:show()
		end
		if "exit" == event then
			for i=1,4 do
				if value[i] then
					cc.Director:getInstance():getScheduler():unscheduleScriptEntry(value[i])
				end
			end
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleCD)
		end
	end
	self:registerScriptHandler(onNodeEvent)
	TouchEffect.addTouchEffect(self)
end