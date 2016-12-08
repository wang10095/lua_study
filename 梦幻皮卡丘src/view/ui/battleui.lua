require "view/tagMap/Tag_ui_battle"
require "battle/matrix"
-- require "battle/enemy"
require "battle/buff"
require "battle/debuff"
require "battle/unit/pet_unit"
require "battle/unit/special_demon"
require "battle/unit/demon_unit"
require "battle/activity2_handler"

BattleUI = class("BattleUI",function()
    return TuiBase:create()
end)

BattleUI.__index = BattleUI
local __instance = nil

local NET_MODE = true
local BATTLE_MODE = {
    INIT_MODE = 0,
    FIGHT_MODE = 1,
    SWITCH_MODE = 2
}

local MATRIX_MODE = {
    STEP_MODE = 1,
    TIME_MODE = 2
}

local ACTIVATE_INTERVAL=1.3
local speed = 1.0
local autoStatus = "0";

---- local constants
local PET_RECT_SIZE = 100
local PET_UNIT_COUNT = 6
local SWITCH_STEPS_PER_ROUND = 5
local SWITCH_TIME_PER_ROUND = 10

local TAG_POWER_PROG = 0
local TAG_POWER_OPTION = 10
local TAG_POWER_DIVIDER = 20
local TAG_DARK_BG = 100
local PET_PER_PAGE = 10

local SKILL_EFFECT_ZORDER = 1
local BUFF_DEBUFF_ZORDER = 2
local DAMAGE_ZORDER = 3
local SKILL_NAME_ZRODER = 4
local TOP_ZORDER = 200

---- local variables
local battle_ = nil
local selectedPetCell_ = nil
local selectedPetUnit_ = nil
local touchStarted = false
local draggingPetSpine_ = nil
local enemyPositions_ = nil
local petSelect = nil
local changePet = false
local petGvContent = nil
local leaveTeam = false
local petUnitIndex = 0

local cachedSpines = {}

---- object variables
BattleUI.effectLayout = nil
BattleUI.battleLayout = nil
BattleUI.uiPanel = nil
BattleUI.matrix = nil
BattleUI.result = 0
BattleUI.touchListener = nil
BattleUI.petUnits = nil
BattleUI.demonUnits = nil
BattleUI.circles = nil
BattleUI.petHPProgresses = nil
BattleUI.demonHPProgresses = nil
BattleUI.petPowerProgresses = nil
BattleUI.demonPowerProgresses = nil
BattleUI.petPositions_ = nil
BattleUI.skillNameEffectPosition = nil
BattleUI.superSkillNameEffectPosition = nil

BattleUI.dragListener = nil
BattleUI.eliminateListener = nil
BattleUI.switchListener = nil
BattleUI.unitActionListener = nil
BattleUI.restartListener = nil
BattleUI.resumeListener = nil
BattleUI.captureListener = nil
BattleUI.debuffListener = nil
BattleUI.effectListener = nil
BattleUI.rmdebuffListener = nil
BattleUI.attackAllListener = nil
BattleUI.moveToNextListener = nil
BattleUI.summonPetListener = nil

BattleUI.labelStepCount = nil
BattleUI.labelDeployOption = nil
BattleUI.labelRewardCount = nil
BattleUI.labelTopOption = nil
BattleUI.switchCount = 5
BattleUI.unitQueue = nil
BattleUI.captureQueue = nil
BattleUI.rewardQueue = nil
BattleUI.mode = BATTLE_MODE.INIT_MODE
BattleUI.hpInfo = nil
BattleUI.switchAnim = nil
BattleUI.petGridPage = 1
BattleUI.wave = 1
BattleUI.skillNameEffect = nil
BattleUI.spineCombo = nil
BattleUI.totalMonsters = 0
BattleUI.monstersDefeated = 0
BattleUI.rewardMonsterIndexes = {}     --会掉奖励的怪物

BattleUI.matrixMode = MATRIX_MODE.STEP_MODE
BattleUI.switchTimeLeft = 0
BattleUI.switchScheduler = nil
BattleUI.buffDebuffScheduler = nil
BattleUI.curRound = 0
BattleUI.battlePetCount = 0
BattleUI.battlePetCell = {}
BattleUI.teamUnits = {}
-- 治疗效果系数，为活动2添加
BattleUI.healFactor = 1.0
BattleUI.specialDemonUnit = nil



---- local functions

local function getPetSpine(model)
    local atlas = string.format(TextureManager.RES_PATH.SPINE_PET, model) .. ".atlas"
    local json = string.format(TextureManager.RES_PATH.SPINE_PET, model) .. ".json"
    local spine = sp.SkeletonAnimation:create(json, atlas, 1)
    -- spine:setAnimation(0, "breath", true)
    return spine
end

local function getPetGvContent()
    if petGvContent ~= nil then
        return petGvContent
    end

    petGvContent = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)

    if StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY3 then
        local tmp = {}
        local availPetModels = {}
        local availPetNum = 0
        for i,pet in ipairs(petGvContent) do
            -- todo: 等级限制
            if pet:get("level") >= 5 then
                pet:set("hp", pet:getAttribute(Constants.PET_ATTRIBUTE.HP))
                table.insert(tmp, pet)
            end
        end
        petGvContent = tmp

        for i, v in ipairs(__instance.hpInfo) do
            -- local pet = ItemManager.getPetById(v.id)
            for m,pet in ipairs(petGvContent) do
                
                if pet:get("id") == v.id then
                    print(pet:get("id").."  "..v.id.."  "..v.hp)
                    pet:set("hp", v.hp)
                end
            end
        end

        for i,pet in ipairs(petGvContent) do
            if pet:get("hp") > 0 then
                if not availPetModels[pet:get("mid")] then
                    availPetNum = availPetNum + 1
                    availPetModels[pet:get("mid")] = 1
                end
            end
        end

        if availPetNum < 5 then
            print("activity3 pet not enough", availPetNum)
            -- 活动3可上阵宠物不足5个，“开始战斗”改为“退出战斗”
            __instance.labelDeployOption:setString("可上阵宠物不足")
            __instance:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.LAYOUT_DEPLOY):getChildByTag(Tag_ui_battle.LAB_START_BATTLE):setString("退出战斗")
            __instance:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.LAYOUT_DEPLOY):getChildByTag(Tag_ui_battle.BTN_START_BATTLE):setOnClickScriptHandler(function()
                Utils.replaceScene("PyramidUI")
            end)
        end
    end

    for i,v in ipairs(petGvContent) do
        v.isInTeam = false
    end

    -- 标记已上阵宠物
    local savedTeamStr
    if NET_MODE then
        local keyStr = __instance:getUserDefaultKey()
        if keyStr then
            savedTeamStr = Utils.userDefaultGet(keyStr)
        end
    else
        savedTeamStr = "{1, 2, 3, 4, 5}"
    end
    
    if savedTeamStr ~= nil and savedTeamStr ~= "" 
        and GuideManager.main_guide_phase_ ~= GuideManager.MAIN_GUIDE_PHASES.CAPTURE 
        and GuideManager.main_guide_phase_ ~= GuideManager.MAIN_GUIDE_PHASES.STAGE_3 
        and StageRecord:getInstance():get("dungeonType") ~= Constants.DUNGEON_TYPE.ACTIVITY3 then

        local petsFromTeam = Utils.stringToTable(savedTeamStr)
        for i,v in ipairs(petsFromTeam) do
            if v ~= 0 then
                for j,pet in ipairs(petGvContent) do
                    if pet:get("id") == v then
                        pet.isInTeam = true
                    end
                end
            end    
        end
    elseif (savedTeamStr == nil or savedTeamStr == "") and StageRecord:getInstance():get("activity3_moveToNextStage")==false then
        for i,circle in pairs(__instance.circles) do
            local json = string.format(TextureManager.RES_PATH.SPINE_UNIT,1,i)..".json"
            local atlas = string.format(TextureManager.RES_PATH.SPINE_UNIT,1,i)..".atlas"
            local spine = sp.SkeletonAnimation:create(json, atlas, 1)
            spine:setAnimation(0, "normal", true)
            spine:setPosition(cc.p(circle:getContentSize().width/2,circle:getContentSize().height/2+30))
            spine:setTag(5000+i)
            circle:addChild(spine, i)
        end
    end

    if StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY3 then
        for k,pet in ipairs(petGvContent) do
            for i,pu in pairs(__instance.petUnits) do
                if pu.pet:get("id") == pet:get("id") then
                    pu.pet.isInTeam = true
                    pet.isInTeam = true
                end
            end
        end
    end
    
    --排列优先级为 星级 > 段位 > 等级 > 资质 > mid
    if GuideManager.main_guide_phase_ > GuideManager.MAIN_GUIDE_PHASES.STAGE_3 then
        table.sort(petGvContent, function(pet1, pet2)
            -- local attack1 = pet1:getAttribute(Constants.PET_ATTRIBUTE.COMMON_ATTACK)
            -- print(" attack1  "..attack1)
            -- local attack2 = pet2:getAttribute(Constants.PET_ATTRIBUTE.COMMON_ATTACK)
            -- print(" attack2  "..attack2)
            local p1 = --[[attack1 * 10000 + ]]pet1:get("star") * 100000  + pet1:get("rank") * 10000 + pet1:get("aptitude") * 100 + pet1:get("level") *1000 + pet1:get("mid")
            if pet1.isInTeam then
                p1 = p1 + 100000000000
            end
            local p2 = --[[attack2 * 10000 + ]]pet2:get("star") * 100000 + pet2:get("rank") * 10000 + pet2:get("aptitude") * 100 + pet2:get("level") *1000 + pet2:get("mid")
            if pet2.isInTeam then
                p2 = p2 + 100000000000
            end
            return p1 > p2
        end)
    end
    return petGvContent
end

local function event_adapt_gvpet(p_convertview, idx)
    local pCell = p_convertview
    idx = (__instance.petGridPage - 1) * PET_PER_PAGE + idx
    local gvCotent = getPetGvContent()
    local pet
    if NET_MODE then
        -- if StageRecord:getInstance():get("dungeonType") ~= Constants.DUNGEON_TYPE.ACTIVITY3 then
            pet = gvCotent[idx + 1]
        -- end
    else
        pet = Pet:create()
        pet:set("id", idx)
        pet:set("mid", idx + 1)
        pet:set("form", 1)
        pet:set("aptitude", 1)
    end
    pCell = PetCell:create(pet)
    pCell.pet = pet
    
    if pet.isInTeam then
        local petSelect = TextureManager.createImg(TextureManager.RES_PATH.PET_SELECT)
        local pos = pCell:getContentSize()
        petSelect:setPosition(cc.p(pos.width/2+8,pos.height/2-12))
        pCell:addChild(petSelect,2)
        table.insert(__instance.battlePetCell,pCell)
    end

    --拖拽上去的宠物的上阵提示添加
    local function add_battle_pet( event )
        local pet = event._usedata
        if pet ~= nil and pet == pCell.pet then
            local petSelect = TextureManager.createImg(TextureManager.RES_PATH.PET_SELECT)
            local pos = pCell:getContentSize()
            petSelect:setPosition(cc.p(pos.width/2+8,pos.height/2-12))
            pCell:addChild(petSelect,2)
            pCell.pet.isInTeam = true
            table.insert(__instance.battlePetCell,pCell)
        end
    end

    local addBattlePet = cc.EventListenerCustom:create("add_battle_pet",add_battle_pet)
    __instance.addBattlePetListener = addBattlePet
    local dispatcher = __instance:getEventDispatcher()
    dispatcher:addEventListenerWithFixedPriority(addBattlePet, 1)

    --上阵宠物阵容改变，上阵提示也改变
    local function event_battle_pet(event)
        local pet = event._usedata
      
        if pet ~= nil and pet == pCell.pet then
            pCell:removeAllChildren()
            local petCell = PetCell:create(pet)
            local size = pCell:getContentSize()
            petCell:setAnchorPoint(cc.p(0.5,0.5))
            petCell:setPosition(cc.p(size.width/2,size.height/2-4))
            pCell:addChild(petCell)
            pCell.pet = pet
            if StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY3 then
                local progImgName = TextureManager.RES_PATH.PROG_PET_HP .. ".png"
                local progBgImgName = TextureManager.RES_PATH.PROG_PET_HP .. "_background.png"
                local prog = CProgressBar:create()
                prog:setProgressSpriteFrameName(progImgName)
                prog:setBackgroundSpriteFrameName(progBgImgName)
                prog:setMaxValue(pet:getAttribute(Constants.PET_ATTRIBUTE.HP))
                prog:setValue(pet:get("hp"))
                prog:setPosition(cc.p(55, 5))
                pCell:addChild(prog)
            end
        end
    end

    local listenerBattlePet = cc.EventListenerCustom:create("on_battle_pet",event_battle_pet)
    __instance.listenerBattlePet = listenerBattlePet
    local eventDispatcher = __instance:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(listenerBattlePet, 1)

    local touchHandler = function ()
        return function ()
            selectedPetCell_ = pCell
        end
    end
    pCell:setTouchBeganClosureHandler(touchHandler)

    if StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY3 then
        local progImgName = TextureManager.RES_PATH.PROG_PET_HP .. ".png"
        local progBgImgName = TextureManager.RES_PATH.PROG_PET_HP .. "_background.png"
        local prog = CProgressBar:create()
        prog:setProgressSpriteFrameName(progImgName)
        prog:setBackgroundSpriteFrameName(progBgImgName)
        local pu = PetUnit:create(pet)
        print(" 宠物生命值   "..pet:get("mid").."    "..pu:getPetAttribute(Constants.PET_ATTRIBUTE.HP).."    "..pet:get("hp"))
        prog:setMaxValue(pu:getPetAttribute(Constants.PET_ATTRIBUTE.HP))
        prog:setValue(pet:get("hp"))
        prog:setPosition(cc.p(55, 5))
        pCell:addChild(prog)

        if pet:get("hp") <= 0 then
            local label = CLabel:createWithTTF("死亡", "fonts/FZCuYuan/M03S.ttf", 24)
            label:enableOutline(cc.c4b(0, 0, 0, 255), 2);
            label:setPosition(cc.p(55, 70))
            pCell:addChild(label, 101, TAG_POWER_OPTION)
        end
    end
    return pCell
end

local function updateSwitchTime(delay)
    __instance.switchTimeLeft = __instance.switchTimeLeft - 1
    __instance.labelStepCount:setString(string.format("剩余时间: %d秒", __instance.switchTimeLeft))
    if __instance.switchTimeLeft == 0 then
        if not __instance.matrix:isStepInProgress() then
            __instance:finishSwitchPhase()
        end
        if __instance.switchScheduler ~= nil then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(__instance.switchScheduler)
            __instance.switchScheduler = nil
        end
    end
end

local function startDrag(touchPos)
    local pos
    local selectedPet

    -- 分别处理列表中的宠物和已上阵的宠物
    if (selectedPetCell_ == nil) then
        -- 处理已上阵宠物
        local petUnitUnderTouch = nil
        for i,v in ipairs(__instance.petPositions_) do
            if __instance.petUnits[i] ~= nil then
                local petRect = cc.rect(v.x - PET_RECT_SIZE/2, v.y - PET_RECT_SIZE/2, PET_RECT_SIZE, PET_RECT_SIZE+30)
                if cc.rectContainsPoint(petRect, touchPos) then
                    petUnitUnderTouch = __instance.petUnits[i]
                    petUnitIndex = i
                    break
                end
            end
        end
        if petUnitUnderTouch == nil then
            return
        end
        
        selectedPetUnit_ = petUnitUnderTouch
        selectedPet = petUnitUnderTouch.pet
        pos = cc.p(petUnitUnderTouch.layout:getPosition())
        petUnitUnderTouch.layout:removeFromParent()
        __instance.petUnits[petUnitUnderTouch.index] = nil
    else
        -- 处理列表中的宠物
        -- 如果是活动三而且选中宠物已经死亡则不进行拖拽操作
        if StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY3 
                and selectedPetCell_.pet:get("hp") <= 0 then
            selectedPetCell_ = nil
            return
        end
        local parent = selectedPetCell_:getParent()
        pos = parent:convertToWorldSpace(cc.p(selectedPetCell_:getPosition()))
        selectedPet = selectedPetCell_.pet

        local tsAtlas = TextureManager.RES_PATH.SPINE_AVATAR_TRASITION .. ".atlas"
        local tsJson = TextureManager.RES_PATH.SPINE_AVATAR_TRASITION .. ".json"
        local transition = sp.SkeletonAnimation:create(tsJson, tsAtlas, 1)
        pos = __instance:convertToNodeSpace(pos)
        pos.x = pos.x + selectedPetCell_:getContentSize().width/2
        pos.y = pos.y - selectedPetCell_:getContentSize().height/2
        transition:setPosition(pos)
        transition:setAnimation(0, "animation", false)
        __instance.effectLayout:addChild(transition, 2)
        
        pos.y = pos.y - 40
    end

    local formConfig = ConfigManager.getPetFormConfig(selectedPet:get("mid"), selectedPet:get("form"))
    local petSpine = getPetSpine(formConfig.model)
    petSpine:setOpacity(0)
    petSpine:runAction(cc.FadeIn:create(0.2))
    petSpine:setPosition(pos)
    __instance.effectLayout:addChild(petSpine, 1)
    draggingPetSpine_ = petSpine
end

local function dropPet(idx)
    -- 如果selectedPetCell_为空而selectedPetUnit_不为空
    -- 表明所选宠物时从其它位置拖过来的，而不是从宠物列表拖过来的，需要交换位置，否则替换
    if selectedPetCell_ == nil and selectedPetUnit_ ~= nil then
        local targetPu = __instance.petUnits[idx]
        if targetPu ~= nil then
            local origIndex = selectedPetUnit_.index
            targetPu.spine:setOpacity(255)
            targetPu.layout:setPosition(__instance.petPositions_[origIndex])
            targetPu.layout:setLocalZOrder(origIndex)
            targetPu.index = origIndex
            __instance.petUnits[origIndex] = targetPu
        end
        selectedPetUnit_.layout:setPosition(__instance.petPositions_[idx])
        selectedPetUnit_.layout:setTag(4000+idx)
        __instance.battleLayout:addChild(selectedPetUnit_.layout, idx)
        selectedPetUnit_.index = idx
        __instance.petUnits[idx] = selectedPetUnit_
        
    else
    -- 如果selectedPetCell_不为空而selectedPetUnit_为空
    -- 表明所选宠物是从宠物列表拖过来的，替换
        local selectedPet = selectedPetCell_.pet
        for k,pu in pairs(__instance.petUnits) do
            if pu.pet:get("mid") == selectedPet:get("mid") then
                pu.layout:removeFromParent()
                pu.pet.isInTeam = false
                __instance.petUnits[k] = nil
                local customEvent = cc.EventCustom:new("on_battle_pet")  --id相同属性不同的宠物的上阵提示交换事件
                customEvent._usedata = pu.pet
                cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
            end
        end

        -- 保证上阵宠物不超过5个
        local petCount = 0
        for i=1,PET_UNIT_COUNT do
            if __instance.petUnits[i] ~= nil or i == idx then
                petCount  = petCount + 1
            end
        end
        __instance.battlePetCount = petCount
        if petCount > 5 then
            -- __instance.battlePetCount = petCount
            changePet = false
            TipManager.showTip("最多只能上阵5个神奇宝贝!")
            return
        end

        if __instance.petUnits[idx] then
            changePet = true
            local customEvent = cc.EventCustom:new("on_battle_pet")  --不同宠物的上阵提示交换事件
            customEvent._usedata = __instance.petUnits[idx].pet
            cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)

            __instance.petUnits[idx].layout:removeFromParent()
            __instance.petUnits[idx].pet.isInTeam = false
            __instance.petUnits[idx]:cleanup()
        else

        end
        __instance.circles[idx]:removeAllChildren()
        -- __instance.teamUnits[idx]:removeFromParent()
        local petUnit = PetUnit:create(selectedPet, idx)
        petUnit.layout:setPosition(__instance.petPositions_[idx])
        __instance.petUnits[idx] = petUnit
        __instance.battleLayout:addChild(petUnit.layout, idx)
    end
end

local function leaveTeams()
    if selectedPetUnit_ == nil then
        return 
    end
    if leaveTeam then
        leaveTeam = false
        print(selectedPetUnit_.pet:get("mid"))
        selectedPetUnit_.pet.isInTeam = false
        local customEvent = cc.EventCustom:new("on_battle_pet")  --下阵事件
        customEvent._usedata = selectedPetUnit_.pet
        cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
        print("分发宠物下阵事件")
        print(petUnitIndex)
        __instance.petUnits[petUnitIndex] = nil
        selectedPetUnit_  = nil
        draggingPetSpine_ = nil
        selectedPetCell_  = nil
        __instance.effectLayout:removeAllChildren()
    end
end

local function stopDrag()
    if (selectedPetCell_ ~= nil or selectedPetUnit_ ~= nil) and draggingPetSpine_ ~= nil then
        local draggingPetPos = cc.p(draggingPetSpine_:getPosition())
        local succ = false
        
        for i,v in ipairs(__instance.petPositions_) do
            local petRect = cc.rect(v.x - PET_RECT_SIZE/2, v.y - PET_RECT_SIZE/2, PET_RECT_SIZE, PET_RECT_SIZE)
            if cc.rectContainsPoint(petRect, draggingPetPos) then
                dropPet(i)
                succ = true
                print("   ------"..__instance.battlePetCount )
                if selectedPetCell_ == nil and selectedPetUnit_ ~= nil then
                else
                    if __instance.battlePetCount > 5 and changePet == false then
                        print("Do not change")
                    else
                        if selectedPetCell_ ~= nil then
                            local customEvent = cc.EventCustom:new("add_battle_pet")  --添加宠物的上阵提示事件
                            customEvent._usedata = selectedPetCell_.pet
                            cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
                        end
                    end
                end
                break
            end
            -- 放置坐标没有其他宠物，放回原处
            -- dropPet(selectedPetUnit_.index)
        end

        if not succ and selectedPetUnit_ ~= nil then
            dropPet(selectedPetUnit_.index)
        end
        selectedPetCell_ = nil
        selectedPetUnit_ = nil
        draggingPetSpine_ = nil
        __instance.effectLayout:removeAllChildren()
        if succ and __instance.battlePetCount == 5 and GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.START_BATTLE then
            Utils.dispatchCustomEvent("event_enter_view",{view = "BattleUI",phase = GuideManager.MAIN_GUIDE_PHASES.START_BATTLE,scene = __instance})
        end
    end
end

local function testDraggingPosition()
    if draggingPetSpine_ ~= nil then
        local draggingPetPos = cc.p(draggingPetSpine_:getPosition())
        for i,v in ipairs(__instance.petPositions_) do
            if __instance.petUnits[i] ~= nil then
                local petRect = cc.rect(v.x - PET_RECT_SIZE/2, v.y - PET_RECT_SIZE/2, PET_RECT_SIZE, PET_RECT_SIZE)
                if cc.rectContainsPoint(petRect, draggingPetPos) then
                    __instance.petUnits[i].spine:setOpacity(122)
                else
                    __instance.petUnits[i].spine:setOpacity(255)
                end
            end
        end
    end
end

-- 生成掉落次序
function BattleUI:generateRewardIndexes()
    self.rewardMonsterIndexes = {}
    self.totalMonsters = 0
    
    local dungeonType = StageRecord:getInstance():get("dungeonType") or 1
    local chapter = StageRecord:getInstance():get("chapter") or 1
    local stage = StageRecord:getInstance():get("stage") or 1

    --todo: 活动副本掉落
    if dungeonType > Constants.DUNGEON_TYPE.ELITE then
        return
    end
    
    local dungeonConfig = ConfigManager.getDungeonConfig(dungeonType, chapter, stage)
    if dungeonConfig.monsters then
        for i,monsterIds in ipairs(dungeonConfig.monsters) do
            for j,v in ipairs(monsterIds) do
                if v > 0 then
                    self.totalMonsters = self.totalMonsters + 1
                end
            end
        end
    end

    local rewardsCount = #self.rewardQueue
    -- todo: 避免重复
    for i=1,rewardsCount do
        table.insert(self.rewardMonsterIndexes, math.random(self.totalMonsters))
        -- table.insert(self.rewardMonsterIndexes, i)
    end
    table.sort(self.rewardMonsterIndexes)
end

-- 掉落奖励
function BattleUI:dropReward(target)
    -- 用while以处理统一位置掉落多个的情况
    while self.monstersDefeated == self.rewardMonsterIndexes[1] do
        local droppedCount = #self.rewardQueue - #self.rewardMonsterIndexes
        droppedCount = droppedCount + 1
        self.labelRewardCount:setString(tostring(droppedCount))
        table.remove(self.rewardMonsterIndexes, 1)
        
        local reward = self.rewardQueue[droppedCount]
        local avatar = TextureManager.getItemAvatar(reward.itemType, reward.mid)
        local targetPos = cc.p(target.layout:getPosition())
        avatar:setPosition(cc.p(targetPos.x, targetPos.y + 70))
        avatar:setScale(0.5)
        self.effectLayout:addChild(avatar)
        avatar:runAction(cc.Sequence:create(
            cc.JumpTo:create(0.3,cc.p(targetPos.x - 10, targetPos.y+60), 0, 1),
            cc.JumpTo:create(0.1,cc.p(targetPos.x - 20, targetPos.y), 0, 1),
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(function()
                avatar:removeFromParent()
            end)
        ))
    end
end

function prepareBattle()
    
    __instance.monstersDefeated = 0
    __instance:generateRewardIndexes()
  
    __instance:getEventDispatcher():removeEventListener(__instance.dragListener)
    __instance:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.LAYOUT_DEPLOY):setVisible(false)

    local bottomLayout = __instance:getControl(Tag_ui_battle.LAYOUT_BOTTOM)
    local bottomBg = bottomLayout:getChildByTag(Tag_ui_battle.LAYOUT_BOTTOM_BG)
    bottomBg:setBackgroundColor(cc.c4b(0, 0, 0, 255))

    __instance.labelStepCount:setVisible(true)
    __instance.labelDeployOption:setVisible(false)

    for k,demonUnit in pairs(__instance.demonUnits) do
        demonUnit.layout:removeFromParent()
    end
    for i,circle in ipairs(__instance.circles) do
        circle:setVisible(false)
    end



    if GuideManager.main_guide_phase_ > GuideManager.MAIN_GUIDE_PHASES.STAGE_2 then
        local count = 0
        
        local colorIndexies = {}
        for k,pu in pairs(__instance.petUnits) do
            pu.layout:removeFromParent(false)
            __instance:runAction(cc.Sequence:create(cc.DelayTime:create(0.3 * math.floor(count / 3)), cc.CallFunc:create(function()
                pu.layout:setPosition(__instance.petPositions_[k])
                __instance.battleLayout:addChild(pu.layout, 1)
                pu:start()
            end)))
            table.insert(colorIndexies, k)
            count = count + 1
        end

        if __instance.matrix == nil then
            __instance.matrix = Matrix:create(colorIndexies)
            __instance:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.LAYOUT_MATRIX):addChild(__instance.matrix:getLayout())
        end
    end
end

function onBattleStart(result)
    -- do
    --     battle_:finishBattle(true)
    --     return
    -- end
    
    if NET_MODE then
        if StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY3 then
            -- todo: 处理层数不对和有奖励没有领取的情况
            if  tonumber(result["status"])==1 then
                __instance:showActivity3RewardChest()
                return
            end
        elseif StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY1 then
            
            Activity1StatusProxy:getInstance():set("token",result["token"])
            
            Activity1StatusProxy:getInstance():set("score",result["score"])

            local stageRecord = StageRecord:getInstance()
            if result.rewards ~= nil then
                stageRecord:set("rewards", result.rewards)
                stageRecord:set("pets", result.pets)
            end
            __instance.rewardQueue = {}
            for i,v in ipairs(result.rewards) do
                table.insert(__instance.rewardQueue, v)
            end
        else
            local stageRecord = StageRecord:getInstance()
            stageRecord:set("battleId", result.battleId)
            stageRecord:set("rewards", result.rewards)
            stageRecord:set("pets", result.pets)

            __instance.rewardQueue = {}
            for i,v in ipairs(result.rewards) do
                table.insert(__instance.rewardQueue, v)
            end

            __instance.captureQueue = {}
            for i,v in ipairs(result.pets) do
                table.insert(__instance.captureQueue, v)
            end
        end
    end

    if __instance.matrix == nil then
        prepareBattle()
    end

    __instance:switchToEliminateMode()
    local listener = cc.EventListenerCustom:create("event_block", function(event)
        Utils.dispatchCustomEvent("event_block_unit",{view = "BattleUI",scene = self})
    end)
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    dispatcher:addEventListenerWithFixedPriority(listener, 1)
    
    if __instance.specialDemonUnit then
        print("event dispatcher")
        print("特殊怪物 ID ＝ "..__instance.specialDemonUnit.monsterId)
        __instance:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function ( )
              Utils.dispatchCustomEvent("event_monster",{view = "BattleUI",id = __instance.specialDemonUnit.monsterId,scene = __instance})
        end)))
    end
    __instance:initDemons(1)
    
    Activity2Handler:getInstance():initBattle(__instance)
end

local function onBattleEnd(result)
    if battle_.result == 1  then
        if StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY3 then
            __instance:showActivity3RewardChest()
            return
        end
    end
  
    if battle_.result == 1 then   --战斗胜利
        local callbackFunc = function()
            local levelUP = 0
            local stageRecord = StageRecord:getInstance()
            if result.level>Player:getInstance():get("level") then --主角升级
                levelUP = 1
                local lastMaxExp = ConfigManager.getUserConfig(Player:getInstance():get("level")).max_exp
                local addExp = lastMaxExp - Player:getInstance():get("exp") + result.exp
                stageRecord:set("exp", addExp)
            else
                stageRecord:set("exp", result.exp - Player:getInstance():get("exp"))
            end
            stageRecord:set("gold", result.gold - Player:getInstance():get("gold"))
            stageRecord:set("level", result.level - Player:getInstance():get("level"))
            if result["pets"] ~= nil then
                for i,v in ipairs(result["pets"]) do
                    StageRecord:getInstance():set("pets",result["pets"])
                    ItemManager.addPet(v)
                end
            end
            local userInfo = {}
            for i,v in ipairs({"energy", "gold", "diamond", "normalChapterId", "normalStageId", "eliteChapterId", "eliteStageId", "level", "exp"}) do
                userInfo[v] = result[v]
            end

            Player:getInstance():update(userInfo)

            local petExps = {}
            for i,v in ipairs(result.pet_exps) do
                local petExp = {}
                local pet = ItemManager.getPetById(v.id)
                petExp.id = v.id
                if v.level > pet:get("level") then
                    petExp.exp = ConfigManager.getUserConfig(pet:get("level")).max_pet_exp - pet:get("exp")
                    petExp.exp = petExp.exp + v.exp
                else
                    petExp.exp = v.exp - pet:get("exp")
                end
                table.insert(petExps, petExp)
            end
            stageRecord:set("petExps", petExps)
            ItemManager.updatePets(result.pet_exps)
            for k,petUnit in pairs(__instance.petUnits) do
                petUnit:win()
            end
            local winStar = 3
            for i = 1,6 do
                local petUnit = __instance.petUnits[i]
                if petUnit then
                    local isdead = petUnit:isDead()
                    if isdead == true then
                        winStar =  winStar - 1
                        if winStar<=1 then
                           winStar = 1
                        end
                    end
                end
            end
            StageRecord:getInstance():set("winStar" ,winStar) --星数
            if levelUP == 1 then
                Player:getInstance():isPlayerLevelUp()
                StageRecord:getInstance():set("battle_victory",1)
                local listener = cc.EventListenerCustom:create("event_battle_end", function( )
                    __instance:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function()
                        MusicManager.battle_victory()
                        Utils.runUIScene("BattleVictoryPopup")
                    end)))
                end)
                local dispatcher = cc.Director:getInstance():getEventDispatcher()
                dispatcher:addEventListenerWithFixedPriority(listener, 1)
            else
                __instance:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function()
                    MusicManager.battle_victory()

                    Utils.runUIScene("BattleVictoryPopup")

                end)))
            end
        end
        --演示剧情
        if GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.CAPTURE + 1 then
            callbackFunc()
        else
            Utils.dispatchCustomEvent("battle_end",{callback = callbackFunc, params = {chapter=StageRecord:getInstance():get("chapter"), stage=StageRecord:getInstance():get("stage")}})
        end
    else            --战斗失败
        for k,demonUnit in pairs(battle_.demonUnits) do
            demonUnit:win()
        end
        battle_:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function()
            MusicManager.battle_defeat()
            Utils.runUIScene("BattleDefeatPopup")
        end)))
    end
end

local function preloadAnimations(callback)
    local loadingPopup = LoadingMaskPopup:getInstance()
    loadingPopup:begin(true)

    cachedSpines = {}
    local resources = {}
    for i=1,6 do
        local petUnit = __instance.petUnits[i]
        local demonUnit = __instance.demonUnits[i]
        local res = petUnit and petUnit:getResources() or {}
        for i,v in ipairs(res) do
            table.insert(cachedSpines, v)
            table.insert(resources, v.spine .. ".png")
        end
        res = demonUnit and demonUnit:getResources() or {}
        for i,v in ipairs(res) do
            table.insert(cachedSpines, v)
            table.insert(resources, v.spine .. ".png")
        end
    end

    local idx = 0
    local sc = SpineCache:getInstance()
    local loadNext
    loadNext = function()
        if idx >= #cachedSpines then
            loadingPopup:complete(callback)
            return
        end
        idx = idx + 1
        local sp = cachedSpines[idx]
        sc:addSpineAsync(sp.key, sp.spine, function(anim)
            loadNext()
        end, 1.0)
    end
    

    -- loadingPopup:complete(callback)
    
    ResourceManager.loadResource(resources, true, loadNext)
end

local function startBattleHandler(pSender)
    MusicManager.playBtnClickEffect()
    local petCount = 0
    local str = "{"
    for i=1,6 do
        if __instance.petUnits[i] then
            str = str .. __instance.petUnits[i].pet:get("id") .. ","
            petCount = petCount + 1
        else
            str = str .. "0,"
        end
    end
    str = str .. "}"
    if petCount ~= 5 then
        TipManager.showTip("上阵宠物必须为5个才可以开始战斗！")
        return
    end

    local dungeonType = StageRecord:getInstance():get("dungeonType")
    dungeonType = (dungeonType == 0) and 1 or dungeonType
    local keyStr = __instance:getUserDefaultKey()
    if keyStr then
        Utils.userDefaultSet(keyStr, str)
    end
    Stagedataproxy:getInstance():set("startBattle",true)
    local function start()
        if NET_MODE then
            if dungeonType == Constants.DUNGEON_TYPE.ACTIVITY2 then
                NetManager.sendCmd("activity2battlestart", onBattleStart, StageRecord:getInstance():get("activity2Level"))
            elseif dungeonType == Constants.DUNGEON_TYPE.ACTIVITY3 then
                NetManager.sendCmd("activity3battlestart", onBattleStart)
            elseif dungeonType == Constants.DUNGEON_TYPE.ACTIVITY1 then
                local activity1Type = Activity1StatusProxy:getInstance():get("activity1Type")
                local token = Activity1StatusProxy:getInstance():get("token")
                local difficulty= Activity1StatusProxy:getInstance():get("difficulty")

                local petIds = ""
                for k,v in pairs(__instance.petUnits) do
                    petIds = petIds .. "," .. v.pet:get("id")
                end
                petIds = string.sub(petIds, 2, -1)
                Activity1StatusProxy:getInstance():set("pid",petIds)
                NetManager.sendCmd("activity1battlestart",onBattleStart,activity1Type,token,difficulty)
            else
                local chapter = StageRecord:getInstance():get("chapter") or 1
                chapter = (chapter == 0) and 1 or chapter
                local stage = StageRecord:getInstance():get("stage") or 1
                stage = (stage == 0) and 1 or stage
                local petIds = ""
                for k,v in pairs(__instance.petUnits) do
                    petIds = petIds .. "," .. v.pet:get("id")
                end
                petIds = string.sub(petIds, 2, -1)
                Activity1StatusProxy:getInstance():set("pid",petIds)
                NetManager.sendCmd("battlestart", onBattleStart, dungeonType, chapter, stage, petIds)
            end
        else
            onBattleStart({})
        end
    end

    preloadAnimations(start)
end

function BattleUI:showActivity3RewardChest()
    local layoutChest = CLayout:create()
    layoutChest:setContentSize(cc.size(100,100))
    local winSize = cc.Director:getInstance():getVisibleSize()
    layoutChest:setPosition(cc.p(winSize.width/2+150,winSize.height/2+50))
    self:addChild(layoutChest,10)
    local treasureChest = TextureManager.createImg("ui_explore/img_chest.png")
    treasureChest:setAnchorPoint(cc.p(0,0))
    treasureChest:setPosition(cc.p(-110,-20))
    layoutChest:addChild(treasureChest,1)
    layoutChest:setOnTouchBeganScriptHandler(function(touch,p_sender)
        local function confirmHandler()
            self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
                self:activity3Recover()
            end)))
        end
        NormalDataProxy:getInstance().confirmHandler = confirmHandler
        Utils.runUIScene("ChestItemsPopup")
        layoutChest:removeFromParent()
        return false
    end)
    local img_open_chest = TextureManager.createImg("ui_explore/img_open_chest.png")
    img_open_chest:setAnchorPoint(cc.p(0,0))
    img_open_chest:setPosition(cc.p(-90,-20))
    layoutChest:addChild(img_open_chest,3)

    local img_arrow = TextureManager.createImg("component_common/img_arrow.png")
    img_arrow:setAnchorPoint(cc.p(0,0))
    img_arrow:setPosition(cc.p(-20,200))
    layoutChest:addChild(img_arrow,5)
    img_arrow:setRotation(90)
    local sequence = cc.Sequence:create(cc.MoveBy:create(0.4,cc.p(0,-15)),cc.MoveBy:create(0.4,cc.p(0,15)),nil)
    img_arrow:runAction(cc.RepeatForever:create(sequence))
end

function BattleUI:activity3Recover()
    for k,pu in pairs(self.petUnits) do
        if not pu:isDead() then
            local hp = math.ceil(pu.curHP * ConfigManager.getActivty3CommonConfig('buff')/100)
            pu:healed(hp)
            self:playHitEffect(pu, -hp, false)
        end
    end
    local hpStr = ""
    for k,pu in pairs(battle_.petUnits) do
        pu.curHP = (pu.curHP) > 0 and pu.curHP or 0
        hpStr = hpStr .. pu.pet:get("id") .. "_" .. pu.curHP .. ","
    end
    hpStr = string.sub(hpStr, 1, -2)
    print("hpStr  "..hpStr)
    NetManager.sendCmd("saveactivity3pethp", function()
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
            self:moveToNextStage()
        end)))
    end, hpStr)
end

function BattleUI:moveToNextStage()
    StageRecord:getInstance():set("stage", StageRecord:getInstance():get("stage") + 1)
    StageRecord:getInstance():set("activity3_moveToNextStage", true)
    local labActivity3Floor = self:getControl(Tag_ui_battle.LAYOUT_TOP):getChildByTag(Tag_ui_battle.LAB_ACTIVITY3_FLOOR)
    PyramidProxy:getInstance():set("floor",PyramidProxy:getInstance():get("floor")+1)
    labActivity3Floor:setString(" 第".. PyramidProxy:getInstance():get("floor") .."层 ")
    for k,v in pairs(self.demonUnits) do
        v.layout:removeFromParent()
    end
    self.demonUnits = {}

    for k,v in pairs(self.demonHPProgresses) do
        v:removeFromParent()
        v:release()
    end
    self.demonHPProgresses = {}

    for k,v in pairs(self.petHPProgresses) do
        v:removeFromParent()
        v:release()
    end
    self.petHPProgresses = {}

    for k,v in pairs(self.petPowerProgresses) do
        v:removeFromParent()
        v:release()
    end
    self.petPowerProgresses = {}

    local pets = {}
    for k,pu in pairs(self.petUnits) do
        if pu:isDead() then
            pu.layout:removeFromParent()
        else
            pu.spine:setAnimation(1, "walk", true)
            pu.layout:runAction(cc.Sequence:create(cc.MoveBy:create(2.0, cc.p(360, 0)), cc.CallFunc:create(function()
                pu.layout:removeFromParent()
            end)))
            pets[pu.index] = pu.pet
        end
    end

    local winSize = cc.Director:getInstance():getWinSize()
    local mask = cc.LayerColor:create(cc.c4b(0, 0, 0, 255), winSize.width, winSize.height)
    mask:setAnchorPoint(cc.p(0, 0))
    mask:setPosition(cc.p(0, 0))
    self:addChild(mask, 100, 100)
    mask:setOpacity(0)
    mask:runAction(cc.Sequence:create(cc.DelayTime:create(1.8), 
                                      cc.FadeIn:create(0.2), 
                                      cc.DelayTime:create(0.2), 
                                      cc.FadeOut:create(0.2), 
                                      cc.CallFunc:create(function()
        mask:removeFromParent()
        self:restart()
       
        for k,pet in pairs(pets) do
            local petUnit = PetUnit:create(pet, k)
            petUnit.layout:setPosition(self.petPositions_[k])
            self.petUnits[k] = petUnit
            self.battleLayout:addChild(petUnit.layout, k)
        end
    end)))
end

function BattleUI:createHPProgress(i)
    if self.petUnits[i] == nil then
        return
    end
    local progImgName = TextureManager.RES_PATH.PROG_PET_HP .. ".png"
    local progBgImgName = TextureManager.RES_PATH.PROG_PET_HP .. "_background.png"
    local prog = CProgressBar:create()
    prog:setProgressSpriteFrameName(progImgName)
    prog:setBackgroundSpriteFrameName(progBgImgName)
    prog:setMaxValue(self.petUnits[i].maxHP)
    prog:setValue(self.petUnits[i].curHP)
    prog:setPosition(cc.p(self.petPositions_[i].x, self.petPositions_[i].y - 10))
    prog:retain()
    self.battleLayout:addChild(prog, 20)

    self.petHPProgresses[i] = prog
    self.petUnits[i].hpProgress = prog
end

function BattleUI:createPowerProgress(i)
    if self.petUnits[i] == nil then
        return
    end

    local progImgName = TextureManager.RES_PATH.PROG_PET_POWER
    local prog = CProgressBar:create()
    prog:setProgressSpriteFrameName(progImgName)
    local progBg = TextureManager.createImg(TextureManager.RES_PATH.PROG_PET_POWER_BACKGROUND, i)
    prog:setMaxValue(100)
    prog:setValue(0)
    prog:setPosition(cc.p(74, 10))
    progBg:addChild(prog, 0, TAG_POWER_PROG)

    progBg:setPosition(cc.p(self.petPositions_[i].x, self.petPositions_[i].y - 10))

    local powerLabel = CLabel:createWithTTF("0", "fonts/FZCuYuan/M03S.ttf", 18)
    powerLabel:enableOutline(cc.c4b(0, 0, 0, 160), 2);
    powerLabel:setPosition(cc.p(20, 13))
    progBg:addChild(powerLabel, 101, TAG_POWER_OPTION)

    -- for i=1,2 do
        local power_section = ConfigManager.getPetConfig(1).skill_energy_part
        local divider = TextureManager.createImg(TextureManager.RES_PATH.POWER_LEVEL_DIVIDER)
        divider:setPosition(cc.p(power_section[1]+ 20 , 10))
        progBg:addChild(divider, 102, TAG_POWER_DIVIDER +1)
    -- end

    progBg:retain()

    self.battleLayout:addChild(progBg, 20)
    self.petPowerProgresses[i] = progBg
    -- table.insert(self.petPowerProgresses,progBg)
end

function BattleUI:createSwitchAnim()
    if self.matrix == nil then
        return
    end
    local atlas = TextureManager.RES_PATH.SPINE_BATTLE_MODE_SWITCH .. ".atlas"
    local json = TextureManager.RES_PATH.SPINE_BATTLE_MODE_SWITCH .. ".json"
    local switchAnim = sp.SkeletonAnimation:create(json, atlas, 1)
    local matrixLayout = self.matrix:getLayout()
    local matrixSize = matrixLayout:getContentSize()

    switchAnim:registerSpineEventHandler(function(event)
        if event.type == "complete" then
            if event.animation == "part1" then
            elseif event.animation == "part3" then
                self.matrix:autoSwitch()
            end
        end
    end)
    switchAnim:setPosition(cc.p(matrixSize.width/2, matrixSize.height/2))
    matrixLayout:addChild(switchAnim, 100)

    self.switchAnim = switchAnim
    self.switchAnim:retain()
end

-- 切换到消除阶段，隐藏血条，显示能量条 怪物说话
function BattleUI:switchToEliminateMode()
    local dungeonType = StageRecord:getInstance():get("dungeonType")
    local chapter = StageRecord:getInstance():get("chapter")
    local stage = StageRecord:getInstance():get("stage")
    local activityType = {
        activity1 = 1,
        activity2 = 2,
        activity3 = 3,
    }
    local roundLimit
    if dungeonType == Constants.DUNGEON_TYPE.NORMAL then
        roundLimit = ConfigManager.getStageNormalConfig(chapter,stage).time_limit
    elseif dungeonType == Constants.DUNGEON_TYPE.ELITE then
        roundLimit = ConfigManager.getStageEliteConfig(chapter,stage).time_limit
    elseif dungeonType == Constants.DUNGEON_TYPE.ACTIVITY1  then
        roundLimit = ConfigManager.getActivityStageConfig(activityType.activity1,stage).time_limit
    elseif  dungeonType == Constants.DUNGEON_TYPE.ACTIVITY2 then
        roundLimit = ConfigManager.getActivityStageConfig(activityType.activity2,stage).time_limit
    elseif  dungeonType == Constants.DUNGEON_TYPE.ACTIVITY3 then
        roundLimit = ConfigManager.getActivityStageConfig(activityType.activity3,stage).time_limit
    end
    if self.curRound == roundLimit then
        self:finishBattle(false)
        return
    end
    
    if GuideManager.main_guide_phase_ > GuideManager.MAIN_GUIDE_PHASES.CAPTURE or self.mode ~= BATTLE_MODE.INIT_MODE  then
        if self.switchAnim == nil then
            self:createSwitchAnim()
        end
        self.switchAnim:setAnimation(0, "part3", false)
    end

    self.labelStepCount:setVisible(true)

    self.mode = BATTLE_MODE.SWITCH_MODE
    self.matrix:resumeMatrix()

    for k,prog in pairs(self.petHPProgresses) do
        prog:setVisible(false)
    end

    for i=1,PET_UNIT_COUNT do
        if self.petUnits[i] ~= nil then
            self.petUnits[i].power = 0
            if self.petPowerProgresses[i] == nil then
                self:createPowerProgress(i)
            end
            local prog = self.petPowerProgresses[i]
            -- if not self.petUnits[i]:isDead() then      --宠物死亡后精灵球也需要积攒能量
                prog:getChildByTag(TAG_POWER_PROG):setValue(0)
                prog:getChildByTag(TAG_POWER_OPTION):setString("0")
                prog:setVisible(true)
                -- for i=1, 2 do
                --     prog:getChildByTag(TAG_POWER_DIVIDER + i):setVisible(false)
                -- end
            -- end
        end
    end

    self.labelStepCount:setString("")
    self:runAction(cc.Sequence:create(cc.DelayTime:create(2.0), cc.CallFunc:create(function()
        if self.matrixMode == MATRIX_MODE.STEP_MODE then
            self.switchCount = 0
            self.labelStepCount:setString(string.format("剩余步数: %d", SWITCH_STEPS_PER_ROUND))
        elseif self.matrixMode == MATRIX_MODE.TIME_MODE then
            self.switchTimeLeft = SWITCH_TIME_PER_ROUND
            self.switchScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateSwitchTime, 1.0, false)
            battle_.labelStepCount:setString(string.format("剩余时间: %d秒", battle_.switchTimeLeft))
        end
        self.matrix:checkShuffle()
    end)))

    local pauseBtn = self:getControl(Tag_ui_battle.LAYOUT_TOP):getChildByTag(Tag_ui_battle.BTN_PAUSE)
    if GuideManager.main_guide_phase_ < GuideManager.MAIN_GUIDE_PHASES.STAGE_3  then
        pauseBtn:setVisible(false)
    else
        pauseBtn:setVisible(true)
    end
    -- self.labelTopOption:setVisible(false)
end

-- 切换到战斗阶段
-- 1. 播放切换动画
-- 2. 显示血条，隐藏能量条，隐藏暂停按钮，显示回合数
-- 3. 生成攻击队列
-- 4. 触发buff和debuff效果
-- 5. 激活下一个攻击单位
function BattleUI:switchToFightMode()
    -- self:finishBattle(true)
    -- 各步骤的时间
    local t_step1 = 1
    local t_step4 = 1.5
    self.mode = BATTLE_MODE.FIGHT_MODE
    self.labelStepCount:setVisible(false)

    -- 1. 播放切换动画
    if self.switchAnim == nil then
        self:createSwitchAnim()
    end
    if self.switchAnim then
        self.switchAnim:setAnimation(0, "part1", false)
        self.switchAnim:addAnimation(0, "part2", true)
    end

    -- 2. 显示血条，隐藏能量条，隐藏暂停按钮，显示回合数
    for k,prog in pairs(self.petPowerProgresses) do
        prog:setVisible(false)
    end

    if self.demonPowerProgresses then
        for k,prog in pairs(self.demonPowerProgresses) do
            prog:setVisible(false)
        end
    end

    for i=1,PET_UNIT_COUNT do
        if self.petUnits[i] ~= nil then
            if self.petHPProgresses[i] == nil then
                self:createHPProgress(i)
            end
            self.petHPProgresses[i]:setVisible(not self.petUnits[i]:isDead())
            -- if StageRecord:getInstance():get("dungeonType") ==Constants.DUNGEON_TYPE.ACTIVITY3 then
            --     for idx,pu in ipairs(self.petUnits) do
            --         self.petHPProgresses[i]:setValue(pu.curHP)
            --         self.petHPProgresses[i]:setMaxValue(pu.maxHP)
            --     end
            -- end
        end

        if self.demonUnits[i] ~= nil then
            if self.demonHPProgresses[i] ~= nil then
                self.demonHPProgresses[i]:setVisible(not self.demonUnits[i]:isDead())
            end
        end
    end
    if GuideManager.main_guide_phase_ > GuideManager.MAIN_GUIDE_PHASES.STAGE_3 and StageRecord:getInstance():get("dungeonType")~= Constants.DUNGEON_TYPE.PVP1 then
        local pauseBtn = self:getControl(Tag_ui_battle.LAYOUT_TOP):getChildByTag(Tag_ui_battle.BTN_PAUSE)
        pauseBtn:setVisible(true)
    end
    self.curRound = self.curRound + 1
    self.labelTopOption:setString(string.format("第%d/5回合", self.curRound))
    self.labelTopOption:setVisible(true)

    -- 3. 生成攻击队列
    self.unitQueue = {}

    local tmpPets = {}
    local tmpDemons = {}
    for i=1,PET_UNIT_COUNT do
        local petI = self.petUnits[i]
        local demonI = self.demonUnits[i]
        local petAvailable = (petI ~= nil and (petI.changeToBall or (not petI:isDead())))
        local demonAvailable = (demonI ~= nil and not demonI:isDead())
        if petAvailable then
            table.insert(tmpPets, petI)
        end
        if demonAvailable then
            table.insert(tmpDemons, demonI)
        end
    end

    for i=1,PET_UNIT_COUNT do
        local petI = tmpPets[i]
        local demonI = tmpDemons[i]
        if petI then
            if demonI then
                if petI:getPetAttribute(Constants.PET_ATTRIBUTE.SPEED) >= demonI:getPetAttribute(Constants.PET_ATTRIBUTE.SPEED) then
                    table.insert(self.unitQueue, petI)
                    table.insert(self.unitQueue, demonI)
                else
                    table.insert(self.unitQueue, demonI)
                    table.insert(self.unitQueue, petI)
                end
            else
                table.insert(self.unitQueue, petI)
            end
        elseif demonI then
            table.insert(self.unitQueue, demonI)
        end
    end

    -- 4. 战斗准备，如触发buff和debuff效果
    local ret = self:prepareUnitsForFight()

    -- 5. 激活下一个攻击单位
    -- 计算激活时间
    local delay = t_step1
    if ret then
        delay = delay + t_step4
    end
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function()
        print("-------------------------2   ")
        self:activateNext()
    end)))
end

function BattleUI:prepareUnitsForFight()
    local ret = false
    
    for k,petUnit in pairs(self.petUnits) do
        ret = petUnit:prepareToFight() or ret
    end

    for k,demonUnit in pairs(self.demonUnits) do
        ret = demonUnit:prepareToFight() or ret
    end

    return ret
end

function BattleUI:summonPets(forPet, positions)
    -- 目前只有怪物有召唤技能
    if not forPet then
        for i,v in ipairs(positions) do
            if v > 0 and self.demonUnits[i] == nil then
                local demonUnit = PetUnit:createAsDemon(v, i)
                local demonPos = self.petPositions_[(i + 2) % 6 + 1]
                demonPos = cc.p(demonPos.x + 360, demonPos.y)
                
                local progImgName = TextureManager.RES_PATH.PROG_PET_HP .. ".png"
                local progBgImgName = TextureManager.RES_PATH.PROG_PET_HP .. "_background.png"
                local progPos = cc.p(demonPos.x, demonPos.y - 10)
                local prog = CProgressBar:create()
                prog:setProgressSpriteFrameName(progImgName)
                prog:setBackgroundSpriteFrameName(progBgImgName)
                prog:setMaxValue(demonUnit.maxHP)
                prog:setValue(demonUnit.maxHP)
                prog:setPosition(progPos)
                self.demonHPProgresses[i] = prog
                prog:retain()
                self.battleLayout:addChild(prog, 20)

                demonUnit.layout:setPosition(demonPos)
                self.battleLayout:addChild(demonUnit.layout, i)
                demonUnit.spine:setAnimation(0, "emerge", false)
                self.demonUnits[i] = demonUnit
            end
        end
    end
end

function BattleUI:sendBattleEndCmd()
    local activity1token = Activity1StatusProxy:getInstance():get("token")
    local activity1Type = Activity1StatusProxy:getInstance():get("activity1Type")
    if self.result == 1 and #StageRecord:getInstance():get("pets") > 0 and GuideManager.main_guide_phase_ > GuideManager.MAIN_GUIDE_PHASES.STAGE_3 then
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
            self:capturePet()
        end)))
    else
        if StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY3 then
            local hpStr = ""
            for k,pu in pairs(battle_.petUnits) do
                pu.curHP = (pu.curHP > 0 and pu.curHP) or 0
                hpStr = hpStr .. pu.pet:get("id") .. "_" .. pu.curHP .. ","
            end
            hpStr = string.sub(hpStr, 1, -2)
            print("activity3 hp "..hpStr)
            NetManager.sendCmd("activity3battleend", onBattleEnd, self.result + 1, hpStr)
        elseif StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY1 then
            local petIds = Activity1StatusProxy:getInstance():get("pid")
            if self.result ~= 1 then
                MusicManager.battle_defeat()
                Utils.runUIScene("BattleDefeatPopup")
            else
                local function onActivity1Battleend(result)
                    Activity1StatusProxy:getInstance():set("score",result["score"])
                    Activity1StatusProxy:getInstance():set("token",result["token"]) 
                    local stageRecord = StageRecord:getInstance()
                    stageRecord:set("gold", result.gold - Player:getInstance():get("gold"))
                    stageRecord:set("exp", result.exp - Player:getInstance():get("exp"))
                    stageRecord:set("level", result.level - Player:getInstance():get("level"))  
                    local userInfo = {}
                    for i,v in ipairs({"gold", "energy", "exp", "level"}) do
                        userInfo[v] = result[v]
                    end
                    Debug.simplePrintTable(userInfo)
                    Player:getInstance():update(userInfo) 
                    
                    StageRecord:getInstance():set("petExps",result["pet_exps"])
                    MusicManager.battle_victory()
                    Utils.runUIScene("BattleVictoryPopup")
                end
                NetManager.sendCmd("activity1battleend", onActivity1Battleend,activity1Type,activity1token,petIds)
            end
        elseif StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY2 then
            for i,petUnit in ipairs(self.petUnits) do
                petUnit.maxHP = math.floor(petUnit.maxHP / 0.2)
            end
            for i,demonUnit in ipairs(self.demonUnits) do
                demonUnit.maxHP = math.floor(demonUnit.maxHP / 0.2)
            end
            local petIds = ""
            for k,v in pairs(battle_.petUnits) do
                petIds = petIds .. "," .. v.pet:get("id")
            end
            petIds = string.sub(petIds, 2, -1)
            NetManager.sendCmd("activity2battleend", onBattleEnd, (self.result > 0) and 3 or 0, petIds)
        else
            if GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.STAGE_1 or GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.STAGE_2  then
                local stype = 0
                local smId = 0
                local smAttackedTimes = 0
                if self.specialDemonUnit then
                    stype = self.specialDemonUnit:getType()
                    smId = self.specialDemonUnit.monsterId
                    smAttackedTimes = self.specialDemonUnit:getAttackedTimes()
                    print(stype, smId, smAttackedTimes)
                end
                local winStar = 3
                for i = 1,6 do
                    local petUnit = __instance.petUnits[i]
                    if petUnit then
                        local isdead = petUnit:isDead()
                        if isdead == true then
                            winStar =  winStar - 1
                            if winStar<=1 then
                               winStar = 1
                            end
                        end
                    end
                end
                StageRecord:getInstance():set("winStar" ,3) --星数
                NetManager.sendCmd("battleend", onBattleEnd, self.result, 3, ""..stype, ""..smId, ""..smAttackedTimes)
            elseif GuideManager.getMainGuidePhase() == GuideManager.MAIN_GUIDE_PHASES.CAPTURE then
                 Utils.dispatchCustomEvent("battle_end",{callback = function( )
                    Utils.runUIScene("CaptureInBattlePopup")
                 end, params = {chapter=1, stage=2}})
            else
                local stype = 0
                local smId = 0
                local smAttackedTimes = 0
                if self.specialDemonUnit then
                    stype = self.specialDemonUnit:getType()
                    smId = self.specialDemonUnit.monsterId
                    smAttackedTimes = self.specialDemonUnit:getAttackedTimes()
                    print(stype, smId, smAttackedTimes)
                end

                local winStar = 3
                for i = 1,6 do
                    local petUnit = __instance.petUnits[i]
                    if petUnit then
                        local isdead = petUnit:isDead()
                        if isdead == true then
                            winStar =  winStar - 1
                            if winStar<=1 then
                               winStar = 1
                            end
                        end
                    end
                end
                StageRecord:getInstance():set("winStar" ,winStar) --星数
                NetManager.sendCmd("battleend", onBattleEnd, self.result, winStar, ""..stype, ""..smId, ""..smAttackedTimes)
            end
        end
    end
end

function BattleUI:capturePet() 
    Utils.runUIScene("CaptureInBattlePopup")
end

function BattleUI:onCapturePet(event)
    if event._usedata ~= nil then
        local result = event._usedata.result
        if result.flag == 1 then
            Player:getInstance():update({diamond = result.diamond})
            -- todo: mark pet list as dirty, so that it would be reloaded when needed
        end
        ItemManager.updateItem(Constants.ITEM_TYPE.MATERIAL, result.ball_type, result.ball_num)
    end
    self:sendBattleEndCmd()
end

function BattleUI:finishBattle(win)
    if win then
        for k,pu in pairs(self.petUnits) do
            pu:removeAllBuffDebuff()
            pu:win()
        end
    else
        for k,du in pairs(self.demonUnits) do
            du:removeAllBuffDebuff()
            du:win()
        end
    end
    self.result = win and 1 or 0

    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
        self:sendBattleEndCmd()
    end)))
end

-- 结束单回合战斗
-- 1. 其他操作(如某些buff&debuff在会合结束时触发)
-- 2. 切换到交换模式
function BattleUI:finishRound()
    -- 1. 其他操作(如某些buff&debuff在会合结束时触发)
    for k,pu in pairs(self.petUnits) do
        pu:clearBuffDebuff()
    end
    for k,du in pairs(self.demonUnits) do
        du:clearBuffDebuff()
    end

    -- 2. 切换到交换模式
    self:switchToEliminateMode()
end

function BattleUI:finishSwitchPhase()
    if not self.matrix:clearSpecialUnits() then
        self.matrix:pauseMatrix()
        self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function()
            self:switchToFightMode()
        end)))
    end
end

function BattleUI:activateNext()
    -- 判断战斗状态
    -- 如果所有宠物都已经死亡则战斗失败
    -- self:finishBattle(true)
    print("111111111")
    local lost = true
    for k,pu in pairs(self.petUnits) do
        if not pu:isDead() then
            lost = false
            break
        end
    end
    if lost then
        self:finishBattle(false)
        return
    end

    -- won表示消灭当前波的所有怪物
    local won = true
    if won then
        for k,du in pairs(self.demonUnits) do
            if not du:isDead() then
                won = false
                break
            end
        end
    end

    -- 如果当前波所有的怪物都已经被消灭，则开始下一波
    if won then
        print("wave finished, init next wave of demons")
        local ret = self:initDemons(self.wave + 1)
        -- 如果初始化下一波怪物失败，说明战斗胜利，否则切换到消除模式
        if not ret then
            self:finishBattle(true)
            return
        else
            self:finishRound()
            return
        end
    end

    if #self.unitQueue == 0 then
        self:finishRound()
        return
    end

    local unit = self.unitQueue[1]
    -- todo: 判断是否满足连击条件
    if unit and unit:isReady() then
        local targets = unit:findTargets(self.petUnits, self.demonUnits)

        if targets == nil or #targets == 0 then
            print("2222222")
            -- if unit.isPet then
            --     local ret = self:initDemons(self.wave + 1)
            --     if not ret then
            --         self:finishBattle(true)
            --     else
            --         self:finishRound()
            --     end
            -- else
            --     self:finishBattle(false)
            -- end
            table.remove(self.unitQueue, 1)
            -- self:activateNext()
        else          
          -- 播放技能名特效，如果是大招，需要播放完技能名特效之后再释放
            local skillId = unit:getSkillConfig().id
            print("skillId = "..skillId)
            local portrait = TextureManager.createImg(TextureManager.RES_PATH.PET_PORTRAIT, unit.model)

            if unit:getValidSkillIndex() == 2 and portrait and unit.isPet then    --只有两个技能的宠物其第二个技能不是大招
                local t1 = 0.15 / speed
                local t2 = 0.75 / speed
                local t3 = 0.3 / speed
                
                local portraitY = self.superSkillNameEffectPosition.y + 40
                local portraitX1 = self.superSkillNameEffectPosition.x - 100
                local portraitX2 = self.superSkillNameEffectPosition.x - 20
                local portraitX3 = self.superSkillNameEffectPosition.x + 20
                local portraitX4 = self.superSkillNameEffectPosition.x + 40
                portrait:setPosition(cc.p(portraitX1, portraitY))
                portrait:setOpacity(125)
                self.effectLayout:addChild(portrait, SKILL_NAME_ZRODER + 1)

                portrait:runAction(cc.Sequence:create(
                    cc.Spawn:create(cc.FadeTo:create(t1, 255), cc.MoveTo:create(t1, cc.p(portraitX2, portraitY))),
                    cc.MoveTo:create(t2, cc.p(portraitX3, portraitY)),
                    cc.Spawn:create(cc.FadeOut:create(t3), cc.MoveTo:create(t3, cc.p(portraitX4, portraitY)))
                ))

                local skillNamelabel = CLabel:createWithTTF(TextManager.getPetSkillName(skillId), "fonts/FZCuYuan/M03S.ttf", 48)
                local labelY = self.skillNameEffectPosition.y
                local labelX1 = self.skillNameEffectPosition.x + 60
                local labelX2 = self.skillNameEffectPosition.x + 10
                local labelX3 = self.skillNameEffectPosition.x - 10
                local labelX4 = self.skillNameEffectPosition.x - 20
                skillNamelabel:enableOutline(cc.c4b(0xff, 0x99, 0, 255), 2)
                skillNamelabel:setPosition(cc.p(labelX1, labelY))
                self.effectLayout:addChild(skillNamelabel, SKILL_NAME_ZRODER + 2)

                skillNamelabel:runAction(cc.Sequence:create(
                    cc.Spawn:create(cc.FadeIn:create(t1), cc.MoveTo:create(t1, cc.p(labelX2, labelY))),
                    cc.MoveTo:create(t2, cc.p(labelX3, labelY)),
                    cc.Spawn:create(cc.FadeOut:create(t3), cc.MoveTo:create(t3, cc.p(labelX4, labelY)))
                ))

                self.skillNameEffect:setPosition(self.superSkillNameEffectPosition)
                self.skillNameEffect:setAnimation(0, "part2", false)
                self.skillNameEffect:setTimeScale(0.6)
                self.skillNameEffect:runAction(cc.Sequence:create(cc.DelayTime:create(1.3 / speed), cc.CallFunc:create(function()
                    self.skillNameEffect:removeFromParent()
                    skillNamelabel:removeFromParent()
                    unit:activate()
                end)))
                self.effectLayout:addChild(self.skillNameEffect, SKILL_NAME_ZRODER)

            elseif unit:activate() then
                local skillNamelabel = CLabel:createWithTTF(TextManager.getPetSkillName(skillId), "fonts/FZCuYuan/M03S.ttf", 28)
                skillNamelabel:enableOutline(cc.c4b(0, 0, 0, 166), 2);
                skillNamelabel:setPosition(self.skillNameEffectPosition)
                self.effectLayout:addChild(skillNamelabel, SKILL_NAME_ZRODER + 1)

                skillNamelabel:runAction(cc.Sequence:create(
                    cc.FadeIn:create(0.2 / speed),
                    cc.DelayTime:create(0.5 / speed),
                    cc.FadeOut:create(0.3 / speed)
                ))

                self.skillNameEffect:setPosition(self.skillNameEffectPosition)
                self.skillNameEffect:setAnimation(0, "part1", false)
                self.skillNameEffect:runAction(cc.Sequence:create(cc.DelayTime:create(1.3 / speed), cc.CallFunc:create(function()
                    self.skillNameEffect:removeFromParent()
                    skillNamelabel:removeFromParent()
                end)))
                self.effectLayout:addChild(self.skillNameEffect, SKILL_NAME_ZRODER)
                print("skillname = "..TextManager.getPetSkillName(skillId))
            end

            if unit.isPet then
                self.petHPProgresses[unit.index]:setVisible(false)
            else
                self.demonHPProgresses[unit.index]:setVisible(false)
            end
        end
    else
        table.remove(self.unitQueue, 1)
        self:activateNext()
    end
end

function BattleUI:onEliminate(event)
    local eu = event._usedata
    local colorIndex = eu.colorIndex
    if colorIndex > PET_UNIT_COUNT then
        return
    end

    local petUnit = self.petUnits[colorIndex]
    if petUnit == nil then--or petUnit:isDead() then
        return
    end

    local emitter = cc.ParticleSystemQuad:create(TextureManager.RES_PATH.PARTICLE_POWER_STAR)
    local startPos = eu:getParent():convertToWorldSpace(cc.p(eu:getPosition()))
    startPos = self:convertToNodeSpace(startPos)
    startPos.x = startPos.x + Constants.UNIT_SIZE.width/2
    startPos.y = startPos.y + Constants.UNIT_SIZE.height/2
    emitter:setPosition(startPos)
    self.effectLayout:addChild(emitter)

    local targetPos = self.petPositions_[colorIndex]
    targetPos.y = targetPos.y
    local t = cc.pGetDistance(targetPos, startPos)/800/speed
    emitter:runAction(cc.Sequence:create(
        cc.JumpTo:create(t, targetPos, 50, 1), 
        cc.CallFunc:create(function()
            self:assemblePower(colorIndex)
        end), 
        cc.DelayTime:create(0.2), 
        cc.CallFunc:create(function()
            emitter:removeFromParent()
        end)
    ))
end

function BattleUI:onSwitch(event)
    local matchCount = self.matrix.getMatchCount()
    if matchCount >= 3 then
        if matchCount >=7 then
            self.spineCombo:setAnimation(0, "amazing", false)
            MusicManager.amazing()
        elseif matchCount >= 5 then
            self.spineCombo:setAnimation(0, "wonderful", false)
            MusicManager.wonderful()
        else
            self.spineCombo:setAnimation(0, "good", false)
            MusicManager.good()
        end
        self.effectLayout:addChild(self.spineCombo, 2)
        self.spineCombo:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function()
            self.spineCombo:removeFromParent()
        end)))
    end
    self.matrix:resetMatchCount()

    if self.matrixMode == MATRIX_MODE.STEP_MODE then
        self.switchCount = self.switchCount + 1
        local leftSteps = math.max(SWITCH_STEPS_PER_ROUND - self.switchCount, 0)
        self.labelStepCount:setString(string.format("剩余步数: %d", leftSteps))
        if leftSteps == 0 then
            self:finishSwitchPhase()
            return
        end
    elseif self.matrixMode == MATRIX_MODE.TIME_MODE then
        if self.switchTimeLeft <= 0 then
            self:finishSwitchPhase()
            if self.switchScheduler  ~= nil then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.switchScheduler)
                self.switchScheduler = nil
            end
            return
        end
    end

    self.matrix:checkShuffle()
end

function BattleUI:onUnitAct(event)
    local action = event._usedata
    local unit = action.unit
    print("reveive unit event", unit.isPet, unit.index, action.name)
    if action.name == "skill_effect" then
        print("skill_effect event")
        -- 显示特效
        local effects = unit:getAttackEffects()
        if effects == nil or #effects == 0 then
            print("received effect event but get no effect")
        end
        if effects then
            for i,e in ipairs(effects) do
                self.effectLayout:addChild(e, SKILL_EFFECT_ZORDER)
            end
        end
    elseif action.name == "action_effect" then
        local actionEffect = unit:getActionEffects()
        if actionEffect then
            for i,e in ipairs(actionEffect) do
                self.effectLayout:addChild(e, SKILL_EFFECT_ZORDER+1)
            end
        end
    elseif action.name == "target_effect" then
        -- 显示目标特效
        local effects = unit:getTargetEffects(action.targets)
        if effects then
            for i,e in ipairs(effects) do
                self.effectLayout:addChild(e, SKILL_EFFECT_ZORDER)
            end
        end

    elseif action.name == "super_skill_effect" then
        local effects = unit:getSuperSkillEffects()
        if effects then
            local superSkillLayout =  CLayout:create()
            superSkillLayout:setAnchorPoint(cc.p(0, 0))
            superSkillLayout:setPosition(cc.p(0, 0))
            superSkillLayout:retain()
            if superSkillLayout:getParent() == nil then
                self.battleLayout:addChild(superSkillLayout,-1)
            end
            for i,e in ipairs(effects) do
                superSkillLayout:addChild(e, 1)
            end
        end
    elseif action.name == "hit" then
        -- MusicManager.playPetHitEffect()
        local targets = action.targets
        for i,target in ipairs(targets) do
            if not target:isDead() then
                -- 
                print(" 计算伤害 ")
                local damage, isCrit
                local skillConfig = unit:getSkillConfig()
                local skillType = skillConfig.skill_type
                if skillType == 1 then
                    damage, isCrit = target:getDamage(unit)
                    print("***************************************** 实际伤害 ＝ "..damage)
                    target:attacked(damage)

                    -- 如果怪物死亡，判断是否需要掉落奖励
                    if not target.isPet and target:isDead() then
                        self.monstersDefeated = self.monstersDefeated + 1
                        self:dropReward(target)
                    end
                    -- 播放特效
                    self:playHitEffect(target, damage, isCrit)
                elseif skillType == 2 then
                    damage, isCrit = target:getHeal(unit)
                    damage = damage * self.healFactor
                    target:healed(damage)
                    damage = -damage
                    -- 播放特效
                    self:playHitEffect(target, damage, isCrit)
                end
            end
        end
    elseif action.name == "dark_start" then
        local layout = CLayout:create()
        local size =self.battleLayout:getContentSize()
        layout:setContentSize(size)
        layout:setPosition(cc.p(size.width/2,size.height/2))
        layout:setBackgroundColor(cc.c4b(0, 0, 0, 120))
        self.battleLayout:addChild(layout,1)
        layout:setScale(3)
        layout:setTag(4096)
    elseif action.name == "dark_end" then
        -- self.battleLayout:setBackgroundColor(cc.c4b(0, 0, 0, 0))
        self.battleLayout:removeChildByTag(4096)
    elseif action.name == "shake" then
        local bg = self:getControl(Tag_ui_battle.LAYOUT_BG)

        local actionBy_1 = cc.MoveBy:create(0.1, cc.p(0,-20))
        local actionByBack_1 = actionBy_1:reverse()
        local move_ease_in_1 = cc.EaseBackIn:create(actionBy_1)
        local move_ease_in_back_1 = move_ease_in_1:reverse()

        local actionBy_2 = cc.MoveBy:create(0.1, cc.p(0,-10))
        local actionByBack_2 = actionBy_2:reverse()
        local move_ease_out_1 = cc.EaseBackOut:create(actionBy_2)
        local move_ease_out_back_1 = move_ease_out_1:reverse()
        self.battleLayout:runAction(cc.Sequence:create(move_ease_in_1,move_ease_in_back_1,move_ease_out_1,move_ease_out_back_1,
                                                       move_ease_in_1,move_ease_in_back_1,move_ease_out_1,move_ease_out_back_1))

        local actionBy_3 = cc.MoveBy:create(0.1, cc.p(0,-20))
        local actionByBack_3 = actionBy_3:reverse()
        local move_ease_in_2 = cc.EaseBackIn:create(actionBy_3)
        local move_ease_in_back_2 = move_ease_in_2:reverse()

        local actionBy_4 = cc.MoveBy:create(0.1, cc.p(0,-10))
        local actionByBack_4 = actionBy_4:reverse()
        local move_ease_out_2 = cc.EaseBackOut:create(actionBy_4)
        local move_ease_out_back_2 = move_ease_out_2:reverse()
        bg:runAction(cc.Sequence:create(move_ease_in_2,move_ease_in_back_2,move_ease_out_2,move_ease_out_back_2,
                                        move_ease_in_2,move_ease_in_back_2,move_ease_out_2,move_ease_out_back_2))
        
        local actionBy_5 = cc.MoveBy:create(0.1, cc.p(0,-20))
        local actionByBack_5 = actionBy_5:reverse()
        local move_ease_in_3 = cc.EaseBackIn:create(actionBy_5)
        local move_ease_in_back_3 = move_ease_in_3:reverse()

        local actionBy_6 = cc.MoveBy:create(0.1, cc.p(0,-10))
        local actionByBack_6 = actionBy_6:reverse()
        local move_ease_out_3 = cc.EaseBackOut:create(actionBy_6)
        local move_ease_out_back_3 = move_ease_out_3:reverse()
        self.effectLayout:runAction(cc.Sequence:create(move_ease_in_3,move_ease_in_back_3,move_ease_out_3,move_ease_out_back_3,
                                                       move_ease_in_3,move_ease_in_back_3,move_ease_out_3,move_ease_out_back_3))
    elseif action.name == "finish" then
        if unit:isActive() then
            -- 处理buff&debuff
            unit:handleBuffDebuff()
            -- 技能特殊效果
            unit:handleSkillExtraEffect(self.petUnits, self.demonUnits)

            unit:disactivate()
            unit.layout:runAction(cc.Sequence:create(cc.DelayTime:create(ACTIVATE_INTERVAL / speed), cc.CallFunc:create(function()
                table.remove(self.unitQueue, 1)
                if unit.isPet then
                    self.petHPProgresses[unit.index]:setVisible(not unit:isDead())
                else
                    self.demonHPProgresses[unit.index]:setVisible(not unit:isDead())
                end
                self:activateNext()
            end)))
        elseif unit:isDead() then
            self:activateNext()
        end
    elseif action.name == "die" then
        MusicManager.playPetDieEffect()
        -- if unit.isPet then
        --     self.petHPProgressess[unit.index]:setVisible(false)
        -- else
        --     self.demonHPProgresses[unit.index]:setVisible(false)
        -- end
    end
end

-- 攻击targets，如果targets为nil，则根据isPet攻击pet或demon一方全部单位
function BattleUI:attackAll(targets, isPet, damage)
    if targets == nil then
        targets = isPet and self.petUnits or self.demonUnits
    end
    for i=1, PET_UNIT_COUNT do
        local target = targets[i]
        if target and not target:isDead() then
            target:attacked(damage)
            -- 如果怪物死亡，判断是否需要掉落奖励
            if not target.isPet and target:isDead() then
                self.monstersDefeated = self.monstersDefeated + 1
                self:dropReward(target)
            end
            -- 播放特效
            self:playHitEffect(target, damage, false)
        end
    end
end

function BattleUI:playHitEffect(target, damage, isCrit)
    -- 更新血条
    local prog = nil
    if target.isPet then
        prog = self.petHPProgresses[target.index]
    else
        prog = self.demonHPProgresses[target.index]
    end
    if target.curHP > 0 and prog ~= nil then
        prog:setValue(target.curHP)
    elseif prog ~= nil then
        prog:setVisible(false)
    end

    -- 播放掉血／回血动画
    local damageLabel
    if damage == 0.01 then
        damageLabel = TextureManager.createImg(TextureManager.RES_PATH.IMG_MISS)
    elseif damage >= 0 then
        damageLabel = (isCrit and TextureManager.getNumberLabelAtlas(TextureManager.ATLAS_FONTS.CRIT_DAMAGE, damage, 32) ) or TextureManager.getNumberLabelAtlas(TextureManager.ATLAS_FONTS.DAMAGE, damage, 25)
    elseif damage < 0 then
        damageLabel = TextureManager.getNumberLabelAtlas(TextureManager.ATLAS_FONTS.HEAL, -damage, 25)
    end
    local damagePos = cc.p(target.layout:getPosition())
    damagePos.y = damagePos.y + 70
    damageLabel:setPosition(damagePos)
    damageLabel:setOpacity(0)
    self.effectLayout:addChild(damageLabel, DAMAGE_ZORDER)
    if isCrit then
        damageLabel:runAction(cc.Spawn:create(
            cc.EaseExponentialOut:create(cc.MoveBy:create(0.5 / speed, cc.p(0, 50))),
            cc.Sequence:create(
                cc.FadeIn:create(0.1 / speed),
                cc.DelayTime:create(0.2 / speed),
                cc.FadeOut:create(0.2 / speed),
                cc.CallFunc:create(function()
                    damageLabel:removeFromParent()
                end)
            ),
            cc.Sequence:create(
                cc.ScaleTo:create(0.2 / speed, 1.5),
                cc.ScaleTo:create(0.3 / speed, 1.0)
            )))
    else
        damageLabel:runAction(cc.Spawn:create(cc.EaseExponentialOut:create(cc.MoveBy:create(0.5 / speed, cc.p(0, 50))),
            cc.Sequence:create(
                cc.FadeIn:create(0.1 / speed),
                cc.DelayTime:create(0.2 / speed),
                cc.FadeOut:create(0.2 / speed),
                cc.CallFunc:create(function()
                    damageLabel:removeFromParent()
                end)
            )))
    end

    -- 播放通用被打击特效
    if damage > 0 then
        local atlas = TextureManager.RES_PATH.SPINE_HIT .. ".atlas"
        local json = TextureManager.RES_PATH.SPINE_HIT .. ".json"
        local hitSpine = sp.SkeletonAnimation:create(json, atlas, 1)
        hitSpine:setTimeScale(speed)
        hitSpine:setAnimation(10, "part1", false)
        hitSpine:setPosition(cc.p(target.layout:getPosition()))
        self.effectLayout:addChild(hitSpine, DAMAGE_ZORDER)
    end
end

function BattleUI:assemblePower(colorIndex)   --积攒能量，宠物死亡后精灵球也需要积攒能量
    local petUnit = self.petUnits[colorIndex]
    if petUnit == nil then--or petUnit:isDead() then
        return
    end

    local oldLevel = petUnit:getPowerLevel()
    petUnit:assemblePower(5)

    local newLevel = petUnit:getPowerLevel()
    if newLevel > oldLevel then
        -- SPINE_POWER_BREAKTHROUGH
        local atlas = TextureManager.RES_PATH.SPINE_POWER_BREAKTHROUGH .. ".atlas"
        local json = TextureManager.RES_PATH.SPINE_POWER_BREAKTHROUGH .. ".json"
        local spine = sp.SkeletonAnimation:create(json, atlas, 1)
        spine:setTimeScale(speed)
        spine:setAnimation(10, "level"..newLevel, true)
        spine:setPosition(cc.p(petUnit.layout:getPosition()))
        spine:runAction(cc.Sequence:create(cc.DelayTime:create(0.7 / speed), cc.CallFunc:create(function()
            spine:removeFromParent()
        end)))
        self.effectLayout:addChild(spine)
        self.petPowerProgresses[colorIndex]:getChildByTag(TAG_POWER_DIVIDER + oldLevel):setVisible(true)
    end

    local atlas = TextureManager.RES_PATH.SPINE_POWER_ARRIVE .. ".atlas"
    local json = TextureManager.RES_PATH.SPINE_POWER_ARRIVE .. ".json"
    local spine = sp.SkeletonAnimation:create(json, atlas, 1)
    spine:setTimeScale(speed)
    spine:setAnimation(10, "part1", false)
    spine:setPosition(cc.p(petUnit.layout:getPosition()))
    spine:runAction(cc.Sequence:create(cc.DelayTime:create(0.5 / speed), cc.CallFunc:create(function()
        spine:removeFromParent()
    end)))
    self.effectLayout:addChild(spine)

    self.petPowerProgresses[colorIndex]:getChildByTag(TAG_POWER_PROG):setValue(petUnit.power)
    self.petPowerProgresses[colorIndex]:getChildByTag(TAG_POWER_OPTION):setString(""..petUnit.power)
end

function BattleUI:onTriggerBuffDebuff(event)
    local target = event._usedata.target
    local damage = event._usedata.damage
    local effect = event._usedata.effect

    print("trigger buff or debuff", target, damage, effect)
    if damage ~= 0 then
        if damage > 0 then
            target:attacked(damage)
        else
            damage = damage * self.healFactor
            target:healed(-damage * self.healFactor)
        end
        self:playHitEffect(target, damage, false)
    end
    local curRound = self.curRound
    if (effect ~= nil) and (effect:getParent() == nil) and (not target:isDead()) then
        effect:setPosition(target.layout:getPosition())
        self.effectLayout:addChild(effect, BUFF_DEBUFF_ZORDER)
    end
    -- target:handleBuffDebuff()
end

function BattleUI:onRemoveBuffDebuff(event)
    local target = event._usedata.target
    local damage = event._usedata.damage
    local effect = event._usedata.effect
    -- if damage ~= 0 then
    --     if damage > 0 then
    --         target:attacked(damage)
    --     else
    --         target:healed(damage)
    --     end
    --     self:playHitEffect(target, damage, false)
    -- end
    -- local curRound = self.curRound
    if effect ~= nil then
        print("********* remove debuff ***********")
        -- effect:setPosition(target.layout:getPosition())
        effect:removeFromParent()
        -- self.effectLayout:addChild(effect, BUFF_DEBUFF_ZORDER)
    end
end

function BattleUI:restart()
    self:cleanup()
    self:init()
end

function BattleUI:getPetPosition()
    return __instance.petPositions_
end

function BattleUI:resume()
    self.matrix:resumeMatrix()
end

-- 初始化第wave波怪
function BattleUI:initDemons(wave)
    for k,du in pairs(self.demonUnits) do
        du.layout:removeFromParent()
        du:cleanup()
    end
    self.demonUnits = {}

    for k,v in pairs(self.demonHPProgresses) do
        v:removeFromParent()
        v:release()
    end
    self.demonHPProgresses = {}

    local demonIds

    if demonIds ~= nil then
        demonIds = nil
    end

    print("init demons", StageRecord:getInstance():get("dungeonType"), StageRecord:getInstance():get("chapter"), StageRecord:getInstance():get("stage"), wave)

    local dungeonType = StageRecord:getInstance():get("dungeonType") or 1
    local chapter = StageRecord:getInstance():get("chapter") or 1
    local stage = StageRecord:getInstance():get("stage") or 1

    if dungeonType == Constants.DUNGEON_TYPE.ACTIVITY1 then
        demonIds = ConfigManager.getDungeonConfig(dungeonType,1, stage).monsters[wave]
    elseif dungeonType == Constants.DUNGEON_TYPE.ACTIVITY2 then
        demonIds = ConfigManager.getDungeonConfig(dungeonType, 2, stage).monsters[wave]
    elseif dungeonType == Constants.DUNGEON_TYPE.ACTIVITY3 then
        demonIds = ConfigManager.getDungeonConfig(dungeonType,3, stage).monsters[wave]
    else
        demonIds = ConfigManager.getDungeonConfig(dungeonType, chapter, stage).monsters[wave]
    end
    -- print("demonIds = "..demonIds)
    if demonIds == nil then
        print("init demons fail: ", dungeonType, chapter, stage, wave)
        return false
    else
        print("init demons success: ", dungeonType, chapter, stage, wave)
    end
    self.wave = wave

    for i,v in ipairs(demonIds) do
        if v > 0 then
            local demonUnit
            if v > 2000 and v < 3000 then
                -- 如果是特殊怪物，判断是否是第一次过关
                local stageRecord = StageRecord:getInstance()
                -- if true then
                if not Player:getInstance():isStagePassed(stageRecord:get("dungeonType") or 1, stageRecord:get("chapter") or 1, stageRecord:get("stage") or 1) then
                    demonUnit = SpecialDemon:create(v, i)
                    print(" specialDemonUnit ")
                    self.specialDemonUnit = demonUnit
                end
            else
                demonUnit = PetUnit:createAsDemon(v, i)
            end

            if demonUnit then
                local demonPos = self.petPositions_[(i + 2) % 6 + 1]
                demonPos = cc.p(demonPos.x + 360, demonPos.y)
                
                if self.mode ~= BATTLE_MODE.INIT_MODE then
                    local progImgName = TextureManager.RES_PATH.PROG_PET_HP .. ".png"
                    local progBgImgName = TextureManager.RES_PATH.PROG_PET_HP .. "_background.png"
                    local progPos = cc.p(demonPos.x, demonPos.y - 10)
                    if demonUnit.isBoss then
                        progImgName = TextureManager.RES_PATH.PROG_BOSS_HP .. ".png"
                        progBgImgName = TextureManager.RES_PATH.PROG_BOSS_HP .. "_background.png"
                        progPos.y = progPos.y - 20
                    end
                    local prog = CProgressBar:create()
                    prog:setProgressSpriteFrameName(progImgName)
                    prog:setBackgroundSpriteFrameName(progBgImgName)
                    prog:setMaxValue(demonUnit.maxHP)
                    prog:setValue(demonUnit.maxHP)
                    prog:setPosition(progPos)
                    prog:retain()
                    self.battleLayout:addChild(prog, 20)

                    prog:setVisible(false)
                    prog:runAction(cc.Sequence:create(cc.DelayTime:create(0.5 / speed), cc.CallFunc:create(function()
                        prog:setVisible(true)
                    end)))

                    self.demonHPProgresses[i] = prog
                    demonUnit.hpProgress = prog
                end

                demonUnit.layout:setPosition(demonPos)
                self.battleLayout:addChild(demonUnit.layout, i)
                demonUnit:start()
                self.demonUnits[i] = demonUnit
            end
        end
    end

    return true
end

function BattleUI:create()
    local ret = BattleUI.new()
    __instance = ret
    ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
    ret:setOnExitSceneScriptHandler(function() ret:onExitScene() end)
    return ret
end

function BattleUI:getControl(tagControl)
    return self.uiPanel:getChildByTag(tagControl)
end

function BattleUI:getPanel(tagPanel)
    local ret = nil
    if tagPanel == Tag_ui_battle.PANEL_BATTLE then
        ret = self:getChildByTag(tagPanel)
    end
    return ret
end

function BattleUI:initBackground()
    local stage = StageRecord:getInstance():get("stage")
    local bg = self:getControl(Tag_ui_battle.LAYOUT_BG)
    local bgName
    if StageRecord:getInstance():get("dungeonType") <= 2 then
        bgName = ConfigManager.getChpaterMapName(StageRecord:getInstance():get("chapter"))
        bgName = "map/"..bgName.."_battle.jpg"
    elseif StageRecord:getInstance():get("dungeonType")==Constants.DUNGEON_TYPE.ACTIVITY1 then
        bgName = ConfigManager.getActivityStageConfig(1,stage).map
        bgName = "map/" .. bgName .. "_battle.jpg"
    elseif StageRecord:getInstance():get("dungeonType")==Constants.DUNGEON_TYPE.ACTIVITY2 then
        bgName = ConfigManager.getActivityStageConfig(2,stage).map
        bgName = "map/" .. bgName .. "_battle.jpg"
    elseif StageRecord:getInstance():get("dungeonType")==Constants.DUNGEON_TYPE.ACTIVITY3 then
        bgName = ConfigManager.getActivityStageConfig(3,stage).map
        bgName = "map/" .. bgName .. "_battle.jpg"
    elseif StageRecord:getInstance():get("dungeonType")==Constants.DUNGEON_TYPE.PVP1 then
        bgName = ConfigManager.getPvp1CommonConfig('pvp_map')
        bgName = "map/" .. bgName .. ".jpg"
    else
        bgName = string.format(TextureManager.RES_PATH.BATTLE_BG, 1, 1)
    end
    bg:setBackgroundImage(bgName)
    
    local bottomLayout = self:getControl(Tag_ui_battle.LAYOUT_BOTTOM)
    local bottomBg = bottomLayout:getChildByTag(Tag_ui_battle.LAYOUT_BOTTOM_BG)
    bottomBg:setBackgroundColor(cc.c4b(114, 63, 35, 255))
end

function BattleUI:initDrag()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)
    
    listener:registerScriptHandler(function(touch, event)
        draggingPetSpine_ = nil
        touchStarted = true
        local touchPos = self:convertTouchToNodeSpace(touch)
        -- 延迟开始拖拽，以保证可以获得点击的目标
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.02), cc.CallFunc:create(function()
            if touchStarted then 
                print("start "..touchPos.x,touchPos.y)
                if touchPos.x > 0 and touchPos.x < 290 and touchPos.y > 200 and touchPos.y < 830 then
                    leaveTeam = true 
                end
                startDrag(touchPos)
            end
        end)))
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN )

    listener:registerScriptHandler(function(touch, event)
        if draggingPetSpine_ ~= nil then
            local pos = self:convertTouchToNodeSpace(touch)
            pos.y = pos.y - 40
            draggingPetSpine_:setPosition(pos)
            testDraggingPosition()
        end
    end, cc.Handler.EVENT_TOUCH_MOVED)

    listener:registerScriptHandler(function(touch, event)
        local touchPos = self:convertTouchToNodeSpace(touch)
        print("end "..touchPos.x.."     "..touchPos.y)
        touchStarted = false
        
        if leaveTeam and touchPos.x > 0 and touchPos.y < 260 then
            print(" 允许下阵 ")
            leaveTeams()
        end
        stopDrag()
    end, cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    self.dragListener = listener
end

function BattleUI:showPetGridView(page)
    local gvPet = self:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.LAYOUT_DEPLOY):getChildByTag(Tag_ui_battle.GV_PETS)
    local gvCotent = getPetGvContent()

    local nextPageBtn = self:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.LAYOUT_DEPLOY):getChildByTag(Tag_ui_battle.BTN_NEXT_PAGE)
    local lastPageBtn = self:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.LAYOUT_DEPLOY):getChildByTag(Tag_ui_battle.BTN_LAST_PAGE)
    local startIndex = (page - 1) * PET_PER_PAGE
    local endIndex = page * PET_PER_PAGE - 1
    local total = #gvCotent
    local curPageCount = (total > (page * PET_PER_PAGE)) and PET_PER_PAGE or (total - startIndex)

    if page < 1 or startIndex > total then
        return
    end

    self.petGridPage = page

    lastPageBtn:setVisible(startIndex > 0)
    nextPageBtn:setVisible(endIndex <= total)

    petGvContent = nil
    gvPet:setCountOfCell(curPageCount)
    gvPet:setDataSourceAdapterScriptHandler(event_adapt_gvpet)
    gvPet:setSizeOfCell(cc.size(112, 122))
    gvPet:reloadData()
    gvPet:setDragable(false)
end

-- 初始化战斗单元（宠物，敌人等）
function BattleUI:initBattleLayout()
    -- if #self.circles == 0 then
        self.circles = {}
        self.petPositions_ = {}
        for i=1,6 do
            local circle = self:getControl(Tag_ui_battle["IMG_CIRCLE_"..i])
            circle:setVisible(true)
            circle:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.75, 76.5), cc.FadeTo:create(0.75, 255))))

            local circlePos = circle:getParent():convertToWorldSpace(cc.p(circle:getPosition()))
            circlePos = self:convertToNodeSpace(circlePos)
            table.insert(self.circles, circle)
            table.insert(self.petPositions_, circlePos)
        end
    -- end
    if self.battleLayout == nil then
        self.battleLayout = self:getControl(Tag_ui_battle.LAYOUT_BATTLE)
        -- self.battleLayout:setAnchorPoint(cc.p(0, 0))
        -- self.battleLayout:setContentSize(cc.Director:getInstance():getWinSize())
        -- self.battleLayout:setPosition(cc.p(0, 0))
        -- self:addChild(self.battleLayout, 1)
    else
        -- self.battleLayout:removeAllChildren()
    end

    -- self.pets = {}
    self:initDemons(1)

    -- todo: add pets from saved team
    if StageRecord:getInstance():get("dungeonType") ~= Constants.DUNGEON_TYPE.ACTIVITY3 then
        local savedTeamStr
        if NET_MODE then
            local keyStr = __instance:getUserDefaultKey()
            if keyStr then
                savedTeamStr = Utils.userDefaultGet(keyStr)
            end
        else
            savedTeamStr = "{1, 2, 3, 4, 5}"
        end
        if savedTeamStr ~= nil and savedTeamStr ~= "" then
            local petsFromTeam = Utils.stringToTable(savedTeamStr)
            for i,v in ipairs(petsFromTeam) do
                if v ~= 0 then
                    local pet
                    if NET_MODE then
                        pet = ItemManager.getPetById(v)
                    else
                        pet = Pet:create()
                        pet:set("id", id)
                        pet:set("mid", v)
                        pet:set("form", 1)
                        pet:set("aptitude", 1)
                    end
                    if pet ~= nil and GuideManager.main_guide_phase_ ~= GuideManager.MAIN_GUIDE_PHASES.STAGE_3 then
                        local petUnit = PetUnit:create(pet, i)
                        petUnit.layout:setPosition(self.petPositions_[i])
                        -- petUnit.layout:retain()
                        petUnit.layout:setTag(4000+i)
                        self.petUnits[i] = petUnit
                        self.battleLayout:addChild(petUnit.layout, i)
                    else
                        cc.UserDefault:getInstance():setStringForKey("pokemon_team_1"..Player:getInstance():get("uid").."_", "")

                    end
                end
            end
        end
    end
end


-- 初始化事件监听：单个单元消除事件event_eliminate，交换成功操作：event_switch
function BattleUI:initEventListeners()
    local eliminateListener = cc.EventListenerCustom:create("event_eliminate", function(event) 
        self:onEliminate(event)
    end)
    self.eliminateListener = eliminateListener
    self:getEventDispatcher():addEventListenerWithFixedPriority(eliminateListener, 1)

    local switchListener = cc.EventListenerCustom:create("event_switch", function(event) 
        self:onSwitch(event)
    end)
    self.switchListener = switchListener
    self:getEventDispatcher():addEventListenerWithFixedPriority(switchListener, 1)

    local unitActionListener = cc.EventListenerCustom:create("event_unit_act", function(event) 
        self:onUnitAct(event)
    end)
    self.unitActionListener = unitActionListener
    self:getEventDispatcher():addEventListenerWithFixedPriority(unitActionListener, 1)

    local restartListener = cc.EventListenerCustom:create("event_restart_battle", function(event) 
        self:restart()
    end)
    self.restartListener = restartListener
    self:getEventDispatcher():addEventListenerWithFixedPriority(restartListener, 1)

    local resumeListener = cc.EventListenerCustom:create("event_resume_battle", function(event) 
        self:resume()
    end)
    self.resumeListener = resumeListener
    self:getEventDispatcher():addEventListenerWithFixedPriority(resumeListener, 1)

    local captureListener = cc.EventListenerCustom:create("event_battle_capture", function(event) 
        self:onCapturePet(event)
    end)
    self.captureListener = captureListener
    self:getEventDispatcher():addEventListenerWithFixedPriority(captureListener, 1)
    
    local debuffListener = cc.EventListenerCustom:create("event_trigger_buff_debuff", function(event) 
        self:onTriggerBuffDebuff(event)
    end)
    self.debuffListener = debuffListener
    self:getEventDispatcher():addEventListenerWithFixedPriority(debuffListener, 1)

    local rmdebuffListener = cc.EventListenerCustom:create("event_remove_buff_debuff", function(event) 
        self:onRemoveBuffDebuff(event)
    end)
    self.rmdebuffListener = rmdebuffListener
    self:getEventDispatcher():addEventListenerWithFixedPriority(rmdebuffListener, 1)

    local effectListener = cc.EventListenerCustom:create("event_battle_effect", function(event)
        local data = event._usedata
        self:addEffect(data.effect, data.pos, data.zorder, data.time)
    end)
    self.effectListener = effectListener
    self:getEventDispatcher():addEventListenerWithFixedPriority(effectListener, 1)

    local attackAllListener = cc.EventListenerCustom:create("event_attack_all", function(event)
        local data = event._usedata
        self:attackAll(data.targets, data.isPet, data.damage)
    end)
    self.attackAllListener = attackAllListener
    self:getEventDispatcher():addEventListenerWithFixedPriority(attackAllListener, 1)

    local summonPetListener = cc.EventListenerCustom:create("event_summon_pets", function(event)
        local data = event._usedata
        self:summonPets(data.for_pet, data.positions)
    end)
    self.summonPetListener = summonPetListener
    self:getEventDispatcher():addEventListenerWithFixedPriority(summonPetListener, 1)
    
end

function BattleUI:addEffect(effect, pos, zorder, time)
    effect:setPosition(pos)
    if zorder then
        effect:setLocalZOrder(zorder)
    end
    self.effectLayout:addChild(effect)
    if time then
        self.effectLayout:runAction(cc.Sequence:create(cc.DelayTime:create(time / speed), cc.CallFunc:create(function()
            effect:removeFromParent()
        end)))
    end
end

function BattleUI:clearSpines()
    local sc = SpineCache:getInstance()
    local resources = {}
    for _,v in ipairs(cachedSpines) do
        table.insert(resources, v.spine)
        sc:removeSpine(v.key)
    end
    
    ResourceManager.removeResources(resources)
end

function BattleUI:cleanup()
    -- todo: test whether this function is invoked

    self.battleLayout:removeAllChildren()
    self.effectLayout:removeAllChildren()
    print("battle ui cleanup")
    if self.petUnits then
        for k,pu in pairs(self.petUnits) do
            pu:cleanup()
        end
        pu = nil
    end

    if self.petHPProgresses then
        for k,v in pairs(self.petHPProgresses) do
            v:release()
        end
    end
    self.petHPProgresses = nil

    if self.petPowerProgresses then
        for k,v in pairs(self.petPowerProgresses) do
            -- v:release()
        end
        self.petPowerProgresses = nil
    end

    if self.switchAnim then
        self.switchAnim:release()
        self.switchAnim = nil
    end

    if self.matrix then
        self.matrix:cleanup()
        self.matrix = nil
    end

    if self.skillNameEffect then
        self.skillNameEffect:release()
        self.skillNameEffect = nil
    end

    if self.spineCombo ~= nil then
        self.spineCombo:release()
        self.spineCombo = nil
    end

    if self.switchScheduler ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.switchScheduler)
        self.switchScheduler = nil
    end

    self:getEventDispatcher():removeEventListener(self.dragListener)
    self:getEventDispatcher():removeEventListener(self.eliminateListener)
    self:getEventDispatcher():removeEventListener(self.switchListener)
    self:getEventDispatcher():removeEventListener(self.unitActionListener)
    self:getEventDispatcher():removeEventListener(self.restartListener)
    self:getEventDispatcher():removeEventListener(self.resumeListener)
    self:getEventDispatcher():removeEventListener(self.captureListener)
    self:getEventDispatcher():removeEventListener(self.debuffListener)
    self:getEventDispatcher():removeEventListener(self.effectListener)
    self:getEventDispatcher():removeEventListener(self.rmdebuffListener)
    self:getEventDispatcher():removeEventListener(self.attackAllListener)
    self:getEventDispatcher():removeEventListener(self.summonPetListener)
    self:getEventDispatcher():removeEventListener(self.moveToNextListener)

    petGvContent = nil

    self:clearSpines()
end

function BattleUI:onExitScene()
    self:cleanup()
end

function BattleUI:init()
    local stageRecord = StageRecord:getInstance()
    self.petUnits = {}
    self.demonUnits = {}
    self.circles = {}
    self.petHPProgresses = {}
    self.demonHPProgresses = {}
    self.petPowerProgresses = {}
    self.demonHPProgresses = {}
    self.unitQueue = {}
    self.captureQueue = {}
    self.rewardQueue = {}
    self.mode = BATTLE_MODE.INIT_MODE
    self.curRound = 0

    self.labelRewardCount:setString("0")
    self.labelTopOption:setString("第1/5回合")

    self.labelStepCount:setVisible(false)
    self.labelDeployOption:setVisible(true)

    self:initBackground()
    self:initBattleLayout()
    self:initDrag()
    self:initEventListeners()

    self.effectLayout = self.effectLayout or CLayout:create()
    self.effectLayout:setAnchorPoint(cc.p(0, 0))
    self.effectLayout:setPosition(cc.p(0, 0))
    self.effectLayout:retain()
    if self.effectLayout:getParent() == nil then
        self:addChild(self.effectLayout,3)
    end
    self:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.LAYOUT_DEPLOY):setVisible(true)
    if StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY3 then
        self.labelDeployOption:setString("请上阵5级以上的宠物")
        local imgChest = self:getControl(Tag_ui_battle.LAYOUT_TOP):getChildByTag(Tag_ui_battle.IMG_REWARD_COUNT_BG)
        imgChest:setVisible(false)
        self.labelRewardCount:setVisible(false)

        local layoutTop = self:getControl(Tag_ui_battle.LAYOUT_TOP)
        local labActivity3Floor = layoutTop:getChildByTag(Tag_ui_battle.LAB_ACTIVITY3_FLOOR)
        labActivity3Floor:setString(" 第".. PyramidProxy:getInstance():get("floor") .."层 ")
        
        local function loadHPHandler(result)
            self.hpInfo = result.hpInfo
            if self.hpInfo == nil then
                local msg = "您当前没有符合条件的宠物，必须上阵20级以上的宠物！"
                TipManager.showTip(msg)
            else
                Debug.simplePrintTable(self.hpInfo)
                self:showPetGridView(1)
            end
        end
        NetManager.sendCmd("loadactivity3pethp", loadHPHandler)
    else
        local layoutTop = self:getControl(Tag_ui_battle.LAYOUT_TOP)
        local labActivity3Floor = layoutTop:getChildByTag(Tag_ui_battle.LAB_ACTIVITY3_FLOOR)
        labActivity3Floor:setVisible(false)
        self:showPetGridView(1)
    end
    if StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY2 then
        self.matrixMode = Activity2Handler:getInstance():getMatrixMode()
        local effect = Activity2Handler:getInstance():getEffect()
        if effect ~= nil then
            self.battleLayout:addChild(effect, TOP_ZORDER)
        end
    end
    -- 技能名特效和连击特效
    local atlas = TextureManager.RES_PATH.SPINE_SKILL_NAME_EFFECT .. ".atlas"
    local json = TextureManager.RES_PATH.SPINE_SKILL_NAME_EFFECT .. ".json"
    self.skillNameEffect = sp.SkeletonAnimation:create(json, atlas, 1)
    self.skillNameEffect:setTimeScale(speed)
    self.skillNameEffect:retain()
    atlas = TextureManager.RES_PATH.SPINE_BATTLE_COMBO .. ".atlas"
    json = TextureManager.RES_PATH.SPINE_BATTLE_COMBO .. ".json"
    self.spineCombo = sp.SkeletonAnimation:create(json, atlas, 1)
    self.spineCombo:setTimeScale(speed)
    self.spineCombo:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2, self.skillNameEffectPosition.y - 150))
    self.spineCombo:retain()
end

function BattleUI:onLoadScene()
    cc.Director:getInstance():getTextureCache():removeAllTextures()
    
    battle_ = self
    -- add ui
    TuiManager:getInstance():parseScene(self, "panel_battle", PATH_UI_BATTLE)
    self.uiPanel = self:getPanel(Tag_ui_battle.PANEL_BATTLE)
    self.labelStepCount = self:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.LAYOUT_MATRIX_FRAME):getChildByTag(Tag_ui_battle.LABEL_BOTTOM_STEP_COUNT)
    self.labelDeployOption = self:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.LAYOUT_MATRIX_FRAME):getChildByTag(Tag_ui_battle.LABEL_BOTTOM_DEPLOY_OPTION)
    self.labelRewardCount = self:getControl(Tag_ui_battle.LAYOUT_TOP):getChildByTag(Tag_ui_battle.LABEL_REWARD_COUNT)
    self.labelTopOption = self:getControl(Tag_ui_battle.LAYOUT_TOP):getChildByTag(Tag_ui_battle.LABEL_TOP_OPTION)
    Utils.floatToBottom(self:getControl(Tag_ui_battle.LAYOUT_BOTTOM))
    Utils.floatToTop(self:getControl(Tag_ui_battle.LAYOUT_TOP))

    self.skillNameEffectPosition = self:convertToNodeSpace(self.labelDeployOption:getParent():convertToWorldSpace(cc.p(self.labelDeployOption:getPosition())))
    self.superSkillNameEffectPosition = cc.p(cc.Director:getInstance():getWinSize().width/2, 500)

    self:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.LAYOUT_DEPLOY):getChildByTag(Tag_ui_battle.BTN_START_BATTLE):setOnClickScriptHandler(startBattleHandler)

    -- 自动
    local stage = StageRecord:getInstance():get("stage")
    local autoBtn = self:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.BTN_AUTO)
    if stage == 5 and  GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.TREASURE_CHEST) == false then
        Utils.userDefaultSet("auto_status", "0")
        Utils.userDefaultSet("anim_speed","1.0")
    elseif stage == 8 and  GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.GREEDY_CAT) == false then
        Utils.userDefaultSet("auto_status", "0")
        Utils.userDefaultSet("anim_speed","1.0")
    end

    local storedAutoStatus = Utils.userDefaultGet("auto_status")
    autoStatus = storedAutoStatus or "0"
    if autoStatus == "1" then
        autoBtn:setNormalSpriteFrameName("ui_battle/btn_manual_normal.png")
    else
        autoBtn:setNormalSpriteFrameName("ui_battle/btn_auto_normal.png")
    end
    autoBtn:setOnClickScriptHandler(function()
        self:toggleAutoStatus()
    end)

    -- 加速
    local speedUpBtn = self:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.BTN_SPEED_X2)

    local storedSpeed = Utils.userDefaultGet("anim_speed")
    speed = storedSpeed and tonumber(storedSpeed) or 1.0
    if speed == 1.0 then
        speedUpBtn:setNormalSpriteFrameName("ui_battle/btn_speed_x1_normal.png")
    elseif speed == 2.0 then
        speedUpBtn:setNormalSpriteFrameName("ui_battle/btn_speed_x2_normal.png")
    elseif speed == 3.0 then
        speedUpBtn:setNormalSpriteFrameName("ui_battle/btn_speed_x3_normal.png")
    end
    speedUpBtn:setOnClickScriptHandler(function()
        self:toggleAnimSpeed()
    end)

    local pauseBtn = self:getControl(Tag_ui_battle.LAYOUT_TOP):getChildByTag(Tag_ui_battle.BTN_PAUSE)
    if GuideManager.main_guide_phase_ < GuideManager.MAIN_GUIDE_PHASES.STAGE_3  then
        pauseBtn:setVisible(false)
    else
        pauseBtn:setVisible(true)
    end

    pauseBtn:setOnClickScriptHandler(function()
        MusicManager.playBtnClickEffect()
        if self.matrix then
            self.matrix:pauseMatrix()
        end
        Utils.runUIScene("BattlePausePopup")
    end)
    
    local nextPageBtn = self:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.LAYOUT_DEPLOY):getChildByTag(Tag_ui_battle.BTN_NEXT_PAGE)
    nextPageBtn:setOnClickScriptHandler(function()
        self:showPetGridView(self.petGridPage + 1)
    end)

    local lastPageBtn = self:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.LAYOUT_DEPLOY):getChildByTag(Tag_ui_battle.BTN_LAST_PAGE)
    lastPageBtn:setScaleX(-1)
    lastPageBtn:setOnClickScriptHandler(function()
        self:showPetGridView(self.petGridPage - 1)
    end)

    self:init()
    MusicManager.battlebackground()
    local function onNodeEvent(event)
        if "enter" == event then
            -- MusicManager.battlebackground()
            -- local dungeonType = 1
            local chapter = 1
            local stage = StageRecord:getInstance():get("stage")
            local petContent = ItemManager.getItemsByType(1)
            local petIds = petContent[1]:get("id")
            local savedTeamStr = "{1,8,9,10,11}"
            local petsFromTeam = Utils.stringToTable(savedTeamStr)
            if StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.PVP1 then
                self:getControl(Tag_ui_battle.LAYOUT_TOP):getChildByTag(Tag_ui_battle.BTN_PAUSE):setVisible(false)
            end
            if GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.STAGE_1 or GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.STAGE_2 then
                local speedUpBtn = self:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.BTN_SPEED_X2)
                local autoBtn = self:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.BTN_AUTO)
                Utils.userDefaultSet("auto_status", "0")
                autoBtn:setEnabled(false)

                Utils.userDefaultSet("anim_speed","1.0")
                speedUpBtn:setEnabled(false)

                for i,v in ipairs(petsFromTeam) do
                    if v ~= 0 then
                        local pet
                        local gvCotent = {}
                        local config = ConfigManager.getGuidePetConfig(v)
                        local pet = Pet:create()
                        pet:set("id", i)
                        pet:set("mid", config.mid)
                        pet:set("star", 5)
                        if ConfigManager.getPetFormConfig(config.mid, 3) then
                            pet:set("form",3)
                        elseif ConfigManager.getPetFormConfig(config.mid, 2) then
                            pet:set("form",2)
                        else
                            pet:set("form",1)
                        end
                        pet:set("aptitude",config.aptitude)
                        pet:set("attributeGrowths",config.grow_random)
                        table.insert(gvCotent,pet)
                       
                        if pet ~= nil and i ~= 1 then
                            local petUnit = PetUnit:create(pet, i)
                            petUnit.layout:setPosition(self.petPositions_[i])
                            self.petUnits[i] = petUnit
                            self.battleLayout:addChild(petUnit.layout, i)
                            petUnit.layout:setVisible(false)
                            
                        elseif i == 1 then
                            local petContent = ItemManager.getItemsByType(1)
                            print(petContent[1]:get("id") )
                            local petUnit = PetUnit:create(petContent[1], 1)
                            petUnit.layout:setTag(3001)
                            petUnit.layout:setPosition(self.petPositions_[1])
                            self.petUnits[1] = petUnit
                            self.battleLayout:addChild(petUnit.layout, 1)
                        end
                    end
                end
                -- preloadAnimations(function()
                    -- NetManager.sendCmd("battlestart", onBattleStart, 1, 1, stage, petIds)
                -- end)

                __instance.labelDeployOption:setString("")
                __instance:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.LAYOUT_DEPLOY):setVisible(false)

                self.matrix = Matrix:create({1, 2, 3, 4, 5})
                self:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.LAYOUT_MATRIX):addChild(__instance.matrix:getLayout())
                self.matrix:checkShuffle()
                self.matrix:pauseMatrix()
            end
            if stage == 5 and GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.TREASURE_CHEST) == false then
                
            end
        elseif "enterTransitionFinish"  == event then
            print(" enterTransitionFinish ")
            StageRecord:getInstance():set("old_level",Player:getInstance():get("level")) 
            local stage = StageRecord:getInstance():get("stage") 

            if GuideManager.main_guide_phase_ >= GuideManager.MAIN_GUIDE_PHASES.STAGE_1  and GuideManager.main_guide_phase_ <= GuideManager.MAIN_GUIDE_PHASES.STAGE_3  then

                local pauseBtn = self:getControl(Tag_ui_battle.LAYOUT_TOP):getChildByTag(Tag_ui_battle.BTN_PAUSE)
                pauseBtn:setVisible(false)
                local function enter_view()
                    if GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.STAGE_1 or GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.STAGE_2  then

                        local savedTeamStr = "{1,8,9,10,11}"
                        local petsFromTeam = Utils.stringToTable(savedTeamStr)
                        local petContent = ItemManager.getItemsByType(1)
                        local petIds = petContent[1]:get("id")
                       
                        for i,v in ipairs(petsFromTeam) do
                            self.petUnits[i] = nil
                            local pet
                            local gvCotent = {}
                            local config = ConfigManager.getGuidePetConfig(v)
                            local pet = Pet:create()
                            pet:set("id", i)
                            pet:set("mid", config.mid)
                            pet:set("aptitude",config.aptitude)
                            pet:set("star",5)
                            -- local petConfig = ConfigManager.getPetFormConfig(config.mid, 3)
                            if ConfigManager.getPetFormConfig(config.mid, 3) then
                                pet:set("form",3)
                            elseif ConfigManager.getPetFormConfig(config.mid, 2) then
                                pet:set("form",2)
                            else
                                pet:set("form",1)
                            end
                            pet:set("attributeGrowths",config.grow_random)
                            battle_.battleLayout:removeChildByTag(3001)
                            if i == 1 then
                                local petContent = ItemManager.getItemsByType(1)
                                local petUnit = PetUnit:create(petContent[1], 1)
                                petUnit.layout:setPosition(self.petPositions_[1])
                                self.petUnits[1] = petUnit
                                self.battleLayout:addChild(petUnit.layout, 1)
                            elseif i > 1 then
                                local petUnit = PetUnit:create(pet, i)
                                petUnit.layout:setPosition(self.petPositions_[i])
                                self.petUnits[i] = petUnit
                                battle_.battleLayout:addChild(petUnit.layout, i)
                                petUnit.layout:setVisible(false)
                            end
                        end

                        preloadAnimations(function()
                            NetManager.sendCmd("battlestart", function(result)
                                for k,pu in pairs(self.petUnits) do
                                    if pu.index ~= 1 then
                                        pu.layout:setVisible(true)
                                        pu.layout:removeFromParent(false)
                                        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3 * math.floor(pu.index / 3)), cc.CallFunc:create(function()
                                            pu.layout:setPosition(self.petPositions_[k])
                                            self.battleLayout:addChild(pu.layout, 1)
                                            pu:start()
                                        end)))
                                    -- else
                                        -- pu.layout:setVisible(true)
                                        -- pu:start()
                                    end
                                end

                                prepareBattle()
                                onBattleStart(result)
                                if stage == 1 then
                                    Utils.dispatchCustomEvent("event_enter_view",{view = "BattleUI",phase = GuideManager.MAIN_GUIDE_PHASES.STAGE_1 ,scene = self})
                                elseif stage == 2 then
                                     Utils.dispatchCustomEvent("event_enter_view",{view = "BattleUI",phase = GuideManager.MAIN_GUIDE_PHASES.STAGE_2 ,scene = self})
                                end
                            end, 1, 1, stage, petIds)
                        end)

                    else
                        Utils.dispatchCustomEvent("event_enter_view",{view = "BattleUI",phase = GuideManager.MAIN_GUIDE_PHASES.STAGE_3,scene = self})
                    end
                end
                print("=manager==" .. GuideManager.main_guide_phase_-2)
                Utils.dispatchCustomEvent("enter_view",{callback = enter_view, params = {view = "battle", chapter=1, stage=StageRecord:getInstance():get("stage")}})
            else
                Utils.dispatchCustomEvent("enter_view",{callback = enter_view, params = {view = "battle", chapter=StageRecord:getInstance():get("chapter"), stage=StageRecord:getInstance():get("stage")}})
            end
          
        elseif "exit" == event then
            MusicManager.mainMusic() 
            if self.addBattlePetListener then
                self:getEventDispatcher():removeEventListener(self.addBattlePetListener)
                self.addBattlePetListener = nil
            end
            if self.listenerBattlePet then
                self:getEventDispatcher():removeEventListener(self.listenerBattlePet)
                self.listenerBattlePet = nil
            end
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function BattleUI:getAnimSpeed()
    return speed
end

function BattleUI:toggleAnimSpeed() --战斗加速
    MusicManager.playBtnClickEffect()
    local speed2 = ConfigManager.getUserCommonConfig('fight_speed2') --2倍加速解锁 主角等级
    local speed3 = ConfigManager.getRechargeCommonConfig('vip_level_fight_speed3')
    local speedUpBtn = self:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.BTN_SPEED_X2)
    if speed == 1.0 then
        if Player:getInstance():get("level")<speed2 and Player:getInstance():get("vip")<speed3 then
            TipManager.showTip("主角等级达到" ..speed2 .. "时解锁")
        else
            speedUpBtn:setNormalSpriteFrameName("ui_battle/btn_speed_x2_normal.png")
            speed = 2.0
        end
    elseif speed == 2.0 then
        speed = 3.0
        if  Player:getInstance():get("vip")<speed3 then
            speedUpBtn:setNormalSpriteFrameName("ui_battle/btn_speed_x1_normal.png")
            speed = 1.0
        else
            speedUpBtn:setNormalSpriteFrameName("ui_battle/btn_speed_x3_normal.png")
            speed = 3.0
        end
    elseif speed == 3.0 then
        speedUpBtn:setNormalSpriteFrameName("ui_battle/btn_speed_x1_normal.png")
        speed = 1.0
    end
    for i = 1, 6 do
        if self.petUnits[i] then
            self.petUnits[i].spine:setTimeScale(speed)
        end
        if self.demonUnits[i] then
            self.demonUnits[i].spine:setTimeScale(speed)
        end
    end
    Utils.userDefaultSet("anim_speed", speed)
end

function BattleUI:getAutoStatus()
    return autoStatus
end

function BattleUI:toggleAutoStatus() --自动战斗
    MusicManager.playBtnClickEffect()
    local autoVipLimit = ConfigManager.getRechargeCommonConfig('vip_level_auto_fight') 
    if Player:getInstance():get("vip")< autoVipLimit then
        TipManager.showTip("VIP达到等级" .. autoVipLimit .. "解锁")
        return
    end
    local autoBtn = self:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.BTN_AUTO)
    autoStatus = (autoStatus ~= "1") and "1" or "0"
    if autoStatus == "1" then
        autoBtn:setNormalSpriteFrameName("ui_battle/btn_manual_normal.png")
    else
        autoBtn:setNormalSpriteFrameName("ui_battle/btn_auto_normal.png")
    end
    Utils.userDefaultSet("auto_status", autoStatus)
    if self.matrix then
        self.matrix:autoSwitch()
    end
end

function BattleUI:getUserDefaultKey()
    local dungeonType = StageRecord:getInstance():get("dungeonType")
    if dungeonType == Constants.DUNGEON_TYPE.NORMAL or dungeonType == Constants.DUNGEON_TYPE.ELITE then
        return "pve_team"
    elseif dungeonType == Constants.DUNGEON_TYPE.ACTIVITY1 or dungeonType == Constants.DUNGEON_TYPE.ACTIVITY2 then
        return "activity_team"
    elseif dungeonType == Constants.DUNGEON_TYPE.PVP1 then
        return "pvp1_team"
    end
    return nil
end