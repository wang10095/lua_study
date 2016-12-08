NormalDataProxy = class("NormalDataProxy", function()    --公用数据存储
    return Model:create("NormalDataProxy", {
        title = '',
        content = '',
        fontSize = 20,
        color = cc.c3b(0xff, 0, 0xff),
        width = 250,
        bg_margin = 30,
        isScene = false,
        isServer = false,
        isPlayerCell = false,-- 判断PlayerCell 是否在运行
        currentHoom = 1,--当前是哪个房子
        isOpen = false,   -- 是否展开 收纳栏
        isPopup = false, --是否有弹出窗  
        signType = 1, --1为每日签到  2为豪华签到
        musicStatus = 1, --音乐状态 1 on 0 off
        effectStatus = 1,--音效状态
        pvpCD = 0,
        FirstComeIn = true,
        isPursue = false, -- 是否追踪 （任务 ）
        isDaliyPursue = false, --是否追踪 （日常）
        isWeekGift = false,
    })
end)

local _allowNewInstance = false
local __instance = nil

NormalDataProxy.confirmHandler = nil
NormalDataProxy.cancelHandler = nil
NormalDataProxy.updateUser  = nil --更新玩家cell
NormalDataProxy.updateItem  = nil  --更新宠物中心训练材料
NormalDataProxy.updateEnergy = nil  --更新副本体力
NormalDataProxy.updateSweepNum = nil --更新精英本扫荡
NormalDataProxy.pveBattle = nil --更新精英本扫荡
NormalDataProxy.updatePvp1CD = nil
NormalDataProxy.updateEnergyProg = nil --更新角色框体力进度条
NormalDataProxy.onCompleteEnermy = nil --战斗宫殿 挑战敌人

function NormalDataProxy:ctor()
    print("constructor of NormalDataProxy, automaticly called by class")
    if not _allowNewInstance then
        error("new instance by hand is not allowed")
    end
end

function NormalDataProxy:getInstance()
	if (__instance == nil) then
        _allowNewInstance = true
		__instance = NormalDataProxy:new()
        -- silence update forever
        _allowNewInstance = false
    end
    return __instance
end

local function event_add_energy()
    local player = Player:getInstance()
    local maxEnergy = ConfigManager.getUserConfig(player:get("level")).max_energy
    local energy = player:get("energy")
    energy = energy + 1
    player:set("energy",energy)
    if energy >= maxEnergy then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(__instance.schedulerID)
        __instance.schedulerID = nil
    end
    if __instance:get("isPlayerCell") == true then
        NormalDataProxy:getInstance():updateUser()
    end
end

local function callback_load_energy(result)
    local recoverTime = ConfigManager.getUserCommonConfig('energy_recover_time')
    Player:getInstance():set("energy",result["energy"])
    local time = result["remainTime"]
    if time ~= 0 then
        local function tick()
            event_add_energy()
            if __instance.schedulerID then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(__instance.schedulerID)
                __instance.schedulerID = nil
            end
            __instance.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(event_add_energy,recoverTime,false)
        end
        if __instance.schedulerID then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(__instance.schedulerID)
            __instance.schedulerID = nil
        end
        __instance.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick,time,false)
    end
end

function NormalDataProxy:loadEnergy()
     if __instance.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(__instance.schedulerID)
        __instance.schedulerID = nil
     end
    NetManager.sendCmd("loadenergy",callback_load_energy)
end