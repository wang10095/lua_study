--
-- Author: hapigames
-- Date: 2014-12-09 12:17:19
--
require "view/tagMap/Tag_popup_daily"

DailyPopup = class("DailyPopup",function()
	return Popup:create()
end)

DailyPopup.__index = DailyPopup
local __instance = nil
local items = nil
local canGet = 0

function DailyPopup:create()
	local ret = DailyPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function DailyPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function DailyPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_daily.PANEL_POPUP_DAILY then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_close()
	Utils.popUIScene(__instance)
end

function DailyPopup:onLoadScene()
	NormalDataProxy:getInstance():set("isDaliyPursue",false)
	TuiManager:getInstance():parseScene(self,"panel_popup_daily",PATH_POPUP_DAILY)
	local btn_close = self:getControl(Tag_popup_daily.PANEL_POPUP_DAILY,Tag_popup_daily.BTN_CLOSE_DIALY)
	btn_close:setOnClickScriptHandler(event_close)
	btn_close:setPositionY(btn_close:getPositionY()+30)
	btn_close:setPositionX(btn_close:getPositionX()+30)
	local function callback_loaddailytask(result)
	-- local result=DailyDataProxy.dailyList   --日常的所有加载数据
		local list = self:getControl(Tag_popup_daily.PANEL_POPUP_DAILY,Tag_popup_daily.LIST_DAILY)
		local dailytaskConfig = ConfigManager.getConfigByFile("texts_dailytask")
		local count = list:getNodeCount()
		
		while count > #result["task"] do
			list:removeLastNode()
			count = list:getNodeCount()
		end
		list:reloadData()
		local dailyList = {}
		for i,v in ipairs(result["task"]) do
			if v["task_state"] ~= 3 then
				table.insert(dailyList,{v["task_id"],v["task_state"],v["num"]})
			end
		end
		table.sort( dailyList, function(daily1,daily2)
			local dailyConfig1 = ConfigManager.getDailyTaskConfig(daily1[1])
			local dailyConfig2 = ConfigManager.getDailyTaskConfig(daily2[1])
			local status1 = 0
			local statut2 = 0
			local d1 = daily1[2]
			local d2 = daily2[2]
			local n1 = daily1[3]
			local n2 = daily2[3]
			if n1 >= dailyConfig1.task_times then
				status1 = n1 + d1 + 100
			end
			if n2 >= dailyConfig2.task_times then
				statut2 = n2 + d2 + 100
			end
			return status1 > statut2
		end)
		canGet = 0
		for k,v in ipairs(dailyList)do
			--任务id  是否完成  次数
			local id,status,times = v[1],v[2],v[3]
			-- print("===id==" .. id,status,times)
			local dailyConfig = ConfigManager.getDailyTaskConfig(id)
			local textsdailyConfig = TextManager.getDailyTaskDesc(id)
			
			local node = list:getNodeAtIndex(k-1)
			local layout_daily = node:getChildByTag(Tag_popup_daily.LAYOUT_DAILYPET)
			local img = TextureManager.createImg("daily/".. id ..".jpg")
			Utils.addCellToParent(img,layout_daily,true)

			local lab_dailytitle = node:getChildByTag(Tag_popup_daily.LAB_DAILYTITLE)
			lab_dailytitle:setString(textsdailyConfig.task_title)
			local lab_finish_prog = node:getChildByTag(Tag_popup_daily.LAB_FINISH_PROG)
			local finish_num = times ..'/'.. dailyConfig.task_times
			if id == 1 then
				if times == 0 then
					finish_num = '去充值'
				elseif times >= 1 then
					finish_num = ''
					canGet  = canGet + 1
				end
			elseif id == 15  then
				finish_num = ''
				if status==2 and Player:getInstance():get("vip")>0 then --未领取
					canGet  = canGet + 1
				end
			elseif times>=dailyConfig.task_times and  times >0 then
				times = dailyConfig.task_times
				canGet  = canGet + 1
				finish_num = times ..'/'.. dailyConfig.task_times
			end
			lab_finish_prog:setString(finish_num)
			local lab_dailydesc = node:getChildByTag(Tag_popup_daily.LAB_DAILY_DESC)
			local num = string.find(textsdailyConfig.task_desc,'%d')
			lab_dailydesc:setString(textsdailyConfig.task_desc)

			local img_exp = node:getChildByTag(Tag_popup_daily.IMG_TEAMEXP)
			local img_diamond = node:getChildByTag(Tag_popup_daily.IMG_DIAMOND)
			local lab_teamexp_mult = node:getChildByTag(Tag_popup_daily.LAB_TEAMEXP_MULT)
			local lab_diamond_mult = node:getChildByTag(Tag_popup_daily.LAB_DIAMOND_MULT)
			local sweepCardNum = ConfigManager.getVipConfig(Player:getInstance():get("vip")).free_sweepcard_num
			if id == 1  then
				img_exp:setSpriteFrame("component_common/img_diamond.png")
				local getDiamond = ConfigManager.getRechargeConfig(1).diamond_num
				lab_teamexp_mult:setString("X" .. getDiamond)
				img_diamond:setVisible(false)
				lab_diamond_mult:setVisible(false)
			elseif id == 15 then
				img_exp:setTexture("item/item_2_3.jpg")
				img_exp:setScale(0.3)
				lab_teamexp_mult:setString("X" .. sweepCardNum)
				img_diamond:setVisible(false)
				lab_diamond_mult:setVisible(false)
			else
				lab_teamexp_mult:setString("X" .. dailyConfig.exp)
				if dailyConfig.gold == 0 and dailyConfig.diamond ==0  then
					img_diamond:setVisible(false)
					lab_diamond_mult:setVisible(false)
				elseif dailyConfig.gold == 0 and dailyConfig.diamond ~=0 then
					lab_diamond_mult:setString("X" .. dailyConfig.diamond)
				elseif dailyConfig.gold ~= 0 and dailyConfig.diamond ==0 then
					lab_diamond_mult:setString("X" .. dailyConfig.gold)
					img_diamond:setSpriteFrame("component_common/img_gold.png")
				end
			end

			local btn_go = node:getChildByTag(Tag_popup_daily.BTN_GO)
			local lab_go = node:getChildByTag(Tag_popup_daily.LAB_GO)
			local btnStatus = 0 --0 前往 1 领取 2已领取
			if status == 3 then
				btn_go:setVisible(false)
				lab_go:setString("已领取")
				btnStatus = 2
			else
				if id == 1 then
					if times == 1 then
						lab_go:setString("领取")
						btn_go:setNormalSpriteFrameName("component_common/btn_bag_select.png")
						btn_go:setSelectedSpriteFrameName("component_common/btn_bag_normal.png")
					else
						lab_go:setString("前往")
						btnStatus = 1
					end
				elseif id == 15 then
					if  status==2 and Player:getInstance():get("vip")>0 then
						lab_go:setString("领取")
						btn_go:setNormalSpriteFrameName("component_common/btn_bag_select.png")
						btn_go:setSelectedSpriteFrameName("component_common/btn_bag_normal.png")
					else
						lab_go:setString("前往")
						btnStatus = 1
					end
				else
					if times>=dailyConfig.task_times then
						lab_go:setString("领取")
						btn_go:setNormalSpriteFrameName("component_common/btn_bag_select.png")
						btn_go:setSelectedSpriteFrameName("component_common/btn_bag_normal.png")
					else
						lab_go:setString("前往")
						btnStatus = 1
					end
				end
			end

			local achievementTable = {   --弹窗为1  replace为2
				[1]="RechargePopup",
				[2]="PveUI",
				[3]="PveUI",
				[4]="PetBreedHouse",
				[5]="PveUI",
				[6]="PetListUI",
				[7]="PetListUI",
				[8]="BattlePalaceUI",
				[9]="RouletteUI",
				[10]="PyramidUI",
				[11]="SilverChampionshipUI",
				[12]="SilverChampionshipUI",
				[13]="GoldhandPopup",
				[14]="WildUI",
				[15]="RechargePopup",
			}

			local function event_go_or_get(p_sender)
				if btnStatus == 1 then
					if id==3 then
						StageRecord:getInstance():set("dungeonType", Constants.DUNGEON_TYPE.ELITE) --设置副本类型  普通 
					else
						StageRecord:getInstance():set("dungeonType", Constants.DUNGEON_TYPE.NORMAL) --设置副本类型  普通 
					end
					NormalDataProxy:getInstance():set("isDaliyPursue",true)
					if id == 8 then
						local week = os.date("*t")
					    local WEEK = {7,1,2,3,4,5,6}
					    local today = tonumber(WEEK[tonumber(week.wday)])
					    if today%2 ~= 0 then 
					        Activity1StatusProxy:getInstance():set("activity1Type", Constants.ACTIVITY1_TYPE.CANDY_AREA)
					    else
					        Activity1StatusProxy:getInstance():set("activity1Type", Constants.ACTIVITY1_TYPE.REGAL_AREA)
					    end 
					end

					local function nextPush()
						if id == 1 or id == 13 or id == 15 then
							Utils.runUIScene(achievementTable[id])
						else
							Utils.pushScene(achievementTable[id])
						end
					end
					Utils.popUIScene(__instance,nextPush)
					return
				end
				local function loadtaskreward(result)
					canGet = canGet - 1
					if canGet <=0 then
						PromtManager.NewsTable.DAILYTASK_FINISH.status = false
					 	PromtManager.checkOnePromt("DAILYTASK_FINISH")
					end

					TipManager.showTip('领取奖励成功')
					Player:getInstance():set("level",result["level"])
					Player:getInstance():set("exp",result["exp"])
					Player:getInstance():set("diamond",result["diamond"])
					Player:getInstance():set("gold",result["gold"])
					Player:getInstance():set("energy",result["energy"])
					if id == 15 then
						local oldAmount = ItemManager.getItemAmount(Constants.ITEM_TYPE.MATERIAL, 3)
						ItemManager.updateItem(Constants.ITEM_TYPE.MATERIAL, 3, sweepCardNum+oldAmount)
					end
					if 	NormalDataProxy:getInstance().updateUser  then
						NormalDataProxy:getInstance().updateUser()
					end
					if #dailyConfig.item~=0 then
						local itemAmount = ItemManager.getItemAmount(dailyConfig.item[1], dailyConfig.item[2])
						ItemManager.updateItem(dailyConfig.item[1],dailyConfig.item[2],dailyConfig.item[3]+itemAmount)
					end
					Player:getInstance():isPlayerLevelUp()
					list:removeNode(node)
					list:reloadData()
				end
				NetManager.sendCmd("loaddailytaskreward",loadtaskreward,id)
			end
			btn_go:setOnClickScriptHandler(event_go_or_get)
		end
	end
	NetManager.sendCmd("loaddailytask",callback_loaddailytask)
	TouchEffect.addTouchEffect(self)
	local function onNodeEvent(event)
		if "enter" == event then
			self:show()
			NormalDataProxy:getInstance():set("isPopup",true)
		end
		if "exit" == event then
			NormalDataProxy:getInstance():set("isPopup",false)
		end
	end
	self:registerScriptHandler(onNodeEvent)
end








