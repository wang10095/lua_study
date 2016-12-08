require "view/tagMap/Tag_ui_defense_team"

DefenseTeamUI = class("DefenseTeamUI",function()
	return TuiBase:create()
end)

DefenseTeamUI.__index = DefenseTeamUI

local __instance = nil

local PET_RECT_SIZE = 100
local draggingPetSpine_ = nil
local PET_UNIT_COUNT = 6
local PET_PER_PAGE = 10
local selectedPetUnit_ = nil
local petPositions_ = nil
local UnitNULL = true

local selectedPetCell_ = nil
local selectedPetUnit_ = nil

DefenseTeamUI.petUnits = nil
DefenseTeamUI.battlePetCount = 0
DefenseTeamUI.petGridPage = 1
DefenseTeamUI.dragListener = nil
DefenseTeamUI.effectLayout = nil
DefenseTeamUI.battlePetCell = {}

local spine = nil
local gvCotent = nil
local nowIndex = 0

function DefenseTeamUI:create()
	local ret = DefenseTeamUI.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function DefenseTeamUI:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function DefenseTeamUI:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_defense_team.PANEL_DEFENSE_TEAM then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function getPetGvContent()
    -- todo: 取消以下注释，并在退出时将petGvContent设置为nil
    if petGvContent ~= nil then
        return petGvContent
    end

    petGvContent = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)

    -- 标记已上阵宠物
    -- Debug.simplePrintTable(Player:getInstance():get("pvp1Team"))
    -- if #Player:getInstance():get("pvp1Team") > 0 then
    --     for i,v in ipairs(Player:getInstance():get("pvp1Team")) do
    --         if v ~= 0 then
    --             print(i.." 上阵 "..v)
    --             for j,pet in ipairs(petGvContent) do
    --                 if pet:get("id") == v then
    --                     pet.isInTeam = true
    --                 end
    --             end
    --         end
    --     end
    -- end
    local team = Player:getInstance():get("pvp1Team")
    Debug.simplePrintTable(team)
    for i,v in ipairs(team) do
        local pet = ItemManager.getPetById(v)
        if pet then
            pet.isInTeam = true
        end
    end

    local petLevelLimit = 1-- ConfigManager.getPvp1CommonConfig('petlevel')
    local tmp = {}
    for i = #petGvContent, 1 ,-1 do
        if petGvContent[i]:get("level") >= petLevelLimit then
            table.insert(tmp, petGvContent[i])
        end
    end
    petGvContent = tmp

    table.sort(petGvContent, function(pet1, pet2)
        local p1 =pet1:get("level") * 100000 + pet1:get("star") * 10000 + pet1:get("rank") * 1000 + pet1:get("mid") * 10
        if pet1.isInTeam then
            p1 = p1 + 10000000
        end
        local p2 = pet2:get("level") *100000 + pet2:get("star") * 10000 + pet2:get("rank") * 1000 + pet2:get("mid") * 10
        if pet2.isInTeam then
            p2 = p2 + 10000000
        end
        return p1 > p2
    end)

    return petGvContent
end

local function event_adapt_gvpet(p_convertview, idx)
    local pCell = p_convertview
    idx = (__instance.petGridPage - 1) * PET_PER_PAGE + idx
    local gvCotent = getPetGvContent()
    local pet = gvCotent[idx + 1]
    pCell = PetCell:create(pet)
    pCell.pet = pet
    
    if pet.isInTeam then
        local petSelect = TextureManager.createImg(TextureManager.RES_PATH.PET_SELECT)
        local pos = pCell:getContentSize()
        petSelect:setPosition(cc.p(pos.width/2,pos.height/2))
        pCell:addChild(petSelect,2)
        table.insert(__instance.battlePetCell,pCell)
    end

    --拖拽上去的宠物的上阵提示添加
    local function add_battle_pet( event )
        local pet = event._usedata
        if pet ~= nil and pet == pCell.pet then
            local petSelect = TextureManager.createImg(TextureManager.RES_PATH.PET_SELECT)
            local pos = pCell:getContentSize()
            petSelect:setPosition(cc.p(pos.width/2,pos.height/2))
            pCell:addChild(petSelect,2)
            pCell.pet.isInTeam = true
            table.insert(__instance.battlePetCell,pCell)
        end
    end
    local addBattlePet = cc.EventListenerCustom:create("add_pvp_battle_pet",add_battle_pet)
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
            petCell:setPosition(cc.p(size.width/2,size.height/2))
            pCell:addChild(petCell)
            pCell.pet = pet
        end
    end
    local listenerBattlePet = cc.EventListenerCustom:create("on_pvp_battle_pet",event_battle_pet)
    __instance.listenerBattlePet = listenerBattlePet
    local eventDispatcher = __instance:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(listenerBattlePet, 1)

    local touchHandler = function ()
        return function ()
            selectedPetCell_ = pCell
        end
    end
    pCell:setTouchBeganClosureHandler(touchHandler)

    return pCell
end

local function getPetSpine(model)
    local atlas = string.format(TextureManager.RES_PATH.SPINE_PET, model) .. ".atlas"
    local json = string.format(TextureManager.RES_PATH.SPINE_PET, model) .. ".json"
    spine = sp.SkeletonAnimation:create(json, atlas, 1)
    spine:setAnimation(0, "breath", true)
    spine:setScaleX(-1)
    return spine
end

local function startDrag(touchPos)
    local pos
    local selectedPet

    -- 分别处理列表中的宠物和已上阵的宠物
    if (selectedPetCell_ == nil) then
        -- 处理已上阵宠物
        local petUnitUnderTouch = nil
        for i,v in ipairs(petPositions_) do
            if __instance.petUnits[i] ~= nil then
                local petRect = cc.rect(v.x - PET_RECT_SIZE/2, v.y - PET_RECT_SIZE/2, PET_RECT_SIZE, PET_RECT_SIZE+30)
                if cc.rectContainsPoint(petRect, touchPos) then
                    petUnitUnderTouch = __instance.petUnits[i]
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
            targetPu.layout:setPosition(petPositions_[origIndex])
            targetPu.layout:setScaleX(-1)
            targetPu.layout:setLocalZOrder(origIndex)
            targetPu.index = origIndex
            __instance.petUnits[origIndex] = targetPu
        end
        selectedPetUnit_.layout:setPosition(petPositions_[idx])
        selectedPetUnit_.layout:setScaleX(-1)
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
                local customEvent = cc.EventCustom:new("on_pvp_battle_pet")  --id相同属性不同的宠物的上阵提示交换事件
                customEvent._usedata = pu.pet
                cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
            end
        end

        -- 保证上阵宠物不超过5个
        local petCount = 0
        for i=1,PET_UNIT_COUNT do
            if __instance.petUnits[i] ~= nil and i ~= idx then
                petCount  = petCount+ 1
            end
        end
        
        if petCount >= 5 then
            __instance.battlePetCount = petCount
            print("保证上阵宠物不超过5个",__instance.battlePetCount)
            TipManager.showTip("最多只能上阵5个神奇宝贝！")
            changePet = false
            return
        end

        if __instance.petUnits[idx] then
            changePet = true
            local customEvent = cc.EventCustom:new("on_pvp_battle_pet")  --不同宠物的上阵提示交换事件
            customEvent._usedata = __instance.petUnits[idx].pet
            cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)

            __instance.petUnits[idx].layout:removeFromParent()
            __instance.petUnits[idx].pet.isInTeam = nil
            __instance.petUnits[idx]:cleanup()
        end
        local petUnit = PetUnit:create(selectedPet, idx)
        petUnit.layout:setPosition(petPositions_[idx])
        petUnit.layout:setScaleX(-1)
        __instance.petUnits[idx] = petUnit
        __instance.battleLayout:addChild(petUnit.layout, idx)
    end
end

local function stopDrag()
    if (selectedPetCell_ ~= nil or selectedPetUnit_ ~= nil) and draggingPetSpine_ ~= nil then
        local draggingPetPos = cc.p(draggingPetSpine_:getPosition())
        local succ = false
        
        for i,v in ipairs(petPositions_) do
            local petRect = cc.rect(v.x - PET_RECT_SIZE/2, v.y - PET_RECT_SIZE/2, PET_RECT_SIZE, PET_RECT_SIZE)
            if cc.rectContainsPoint(petRect, draggingPetPos) then
                dropPet(i)
                succ = true
                if selectedPetCell_ == nil and selectedPetUnit_ ~= nil then
                    
                else
                    if __instance.battlePetCount >= 5 and changePet == false then
                        print("Do not change")
                    else
                        if selectedPetCell_ ~= nil then
                            local customEvent = cc.EventCustom:new("add_pvp_battle_pet")  --添加宠物的上阵提示事件
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
        draggingPetSpine_:removeFromParent()
        draggingPetSpine_ = nil
        -- __instance.effectLayout:removeAllChildren()
    end
end

local function testDraggingPosition()
    if draggingPetSpine_ ~= nil then
        local draggingPetPos = cc.p(draggingPetSpine_:getPosition())
        for i,v in ipairs(petPositions_) do
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

function DefenseTeamUI:initDrag()
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(false)

    listener:registerScriptHandler(function(touch, event)
        draggingPetSpine_ = nil
        touchStarted = true
        local touchPos = self:convertTouchToNodeSpace(touch)
        -- 延迟开始拖拽，以保证可以获得点击的目标
        self:runAction(cc.Sequence:create(cc.DelayTime:create(0.02), cc.CallFunc:create(function()
            if touchStarted then 
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
        touchStarted = false
        stopDrag()
    end, cc.Handler.EVENT_TOUCH_ENDED)

    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

    self.dragListener = listener
end

function DefenseTeamUI:showPetGridView(page)
    gvCotent = getPetGvContent()

    local gvTeam = layoutBottom:getChildByTag(Tag_ui_defense_team.GV_DEFENSETEAM)
    local nextPageBtn = layoutBottom:getChildByTag(Tag_ui_defense_team.BTN_NEXT_RIGHT)
    local lastPageBtn = layoutBottom:getChildByTag(Tag_ui_defense_team.BTN_LAST_LEFT)
    local startIndex = (page - 1) * PET_PER_PAGE
    local endIndex = page * PET_PER_PAGE - 1
    local total = #gvCotent
    local curPageCount = (total > (page * PET_PER_PAGE)) and PET_PER_PAGE or (total - startIndex)
  
    if page < 1 or startIndex > total then
        return
    end
    __instance.petGridPage = page

    lastPageBtn:setVisible(startIndex > 0)
    nextPageBtn:setVisible(endIndex < total)

    gvTeam:setCountOfCell(curPageCount)
    gvTeam:setDataSourceAdapterScriptHandler(event_adapt_gvpet)
    gvTeam:setSizeOfCell(cc.size(113, 113))
    gvTeam:reloadData()
    gvTeam:setDragable(false)
end

function DefenseTeamUI:showTeam()
    for i,petUnit in ipairs(self.petUnits) do
        petUnit:cleanup()
    end
    self.petUnits = {}

    local team = Player:getInstance():get("pvp1Team")
    Debug.simplePrintTable(team)
    for i,v in ipairs(team) do
        local pet = ItemManager.getPetById(v)
        if pet then
            local petUnit = PetUnit:create(pet, i)
            petUnit.layout:setPosition(petPositions_[i])
            petUnit.layout:setScaleX(-1)
            self.battleLayout:addChild(petUnit.layout, i)
            self.petUnits[i] = petUnit
        end
    end
end

local function event_callback_team(result)
    -- @pets{'location','id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}"},
    local team = {}
    for i = 1, 6 do
        local petI = nil
        for k,pet in ipairs(result.pets) do
            if pet.location == i then
                petI = pet
                break
            end
        end
        if petI then
            table.insert(team, petI.id)
        else
            table.insert(team, 0)
        end
    end
    
    Player:getInstance():set("pvp1Team", team)

    __instance:showPetGridView(1)
    __instance:showTeam()
end

local function event_save()
    local btnSave = layoutBottom:getChildByTag(Tag_ui_defense_team.BTN_SAVE)
    __instance.battlePetCount = 0
    for i=1,6 do
        if __instance.petUnits[i] ~= nil then
            __instance.battlePetCount = __instance.battlePetCount + 1
        end
    end
    GoldhandDataProxy:getInstance():set("isborrow",1)
    local petIds = ""
    for k,v in pairs(__instance.petUnits) do
        petIds = petIds .. "," .. k .."_".. v.pet:get("id")
    end

    if petIds == "" then
        TipManager.showTip("请上阵至少一个宠物！")
        return
    end

    petIds = string.sub(petIds, 2, -1)
    local function event_save_team(result)
        Utils.replaceScene("SilverChampionshipUI",__instance)
        btnSave:setEnabled(true)

        local petCount = 0
        local team = {}
        local str = "{"
        for i=1,6 do
            table.insert(team, __instance.petUnits[i] and __instance.petUnits[i].pet:get("id") or 0)
            str = str .. team[i] .. ","
        end
        str = str .. "}"

        Player:getInstance():set("pvp1Team", team)
        Debug.simplePrintTable(Player:getInstance():get("pvp1Team"))

        Utils.userDefaultSet("pokemon_pvp1_defence_team", str)

    end
    SilverChampionShipproxy:getInstance():set("teamid",petIds)
    NetManager.sendCmd("savepvp1team",event_save_team,petIds)

    btnSave:setEnabled(false)

end

function DefenseTeamUI:initTeam()
    Debug.simplePrintTable(Player:getInstance():get("pvp1Team"))
    if #Player:getInstance():get("pvp1Team") > 0 then
        self:showPetGridView(1)
        self:showTeam()
        return
    end

    local savedTeamStr = Utils.userDefaultGet("pokemon_pvp1_defence_team")
    if savedTeamStr ~= nil and savedTeamStr ~= "" then
        local team = Utils.stringToTable(savedTeamStr)
        Player:getInstance():set("pvp1Team", team)
        self:showPetGridView(1)
        self:showTeam()
    else
        NetManager.sendCmd("loadenemyteam",event_callback_team,Player:getInstance():get("uid"))
    end
end

function DefenseTeamUI:onLoadScene()
	self.effectLayout = self.effectLayout or CLayout:create()
	self.effectLayout:setAnchorPoint(cc.p(0, 0))
    self.effectLayout:setPosition(cc.p(0, 0))
    -- self.effectLayout:retain()
    if self.effectLayout:getParent() == nil then
        self:addChild(self.effectLayout, 2)
    end
    
    self.petUnits = {}

	TuiManager:getInstance():parseScene(self,"panel_defense_team",PATH_UI_DEFENSE_TEAM)

    local layoutBg = self:getControl(Tag_ui_defense_team.PANEL_DEFENSE_TEAM,Tag_ui_defense_team.LAYOUT_BG)
    local img = TextureManager.createImg(TextureManager.RES_PATH.BATTLE_BG,1,1)
    Utils.addCellToParent(img,layoutBg)
    
	layoutBottom = self:getControl(Tag_ui_defense_team.PANEL_DEFENSE_TEAM,Tag_ui_defense_team.LAYOUT_DEFENSE)
	Utils.floatToBottom(layoutBottom)
    
    self.battleLayout = self:getControl(Tag_ui_defense_team.PANEL_DEFENSE_TEAM,Tag_ui_defense_team.LAYOUT_BATTLE)
	self.circles = {}
    petPositions_ = {}
    for i=1,6 do
        local circle = self:getControl(Tag_ui_defense_team.PANEL_DEFENSE_TEAM,Tag_ui_defense_team["IMG_CIRCLE_"..i])
        circle:setVisible(true)
        circle:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(0.75, 76.5), cc.FadeTo:create(0.75, 255))))

        local circlePos = circle:getParent():convertToWorldSpace(cc.p(circle:getPosition())) --位置
        circlePos = self:convertToNodeSpace(circlePos)
        table.insert(self.circles, circle)
        table.insert(petPositions_, circlePos)
    end

	local nextPageBtn = layoutBottom:getChildByTag(Tag_ui_defense_team.BTN_NEXT_RIGHT)
    nextPageBtn:setOnClickScriptHandler(function()
        self:showPetGridView(self.petGridPage + 1)
    end)

    local lastPageBtn = layoutBottom:getChildByTag(Tag_ui_defense_team.BTN_LAST_LEFT)
    -- lastPageBtn:setScaleX(-1)
    lastPageBtn:setOnClickScriptHandler(function()
        self:showPetGridView(self.petGridPage - 1)
    end)

    self:initDrag()

    local btnSave = layoutBottom:getChildByTag(Tag_ui_defense_team.BTN_SAVE)
	btnSave:setOnClickScriptHandler(event_save)

    local btnBack = layoutBottom:getChildByTag(Tag_ui_defense_team.BTN_BACK)
    btnBack:setOnClickScriptHandler(function()
       Utils.replaceScene("SilverChampionshipUI",__instance)
    end)

    self:initTeam()
    local function onNodeEvent(event)
        if "enterTransitionFinish"  == event then
            Utils.dispatchCustomEvent("event_champion",{view = "DefenseTeamUI",phase = GuideManager.FUNC_GUIDE_PHASES.DEFANCE_TEAM,scene = self})
        elseif "exit" == event then
            petGvContent = nil
        end
    end
    self:registerScriptHandler(onNodeEvent)
end