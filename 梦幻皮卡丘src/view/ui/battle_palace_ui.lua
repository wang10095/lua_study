require "view/tagMap/Tag_ui_battle_palace"

BattlePalaceUI = class("BattlePalaceUI",function()
    return TuiBase:create()
end)

BattlePalaceUI.__index = BattlePalaceUI
local __instance = nil
local addscore
local scrol
local directGetScore = false ---直接得分没有触发任何事件
local coolTime = nil
local lab_cool,lab_cool_time
local scheduleCoolID,scheduleID
local event_id2,event_score2
local labScore

function  BattlePalaceUI:create()
    local ret = BattlePalaceUI.new()
    __instance = ret
    ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
    return ret
end

function BattlePalaceUI:getPanel(tagPanel)
    local ret = nil
    if tagPanel == Tag_ui_battle_palace.PANEL_BATTLE_PALACE then
        ret = self:getChildByTag(tagPanel)
    end
    return ret
end

function BattlePalaceUI:getControl(tagPanel, tagControl)
    local ret = nil
    ret = self:getPanel(tagPanel):getChildByTag(tagControl)
    return ret
end

function BattlePalaceUI:dtor()
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID)
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleBtnEnabled)
    if scheduleCoolID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleCoolID)
    end
    if self.listener1 then
        self:getEventDispatcher():removeEventListener(self.listener1)
    end
    if self.listener2 then
       self:getEventDispatcher():removeEventListener(self.listener2)
    end
    if self.listener3 then
       self:getEventDispatcher():removeEventListener(self.listener3)
    end
    if self.listenerDtor then
       self:getEventDispatcher():removeEventListener(self.listenerDtor)
    end 
end

local function loadactivity1status(result ) --加载状态 
    __instance.token = result["token"]
    __instance.diceCount = result["dicecount"] 
    __instance.todayRemainTimes = result["remaintimes"] 
    __instance.score = result["score"] 
    __instance.rewardtimes = result["rewardtimes"]
    __instance.eventNum = result["diceevent"]
    __instance.index = result["grid"] % 42  
    if __instance.index == 0 then
        __instance.index = 1
    end

    if __instance.eventNum ~= 0 then
        Activity1StatusProxy:getInstance():set("ernie_id",5)
        __instance.onLoadGridevent()
    end
    Activity1StatusProxy:getInstance():set("token", __instance.token)
    if NormalDataProxy:getInstance().onCompleteEnermy then
        NormalDataProxy:getInstance().onCompleteEnermy()
    end
    NormalDataProxy:getInstance().onCompleteEnermy = nil

    labScore:setString(__instance.score)
    labRemainTimes:setString(__instance.todayRemainTimes)
    labRemainTimes:setVisible(__instance.todayRemainTimes>0)
    labRemainTip1:setVisible(__instance.todayRemainTimes>0)
    labRemainTip2:setVisible(__instance.todayRemainTimes>0)
    labRewardTimes:setString(__instance.rewardtimes)
    
    local labTrophy = layoutBottom:getChildByTag(Tag_ui_battle_palace.LAB_TROPHY)
    local labRewardMulit = layoutBottom:getChildByTag(Tag_ui_battle_palace.LAB_REWARDMULT)
    
    local reward = ConfigManager.getActivity1RewardConfig(Player:getInstance():get("level"))

    local level_1 = ConfigManager.getActivity1ScoreConfig(1)
    local level_2 = ConfigManager.getActivity1ScoreConfig(2)
    local level_3 = ConfigManager.getActivity1ScoreConfig(3)
    if __instance.score <= level_1.score then
        labTrophy:setString(level_1.reward_level)
        labTrophy:setColor(cc.c3b(135,198,117))
    elseif __instance.score <= level_2.score and  __instance.score > level_1.score then
        labTrophy:setString(level_2.reward_level)
        labTrophy:setColor(cc.c3b(255,255,255))
    else
        labTrophy:setString(level_3.reward_level)
        labTrophy:setColor(cc.c3b(253,233,110))
    end
    -- print("====__instance.index==" ..__instance.index)
    local imgGrid 
    if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
        imgGrid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT".. __instance.index]) --糖果区
    else
        imgGrid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT_".. __instance.index]) --土豪区
    end
    Pos = cc.p(imgGrid:getPosition())
    imgSelect:setPosition(cc.p(Pos.x,Pos.y))
    local cs = scrol:getContainerSize()
    local Min = scrol:getMinOffset()
    if (Pos.y-cs.height/4) > -Min.y then
        scrol:setContentOffsetToTopInDuration(0.5)
    elseif (Pos.y-cs.height/4) < 0 then 
        scrol:setContentOffsetToBottom()
    else
        scrol:setContentOffset(cc.p(0,-(Pos.y-cs.height/4)))
    end
    
    __instance:onGridSpineBreath(__instance.index,Pos)
    
    local layoutDice = layoutBottom:getChildByTag(Tag_ui_battle_palace.LAYOUT_DICE)
    labDiceCount:setString(__instance.diceCount)

    coolTime = result["remainTime"]
    if coolTime<=0 then
        lab_cool:setVisible(false)
        lab_cool_time:setVisible(false)
    else
        lab_cool:setVisible(true)
        lab_cool_time:setVisible(true)
        local hh,mm,ss = Utils.parseTime(coolTime)
        hh,mm,ss = string.format("%.2d",hh),string.format("%.2d",mm),string.format("%.2d",ss)
        lab_cool_time:setString(hh..":" ..mm.. ":" ..ss)

        scheduleCoolID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
            coolTime = coolTime -1
            local hh,mm,ss = Utils.parseTime(coolTime)
            hh,mm,ss = string.format("%.2d",hh),string.format("%.2d",mm),string.format("%.2d",ss)
            lab_cool_time:setString(hh..":" ..mm.. ":" ..ss)
            if coolTime<=0 then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleCoolID)
                lab_cool:setVisible(false)
                lab_cool_time:setVisible(false)
            end
        end, 1, false)
    end
end

local function  event_get_reward()
    if __instance.diceCount == 0 then
        local function getactivity1rewards( result )
            Activity1StatusProxy:getInstance().rewardTable = result
            Activity1StatusProxy:getInstance():set("score",__instance.score)
            -- Activity1StatusProxy:getInstance():set("rewardTimes",__instance.rewardtimes)
            local function confirmHandler()
                NetManager.sendCmd("loadactivity1status",loadactivity1status,__instance.activity1Type)
            end
            NormalDataProxy:getInstance().confirmHandler = confirmHandler
            Utils.runUIScene("ActivityEndPopup")
        end
        NetManager.sendCmd("getactivity1rewards",getactivity1rewards,__instance.activity1Type,__instance.token)
    end
end

function BattlePalaceUI:onComplete()
    __instance.token = Activity1StatusProxy:getInstance():get("token")
    __instance.score = Activity1StatusProxy:getInstance():get("score")
    labScore:setString(__instance.score)
    labScore:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1.5),cc.ScaleTo:create(0.2,1.0),nil))
    print("======jiesuan *****==" .. __instance.diceCount)
    if __instance.diceCount <= 0 then
        local function getactivity1rewards( result )
            Activity1StatusProxy:getInstance().rewardTable = result
            Activity1StatusProxy:getInstance():set("score",__instance.score)
            local function confirmHandler()
                NetManager.sendCmd("loadactivity1status",loadactivity1status,__instance.activity1Type)
            end
            NormalDataProxy:getInstance().confirmHandler = confirmHandler
            Utils.runUIScene("ActivityEndPopup")
        end
        NetManager.sendCmd("getactivity1rewards",getactivity1rewards,__instance.activity1Type,__instance.token)
    elseif  __instance.eventNum == 4 then
        local function new_token(result)
            __instance.token = result["token"]
        end
        NetManager.sendCmd("loadactivity1status",new_token,__instance.activity1Type)
    end
end

function BattlePalaceUI:onLoadGridAction()
    if __instance.eventNum == 0 then
        __instance.eventNum = 9  --领取物品奖励
    end
    local imgGrid
    if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
        imgGrid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT"..__instance.index]) --糖果区地图
    else
        imgGrid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT_"..__instance.index]) --土豪区地图
    end
    local function CallFucnCallback()
        imgGrid:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(__instance.onLoadGridevent)))
    end
    imgGrid:runAction(cc.Sequence:create(cc.DelayTime:create(1.3+0.7*__instance.sand),cc.CallFunc:create(CallFucnCallback)))
end

function BattlePalaceUI:onLoadGridevent() 
    Activity1StatusProxy:getInstance():set("token",__instance.token)
    print("=====触发事件=====" .. __instance.eventNum)
    if __instance.eventNum == 1 then  --普通
        labScore:setString(__instance.score)
        event_get_reward()
        if __instance.diceCount > 0 then
           TipManager.showTip("当前得分 " ..  __instance.score)
        end
    elseif __instance.eventNum == 2 then  --遇怪
        if __instance.listener1 then
            __instance:getEventDispatcher():removeEventListener(__instance.listener1)
            __instance.listener1 = nil
        end
        if __instance.listenerDtor then
            __instance:getEventDispatcher():removeEventListener(__instance.listenerDtor)
            __instance.listenerDtor = nil
        end
        print("==__instance.diceCount======" .. __instance.diceCount)
        Activity1StatusProxy:getInstance():set("diceCount",__instance.diceCount)
        NormalDataProxy:getInstance().onCompleteEnermy = __instance.onComplete
        
        local listenerDtor = cc.EventListenerCustom:create("call_ui_dtor",__instance.dtor)
        __instance.listenerDtor = listenerDtor
        local eventDispatcher = __instance:getEventDispatcher()
        eventDispatcher:addEventListenerWithFixedPriority(listenerDtor, 1)

        Utils.runUIScene("ActivityEncounterPopup")
    elseif __instance.eventNum == 3 then  --答题
        if __instance.listener2 then
            __instance:getEventDispatcher():removeEventListener(__instance.listener2)
            __instance.listener2 = nil
        end

        local function loadactivity1questions(result)
            Activity1StatusProxy:getInstance():set("token",__instance.token)
            Activity1StatusProxy:getInstance():set("qid",result["question"])
            Utils.runUIScene("ActivityQuestionPopup")
            local listener2 = cc.EventListenerCustom:create("game_custom_event2",__instance.onComplete)
            __instance.listener2 = listener2
            local eventDispatcher = __instance:getEventDispatcher()
            eventDispatcher:addEventListenerWithFixedPriority(listener2, 1)
        end
        NetManager.sendCmd("loadactivity1questions",loadactivity1questions,__instance.activity1Type,__instance.token)
    elseif __instance.eventNum == 4 then  --摇奖
        if __instance.listener3 then
            __instance:getEventDispatcher():removeEventListener(__instance.listener3)
            __instance.listener3 = nil
        end

        Activity1StatusProxy:getInstance():set("token",__instance.token)
        Activity1StatusProxy:getInstance():set("score",__instance.score)
        Utils.runUIScene("ActivityTurnTablePopup")
        local listener3 = cc.EventListenerCustom:create("game_custom_event3",__instance.onComplete)
        __instance.listener3 = listener3
        local eventDispatcher = __instance:getEventDispatcher()
        eventDispatcher:addEventListenerWithFixedPriority(listener3, 1)

    elseif __instance.eventNum == 5 then  --倒退3步
        __instance.BeginGrid = __instance.index  --当前位置
        __instance.onBackFoursteps()
        local function backFoursteps( ... )
            if __instance.index - 3 > 0 then
                __instance.index = __instance.index - 3 
            else
                __instance.index = __instance.index - 3 + 42
            end
            local grid
            if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
                grid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT".. __instance.index])
            else
                grid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT_".. __instance.index])
            end
            local pos  = cc.p(grid:getPosition())
            local Min = scrol:getMinOffset()
            imgSelect:setPosition(cc.p(pos.x,pos.y))

            if pos.y/2 > -Min.y/2+100 then
                scrol:setContentOffsetToTopInDuration(0.5)
            else
                scrol:setContentOffsetEaseIn(cc.p(0,-pos.y/2),0.5,1)
            end
        end
        imgSelect:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(backFoursteps)))
        
        TipManager.showTip("后退3步")
        local grid
        if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
            grid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT".. __instance.index-3])
        else
            grid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT_".. __instance.index-3])
        end
       
        local pos  = cc.p(grid:getPosition())
        imgSelect:setPosition(cc.p(pos.x,pos.y))
    elseif __instance.eventNum == 6 then --前进3步
        __instance.BeginGrid = __instance.index
        __instance.FinGrid = 3
        -- __instance.onGridSpineWalk()
        __instance:onGridFourWalk()
        local function moveFourSteps()
            if __instance.index + 3 <= 42 then
                __instance.index = __instance.index + 3 
            else
                __instance.index = __instance.index + 3 - 42 --前进3步 超过终点 
            end
            local grid
            if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
                grid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT".. __instance.index])
            else
                grid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT_".. __instance.index])
            end
            local pos  = cc.p(grid:getPosition())
            imgSelect:setPosition(cc.p(pos.x,pos.y))
            local Min = scrol:getMinOffset()
            if pos.y/2 > -Min.y/2+200 then
                scrol:setContentOffsetToTopInDuration(0.5)
            else
                scrol:setContentOffsetEaseIn(cc.p(0,-pos.y/2),0.5,1)
            end
        end
        imgSelect:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(moveFourSteps)))
       
        TipManager.showTip("再前进3步")
        local grid
        if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
            grid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT".. __instance.index+3])
        else
            grid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT_".. __instance.index+3])
        end
        local pos  = cc.p(grid:getPosition())
        imgSelect:setPosition(cc.p(pos.x,pos.y))
    elseif __instance.eventNum == 7 then  --筛子数+1
        __instance.diceCount = __instance.diceCount + 1
        labDiceCount:setString(__instance.diceCount)
        event_get_reward()
        if __instance.diceCount > 0 then
            TipManager.showTip("筛子数+1 当前得分 " ..  __instance.score)
        end
    elseif __instance.eventNum == 9 then  --物品奖励
        event_get_reward()
        if __instance.diceCount > 0 then
            TipManager.showTip("获得金币和物品 当前得分 " ..  __instance.score)
        end
    else
        --最终奖励结果x2
        if __instance.diceCount > 0 then
            TipManager.showTip("最终奖励翻倍 当前得分" ..  __instance.score)
        end
        event_get_reward()
    end
end

function BattlePalaceUI:onGridSpineBreath(index,Pos)
    local playerSex = Player:getInstance():get("sex")
    -- print("玩家性别 :"..playerSex)

    if playerSex == 1 and Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA  then
        __instance.layoutPeople = node:getChildByTag(Tag_ui_battle_palace.LAYOUT_PEOPLE1)
        local json = TextureManager.RES_PATH.SPINE_ACTIVITY1_BOY .. ".json"
        local atlas = TextureManager.RES_PATH.SPINE_ACTIVITY1_BOY .. ".atlas"
        __instance.skeletonNode = sp.SkeletonAnimation:create(json, atlas)
    elseif playerSex ~= 1 and Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA  then
        __instance.layoutPeople = node:getChildByTag(Tag_ui_battle_palace.LAYOUT_PEOPLE1)
        local json = TextureManager.RES_PATH.SPINE_ACTIVITY1_GIRL .. ".json"
        local atlas = TextureManager.RES_PATH.SPINE_ACTIVITY1_GIRL .. ".atlas"
        __instance.skeletonNode = sp.SkeletonAnimation:create(json, atlas)
    elseif  playerSex == 1 and Activity1StatusProxy:getInstance():get("activity1Type") ~= Constants.ACTIVITY1_TYPE.CANDY_AREA  then
        __instance.layoutPeople = node:getChildByTag(Tag_ui_battle_palace.LAYOUT_PEOPLE2)
        local json = TextureManager.RES_PATH.SPINE_ACTIVITY1_BOY .. ".json"
        local atlas = TextureManager.RES_PATH.SPINE_ACTIVITY1_BOY .. ".atlas"
        __instance.skeletonNode = sp.SkeletonAnimation:create(json, atlas)
    else
        __instance.layoutPeople = node:getChildByTag(Tag_ui_battle_palace.LAYOUT_PEOPLE2)
        local json = TextureManager.RES_PATH.SPINE_ACTIVITY1_GIRL .. ".json"
        local atlas = TextureManager.RES_PATH.SPINE_ACTIVITY1_GIRL .. ".atlas"
        __instance.skeletonNode = sp.SkeletonAnimation:create(json, atlas)
    end
    __instance.layoutPeople:removeAllChildren()
    __instance.layoutPeople:setPosition(cc.p(Pos.x,Pos.y))
    if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA  then
        if index < 14 then
            __instance.skeletonNode:setAnimation(0, "back_breath", true)
            local size = __instance.layoutPeople:getContentSize()
            __instance.skeletonNode:setPosition(Arp(cc.p(size.width/2, size.height/2-14)))
            __instance.layoutPeople:addChild(__instance.skeletonNode)
        elseif (index >= 14 and index <18) or (index >= 25 and index <27) or (index >= 33 and index < 35) then
            __instance.skeletonNode:setAnimation(0, "side_breath", true)
            __instance.skeletonNode:setScaleX(-1)  
            local size = __instance.layoutPeople:getContentSize()
            __instance.skeletonNode:setPosition(Arp(cc.p(size.width/2, size.height/2-14)))
            __instance.layoutPeople:addChild(__instance.skeletonNode)
        elseif index >= 18 and index <21 or (index >= 23 and index <25) or (index >= 27 and index <29) or (index >= 31 and index <33) or (index >=35 and index <38) or index == 40 then
            __instance.skeletonNode:setAnimation(0, "face_breath", true)
            local size = __instance.layoutPeople:getContentSize()
            __instance.skeletonNode:setPosition(Arp(cc.p(size.width/2, size.height/2-14)))
            __instance.layoutPeople:addChild(__instance.skeletonNode)
        elseif (index >= 21 and index <23) or (index >=29 and index < 31) or (index >=38 and index < 41) or index == 41 or index == 42 then
            __instance.skeletonNode:setAnimation(0, "side_breath", true)
            __instance.skeletonNode:setScaleX(1)  
            local size = __instance.layoutPeople:getContentSize()
            __instance.skeletonNode:setPosition(Arp(cc.p(size.width/2, size.height/2-14)))
            __instance.layoutPeople:addChild(__instance.skeletonNode)
        end
    else
        if  (index >=1 and index <4 ) or (index>=6 and index<10) or (index>=12 and index<18) then  
            __instance.skeletonNode:setAnimation(0, "back_breath", true)  --上
            local size = __instance.layoutPeople:getContentSize()
            __instance.skeletonNode:setPosition(Arp(cc.p(size.width/2, size.height/2-14)))
            __instance.layoutPeople:addChild(__instance.skeletonNode)
        elseif (index >= 4 and index <6) or (index >= 18 and index <22) or (index >= 28 and index < 30) then
            __instance.skeletonNode:setAnimation(0, "side_breath", true)   --向右
            __instance.skeletonNode:setScaleX(-1)  
            local size = __instance.layoutPeople:getContentSize()
            __instance.skeletonNode:setPosition(Arp(cc.p(size.width/2, size.height/2-14)))
            __instance.layoutPeople:addChild(__instance.skeletonNode)
        elseif (index >= 22 and index <24) or (index >= 26 and index <28) or (index >= 30 and index <38) or index == 40  then
            __instance.skeletonNode:setAnimation(0, "face_breath", true)  --下
            local size = __instance.layoutPeople:getContentSize()
            __instance.skeletonNode:setPosition(Arp(cc.p(size.width/2, size.height/2-14)))
            __instance.layoutPeople:addChild(__instance.skeletonNode)
        elseif (index >= 10 and index <12) or (index >=24 and index < 26) or (index >=38 and index < 40) or index == 41 or index == 42 then
            __instance.skeletonNode:setAnimation(0, "side_breath", true) --左
            __instance.skeletonNode:setScaleX(1)  
            local size = __instance.layoutPeople:getContentSize()
            __instance.skeletonNode:setPosition(Arp(cc.p(size.width/2, size.height/2-14)))
            __instance.layoutPeople:addChild(__instance.skeletonNode)
        end
    end
end

function BattlePalaceUI:onBackFoursteps() --回退三步
    if __instance.BeginGrid == 0 then
        local imgGrid1 
        if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
            imgGrid1 = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT".. 1])
        else
            imgGrid1 = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT_".. 1])
        end
        local Pos1 = cc.p(imgGrid1:getPosition())
        __instance.layoutPeople:setPosition(cc.p(Pos1.x,Pos1.y-14))
    else
        local imgGrid1 
        if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
            imgGrid1 = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT".. __instance.BeginGrid])
        else
            imgGrid1 = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT_".. __instance.BeginGrid])
        end
        local Pos1 = cc.p(imgGrid1:getPosition())
        __instance.layoutPeople:setPosition(cc.p(Pos1.x,Pos1.y-14))
    end

    local array = cc.DelayTime:create(0)
    local function moveToNextGrid(currentGrid,NextGrid)
        local startGrid
        local endGrid 
        if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
            startGrid= node:getChildByTag(Tag_ui_battle_palace["IMG_RECT".. currentGrid])
            endGrid= node:getChildByTag(Tag_ui_battle_palace["IMG_RECT".. NextGrid])
        else
            startGrid= node:getChildByTag(Tag_ui_battle_palace["IMG_RECT_".. currentGrid])
            endGrid= node:getChildByTag(Tag_ui_battle_palace["IMG_RECT_".. NextGrid])
        end
        local Pos1 = cc.p(startGrid:getPosition())
        local Pos2 = cc.p(endGrid:getPosition())
        local walk = function ()
        end
        local extraEvent = function ()
        end

        if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
          if (currentGrid > 14 and currentGrid <= 18) or (currentGrid > 25 and currentGrid <= 27) or (currentGrid > 33 and currentGrid <= 35) or currentGrid==42  then
                walk = function ( ) 
                    __instance.skeletonNode:setScaleX(1)  
                    __instance.skeletonNode:addAnimation(0, "side_walk", true)
                end
            elseif (currentGrid > 21 and currentGrid <= 23) or (currentGrid > 29 and currentGrid <= 31) or (currentGrid > 38 and currentGrid <= 40) then
                walk = function()
                    __instance.skeletonNode:setScaleX(-1)  
                    __instance.skeletonNode:addAnimation(0, "side_walk", true)
                end
            elseif currentGrid <= 14 then
                walk = function()   __instance.skeletonNode:addAnimation(0, "face_walk", true)  end
            else
                walk = function ()  __instance.skeletonNode:addAnimation(0, "back_walk", true)  end
            end
            array = cc.Sequence:create(array,cc.CallFunc:create(walk), cc.MoveTo:create(0.4, cc.p(Pos2.x,Pos2.y)))
        else
            if (currentGrid > 28 and currentGrid <= 30) or (currentGrid > 18 and currentGrid <= 22) or (currentGrid > 4 and currentGrid <= 6) then
                walk = function ( )  --向左
                    __instance.skeletonNode:setScaleX(1)  
                    __instance.skeletonNode:addAnimation(0, "side_walk", true)
                end
            elseif  currentGrid == 42 or (currentGrid > 38 and currentGrid <= 40) or (currentGrid > 24 and currentGrid <= 26) or (currentGrid > 10 and currentGrid <= 12) or currentGrid==1 then
                walk = function() --向右
                    __instance.skeletonNode:setScaleX(-1)  
                    __instance.skeletonNode:addAnimation(0, "side_walk", true)
                end
            elseif (currentGrid > 12 and currentGrid <= 18) or (currentGrid > 6 and currentGrid <= 10) or (currentGrid > 1 and currentGrid <= 4) then  --向下 
                walk = function() --向下
                   __instance.skeletonNode:addAnimation(0, "face_walk", true) 
                end
            else
                walk = function ()   --向上
                    __instance.skeletonNode:addAnimation(0, "back_walk", true) 
                end
            end
            array = cc.Sequence:create(array,cc.CallFunc:create(walk), cc.MoveTo:create(0.4, cc.p(Pos2.x,Pos2.y)))
        end
    end
    local startGrid = __instance.BeginGrid
    local endGrid 
    if __instance.BeginGrid - 3 > 0 then
        endGrid = __instance.BeginGrid - 3 
        for i = startGrid, endGrid+1,-1 do
            moveToNextGrid(i,i-1)
        end
    else
        endGrid =__instance.BeginGrid - 3 + 42
        for i = startGrid,2,-1 do
            moveToNextGrid(i,i-1)
        end
        moveToNextGrid(1,42)
        for i = 42, endGrid+1,-1 do
            moveToNextGrid(i,i-1)
        end
    end

    local function breath()
        if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
            if (endGrid >= 14 and endGrid < 18) or (endGrid >= 25 and endGrid < 27) or (endGrid >= 33 and endGrid < 35) then
                __instance.skeletonNode:setScaleX(-1)  
                __instance.skeletonNode:addAnimation(0, "side_breath", true)
            elseif (endGrid >= 21 and endGrid < 23) or (endGrid >= 29 and endGrid < 31) or (endGrid >= 38 and endGrid < 40) then
                __instance.skeletonNode:setScaleX(1)  
                __instance.skeletonNode:addAnimation(0, "side_breath", true)
            elseif endGrid < 14 then
                __instance.skeletonNode:addAnimation(0, "back_breath", true)
            else
                __instance.skeletonNode:addAnimation(0, "face_breath", true)
            end
        else
            if  (endGrid >=1 and endGrid <4 ) or (endGrid>=6 and endGrid<10) or (endGrid>=12 and endGrid<18) then  
                __instance.skeletonNode:addAnimation(0, "back_breath", true)  --向上
            elseif (endGrid >= 4 and endGrid <6) or (endGrid >= 18 and endGrid <22) or (endGrid >= 28 and endGrid < 30) then
                __instance.skeletonNode:setScaleX(-1)    --向右
                __instance.skeletonNode:addAnimation(0, "side_breath", true)
            elseif (endGrid >= 22 and endGrid <24) or (endGrid >= 26 and endGrid <28) or (endGrid >= 30 and endGrid <38) or endGrid == 40  then
                __instance.skeletonNode:addAnimation(0, "face_breath", true)  --向下
            elseif (endGrid >= 10 and endGrid <12) or (endGrid >=24 and endGrid < 26) or (endGrid >=38 and endGrid < 40) or endGrid == 41 or endGrid == 42 then
                __instance.skeletonNode:setScaleX(1)   --向左
                __instance.skeletonNode:addAnimation(0, "side_breath", true)
            end
        end
    end

    local function event_change_score()  --改变分数
        labScore:setString(__instance.score)
        labScore:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1.5),cc.ScaleTo:create(0.2,1.0),nil))
        if  event_id2 ~=0 then
            __instance.eventNum = event_id2
            __instance.score = __instance.score + addscore
            labScore:setString(__instance.score)
            __instance:onLoadGridevent()
        else
            event_get_reward()
            if __instance.diceCount > 0 then
                TipManager.showTip("当前得分 " ..  __instance.score)
            end
        end
    end
    __instance.layoutPeople:runAction(cc.Sequence:create(array,cc.CallFunc:create(event_change_score),cc.CallFunc:create(breath)))
end

function BattlePalaceUI:onGridFourWalk() --前进
    if __instance.BeginGrid == 0 then
        local imgGrid1 
        if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
            imgGrid1 = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT".. 1])
        else
            imgGrid1 = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT_".. 1])
        end
        local Pos1 = cc.p(imgGrid1:getPosition())
        __instance.layoutPeople:setPosition(cc.p(Pos1.x,Pos1.y-14))
    else
        local imgGrid1 
        if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
            imgGrid1 = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT".. __instance.BeginGrid])
        else
            imgGrid1 = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT_".. __instance.BeginGrid])
        end
        local Pos1 = cc.p(imgGrid1:getPosition())
        __instance.layoutPeople:setPosition(cc.p(Pos1.x,Pos1.y-14))
    end
  
    local array = cc.DelayTime:create(0)
    local function moveToNextGrid(currentGrid,NextGrid) --到下一个格子
        local startGrid --起始格子
        local endGrid  --结束 格子
        if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
            startGrid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT".. currentGrid])
            endGrid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT".. NextGrid])
        else
            startGrid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT_".. currentGrid])
            endGrid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT_".. NextGrid])
        end
        local Pos1 = cc.p(startGrid:getPosition())
        local Pos2 = cc.p(endGrid:getPosition())
        local walk = function ()
        end
        local extraEvent = function ()
        end
        -- print("====cu=" .. currentGrid)
        if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
            if (currentGrid >= 14 and currentGrid < 18) or (currentGrid >= 25 and currentGrid < 27) or (currentGrid >= 33 and currentGrid < 35)  then
                walk = function ( )
                    __instance.skeletonNode:setScaleX(-1)  
                    __instance.skeletonNode:addAnimation(0, "side_walk", true)
                end
            elseif (currentGrid >= 21 and currentGrid < 23) or (currentGrid >= 29 and currentGrid < 31) or (currentGrid >= 38 and currentGrid < 40) or currentGrid >= 41 then
                walk = function()
                    __instance.skeletonNode:setScaleX(1)  
                    __instance.skeletonNode:addAnimation(0, "side_walk", true)
                end
            elseif currentGrid < 14 or currentGrid == 40 then
                walk = function(  )
                    __instance.skeletonNode:addAnimation(0, "back_walk", true)
                end
            else
                walk = function (  )
                    __instance.skeletonNode:addAnimation(0, "face_walk", true)
                end
            end
            array = cc.Sequence:create(array,cc.CallFunc:create(walk), cc.MoveTo:create(0.4, cc.p(Pos2.x,Pos2.y)))
        else
            if  (currentGrid >=1 and currentGrid <4 ) or (currentGrid>=6 and currentGrid<10) or (currentGrid>=12 and currentGrid<18) then  

                walk = function(  ) --向上
                    __instance.skeletonNode:addAnimation(0, "back_walk", true)
                end
            elseif (currentGrid >= 4 and currentGrid <6) or (currentGrid >= 18 and currentGrid <22) or (currentGrid >= 28 and currentGrid < 30) then
           
                walk = function ( ) --向右
                    __instance.skeletonNode:setScaleX(-1)
                    __instance.skeletonNode:addAnimation(0, "side_walk", true)
                end
            elseif (currentGrid >= 22 and currentGrid <24) or (currentGrid >= 26 and currentGrid <28) or (currentGrid >= 30 and currentGrid <38) or currentGrid == 40  then
               
                walk = function (  ) --向下
                    __instance.skeletonNode:addAnimation(0, "face_walk", true)
                end
            elseif (currentGrid >= 10 and currentGrid <12) or (currentGrid >=24 and currentGrid < 26) or (currentGrid >=38 and currentGrid < 40) or currentGrid == 41 or currentGrid == 42 then
       
                walk = function()   --向左
                    __instance.skeletonNode:setScaleX(1)  
                    __instance.skeletonNode:addAnimation(0, "side_walk", true)
                end
            end
            array = cc.Sequence:create(array,cc.CallFunc:create(walk), cc.MoveTo:create(0.4, cc.p(Pos2.x,Pos2.y)))
        end

         --scrol的偏移量
        local Min = scrol:getMinOffset()
        local cs = scrol:getContainerSize()
        if (Pos2.y-cs.height/4) > 0 and (Pos2.y-cs.height/4) < -Min.y/2 then
            scrol:setContentOffsetEaseIn(cc.p(0,Min.y/2),1.5,1)
        elseif (Pos2.y-cs.height/4) < -Min.y and (Pos2.y-cs.height/4) > -Min.y/2+200 then
            scrol:setContentOffsetToTopInDuration(1.5)
        elseif (Pos2.y-cs.height/4) > -Min.y+200 then
            scrol:setContentOffsetToTopInDuration(1.5)
        elseif (Pos2.y-cs.height/4) < 0 then
            scrol:setContentOffsetToBottom()
        else
            scrol:setContentOffsetEaseIn(cc.p(0,-(Pos2.y-cs.height/4)),1.5,1)
        end
    end

    local startGrid = __instance.BeginGrid  --当前起始格子
    local endGrid 
    if __instance.BeginGrid + __instance.FinGrid <= 42 then
        endGrid =__instance.BeginGrid + __instance.FinGrid 
        for i = startGrid, endGrid-1 do
            moveToNextGrid(i,i+1)
        end
    else 
        endGrid = __instance.BeginGrid + __instance.FinGrid - 42 
        for i = startGrid,41 do
            moveToNextGrid(i,i+1)
        end
        moveToNextGrid(42,1)
        for i = 1,endGrid-1  do
            moveToNextGrid(i,i+1)
        end
    end
  
    local function breath()  --走完之后转换为呼吸状态
        if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
            if (endGrid >= 14 and endGrid < 18) or (endGrid >= 25 and endGrid < 27) or (endGrid >= 33 and endGrid < 35) then
                __instance.skeletonNode:setScaleX(-1)  
                __instance.skeletonNode:addAnimation(0, "side_breath", true)
            elseif (endGrid >= 21 and endGrid < 23) or (endGrid >= 29 and endGrid < 31) or (endGrid >= 38 and endGrid < 40) then
                __instance.skeletonNode:setScaleX(1)  
                __instance.skeletonNode:addAnimation(0, "side_breath", true)
            elseif endGrid < 14 then
                __instance.skeletonNode:addAnimation(0, "back_breath", true)
            else
                __instance.skeletonNode:addAnimation(0, "face_breath", true)
            end
        else   
            if  (endGrid >=1 and endGrid <4 ) or (endGrid>=6 and endGrid<10) or (endGrid>=12 and endGrid<18) then  
                __instance.skeletonNode:addAnimation(0, "back_breath", true)
            elseif (endGrid >= 4 and endGrid <6) or (endGrid >= 18 and endGrid <22) or (endGrid >= 28 and endGrid < 30) then
                __instance.skeletonNode:setScaleX(-1)    --向右
                __instance.skeletonNode:addAnimation(0, "side_breath", true)
            elseif (endGrid >= 22 and endGrid <24) or (endGrid >= 26 and endGrid <28) or (endGrid >= 30 and endGrid <38) or endGrid == 40  then
                __instance.skeletonNode:addAnimation(0, "face_breath", true)
            elseif (endGrid >= 10 and endGrid <12) or (endGrid >=24 and endGrid < 26) or (endGrid >=38 and endGrid < 40) or endGrid == 41 or endGrid == 42 then
                __instance.skeletonNode:setScaleX(1)   --向左
                __instance.skeletonNode:addAnimation(0, "side_breath", true)
            end
        end

        local grid 
        if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
            grid= node:getChildByTag(Tag_ui_battle_palace["IMG_RECT".. __instance.index])
        else
             grid= node:getChildByTag(Tag_ui_battle_palace["IMG_RECT_".. __instance.index])
        end
        local pos  = cc.p(grid:getPosition())
        imgSelect:setPosition(cc.p(pos.x,pos.y))
    end

    local function event_change_score()  --改变分数
        labScore:setString(__instance.score)
        labScore:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1.5),cc.ScaleTo:create(0.2,1.0),nil))
        if  event_id2 ~=0 then
            -- print("====前进3步=后出发事件2==")
            __instance.eventNum = event_id2
            __instance.score = __instance.score + addscore
            labScore:setString(__instance.score)
            __instance:onLoadGridevent()
        else
            event_get_reward()
            if __instance.diceCount > 0 then
                TipManager.showTip("当前得分 " ..  __instance.score)
            end
        end
    end
    __instance.layoutPeople:runAction(cc.Sequence:create(array,cc.CallFunc:create(event_change_score),cc.CallFunc:create(breath)))
end

function BattlePalaceUI:onGridSpineWalk() --前进
    if __instance.BeginGrid == 0 then
        local imgGrid1 
        if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
            imgGrid1 = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT".. 1])
        else
            imgGrid1 = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT_".. 1])
        end
        local Pos1 = cc.p(imgGrid1:getPosition())
        __instance.layoutPeople:setPosition(cc.p(Pos1.x,Pos1.y-14))
    else
        local imgGrid1 
        if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
            imgGrid1 = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT".. __instance.BeginGrid])
        else
            imgGrid1 = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT_".. __instance.BeginGrid])
        end
        local Pos1 = cc.p(imgGrid1:getPosition())
        __instance.layoutPeople:setPosition(cc.p(Pos1.x,Pos1.y-14))
    end
  
    local array = cc.DelayTime:create(0)
    local function moveToNextGrid(currentGrid,NextGrid) --到下一个格子
        local startGrid --起始格子
        local endGrid  --结束 格子
        if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
            startGrid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT".. currentGrid])
            endGrid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT".. NextGrid])
        else
            startGrid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT_".. currentGrid])
            endGrid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT_".. NextGrid])
        end
        local Pos1 = cc.p(startGrid:getPosition())
        local Pos2 = cc.p(endGrid:getPosition())
        local walk = function ()
        end
        local extraEvent = function ()
        end
        -- print("====cu=" .. currentGrid)
        if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
            if (currentGrid >= 14 and currentGrid < 18) or (currentGrid >= 25 and currentGrid < 27) or (currentGrid >= 33 and currentGrid < 35)  then
                walk = function ( )
                    __instance.skeletonNode:setScaleX(-1)  
                    __instance.skeletonNode:addAnimation(0, "side_walk", true)
                end
            elseif (currentGrid >= 21 and currentGrid < 23) or (currentGrid >= 29 and currentGrid < 31) or (currentGrid >= 38 and currentGrid < 40) or currentGrid >= 41 then
                walk = function()
                    __instance.skeletonNode:setScaleX(1)  
                    __instance.skeletonNode:addAnimation(0, "side_walk", true)
                end
            elseif currentGrid < 14 or currentGrid == 40 then
                walk = function(  )
                    __instance.skeletonNode:addAnimation(0, "back_walk", true)
                end
            else
                walk = function (  )
                    __instance.skeletonNode:addAnimation(0, "face_walk", true)
                end
            end
            array = cc.Sequence:create(array,cc.CallFunc:create(walk), cc.MoveTo:create(0.4, cc.p(Pos2.x,Pos2.y)))
        else
            if  (currentGrid >=1 and currentGrid <4 ) or (currentGrid>=6 and currentGrid<10) or (currentGrid>=12 and currentGrid<18) then  

                walk = function(  ) --向上
                    __instance.skeletonNode:addAnimation(0, "back_walk", true)
                end
            elseif (currentGrid >= 4 and currentGrid <6) or (currentGrid >= 18 and currentGrid <22) or (currentGrid >= 28 and currentGrid < 30) then
           
                walk = function ( ) --向右
                    __instance.skeletonNode:setScaleX(-1)
                    __instance.skeletonNode:addAnimation(0, "side_walk", true)
                end
            elseif (currentGrid >= 22 and currentGrid <24) or (currentGrid >= 26 and currentGrid <28) or (currentGrid >= 30 and currentGrid <38) or currentGrid == 40  then
               
                walk = function (  ) --向下
                    __instance.skeletonNode:addAnimation(0, "face_walk", true)
                end
            elseif (currentGrid >= 10 and currentGrid <12) or (currentGrid >=24 and currentGrid < 26) or (currentGrid >=38 and currentGrid < 40) or currentGrid == 41 or currentGrid == 42 then
       
                walk = function()   --向左
                    __instance.skeletonNode:setScaleX(1)  
                    __instance.skeletonNode:addAnimation(0, "side_walk", true)
                end
            end
            array = cc.Sequence:create(array,cc.CallFunc:create(walk), cc.MoveTo:create(0.4, cc.p(Pos2.x,Pos2.y)))
        end

         --scrol的偏移量
        local Min = scrol:getMinOffset()
        local cs = scrol:getContainerSize()
        if (Pos2.y-cs.height/4) > 0 and (Pos2.y-cs.height/4) < -Min.y/2 then
            scrol:setContentOffsetEaseIn(cc.p(0,Min.y/2),1.5,1)
        elseif (Pos2.y-cs.height/4) < -Min.y and (Pos2.y-cs.height/4) > -Min.y/2+200 then
            scrol:setContentOffsetToTopInDuration(1.5)
        elseif (Pos2.y-cs.height/4) > -Min.y+200 then
            scrol:setContentOffsetToTopInDuration(1.5)
        elseif (Pos2.y-cs.height/4) < 0 then
            scrol:setContentOffsetToBottom()
        else
            scrol:setContentOffsetEaseIn(cc.p(0,-(Pos2.y-cs.height/4)),1.5,1)
        end
    end

    local startGrid = __instance.BeginGrid  --当前起始格子
    local endGrid 
    if __instance.BeginGrid + __instance.FinGrid <= 42 then
        endGrid =__instance.BeginGrid + __instance.FinGrid 
        for i = startGrid, endGrid-1 do
            moveToNextGrid(i,i+1)
        end
    else 
        endGrid = __instance.BeginGrid + __instance.FinGrid - 42 
        for i = startGrid,41 do
            moveToNextGrid(i,i+1)
        end
        moveToNextGrid(42,1)
        for i = 1,endGrid-1  do
            moveToNextGrid(i,i+1)
        end
    end
  
    local function breath()  --走完之后转换为呼吸状态
        if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
            if (endGrid >= 14 and endGrid < 18) or (endGrid >= 25 and endGrid < 27) or (endGrid >= 33 and endGrid < 35) then
                __instance.skeletonNode:setScaleX(-1)  
                __instance.skeletonNode:addAnimation(0, "side_breath", true)
            elseif (endGrid >= 21 and endGrid < 23) or (endGrid >= 29 and endGrid < 31) or (endGrid >= 38 and endGrid < 40) then
                __instance.skeletonNode:setScaleX(1)  
                __instance.skeletonNode:addAnimation(0, "side_breath", true)
            elseif endGrid < 14 then
                __instance.skeletonNode:addAnimation(0, "back_breath", true)
            else
                __instance.skeletonNode:addAnimation(0, "face_breath", true)
            end
        else   
            if  (endGrid >=1 and endGrid <4 ) or (endGrid>=6 and endGrid<10) or (endGrid>=12 and endGrid<18) then  
                __instance.skeletonNode:addAnimation(0, "back_breath", true)
            elseif (endGrid >= 4 and endGrid <6) or (endGrid >= 18 and endGrid <22) or (endGrid >= 28 and endGrid < 30) then
                __instance.skeletonNode:setScaleX(-1)    --向右
                __instance.skeletonNode:addAnimation(0, "side_breath", true)
            elseif (endGrid >= 22 and endGrid <24) or (endGrid >= 26 and endGrid <28) or (endGrid >= 30 and endGrid <38) or endGrid == 40  then
                __instance.skeletonNode:addAnimation(0, "face_breath", true)
            elseif (endGrid >= 10 and endGrid <12) or (endGrid >=24 and endGrid < 26) or (endGrid >=38 and endGrid < 40) or endGrid == 41 or endGrid == 42 then
                __instance.skeletonNode:setScaleX(1)   --向左
                __instance.skeletonNode:addAnimation(0, "side_breath", true)
            end
        end

        local grid 
        if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
            grid= node:getChildByTag(Tag_ui_battle_palace["IMG_RECT".. __instance.index])
        else
             grid= node:getChildByTag(Tag_ui_battle_palace["IMG_RECT_".. __instance.index])
        end
        local pos  = cc.p(grid:getPosition())
        imgSelect:setPosition(cc.p(pos.x,pos.y))
    end

    local function event_change_score()  --改变分数
        labScore:setString(__instance.score)
        labScore:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1.5),cc.ScaleTo:create(0.2,1.0),nil))
        -- event_get_reward()
    end
    __instance.layoutPeople:runAction(cc.Sequence:create(array,cc.CallFunc:create(event_change_score),cc.CallFunc:create(breath)))
end

function BattlePalaceUI:onLoadgrideventHandler( p_sender )   --转筛子 
    if __instance.diceCount == 0 then
        TipManager.showTip("今日次数已用完")
        return 
    end
    if coolTime >0 then
        TipManager.showTip("冷却时间未结束")
        return
    end

    local function throwdice( result ) --转筛子 后端返回 
        local layoutDice = __instance:getControl(Tag_ui_battle_palace.PANEL_BATTLE_PALACE,Tag_ui_battle_palace.LAYOUT_DICESPINE)
        __instance.diceCount  = __instance.diceCount -1  --筛子
        labRemainTimes:setString(__instance.todayRemainTimes) --剩余次数 
        labRemainTimes:setVisible(__instance.todayRemainTimes>0)
        labRemainTip1:setVisible(__instance.todayRemainTimes>0)
        labRemainTip2:setVisible(__instance.todayRemainTimes>0)
        labDiceCount:setString(__instance.diceCount)
        local rewardtimes = result["rewardtimes"]
        __instance.rewardTimes = rewardtimes
        Activity1StatusProxy:getInstance():set("rewardTimes",result["rewardtimes"])
        labRewardTimes:setString(rewardtimes) --奖励数量 
        -- __instance.index = result["grid"]
        __instance.sand = result["sand"] --筛子数
        __instance.token = result["token"]

        if result["event_id2"] ~= 0 then  --没有连续出触发
            __instance.eventNum = result["event_id2"]
            event_id2 = result["event_id"]
            event_score2 = result["score2"]
        else
            __instance.eventNum = result["event_id"]  --事件id
            event_id2 = 0
            event_score2 = 0
        end
        Spine.addSpine(layoutDice,"activity1","dice","part"..__instance.sand,false) --转筛子特效
        local function boy()
            __instance.BeginGrid = __instance.index - __instance.sand  --起始位置
            if __instance.BeginGrid <= 0 then
               __instance.BeginGrid = __instance.BeginGrid + 42
            end
            __instance.FinGrid = __instance.sand   --筛子数
            __instance.onGridSpineWalk() --前进 
        end
        layoutDice:runAction(cc.Sequence:create(cc.DelayTime:create(2.75),cc.CallFunc:create(boy)))

        if __instance.index + __instance.sand <= 42 then
            __instance.index = __instance.index + __instance.sand
        else
            __instance.index = __instance.index + __instance.sand - 42  -- 越过终点  
        end

        addscore = result["score"] --增加的分数 可能为0
        __instance.score = __instance.score + addscore

        local labTrophy = layoutBottom:getChildByTag(Tag_ui_battle_palace.LAB_TROPHY)
        local labRewardMulit = layoutBottom:getChildByTag(Tag_ui_battle_palace.LAB_REWARDMULT)
        
        local reward = ConfigManager.getActivity1RewardConfig(Player:getInstance():get("level"))

        local level_1 = ConfigManager.getActivity1ScoreConfig(1)
        local level_2 = ConfigManager.getActivity1ScoreConfig(2)
        local level_3 = ConfigManager.getActivity1ScoreConfig(3)
        if __instance.score <= level_1.score then
            labTrophy:setString(level_1.reward_level)
            labTrophy:setColor(cc.c3b(135,198,117))
        elseif __instance.score <= level_2.score and  __instance.score > level_1.score then
            labTrophy:setString(level_2.reward_level)
            labTrophy:setColor(cc.c3b(255,255,255))
        else
            labTrophy:setString(level_3.reward_level)
            labTrophy:setColor(cc.c3b(253,233,110))
        end
        
        local player = Player:getInstance()
        player:set("gold",player:get("gold")+result["gold"])
        player:set("diamond",player:get("diamond")+result["diamond"])
        ItemManager.updatePets(result["pets"])
        ItemManager.updateItems(result["items"])
        ernie_id = result["ernie_id"] --四号事件
        Activity1StatusProxy:getInstance():set("ernie_id",ernie_id)
        if __instance.index == 0 then
            if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
                local imgGrid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT".. 1])
                Pos = cc.p(imgGrid:getPosition())
            else
                local imgGrid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT_".. 1])
                Pos = cc.p(imgGrid:getPosition())
            end
        else
            if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then
                local imgGrid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT".. __instance.index ])
                Pos = cc.p(imgGrid:getPosition())
            else
                local imgGrid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT_".. __instance.index ])
                Pos = cc.p(imgGrid:getPosition())
            end
        end
        __instance.onLoadGridAction()
        __instance.btnEnable = false --此时不可以转筛子
        __instance.onbtnDiceEnabled()
    end 
    MusicManager.dice()
    NetManager.sendCmd("throwdice",throwdice,__instance.activity1Type,__instance.token)
end

function BattlePalaceUI:onbtnDiceEnabled()
    local function callBack()
        __instance.btnEnable = true
    end
    __instance:runAction(cc.Sequence:create(cc.DelayTime:create(3+0.7*__instance.sand),cc.CallFunc:create(callBack)))
end

function BattlePalaceUI:onbtnDiceCilckStatus( ) --筛子转完 才可以再次转
    if __instance.btnEnable == true then
        btnDice:setEnabled(true)
    else
        btnDice:setEnabled(false)
        btnDice:setColor(cc.c3b(86,86,86))
    end
end

local function event_return( p_sender )
    if NormalDataProxy:getInstance():get("isDaliyPursue") then
        Utils.popScene()
        Utils.runUIScene("DailyPopup")
        return
    end
    Utils.replaceScene("ExploreUI",__instance)
end

function BattlePalaceUI:onLoadScene()
    TuiManager:getInstance():parseScene(self,"panel_battle_palace",PATH_UI_BATTLE_PALACE)
    layoutBottom = self:getControl(Tag_ui_battle_palace.PANEL_BATTLE_PALACE,Tag_ui_battle_palace.LAYOUT_BOTTOM)
    Utils.floatToBottom(layoutBottom)
    local layoutTop = self:getControl(Tag_ui_battle_palace.PANEL_BATTLE_PALACE,Tag_ui_battle_palace.LAYOUT_TITLE)
    Utils.floatToTop(layoutTop)

    lab_cool = layoutTop:getChildByTag(Tag_ui_battle_palace.LAB_COOL) --冷却时间
    lab_cool_time = layoutTop:getChildByTag(Tag_ui_battle_palace.LAB_COOL_TIME)

    local scrol1 = self:getControl(Tag_ui_battle_palace.PANEL_BATTLE_PALACE,Tag_ui_battle_palace.SCROL_BATTLEPALACE1)
    local scrol2 = self:getControl(Tag_ui_battle_palace.PANEL_BATTLE_PALACE,Tag_ui_battle_palace.SCROL_BATTLEPALACE2)
    if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then  --糖果区
        scrol = scrol1
        scrol1:setVisible(true)
        scrol2:setVisible(false)
        local imgTitle = layoutTop:getChildByTag(Tag_ui_battle_palace.IMG_BATTLEPLACE_TITLE2)
        imgTitle:setVisible(false)
    else
        scrol = scrol2
        scrol1:setVisible(false)
        scrol2:setVisible(true)
        local imgTitle = layoutTop:getChildByTag(Tag_ui_battle_palace.IMG_BATTLEPLACE_TITLE1)
        imgTitle:setVisible(false)
    end

    local tempResult = {}
    self.btnEnable = true 

    local btnReturn = layoutBottom:getChildByTag(Tag_ui_battle_palace.BTN_RETURN) --返回按钮
    btnReturn:setOnClickScriptHandler(event_return)
    labScore = layoutBottom:getChildByTag(Tag_ui_battle_palace.LAB_SCORE)--分数
    labScore:retain()
    self.activity1Type = Activity1StatusProxy:getInstance():get("activity1Type") --获得当前类型  糖果区  土豪

    labRemainTimes = layoutTop:getChildByTag(Tag_ui_battle_palace.LAB_TIMES) --今日剩余次数
    labRemainTip1 = layoutTop:getChildByTag(Tag_ui_battle_palace.LAB_TODAYREMAIN)
    labRemainTip2 = layoutTop:getChildByTag(Tag_ui_battle_palace.LAB_CI)
    labRewardTimes = layoutBottom:getChildByTag(Tag_ui_battle_palace.LAB_REWARDMULT) --青铜奖励 数量

    labDiceCount = self:getControl(Tag_ui_battle_palace.PANEL_BATTLE_PALACE,Tag_ui_battle_palace.LAB_DICECOUNT) --剩余筛子数
    if Activity1StatusProxy:getInstance():get("activity1Type") == Constants.ACTIVITY1_TYPE.CANDY_AREA then  --糖果区
        node = scrol:getContainer()
        imgSelect = node:getChildByTag(Tag_ui_battle_palace.IMG_SELECTED1)
        for i = 1,42 do
            local WEEK = {'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'}
            local imgGrid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT".. i])
            local gridConfig = ConfigManager.getActivity1GridConfig(i)
            local week = os.date("*t")
            local event = gridConfig[tostring(WEEK[tonumber(week.wday)])]
            imgGrid:setSpriteFrame("ui_battle_palace/img_gridevent_" .. event .. ".png")
        end
    else
        node = scrol:getContainer()
        imgSelect = node:getChildByTag(Tag_ui_battle_palace.IMG_SELECTED2)
        for i = 1,42 do
            local WEEK = {'Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'}
            local imgGrid = node:getChildByTag(Tag_ui_battle_palace["IMG_RECT_".. i])
            local gridConfig = ConfigManager.getActivity1GridConfig(i)
            local week = os.date("*t")
            local event = gridConfig[tostring(WEEK[tonumber(week.wday)])]
            imgGrid:setSpriteFrame("ui_battle_palace/img_gridevent_" .. event .. ".png")
        end
    end

    Utils.floatToBottom(scrol)
    local Min = scrol:getMinOffset()
    scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        local xx  = scrol:getContentOffset().y
        if xx < Min.y+5 then
            scrol:setContentOffset(cc.p(0,Min.y+5))
        elseif xx > 0 then
            scrol:setContentOffset(cc.p(0,0))
        end
    end, 0, false)

    btnDice = self:getControl(Tag_ui_battle_palace.PANEL_BATTLE_PALACE,Tag_ui_battle_palace.BTN_DICE) --筛子
    btnDice:setOnClickScriptHandler(self.onLoadgrideventHandler)
    scheduleBtnEnabled = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        if self.onbtnDiceCilckStatus then
            self.onbtnDiceCilckStatus()
        end
    end, 0, false)
    TouchEffect.addTouchEffect(self)

    local function onNodeEvent(event)
        if "enter"==event then
            self.activity1Type = Activity1StatusProxy:getInstance():get("activity1Type")
            NetManager.sendCmd("loadactivity1status",loadactivity1status,self.activity1Type)
        end
        if "exit" == event then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID)
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleBtnEnabled)
            if scheduleCoolID then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleCoolID)
            end
            if self.listener1 then
                self:getEventDispatcher():removeEventListener(self.listener1)
            end
            if self.listener2 then
               self:getEventDispatcher():removeEventListener(self.listener2)
            end
            if self.listener3 then
               self:getEventDispatcher():removeEventListener(self.listener3)
            end
            if self.listenerDtor then
               self:getEventDispatcher():removeEventListener(self.listenerDtor)
            end 
        end
    end
    self:registerScriptHandler(onNodeEvent)
end



