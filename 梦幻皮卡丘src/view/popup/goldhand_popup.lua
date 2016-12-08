--
-- Author: hapigames
-- Date: 2014-12-03 22:15:10
--
require "view/tagMap/Tag_popup_goldhand"

GoldhandPopup = class("GoldhandPopup",function()
	return Popup:create()
end)

GoldhandPopup.__index = GoldhandPopup
local __instance = nil
local lab_tips = nil
local list = nil
local layoutRelease 
local layoutGold
local layoutSkill
local lab_remaintimes
local lab_tips13,lab_tips12
local diamondSecond 

function GoldhandPopup:create()
	local ret = GoldhandPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function GoldhandPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function GoldhandPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_goldhand.PANEL_POPUP_GOLDHAND then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function GoldhandPopup:dtor()
	self:getEventDispatcher():removeEventListener(continuiousListener)
end

local function event_goldhand(result)
	local goldhandnum = ConfigManager.getVipConfig(Player:getInstance():get("vip")).goldhand_num --总次数
	MusicManager.subMusicVolume(1)
	MusicManager.goldhand()
	lab_tips:setVisible(false)
	list:setVisible(true)
	local function CallFucnCallback( )
		Spine.addSpine(layoutSkill,"battle","skill_name","part2",false)
	end
	local function CallFucnCallback1( )
		Spine.addSpine(layoutRelease,"goldhand","release","part1",false)
	end
	local function CallFucnCallback2( )
		Spine.addSpine(layoutGold,"goldhand","gold","part1",false)
	end
	__instance:runAction(cc.Sequence:create(cc.CallFunc:create(CallFucnCallback),cc.DelayTime:create(0.1),cc.CallFunc:create(CallFucnCallback1),cc.DelayTime:create(1.6),cc.CallFunc:create(CallFucnCallback2)))
	__instance:runAction(cc.Sequence:create(cc.DelayTime:create(4),cc.CallFunc:create(function( )
		MusicManager.addMusicVolume(1)
	end)))
	list:removeAllNodes()
	local count = list:getNodeCount()
	local remainNum = goldhandnum - result["goldhandTimes"]
	lab_remaintimes:setString(remainNum)
	Player:getInstance():set("goldhandTimes",result["goldhandTimes"])
	Player:getInstance():set("gold",result["gold"])
	Player:getInstance():set("diamond",result["diamond"])
	if NormalDataProxy:getInstance().updateUser then
		NormalDataProxy:getInstance().updateUser()
	end

	local eventDispatcher = __instance:getEventDispatcher()
	local event = cc.EventCustom:new("recharge_update_gold")
	eventDispatcher:dispatchEvent(event)
	local eventDispatcher = __instance:getEventDispatcher()
	local event = cc.EventCustom:new("recharge_update_diamond")
	eventDispatcher:dispatchEvent(event)
	local goldhandlist = {}
	for i,v in pairs(result["list"]) do
		table.insert(goldhandlist,{i,v["getgoldnum"],v["critmultiple"]})
	end
	while count < #goldhandlist  do
		local pCell = CGridViewCell:new()
		TuiManager:getInstance():parseCell(pCell, "cell_content", PATH_POPUP_GOLDHAND)
		list:insertNodeAtLast(pCell)
		count = list:getNodeCount()
	end
	list:reloadData()
	for i=1,#goldhandlist do
		local node = list:getNodeAtIndex(i-1)
		local lab_usediamond_num = node:getChildByTag(Tag_popup_goldhand.LAB_USEDIAMOND_NUM)
		local labGoldNum = node:getChildByTag(Tag_popup_goldhand.LAB_GETGOLD_NUM)
		local labCritmult = node:getChildByTag(Tag_popup_goldhand.LAB_CRIT_MULT)
		labGoldNum:setString(goldhandlist[i][3])
		labCritmult:setString(goldhandlist[i][2])
		if goldhandlist[i][2] >1 and goldhandlist[i][2]<5 then
			labCritmult:setColor(Constants.APTITUDE_COLOR[2])
		elseif goldhandlist[i][2] >=5 and goldhandlist[i][2] <10 then
			labCritmult:setColor(Constants.APTITUDE_COLOR[3])
		elseif goldhandlist[i][2] >=10 then
			labCritmult:setColor(Constants.APTITUDE_COLOR[4])
		end
		lab_usediamond_num:setString(lab_tips12:getString())
	end
	__instance:diaplayNextGoldhand()
end

function GoldhandPopup:onGoldhandListener()
	local goldhandnum = ConfigManager.getVipConfig(Player:getInstance():get("vip")).goldhand_num --总次数
	if goldhandnum - Player:getInstance():get("goldhandTimes") <=0 then
		TipManager.showTip("今日聚宝次数已经用完!")
	elseif Player:getInstance():get("diamond")<tonumber(lab_tips12:getString()) then
		Utils.useRechargeDiamond()
	else
		NetManager.sendCmd("goldhand",event_goldhand,Constants.GOLDHAND_TYPE.ONCE)
	end
end


function GoldhandPopup:onContinuiousListener(event)
	local goldhandnum = ConfigManager.getVipConfig(Player:getInstance():get("vip")).goldhand_num --总次数
	local function event_goldhandContinuious(result)
		MusicManager.subMusicVolume(1)
		MusicManager.goldhand()
		lab_tips:setVisible(false)
		list:setVisible(true)
		local function CallFucnCallback( )
			Spine.addSpine(layoutSkill,"battle","skill_name","part2",false)
		end
		local function CallFucnCallback1(  )
			Spine.addSpine(layoutRelease,"goldhand","release","part1",false)
		end
		local function CallFucnCallback2( )
			Spine.addSpine(layoutGold,"goldhand","gold","part1",false)
		end
		__instance:runAction(cc.Sequence:create(cc.CallFunc:create(CallFucnCallback),cc.DelayTime:create(0.1),cc.CallFunc:create(CallFucnCallback1),cc.DelayTime:create(1.6),cc.CallFunc:create(CallFucnCallback2)))
		__instance:runAction(cc.Sequence:create(cc.DelayTime:create(4),cc.CallFunc:create(function( )
			MusicManager.addMusicVolume(1)
		end)))
		list:removeAllNodes()
		local count = list:getNodeCount()
		local remainGoldhandTime = goldhandnum - result["goldhandTimes"] --剩余次数
		lab_remaintimes:setString(remainGoldhandTime)
		Player:getInstance():set("goldhandTimes",result["goldhandTimes"]) --当前用了多少次
		Player:getInstance():set("gold",result["gold"])
		Player:getInstance():set("diamond",result["diamond"])
		if NormalDataProxy:getInstance().updateUser then
			NormalDataProxy:getInstance().updateUser()
		end

		local eventDispatcher = __instance:getEventDispatcher()
		local event = cc.EventCustom:new("recharge_update_gold")
		eventDispatcher:dispatchEvent(event)
		local eventDispatcher = __instance:getEventDispatcher()
		local event = cc.EventCustom:new("recharge_update_diamond")
		eventDispatcher:dispatchEvent(event)

		local goldhandlist = {}
		for i,v in pairs(result["list"]) do
			table.insert(goldhandlist,{i,v["getgoldnum"],v["critmultiple"]})
		end
		while count < #goldhandlist  do
			local pCell = CGridViewCell:new()
			TuiManager:getInstance():parseCell(pCell, "cell_content", PATH_POPUP_GOLDHAND)
			list:insertNodeAtLast(pCell)
			count = list:getNodeCount()
		end
		list:reloadData()
		local nodeTable = {}
		for i=1,#goldhandlist do
			local node = list:getNodeAtIndex(i-1)
			node:setVisible(false)
			local lab_usediamond_num = node:getChildByTag(Tag_popup_goldhand.LAB_USEDIAMOND_NUM)
			lab_usediamond_num:setString(diamondSecond)
			local labGoldNum = node:getChildByTag(Tag_popup_goldhand.LAB_GETGOLD_NUM)
			local labCritmult = node:getChildByTag(Tag_popup_goldhand.LAB_CRIT_MULT)
			labGoldNum:setString(goldhandlist[i][3])
			labCritmult:setString(goldhandlist[i][2])
			table.insert(nodeTable,node)
			if goldhandlist[i][2] >1 and goldhandlist[i][2]<5 then
				labCritmult:setColor(Constants.APTITUDE_COLOR[2])
			elseif goldhandlist[i][2] >=5 and goldhandlist[i][2] <10 then
				labCritmult:setColor(Constants.APTITUDE_COLOR[3])
			elseif goldhandlist[i][2] >=10 then
				labCritmult:setColor(Constants.APTITUDE_COLOR[4])
			end
		end
		local array = cc.DelayTime:create(0)
		local callback = function ()
		end
		for i=1,#goldhandlist do
			callback = function()
				nodeTable[i]:setVisible(true)
				nodeTable[i]:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3,1.3),cc.ScaleTo:create(0.1,1)))
			end
			array = cc.Sequence:create(array,cc.DelayTime:create(0.3), cc.CallFunc:create(callback),nil)
		end
		__instance:runAction(cc.Sequence:create(cc.DelayTime:create(2.3),array))

		__instance:diaplayNextGoldhand()	
	end
	if goldhandnum - Player:getInstance():get("goldhandTimes") <=0 then
		TipManager.showTip("今日聚宝次数已经用完!")
	else
		NetManager.sendCmd("goldhand",event_goldhandContinuious,Constants.GOLDHAND_TYPE.CONTINUOUS)
	end
end

local function event_close( p_sender )
	if NormalDataProxy:getInstance():get("isDaliyPursue") then
		Utils.popUIScene(__instance)
		Utils.runUIScene("DailyPopup")
		return
	end
	Utils.popUIScene(__instance)
end

function GoldhandPopup:diaplayNextGoldhand()
	local vipGoldhandNum = ConfigManager.getVipConfig(Player:getInstance():get("vip")).goldhand_num
	local usedGoldHand = Player:getInstance():get("goldhandTimes") --已经聚宝次数
	usedGoldHand = usedGoldHand + 1
	local costDiamond = ConfigManager.getGoldHandDiamondCost(usedGoldHand)
	if costDiamond == nil then
		while (costDiamond==nil) do
			usedGoldHand = usedGoldHand + 1
			costDiamond = ConfigManager.getGoldHandDiamondCost(usedGoldHand)
		end
	end
	if costDiamond==nil then
		costDiamond = ConfigManager.getGoldHandDiamondCost(vipGoldhandNum)
	end
	lab_tips12:setString(costDiamond)
	local goldBasic = ConfigManager.getGoldhandCommonConfig('base_gold')
	local goldCoefficient = ConfigManager.getGoldhandCommonConfig('gold_coefficient')
	local getGold = math.floor((goldBasic+Player:getInstance():get("level")*goldCoefficient)*(1+Player:getInstance():get("goldhandTimes")*0.01))
	lab_tips13:setString(getGold)
end

function GoldhandPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_goldhand",PATH_POPUP_GOLDHAND)
	local btnClose = self:getControl(Tag_popup_goldhand.PANEL_POPUP_GOLDHAND,Tag_popup_goldhand.BTN_CLOSE)
	btnClose:setOnClickScriptHandler(event_close)
	local layoutCycle = self:getControl(Tag_popup_goldhand.PANEL_POPUP_GOLDHAND,Tag_popup_goldhand.LAYOUT_CYCLE)
	Spine.addSpine(layoutCycle,"goldhand","cycle","part1",true) --猫咪
	list = self:getControl(Tag_popup_goldhand.PANEL_POPUP_GOLDHAND,Tag_popup_goldhand.LIST_CONTENT)
	list:setVisible(false)
	layoutRelease = __instance:getControl(Tag_popup_goldhand.PANEL_POPUP_GOLDHAND,Tag_popup_goldhand.LAYOUT_RELEASE)
	layoutGold = __instance:getControl(Tag_popup_goldhand.PANEL_POPUP_GOLDHAND,Tag_popup_goldhand.LAYOUT_GOLD)
	layoutSkill = __instance:getControl(Tag_popup_goldhand.PANEL_POPUP_GOLDHAND,Tag_popup_goldhand.LAYOUT_SKILL)

	lab_tips = self:getControl(Tag_popup_goldhand.PANEL_POPUP_GOLDHAND,Tag_popup_goldhand.LAB_TIP3)
	lab_remaintimes = __instance:getControl(Tag_popup_goldhand.PANEL_POPUP_GOLDHAND,Tag_popup_goldhand.LAB_NUM)

	local goldhandnum = ConfigManager.getVipConfig(Player:getInstance():get("vip")).goldhand_num --总次数
	
	local remaintime = Player:getInstance():get("goldhandTimes")
	lab_remaintimes:setString(goldhandnum - remaintime)

	local function event_continuious(p_sender)
		local proxy = NormalDataProxy:getInstance()
		proxy.confirmHandler = self.onContinuiousListener
		
		local function event_secondensure( result )
			GoldhandDataProxy:getInstance():set("usediamondnum",result["usediamondnum"])
			GoldhandDataProxy:getInstance():set("goldhandtimes",result["goldhandtimes"])
			GoldhandDataProxy:getInstance():set("isborrow",0)
			Utils.runUIScene("SecondensurePopup")
			diamondSecond = result["usediamondnum"] / result["goldhandtimes"]
		end

		if goldhandnum - Player:getInstance():get("goldhandTimes") <=0 then
			TipManager.showTip("今日聚宝次数已经用完!")
		else
			NetManager.sendCmd("secondensure",event_secondensure)
		end
	end
	
	local btn_jubao = self:getControl(Tag_popup_goldhand.PANEL_POPUP_GOLDHAND,Tag_popup_goldhand.BTN_JUBAO)
	btn_jubao:setOnClickScriptHandler(self.onGoldhandListener)

	local btn_continue = self:getControl(Tag_popup_goldhand.PANEL_POPUP_GOLDHAND,Tag_popup_goldhand.BTN_CONTINUE)
	btn_continue:setOnClickScriptHandler(event_continuious)

	local layout_tip = self:getControl(Tag_popup_goldhand.PANEL_POPUP_GOLDHAND,Tag_popup_goldhand.LAYOUT_TIP)
	 lab_tips12 = layout_tip:getChildByTag(Tag_popup_goldhand.LAB_TIPS12) --钻石
	 lab_tips13 = layout_tip:getChildByTag(Tag_popup_goldhand.LAB_TIPS13)
	 self:diaplayNextGoldhand()

	local function onNodeEvent(event)
		if "enter" == event then
			self:show()
			NormalDataProxy:getInstance():set("isPopup",true)
			local goldhandCommon = ConfigManager.getGoldhandCommonConfig('openlevel')
			if Player:getInstance():get("level") == goldhandCommon then
				Utils.dispatchCustomEvent("event_goldhand",{view = "GoldhandPopup",phase = GuideManager.FUNC_GUIDE_PHASES.GOLDHAND_ONCE,scene = self})
			end
		end
		if "exit" == event then
			NormalDataProxy:getInstance():set("isPopup",false)
		end
	end
	self:registerScriptHandler(onNodeEvent)
	TouchEffect.addTouchEffect(self)
end
