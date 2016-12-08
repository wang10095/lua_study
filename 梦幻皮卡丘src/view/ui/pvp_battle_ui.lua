PvPBattleUI = class("PvPBattleUI",function()
    return BattleUI:create()
end)

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

local BOTTOM_ANIM_TRACK = 100
local BOTTOM_ANIM_ZORDER = 100

---- local constants
local PET_RECT_SIZE = 100
local PET_UNIT_COUNT = 6
local SWITCH_STEPS_PER_ROUND = 5
local SWITCH_TIME_PER_ROUND = 5

local TAG_POWER_PROG = 0
local TAG_POWER_OPTION = 10
local TAG_POWER_DIVIDER = 20
local TAG_DARK_BG = 100
local PET_PER_PAGE = 10

local SKILL_EFFECT_ZORDER = 1
local BUFF_DEBUFF_ZORDER = 2
local DAMAGE_ZORDER = 3
local SKILL_NAME_ZRODER = 4

---- local variables
local battle_ = nil
local selectedPetCell_ = nil
local selectedPetUnit_ = nil
local touchStarted = false
local draggingPetSpine_ = nil
local petPositions_ = nil
local enemyPositions_ = nil
local skillNameEffectPosition_ = nil
local superSkillNameEffectPosition_ = nil
local petSelect = nil
local changePet = false
local petGvContent = nil
local enemyPets_ = nil
local enemyUid_ = nil

PvPBattleUI.demonPowerProgresses = nil
PvPBattleUI.bottomAnim = nil

-- local functions

local function startBattleHandler(pSender)
    
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

    for k,petUnit in pairs(__instance.petUnits) do
        petUnit.changeToBall = false
    end
    Stagedataproxy:getInstance():set("startBattle",true)
    Utils.userDefaultSet(__instance:getUserDefaultKey(), str);
    Player:getInstance():set("pvp1_battle_team",str)
    NetManager.sendCmd("pvp1battlestart", function(result)
        __instance:onBattleStart(result)
    end, enemyUid_)
end

function PvPBattleUI:onBattleStart(result)
    self.labelDeployOption:removeFromParent()
    self:getControl(Tag_ui_battle.LAYOUT_TOP):getChildByTag(Tag_ui_battle.BTN_PAUSE):setVisible(false)
    for i= 1,6 do
       local circle = self:getControl(Tag_ui_battle["IMG_CIRCLE_"..i])
       -- circle:removeAllChild()
       circle:setVisible(false)
    end
    self:switchToEliminateMode()
end

function PvPBattleUI:create()
    local ret = PvPBattleUI.new()
    __instance = ret
    ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
    ret:setOnExitSceneScriptHandler(function() ret:onExitScene() end)
    return ret
end

function PvPBattleUI:init()
    self.petUnits = {}
    self.demonUnits = {}
    self.circles = {}
    self.petHPProgresses = {}
    self.demonHPProgresses = {}
    self.petPowerProgresses = {}
    self.demonHPProgresses = {}
    self.demonPowerProgresses = {}
    self.unitQueue = {}
    self.captureQueue = {}
    self.rewardQueue = {}
    self.mode = BATTLE_MODE.INIT_MODE
    self.curRound = 0

    self.labelTopOption:setString()
    self.labelTopOption:setVisible(false)
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
        self:addChild(self.effectLayout,2)
    end

    self:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.LAYOUT_DEPLOY):setVisible(true)

    self:showPetGridView(1)

    -- 技能名特效和连击特效
    local atlas = TextureManager.RES_PATH.SPINE_SKILL_NAME_EFFECT .. ".atlas"
    local json = TextureManager.RES_PATH.SPINE_SKILL_NAME_EFFECT .. ".json"
    self.skillNameEffect = sp.SkeletonAnimation:create(json, atlas, 1)
    self.skillNameEffect:retain()

    atlas = TextureManager.RES_PATH.SPINE_BATTLE_COMBO .. ".atlas"
    json = TextureManager.RES_PATH.SPINE_BATTLE_COMBO .. ".json"
    self.spineCombo = sp.SkeletonAnimation:create(json, atlas, 1)
    self.spineCombo:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2, self.skillNameEffectPosition.y - 150))
    self.spineCombo:retain()
end

function PvPBattleUI:onLoadScene()
    battle_ = self
    -- add ui
    TuiManager:getInstance():parseScene(self, "panel_battle", PATH_UI_BATTLE)
    self.uiPanel = self:getPanel(Tag_ui_battle.PANEL_BATTLE)
    self.labelDeployOption = self:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.LAYOUT_MATRIX_FRAME):getChildByTag(Tag_ui_battle.LABEL_BOTTOM_DEPLOY_OPTION)
    self.labelTopOption = self:getControl(Tag_ui_battle.LAYOUT_TOP):getChildByTag(Tag_ui_battle.LABEL_TOP_OPTION)
    self.labelStepCount = self:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.LAYOUT_MATRIX_FRAME):getChildByTag(Tag_ui_battle.LABEL_BOTTOM_STEP_COUNT)
    
    local labActivity3Floor = self:getControl(Tag_ui_battle.LAYOUT_TOP):getChildByTag(Tag_ui_battle.LAB_ACTIVITY3_FLOOR)
    labActivity3Floor:setVisible(false)
    self:getControl(Tag_ui_battle.LAYOUT_TOP):getChildByTag(Tag_ui_battle.IMG_REWARD_COUNT_BG):removeFromParent()
    self:getControl(Tag_ui_battle.LAYOUT_TOP):getChildByTag(Tag_ui_battle.LABEL_REWARD_COUNT):removeFromParent()

    Utils.floatToBottom(self:getControl(Tag_ui_battle.LAYOUT_BOTTOM))
    Utils.floatToTop(self:getControl(Tag_ui_battle.LAYOUT_TOP))

    self.skillNameEffectPosition = self:convertToNodeSpace(self.labelDeployOption:getParent():convertToWorldSpace(cc.p(self.labelDeployOption:getPosition())))
    self.superSkillNameEffectPosition = cc.p(cc.Director:getInstance():getWinSize().width/2, 500)

    self:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.LAYOUT_DEPLOY):getChildByTag(Tag_ui_battle.BTN_START_BATTLE):setOnClickScriptHandler(startBattleHandler)

    local pauseBtn = self:getControl(Tag_ui_battle.LAYOUT_TOP):getChildByTag(Tag_ui_battle.BTN_PAUSE)
    pauseBtn:setVisible(false)
    -- pauseBtn:setOnClickScriptHandler(function()
    --     if self.mode == BATTLE_MODE.FIGHT_MODE then
    --         return
    --     end
    --     Utils.runUIScene("BattlePausePopup")
    -- end)

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
    self:initDemons(0)
end

function PvPBattleUI:getInstance()
    if (not __instance) then
        __instance = LoadScene("PvPBattleUI")
    end
    return __instance;
end

PvPBattleUI.setEnemy = function(uid, enemyPets)
    print("pvp battle", enemyPets)
    enemyPets_ = enemyPets
    enemyUid_ = uid
    -- self:initDemons(0)
end

function PvPBattleUI:initDemons(wave)
    if wave > 1 then
        return
    end
    if enemyPets_ then
        self:initEnemyPets()
    end
end

function PvPBattleUI:initEnemyPets()
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

    for i,v in ipairs(enemyPets_) do

        Debug.simplePrintTable(v)
        local pet = Pet:create()
        pet:update(v)
        print(" 位置 ＝ "..v.location," 宠物 ＝ "..pet:get("mid"))
        local demonUnit = PetUnit:createAsDemon(nil, v.location, pet)

        if demonUnit then
            local demonPos = self.petPositions_[(v.location + 2)%6 + 1]
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
            self.demonHPProgresses[v.location] = prog
            prog:retain()
            self.battleLayout:addChild(prog, 20)

            prog:setVisible(false)

            demonUnit.layout:setPosition(demonPos)
            self.battleLayout:addChild(demonUnit.layout, v.location)
            demonUnit:start()
            self.demonUnits[v.location] = demonUnit
        end
    end

    return true
end

function PvPBattleUI:createPowerProgress(isPet, i)
    local progImgName = TextureManager.RES_PATH.PROG_PET_POWER
    local prog = CProgressBar:create()
    prog:setProgressSpriteFrameName(progImgName)
    local progBg = TextureManager.createImg(TextureManager.RES_PATH.PROG_PET_POWER_BACKGROUND, i)
    prog:setMaxValue(100)
    prog:setValue(0)
    prog:setPosition(cc.p(74, 10))
    progBg:addChild(prog, 0, TAG_POWER_PROG)

    local position
    if isPet then
        position = cc.p(self.petPositions_[i])
    else
        position = cc.p(self.petPositions_[(i + 2)%6 + 1])
        position.x = position.x + 360
    end
    progBg:setPosition(cc.p(position.x, position.y - 10))

    local powerLabel = CLabel:createWithTTF("0", "fonts/FZCuYuan/M03S.ttf", 18)
    powerLabel:enableOutline(cc.c4b(0, 0, 0, 160), 2);
    powerLabel:setPosition(cc.p(20, 13))
    progBg:addChild(powerLabel, 101, TAG_POWER_OPTION)

    -- for i=1,2 do
        local power_section = ConfigManager.getPetConfig(1).skill_energy_part
        local divider = TextureManager.createImg(TextureManager.RES_PATH.POWER_LEVEL_DIVIDER)
        divider:setPosition(cc.p(power_section[1] + 20, 10))
        progBg:addChild(divider, 102, TAG_POWER_DIVIDER + 1)
    -- end

    -- progBg:retain()

    self.battleLayout:addChild(progBg, 20)

    if isPet then
        self.petPowerProgresses[i] = progBg
    else
        self.demonPowerProgresses[i] = progBg
    end
end

-- 切换到消除阶段，隐藏血条，显示能量条
function PvPBattleUI:switchToEliminateMode()

    self.mode = BATTLE_MODE.SWITCH_MODE

    for k,prog in pairs(self.petHPProgresses) do
        prog:setVisible(false)
    end

    self:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.LAYOUT_DEPLOY):setVisible(false)
    self:getControl(Tag_ui_battle.LAYOUT_TOP):getChildByTag(Tag_ui_battle.BTN_PAUSE):setVisible(false)
    for i=1,PET_UNIT_COUNT do
        if self.petUnits[i] ~= nil then
            self.petUnits[i].power = 0
            if self.petPowerProgresses[i] == nil then
                self:createPowerProgress(true, i)
            end
            local prog = self.petPowerProgresses[i]
            if not self.petUnits[i]:isDead() then 
                prog:getChildByTag(TAG_POWER_PROG):setValue(0)
                prog:getChildByTag(TAG_POWER_OPTION):setString("0")
                prog:setVisible(true)
            else
                prog:setVisible(false)
                -- for i=1, 2 do
                --     prog:getChildByTag(TAG_POWER_DIVIDER + i):setVisible(false)
                -- end
            end
        end

        if self.demonUnits[i] ~= nil then
            self.demonUnits[i].power = 0
            if self.demonPowerProgresses[i] == nil then
                self:createPowerProgress(false, i)
            end
            local prog = self.demonPowerProgresses[i]
            if not self.demonUnits[i]:isDead() then 
                prog:getChildByTag(TAG_POWER_PROG):setValue(0)
                prog:getChildByTag(TAG_POWER_OPTION):setString("0")
                prog:setVisible(true)
                -- for i=1, 2 do
                --     prog:getChildByTag(TAG_POWER_DIVIDER + i):setVisible(false)
                -- end
            else
                prog:setVisible(false)
            end
        end
    end

    local bottomAnim = self:getBottomAnim()
    bottomAnim:setAnimation(BOTTOM_ANIM_TRACK, "fire_energy_part1", false)

    local petPowerTable = self:getPowerTable(self.petUnits)
    local demonPowerTable = self:getPowerTable(self.demonUnits)

    local allocatePower
    allocatePower = function(i)
        if i > PET_UNIT_COUNT then
            self:getBottomAnim():setAnimation(BOTTOM_ANIM_TRACK, "eat", true)
            self:switchToFightMode()
            return
        end

        local petUnit = self.petUnits[i]
        local demonUnit = self.demonUnits[i]
        local t = 0.5

        if petUnit and not petUnit:isDead() then
            bottomAnim:setAnimation(BOTTOM_ANIM_TRACK, "fire_energy_part2_left", false)
            self:assemblePower(petUnit, petPowerTable[petUnit.index])
            if demonUnit and not demonUnit:isDead() then
                self:runAction(cc.Sequence:create(cc.DelayTime:create(t), cc.CallFunc:create(function()
                    bottomAnim:setAnimation(BOTTOM_ANIM_TRACK, "fire_energy_part2_right", false)
                    self:assemblePower(demonUnit, demonPowerTable[demonUnit.index])
                end), cc.DelayTime:create(t), cc.CallFunc:create(function()
                    allocatePower(i + 1)
                end)))
            else
                self:runAction(cc.Sequence:create(cc.DelayTime:create(t), cc.CallFunc:create(function()
                    allocatePower(i + 1)
                end)))
            end
        elseif demonUnit and not demonUnit:isDead() then
            bottomAnim:setAnimation(BOTTOM_ANIM_TRACK, "fire_energy_part2_right", false)
            -- todo: 计算power
            self:assemblePower(demonUnit, demonPowerTable[demonUnit.index])
            self:runAction(cc.Sequence:create(cc.DelayTime:create(t), cc.CallFunc:create(function()
                allocatePower(i + 1)
            end)))
        else
            allocatePower(i + 1)
        end
    end
    self:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function()
        allocatePower(1)
    end)))
end

function PvPBattleUI:firePower(petUnit, power)
    self:getControl(Tag_ui_battle.LAYOUT_TOP):getChildByTag(Tag_ui_battle.BTN_PAUSE):setVisible(false)
    local emitter = cc.ParticleSystemQuad:create(TextureManager.RES_PATH.PARTICLE_POWER_STAR)
    local startPos = petUnit.isPet and cc.p(235, 270) or cc.p(400, 270)
    startPos = self:convertToNodeSpace(startPos)
    startPos.x = startPos.x + Constants.UNIT_SIZE.width/2
    startPos.y = startPos.y + Constants.UNIT_SIZE.height/2
    emitter:setPosition(startPos)
    self.effectLayout:addChild(emitter, BOTTOM_ANIM_ZORDER - 1)

    local targetPos = cc.p(petUnit.layout:getPosition())
    targetPos.y = targetPos.y
    local t = 0.5
    emitter:runAction(cc.Sequence:create(
        cc.MoveTo:create(t, targetPos), 
        cc.CallFunc:create(function()
            self:assemblePower(colorIndex)
        end), 
        cc.DelayTime:create(0.2), 
        cc.CallFunc:create(function()
            emitter:removeFromParent()
        end)
    ))
end

function PvPBattleUI:assemblePower(petUnit, power)
    if petUnit == nil or petUnit:isDead() then
        return
    end
    self:getControl(Tag_ui_battle.LAYOUT_TOP):getChildByTag(Tag_ui_battle.BTN_PAUSE):setVisible(false)
    local function callback()
        local oldLevel = petUnit:getPowerLevel()
        petUnit:assemblePower(power)

        local newLevel = petUnit:getPowerLevel()
        if newLevel > oldLevel then
            -- SPINE_POWER_BREAKTHROUGH
            local atlas = TextureManager.RES_PATH.SPINE_POWER_BREAKTHROUGH .. ".atlas"
            local json = TextureManager.RES_PATH.SPINE_POWER_BREAKTHROUGH .. ".json"
            local spine = sp.SkeletonAnimation:create(json, atlas, 1)
            spine:setAnimation(10, "level"..newLevel, true)
            spine:setPosition(cc.p(petUnit.layout:getPosition()))
            spine:runAction(cc.Sequence:create(cc.DelayTime:create(0.7), cc.CallFunc:create(function()
                spine:removeFromParent()
            end)))
            self.effectLayout:addChild(spine)
            if petUnit.isPet then
                self.petPowerProgresses[petUnit.index]:getChildByTag(TAG_POWER_DIVIDER + oldLevel):setVisible(true)
            else
                self.demonPowerProgresses[petUnit.index]:getChildByTag(TAG_POWER_DIVIDER + oldLevel):setVisible(true)
            end
        end

        local atlas = TextureManager.RES_PATH.SPINE_POWER_ARRIVE .. ".atlas"
        local json = TextureManager.RES_PATH.SPINE_POWER_ARRIVE .. ".json"
        local spine = sp.SkeletonAnimation:create(json, atlas, 1)
        spine:setAnimation(10, "part1", false)
        spine:setPosition(cc.p(petUnit.layout:getPosition()))
        spine:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
            spine:removeFromParent()
        end)))
        self.effectLayout:addChild(spine)

        local prog = petUnit.isPet and self.petPowerProgresses[petUnit.index] or self.demonPowerProgresses[petUnit.index]
        prog:getChildByTag(TAG_POWER_PROG):setValue(petUnit.power)
        prog:getChildByTag(TAG_POWER_OPTION):setString(""..petUnit.power)
    end

    self:firePower(petUnit, power)
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(callback)))
end

function PvPBattleUI:sendBattleEndCmd()
    if self.result == 1 then
        self:getBottomAnim():setAnimation(BOTTOM_ANIM_TRACK, "win", false)
    else
        self.result = 2
        self:getBottomAnim():setAnimation(BOTTOM_ANIM_TRACK, "lose", false)
    end
    NetManager.sendCmd("pvp1battleend", function(result)
        self:onBattleEnd(result)
    end, self.result)
end

function PvPBattleUI:onBattleEnd(result)
    -- todo: 战斗结果弹框
    SilverChampionShipproxy:getInstance().pvpBattleEnd = result
    if battle_.result == 1 then --victory
        battle_:runAction(cc.Sequence:create(cc.DelayTime:create(2.0), cc.CallFunc:create(function()
            Utils.runUIScene("PvpVictoryPopup")
        end)))
    else  
        battle_:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function()
            Utils.runUIScene("PvpDefeatPopup")
        end)))
    end
end

function PvPBattleUI:getBottomAnim()
    if not self.bottomAnim then
        local matrixLayout = self:getControl(Tag_ui_battle.LAYOUT_BOTTOM):getChildByTag(Tag_ui_battle.LAYOUT_MATRIX)

        local bottomAnimBg = TextureManager.createImg(TextureManager.RES_PATH.IMG_PVP1_BOTTOM_ANIM_BG)
        bottomAnimBg:setAnchorPoint(cc.p(0.5, 0))
        bottomAnimBg:setPosition(cc.p(matrixLayout:getContentSize().width/2, 0))
        matrixLayout:addChild(bottomAnimBg)

        local atlas = TextureManager.RES_PATH.SPINE_PVP1_BOTTOM_ANIM .. ".atlas"
        local json = TextureManager.RES_PATH.SPINE_PVP1_BOTTOM_ANIM .. ".json"
        self.bottomAnim = sp.SkeletonAnimation:create(json, atlas, 1)
        self.bottomAnim:setPosition(cc.p(matrixLayout:getContentSize().width/2, 0))
        matrixLayout:addChild(self.bottomAnim, BOTTOM_ANIM_ZORDER)
    end
    return self.bottomAnim
end

function PvPBattleUI:getPowerTable(units)
    local queue = {}

    for i=1, 6  do
        local pu = units[i]
        if pu then
            table.insert(queue, pu)
        end
    end

    local function switch(i, j)
        local tmp = queue[i]
        queue[i] = queue[j]
        queue[j] = tmp
    end

    if #queue > 0 then
        switch(1, math.random(#queue))
    end
    if #queue > 1 then
        switch(2, math.random(2, #queue))
    end

    local energy1Table = {30, 90}
    local energy2Table = {60, 40}
    local energy1 = energy1Table[((self.curRound)%2) + 1]
    local energy2 = energy2Table[((self.curRound)%2) + 1]
    local ret = {}
    for i=1,#queue do
        ret[queue[i].index] = (i <= 2) and energy1 or energy2
    end
    Debug.simplePrintTable(ret)
    return ret
end