require "view/tagMap/Tag_popup_activity1_encounter"

ActivityEncounterPopup = class("ActivityEncounterPopup",function()
	return Popup:create()
end)

ActivityEncounterPopup.__index = ActivityEncounterPopup
local __instance = nil
local nowDiff = 1
local btnEscape,btnBoss,btnMidBoss,btnSuperBoss

function ActivityEncounterPopup:create()
	local ret = ActivityEncounterPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function ActivityEncounterPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function ActivityEncounterPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_activity1_encounter.PANEL_POPUP_ACTIVITY1_ENCOUNTER then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function onbattlestart(p_sender)
	btnBoss:setEnabled(false)
	btnMidBoss:setEnabled(false)
	btnSuperBoss:setEnabled(false)
	local tag = p_sender:getTag()
	local k = {
		Tag_popup_activity1_encounter.BTN_BOSS,
		Tag_popup_activity1_encounter.BTN_MIDBOSS,
		Tag_popup_activity1_encounter.BTN_SUPERBOSS
	}
	local difficulty 
	for i=1,3 do
		if k[i] == tag then
			difficulty = i
		end
	end
	Activity1StatusProxy:getInstance():set("difficulty",difficulty+1)
	local activity1Type = Activity1StatusProxy:getInstance():get("activity1Type")
	local diff
	if activity1Type == Constants.ACTIVITY1_TYPE.CANDY_AREA then
		diff = 'candy_difficulty'
	else
		diff = 'regal_difficulty'
	end
	local level = Player:getInstance():get("level")
	local monsterConfig
	local monster = ConfigManager.getActivity1MonsterConfig()
	for i = 1, 16 do
		if level <= monster[i].level then
			monsterConfig = monster[i]
			break
		end
	end
	
	StageRecord:getInstance():set("stage",monsterConfig[diff..difficulty])
	StageRecord:getInstance():set("chapter",1)
	StageRecord:getInstance():set("dungeonType",Constants.DUNGEON_TYPE.ACTIVITY1)
	Utils.replaceScene("BattleUI",__instance)

	local eventDispatcher = __instance:getEventDispatcher()
	local event = cc.EventCustom:new("call_ui_dtor")
	eventDispatcher:dispatchEvent(event)
	Utils.popUIScene(__instance)
end

local function onEscape(p_sender)
	btnEscape:setEnabled(false)
	local difficulty = 1
	Activity1StatusProxy:getInstance():set("difficulty",1)
	local token = Activity1StatusProxy:getInstance():get("token")
	local function activity1battlestart( result )
		Activity1StatusProxy:getInstance():set("token",result["token"])
		Activity1StatusProxy:getInstance():set("score",result["score"])
		local score = ConfigManager.getActivty1CommonConfig('event2_' .. difficulty .. '_score')
	    TipManager.showTip("逃兵是要被扣分的 " .. score .. "分")
	    Utils.popUIScene(__instance)

		if NormalDataProxy:getInstance().onCompleteEnermy then
			NormalDataProxy:getInstance().onCompleteEnermy()
		end
		NormalDataProxy:getInstance().onCompleteEnermy = nil
	end
	NetManager.sendCmd("activity1battlestart",activity1battlestart,__instance.activity1Type,token,difficulty)
end

function ActivityEncounterPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_activity1_encounter",PATH_POPUP_ACTIVITY1_ENCOUNTER)
	self.activity1Type = Activity1StatusProxy:getInstance():get("activity1Type")

	btnEscape = self:getControl(Tag_popup_activity1_encounter.PANEL_POPUP_ACTIVITY1_ENCOUNTER,Tag_popup_activity1_encounter.BTN_ESCAPE)
	btnEscape:setOnClickScriptHandler(onEscape)
	btnBoss = self:getControl(Tag_popup_activity1_encounter.PANEL_POPUP_ACTIVITY1_ENCOUNTER,Tag_popup_activity1_encounter.BTN_BOSS)
	btnBoss:setOnClickScriptHandler(onbattlestart)
	btnMidBoss = self:getControl(Tag_popup_activity1_encounter.PANEL_POPUP_ACTIVITY1_ENCOUNTER,Tag_popup_activity1_encounter.BTN_MIDBOSS)
	btnMidBoss:setOnClickScriptHandler(onbattlestart)
	btnSuperBoss = self:getControl(Tag_popup_activity1_encounter.PANEL_POPUP_ACTIVITY1_ENCOUNTER,Tag_popup_activity1_encounter.BTN_SUPERBOSS)
	btnSuperBoss:setOnClickScriptHandler(onbattlestart)
	TouchEffect.addTouchEffect(self)

	for i=1,4 do
		local lab_defen = self:getControl(Tag_popup_activity1_encounter.PANEL_POPUP_ACTIVITY1_ENCOUNTER,Tag_popup_activity1_encounter["LAB_DEFEN" .. i])
		local score = ConfigManager.getActivty1CommonConfig('event2_' .. i .. '_score')
		if i == 1 then
			lab_defen:setString("得分" .. score)
		else
			lab_defen:setString("得分+" .. score)
		end
	end
end