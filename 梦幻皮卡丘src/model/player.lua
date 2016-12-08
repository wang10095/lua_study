Player = class("Player", function()
    return Model:create("Player", {
        uid = 2,
        nickname = "",
        role = 0,
        sex = 0, -- 1 男  2 女
        level = 0,
        exp = 0,
        maxExp = 0,
        energy = 0,
        maxEnergy = 0,
        gold = 0,
        diamond = 0, 
        arena = 0,
        pavilion = 0,
        vip = 0,
        normalChapterId = 0,
        normalStageId = 0,
        eliteChapterId = 0,
        eliteStageId = 0,
        buyedEnergyCount = 0, --已经购买的体力次数
        team = {},
        pvp1Team = {},
        pvp1_battle_team = "",
        skillPoints = 0,--剩余技能点数 
        goldhandTimes = 0,
        auth_code = '',
        badge = 0, --徽章
        fame = 0, --声望
        main_guide = 0, 
        func_guide = 0,
        view_story = 0, --场景剧情
        chapter_story = 0, --章节剧情
        server_id = 1,
        resetEliteNum = 0, -- 剩余重置次数
        buyPvp1Times = 0, -- 购买PVP1的次数
        rootPvpTimes = 0,--已经清除pvp冷却时间次数
    })
end
)

local __instance = nil

function Player:ctor()
    local team = {}

end

function Player:getInstance()
	if (__instance == nil) then
		__instance = Player:new()
    end
    return __instance
end

function Player:update(properties)
    for k,v in pairs(properties) do
        self:set(k, v)
    end
    if self:get("level") == 0 then 
        self:set("level",1)
    end
    local userConfig = ConfigManager.getUserConfig(self:get("level")) 
    Debug.simplePrintTable(userConfig)
    self:set("maxEnergy", userConfig.max_energy)
    self:set("maxExp", userConfig.max_exp)

    local event = cc.EventCustom:new("event_update_user")
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function Player:reset()
    __instance = Player:new()
end

function Player:isStagePassed(dungeonType, chapter, stage)
    if dungeonType ~= Constants.DUNGEON_TYPE.NORMAL and dungeonType ~= Constants.DUNGEON_TYPE.ELITE then
        return true
    end
    
    local passedChapter = (dungeonType == Constants.DUNGEON_TYPE.NORMAL) and self:get("normalChapterId") or self:get("eliteChapterId")
    local passedStage = (dungeonType == Constants.DUNGEON_TYPE.NORMAL) and self:get("normalStageId") or self:get("eliteStageId")

    if chapter < passedChapter then
        return true
    end
    if chapter == passedChapter then
        return stage <= passedStage
    end
    return false
end
function Player:isPlayerLevelUp()
    local levelFrom = StageRecord:getInstance():get("old_level")
    if self:get("level")>levelFrom then
        TDGAAccount:setLevel(self:get("level"))
        Utils.runUIScene("PlayerLevelUpPopup")
        if NormalDataProxy:getInstance().updateUser then
            NormalDataProxy:getInstance().updateUser()
        end
    end
end