module("Utils", package.seeall)

addCellToParent = function (child, parent, useScale)
	local size = parent:getContentSize()
	if useScale ~= nil then
		local scale = size.width/child:getContentSize().width
		child:setScale(scale)
	end
	child:setAnchorPoint(cc.p(0.5,0.5))
  	child:setPosition(Arp(cc.p(size.width/2, size.height/2)))
  	parent:addChild(child)
end

copyPropertyTable = function (desTable, srcTable)
    -- Debug.printPropertyTable("copyTable", srcTable)
    for i,v in pairs(srcTable) do 
        repeat  
            local vtyp = type(v)  
            if (vtyp == "table") then  
                if i == "__properties" then 
                    desTable[i] = copyPropertyTable(v)  
                else
                    break
                end
            elseif (vtyp == "function") then  
                break
            else  
                desTable[i] = v  
            end  
        until true
    end  
end

getAngle = function (pos1, pos2)
    if pos1.x == pos2.x then
        if (pos1.y > pos2.y) then
            return -90
        else
            return 90
        end
    end
    if pos1.x > pos2.x then
        return math.atan((pos2.y-pos1.y)/(pos2.x-pos1.x)) * 180/3.14159 - 180
    end
    return math.atan((pos2.y-pos1.y)/(pos2.x-pos1.x)) * 180/3.14159
end

runWithScene = function(sceneName)
    ResourceManager.loadResourceOfView(sceneName, function()
        CSceneManager:getInstance():runWithScene(LoadScene(sceneName))
    end)
end

local sceneLockEntry = nil
replaceScene = function (sceneName, scene)
    if sceneLockEntry ~= nil then
        return
    end

    local transTime = 0.3
    local function sceneLockHandler()
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(sceneLockEntry)
        sceneLockEntry = nil
    end
    sceneLockEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(sceneLockHandler, transTime, false)

    scene = scene or CSceneManager:getInstance():getRunningScene()
	if (scene ~= nil and scene.dtor ~= nil) then
		scene:dtor()
	end

    ResourceManager.loadResourceOfViewAsync(sceneName, function()
        CSceneManager:getInstance():replaceScene(CCSceneExTransitionFade:create(transTime,LoadScene(sceneName)))
        if (scene ~= nil) then
            -- print("scene:getClassName()", scene:getClassName())
            ResourceManager.removeResourceOfView(scene:getClassName())
        end
    end, true)
end

pushScene = function(sceneName)
    -- CSceneManager:getInstance():pushScene(CCSceneExTransitionFade:create(0.3,LoadScene(sceneName)))
    -- CSceneManager:getInstance():pushScene(LoadScene(sceneName))
    if sceneLockEntry ~= nil then
        return
    end

    local transTime = 0.3
    local function sceneLockHandler()
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(sceneLockEntry)
        sceneLockEntry = nil
    end
    sceneLockEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(sceneLockHandler, transTime, false)

    scene = CSceneManager:getInstance():getRunningScene()
    if (scene ~= nil and scene.dtor ~= nil) then
        print("dtor "..scene:getClassName())
        scene:dtor()
    end

    ResourceManager.loadResourceOfViewAsync(sceneName, function()
        CSceneManager:getInstance():pushScene(LoadScene(sceneName))
        -- if (scene ~= nil) then
        --     ResourceManager.removeResourceOfView(scene:getClassName())
        -- end
    end, true)
end

popScene = function()
    local scene = CSceneManager:getInstance():getRunningScene()
    local oldSceneName = scene:getClassName()
    CSceneManager:getInstance():popScene()
    ResourceManager.removeResourceOfView(oldSceneName)
end

local uiSceneLockEntry = nil
runUIScene = function (sceneName)
    print(tostring(uiSceneLockEntry))
    if uiSceneLockEntry ~= nil then
        return
    end

    local transTime = 0.3
    local function uiSceneLockHandler()
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(uiSceneLockEntry)
        uiSceneLockEntry = nil
    end
    uiSceneLockEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(uiSceneLockHandler, transTime, false)

    local scene = LoadScene(sceneName)
    scene:retain()
    ResourceManager.loadResourceOfViewAsync(sceneName, function()
        CSceneManager:getInstance():runUIScene(scene, nil, true)
        scene:release()
    end, false)
    return scene
end

popUIScene = function (scene, closeCallback)
    if (scene ~= nil and scene.dtor ~= nil) then
        scene:dtor()
    end
    if scene.HY_POPUP_FLAG then
       scene:close(closeCallback)
    else
        local oldSceneName = scene:getClassName()
        CSceneManager:getInstance():popUIScene(scene)
        ResourceManager.removeResourceOfView(oldSceneName)
    end
end

popAllUIScene = function()
    --todo: release resources
    CSceneManager:getInstance():popAllUIScene()
end

stringToTable = function(str)
    local func = loadstring("return " .. str)
    return func()
end

floatToTop = function(node)
    local winSize = cc.Director:getInstance():getVisibleSize()
    local nodePos = cc.p(node:getPosition())
    node:setPositionY(nodePos.y + (winSize.height - Constants.DESIGN_SIZE.height)/2);
end

floatToBottom = function(node)
    local winSize = cc.Director:getInstance():getVisibleSize()
    local nodePos = cc.p(node:getPosition())
    node:setPositionY(nodePos.y - (winSize.height - Constants.DESIGN_SIZE.height)/2);
end

parseTime = function (seconds)
    local h, m, s = math.floor(seconds/3600), math.floor(seconds/60)%60, math.floor(seconds)%60
    return h,m,s
end

parseMultiLineString = function ( str )
    return string.gsub(str, "#$#", "\r\n")
end

bit={data32={}}  
for i=1,32 do  
    bit.data32[i]=2^(32-i)  
end  
 
function bit:d2b(arg)   --一个整数32bit   转换为32位bit
    local   tr={}  
    for i=1,32 do  
        if arg >= self.data32[i] then  
        tr[i]=1  
        arg=arg-self.data32[i]  
        else  
        tr[i]=0  
        end  
    end
    return   tr  
end   --bit:d2b  
 
function    bit:b2d(arg)    --  32位转化为整数
    local   nr=0 
    for i=1,32 do  
        if arg[i] ==1 then  
        nr=nr+2^(32-i)  
        end  
    end  
    return  nr  
end   --bit:b2d  
 
function    bit:_xor(a,b)  
    local   op1=self:d2b(a)  
    local   op2=self:d2b(b)  
    local   r={}  
 
    for i=1,32 do  
        if op1[i]==op2[i] then  
            r[i]=0  
        else  
            r[i]=1  
        end  
    end  
    return  self:b2d(r)  
end --bit:xor  
 
function    bit:_and(a,b)  
    local   op1=self:d2b(a)  
    local   op2=self:d2b(b)  
    local   r={}  
      
    for i=1,32 do  
        if op1[i]==1 and op2[i]==1  then  
            r[i]=1  
        else  
            r[i]=0  
        end  
    end  
    return  self:b2d(r)  
      
end --bit:_and  
 
function    bit:_or(a,b)  
    local   op1=self:d2b(a)  
    local   op2=self:d2b(b)  
    local   r={}  
      
    for i=1,32 do  
        if  op1[i]==1 or   op2[i]==1   then  
            r[i]=1  
        else  
            r[i]=0  
        end  
    end  
    return  self:b2d(r)  
end --bit:_or  
 
function    bit:_not(a)  
    local   op1=self:d2b(a)  
    local   r={}  
 
    for i=1,32 do  
        if  op1[i]==1   then  
            r[i]=0  
        else  
            r[i]=1  
        end  
    end  
    return  self:b2d(r)  
end --bit:_not  
 
function    bit:_rshift(a,n)  
    local   op1=self:d2b(a)  
    local   r=op1 
      
    if n < 32 and n > 0 then  
        for i=1,n do  
            for i=31,1,-1 do  
                op1[i+1]=op1[i]  
            end  
            op1[1]=0  
        end  
    r=op1 
    end  
    return  self:b2d(r)  
end --bit:_rshift  
 
function    bit:_lshift(a,n)   --左移
    local   op1=self:d2b(a)  
    local   r=op1 
     -- print(string.format("bit:_lshift %d %d",a,n))
     -- bit:print(op1)
    if n < 32 and n > 0 then  
        for i=1,n   do  
            for i=1,31 do  
                op1[i]=op1[i+1]  
            end  
            op1[32]=0  
            -- bit:print(op1)
        end 
        r=op1
    end  
    -- print(string.format(self:b2d(r)))
    return  self:b2d(r)  
end --bit:_lshift  
 
 
function    bit:print(ta)  
    local   sr="" 
    for i=1,32 do  
        sr=sr..ta[i]  
    end  
    print(sr)  
end 


roundingOff = function(num)-- 四舍五入到小数点后1位  0.36 ~ 0.4  0.32~ 0.3 (对于小数点后两位有效)
    local oldNum = num
    oldNum = oldNum *10
    num = num*100%10
    if num >=5 then
        oldNum = math.ceil(oldNum)
    else
        oldNum = math.floor(oldNum)
    end
    return oldNum/10
end

keyBoardReturn = function(self)  --安卓返回键 
    local keyListener = cc.EventListenerKeyboard:create()
    local function  key_return()
        cc.Director:getInstance():endToLua()
    end
    keyListener:registerScriptHandler(key_return,cc.Handler.EVENT_KEYBOARD_RELEASED)
    local eventDispatch = self:getEventDispatcher()
    eventDispatch:addEventListenerWithSceneGraphPriority(keyListener,self)
end


function dispatchCustomEvent(eventName, data)
    local customEvent = cc.EventCustom:new(eventName)
    customEvent._usedata = data
    cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
end

function addCustomEventListener(eventName, handler)
    local listener = cc.EventListenerCustom:create(eventName, handler)
    local dispatcher = cc.Director:getInstance():getEventDispatcher()
    dispatcher:addEventListenerWithFixedPriority(listener, 1)
    return listener
end

-- 从数组tb中取出n个随机元素
-- param: 
--[[ 
    tb: 源数组，
    tbLength: 源数组长度， 
    num: 需要取出的数量， num可以为整数，也可以为table表示随机范围，
         如num={2, 4}表示取出随机2至4个元素
    checkFunc: 检查符合要求的元素的方法
--]]
function randomElemsFromTable(tb, tbLength, num, checkFunc)
    if type(num) == "table" then
        num = math.random(num[1], num[2])
    end

    local queue = {}
    for i = 1, tbLength do
        if (checkFunc and checkFunc(tb[i])) or tb[i] then
            table.insert(queue, i)
        end
    end

    local function switch(i, j)
        local tmp = queue[i]
        queue[i] = queue[j]
        queue[j] = tmp
    end

    local ret = {}
    for i = 1, num do
        if i > #queue then
            break
        end
        switch(i, math.random(i, #queue))
        table.insert(ret, tb[queue[i]])
    end

    return ret
end

-- 字符串分割函数
-- param: str: 需要拆分的字符串, delimiter: 分隔符
-- return: 保存拆分结果的数组
function splitString(str, delimiter)
    if str==nil or str=='' or delimiter==nil then
        return nil
    end
    
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

-- 通过UserDefault存储字段
-- 如果without_server为空或者false则需要在UserDefault的key中加入当前serverId
function userDefaultSet(key, value, without_server)
    local serverId = 0
    if not without_server then
        serverId = Player:getInstance():get("server_id").."_"..Player:getInstance():get("uid")
    end
    local keyPrefix = "hy_pokemon_" .. serverId .. "_"
    key = keyPrefix .. key
    cc.UserDefault:getInstance():setStringForKey(key, value)
    cc.UserDefault:getInstance():flush()
end

-- 通过UserDefault取出字段
-- 如果without_server为空或者false则需要在UserDefault的key中加入当前serverId
function userDefaultGet(key, without_server)
    local serverId = 0
    if not without_server then
        serverId = Player:getInstance():get("server_id").."_"..Player:getInstance():get("uid")
    end
    local keyPrefix = "hy_pokemon_" .. serverId .. "_"
    key = keyPrefix .. key
    return cc.UserDefault:getInstance():getStringForKey(key)
end

function useRechargeDiamond(title,content) -- 钻石充值
    local proxy = NormalDataProxy:getInstance()
    if title then
        proxy:set("title",title)
    else
        proxy:set("title","钻石不足")
    end
    if content then
        proxy:set("content",content)
    else
        proxy:set("content","是否进行充值？")
    end

    local function confirmHandler()
        Utils.runUIScene("RechargePopup")
    end
    proxy.confirmHandler = confirmHandler
    Utils.runUIScene("NormalPopup")
end

function useGoldhand() --点金手  增加金币
    local proxy = NormalDataProxy:getInstance()
    proxy:set("title","金币不足")
    proxy:set("content","是否使用点金手")
    local function confirmHandler()
        local goldhandCommon = ConfigManager.getGoldhandCommonConfig('openlevel')
        if Player:getInstance():get("level") >= goldhandCommon then
            Utils.runUIScene("GoldhandPopup")
        else
            MusicManager.error_tip()
            local msg = "该功能"..goldhandCommon.."级后开启"
            TipManager.showTip(msg)
        end
    end
    proxy.confirmHandler = confirmHandler
    Utils.runUIScene("NormalPopup")
end

function buyEnergy() --购买体力
    local buyLimit = ConfigManager.getVipConfig(Player:getInstance():get("vip")).buy_energy_num --体力购买上线
    local costDiamond = ConfigManager.getUserCommonConfig('energy_buy') --购买体力消耗
    local buyedCount = Player:getInstance():get("buyedEnergyCount") --已经购买的次数

    local cost = 0
    if buyedCount>=#costDiamond then
        cost = costDiamond[#costDiamond]
    else
        cost = costDiamond[buyedCount+1] 
    end
    local buyValue = ConfigManager.getUserCommonConfig('energy_buy_value')
    NormalDataProxy:getInstance():set("title","购买体力")
    NormalDataProxy:getInstance():set("content","花费" .. cost .. "钻石购买" .. buyValue .. "点体力\n今天已购买了" .. buyedCount .. "次")
    local energyPopup = Utils.runUIScene("NormalPopup")
    local function confirmHandler()
        if Player:getInstance():get("diamond")< cost then 
            useRechargeDiamond()
        else
            if buyedCount >= buyLimit then
                if Player:getInstance():get("vip")>=15 then
                    TipManager.showTip("今日购买次数已用完")
                else
                    useRechargeDiamond("VIP等级不足","是否升级VIP获得更多购买次数?") --购买次数不足
                end
            else
                local function event_buyenergy( result )
                    Player:getInstance():set("energy",result["energy"])
                    Player:getInstance():set("buyedEnergyCount",result["buyedEnergyCount"])
                    TipManager.showTip("体力购买成功 当前体力" .. result["energy"])
                    if NormalDataProxy:getInstance().updateEnergy then --更新pve体力
                        NormalDataProxy:getInstance().updateEnergy()
                    end
                    if NormalDataProxy:getInstance().updateUser  then --更新playercell信息 
                       NormalDataProxy:getInstance().updateUser()
                    end
                    if NormalDataProxy:getInstance().updateEnergyProg then --更新角色框体力
                       NormalDataProxy:getInstance().updateEnergyProg()
                    end
                end
                NetManager.sendCmd("buyenergy",event_buyenergy)
            end
        end
    end
    NormalDataProxy:getInstance().confirmHandler = confirmHandler
end

function showPetInfoTips(layoutNode,mid,form) 
    layoutNode:setOnTouchBeganScriptHandler(function() 
        return Constants.TOUCH_RET.TRANSIENT
    end)
    layoutNode:setOnTouchEndedScriptHandler(function() 
        AtlasDataProxy:getInstance():set("mid",mid)
        AtlasDataProxy:getInstance():set("form",form)
        Utils.runUIScene("PetInfoPopup")
        return Constants.TOUCH_RET.TRANSIENT
    end)
end

function showItemInfoTips(layoutNode,item)
    layoutNode:setOnTouchBeganScriptHandler(function() 
        return Constants.TOUCH_RET.TRANSIENT
    end)
    layoutNode:setOnTouchEndedScriptHandler(function() 
        ItemManager.currentItem = item
        Utils.runUIScene("IteminfoPopup")
        return Constants.TOUCH_RET.TRANSIENT
    end)
end

function getPetMaxAptitude(aptitudeId)
   return (ConfigManager.getPetGrowRandom(aptitudeId).addedValueLimit)/100
end

-- 处理字符串中的公式
function parseFormula(str, params)
    local formulaPattern = "{.*}"
    local formula = string.sub(str, string.find(str, formulaPattern));
    local funcStr = "return "..string.format(formula, unpack(params))
    local func = loadstring(funcStr)
    local value = func()[1]
    str = string.gsub(str, formulaPattern, tostring(value))
    return str
end
