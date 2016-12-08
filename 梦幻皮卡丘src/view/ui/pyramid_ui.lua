require "view/tagMap/Tag_ui_pyramid"

PyramidUI = class("PyramidUI",function()
	return TuiBase:create()
end)

PyramidUI.__index = PyramidUI
local __instance = nil
local stage = nil
local isReset = false
local btnChallenge = nil
local btnGetReward = nil

function  PyramidUI:create()
	local ret = PyramidUI.new()
	__instance = ret 
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function PyramidUI:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_pyramid.PANEL_PYRAMID then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function PyramidUI:getControl(tagPanel, tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

local function event_return()
    if NormalDataProxy:getInstance():get("isDaliyPursue") then
        Utils.popScene()
        Utils.runUIScene("DailyPopup")
        return
    end
    Utils.replaceScene("ExploreUI",__instance)
end

local function event_rank()
    RankDataProxy:getInstance():set("rank_type",Constants.RANK_TYPE.ACTIVITY)
    -- local function loadactivity3rank( result )
    --     RankDataProxy.arenarank = result
    Utils.replaceScene("RankUI",__instance)
    -- end
    -- NetManager.sendCmd("loadactivity3rank",loadactivity3rank)
end    

local function continue_challenge()
    if isReset == true then  --重置之后判断是否需要领取奖励
        if stage == 1 then  --在第一层  直接开始挑战
            local stageRecord = StageRecord:getInstance()
            stageRecord:set("dungeonType", Constants.DUNGEON_TYPE.ACTIVITY3)
            stageRecord:set("stage", stage)
            Utils.replaceScene("BattleUI",__instance)
        else   --不是第一层  先领取奖励后 再继续挑战
            local  function confirmHandler()
                startLayer:setString("出发层" .. stage)
                labChallenge:setString("继续挑战")
                btnGetReward:setVisible(false)
                btnChallenge:setVisible(true)
            end
            NormalDataProxy:getInstance().confirmHandler = confirmHandler
            Utils.runUIScene("PyramidRewardsPopup")
        end
    else  --直接挑战   需要在战斗界面判断是否领取奖励
        local stageRecord = StageRecord:getInstance()
        stageRecord:set("dungeonType", Constants.DUNGEON_TYPE.ACTIVITY3)
        stageRecord:set("stage", stage)
        stageRecord:set("activity3_moveToNextStage",false)
        Utils.replaceScene("BattleUI",__instance)
    end
    isReset = false
end

local function callback_reset(result)
    isReset = true
    dayRemainNum:setString(result["reset_times"])
    dayRemainNum:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1.5),cc.ScaleTo:create(0.2,1.0),nil))
    if result["stage"]==1 then
        stage = 1
        startLayer:setString("出发层:1")
        labChallenge:setString("开始挑战")
        PyramidProxy:getInstance():set("reset_has_reward",1) --不需要领取重置奖励
    else
        stage = result["stage"] 
        startLayer:setString("前" .. stage-1 .. "层奖励")
        labChallenge:setString("领取奖励")
        PyramidProxy:getInstance():set("reset_has_reward",0) --需要领取重置奖励
        btnGetReward:setVisible(true)
        btnChallenge:setVisible(false) 
    end
    if tonumber(result["reset_times"])<=0 then
        labReset:setVisible(false)
        btnReset:setVisible(false)
    else
        labReset:setVisible(true)
        btnReset:setVisible(true)
    end
end

local function event_reset()
    if tonumber(dayRemainNum:getString()) <= 0 then
        TipManager.showTip("今日重置次数已用完")
        return
    end
    if stage == 1 then
        TipManager.showTip("当前在第一层 不能重置")
        return
    end
    if PyramidProxy:getInstance():get("has_reward") ~=1 and PyramidProxy:getInstance():get("reset_has_reward") == 1 then
        NetManager.sendCmd("getactivity3reset",callback_reset)
    else
        TipManager.showTip("请先领取奖励")
    end
end 

function PyramidUI:onLoadScene()
    TuiManager:getInstance():parseScene(self,"panel_pyramid",PATH_UI_PYRAMID)
    local layoutTop = self:getControl(Tag_ui_pyramid.PANEL_PYRAMID, Tag_ui_pyramid.LAYOUT_TOP)
    Utils.floatToTop(layoutTop)
    layoutButtom = self:getControl(Tag_ui_pyramid.PANEL_PYRAMID,Tag_ui_pyramid.LAYOUT_BUTTOM)
    Utils.floatToBottom(layoutButtom)
    local btnReturn = layoutButtom:getChildByTag(Tag_ui_pyramid.BTN_PYRAMID_BACK)
    btnReturn:setOnClickScriptHandler(event_return)
    labReset = layoutButtom:getChildByTag(Tag_ui_pyramid.LAB_PYRAMID_RESET)
    btnReset = layoutButtom:getChildByTag(Tag_ui_pyramid.BTN_PYRAMID_RESET)
    btnReset:setOnClickScriptHandler(event_reset)
    dayRemainNum = layoutButtom:getChildByTag(Tag_ui_pyramid.LAB_REMAIN_NUM)

    local btnRank = layoutTop:getChildByTag(Tag_ui_pyramid.BTN_RANK)
    btnRank:setOnClickScriptHandler(event_rank)

    startLayer = self:getControl(Tag_ui_pyramid.PANEL_PYRAMID,Tag_ui_pyramid.LAB_START_LAYER_NUM)
    labChallenge = self:getControl(Tag_ui_pyramid.PANEL_PYRAMID,Tag_ui_pyramid.LAB_CONTINUE_CHALLENGE)
    btnChallenge = self:getControl(Tag_ui_pyramid.PANEL_PYRAMID,Tag_ui_pyramid.BTN_CONTINUE_CHALLENGE)
    btnChallenge:setOnClickScriptHandler(continue_challenge)
    btnGetReward = self:getControl(Tag_ui_pyramid.PANEL_PYRAMID,Tag_ui_pyramid.BTN_GETREWARD)
    btnGetReward:setOnClickScriptHandler(continue_challenge)
    btnGetReward:setVisible(false)

    local function load_pyramid_status(result)
        PyramidProxy:getInstance():set("floor",result["stage"])
        if result["has_reward"]==1 then
            stage = result["stage"] - 1
        else
            stage = result["stage"]
        end
        dayRemainNum:setString(result["reset_times"]) --重置次数
        PyramidProxy:getInstance():set("has_reward",result["has_reward"]) --是否领取奖励
        PyramidProxy:getInstance():set("reset_has_reward",result["reset_has_reward"]) --是否领取了重置奖励

        if tonumber(result["reset_times"])<=0 then   -- 当重置次数为0 不显示重置按钮
            labReset:setVisible(false)
            btnReset:setVisible(false) 
        end

        if tonumber(result["reset_has_reward"])==0  then  --重置之后没有领取奖励  需要领取奖励
            isReset = true
            startLayer:setString("前" .. stage-1 .. "层奖励")
            labChallenge:setString("领取奖励")
            btnGetReward:setVisible(true)
            btnChallenge:setVisible(false)
        else
            isReset = false
            startLayer:setString("出发层:" .. stage)
            if stage == 1 then           
                labChallenge:setString("开始挑战")
            else
                labChallenge:setString("继续挑战")
            end
        end
    end   
    NetManager.sendCmd("loadactivity3status",load_pyramid_status)
    TouchEffect.addTouchEffect(self) 
end


