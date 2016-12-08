require "view/tagMap/Tag_ui_login"

LogInUI = class("LogInUI", function()
	return TuiBase:create()
end) 

LogInUI.__index = LogInUI
local  __instance = nil
local deviceID = nil
local account,password = nil,nil

function LogInUI:create()
	local ret = LogInUI.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function LogInUI:getControl(tagPanel, tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function LogInUI:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_login.PANEL_LOGIN then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_login(p_sender) --切换账号
    Utils.runUIScene("LogInPopup")
    return false
end    

local function loadAllHandler(result)
    Player:getInstance():update(result["user"])
    TDGAAccount:setAccount(Player:getInstance():get("uid"))
    TDGAAccount:setGameServer(Player:getInstance():get("server_id"))

    ItemManager.updatePets(result["pets"])         
    ItemManager.updateItems(result["items"])   
    Player:getInstance():set("goldhandRemainTimes",result["goldhandRemainTimes"])--使聚宝功次数
    Player:getInstance():set("buyedEnergyCount",result["buyedEnergyCount"])--购买体力次数
    NormalDataProxy:getInstance():loadEnergy()       
    StageRecord:getInstance():set("old_level",Player:getInstance():get("level"))                       
    Utils.dispatchCustomEvent("event_load_all", {mainGuide = result["user"]["main_guide"],funcGuide = result["user"]["func_guide"]})
    -- Utils.dispatchCustomEvent("event_load_all",{mainGuide=30,funcGuide=2147483648})
end    

local function loginHandler(result)--登陆的返回方法
    print("==登陆成功=")
    TDGAAccount:setAccount(result["uid"])
    
    Player:getInstance():set("uid", result["uid"])
    Player:getInstance():set("auth_code", result["auth_code"])
    ItemManager.resetItems() --将所有东西置空
    NetManager.sendCmd("loadall", loadAllHandler, Player:getInstance():get("auth_code")) 
end

local function event_start_game()
    deviceID  = DeviceUtils:getDeviceID()
    account = cc.UserDefault:getInstance():getStringForKey("account")
    password = cc.UserDefault:getInstance():getStringForKey("password")
    MusicManager.start_game()
    if string.len(account) == 0 then
        Utils.runUIScene("LogInPopup")
        -- NetManager.registerResponseHandler("register",event_direct_register)
        -- NetManager.sendCmd("register", event_direct_register, deviceID,deviceID)
    else
        NetManager.sendCmd("login",loginHandler,account,password)
    end
end

local function login_after_register_Handler(result)--注册的返回方法
    Player:getInstance():set("uid", result["uid"])
    Player:getInstance():set("auth_code", result["auth_code"])
    cc.UserDefault:getInstance():setStringForKey(deviceID,deviceID)
    cc.UserDefault:getInstance():setStringForKey(deviceID,deviceID)
end

local function event_direct_register(result)

    TDGAAccount:setAccount(result["uid"])
    TDGAAccount:setAccountName(deviceID)
    TDGAAccount:setAccountType(kAccountAnonymous)
    NetManager.sendCmd("login", login_after_register_Handler,deviceID,deviceID)--注册之后直接登录
end

local function event_select_server()
    Utils.runUIScene("ServicerPopup")
    return false
end

function LogInUI:onLoadScene()
    -- self:removeAllChild()
	TuiManager:getInstance():parseScene(self,"panel_login",PATH_UI_LOGIN)
    
    local imgBg = self:getControl(Tag_ui_login.PANEL_LOGIN,Tag_ui_login.IMG_BG)
    local pos = cc.p(imgBg:getPosition())
    -- Utils.floatToTop(imgBg)
    local json1 = TextureManager.RES_PATH.SPINE_MAIN_LOGIN..".json"
    local atlas1 = TextureManager.RES_PATH.SPINE_MAIN_LOGIN..".atlas"
    local spine1 = sp.SkeletonAnimation:create(json1, atlas1)
    spine1:setAnimation(0, "part1", true)
    local layoutLogin = self:getControl(Tag_ui_login.PANEL_LOGIN,Tag_ui_login.LAYOUT_LOGIN)
    local sizeSpine1 = layoutLogin:getContentSize()
    spine1:setPosition(cc.p(sizeSpine1.width/2,sizeSpine1.height/2))
    layoutLogin:addChild(spine1)

    local json2 = TextureManager.RES_PATH.SPINE_MAIN_LOGO..".json"
    local atlas2 = TextureManager.RES_PATH.SPINE_MAIN_LOGO..".atlas"
    local spine2 = sp.SkeletonAnimation:create(json2, atlas2)
    spine2:setAnimation(0, "part1", true)
    local layoutLogo = self:getControl(Tag_ui_login.PANEL_LOGIN, Tag_ui_login.LAYOUT_LOGO)
    Utils.floatToTop(layoutLogo)
    -- Spine.addSpine(layoutLogo,"main","logo","part1",true)
    local sizeSpine2 = layoutLogo:getContentSize()
    spine2:setPosition(cc.p(sizeSpine2.width/2,sizeSpine2.height/2))
    layoutLogo:addChild(spine2)
    local winSize = cc.Director:getInstance():getVisibleSize()
    local size = imgBg:getContentSize()
    local glView = cc.Director:getInstance():getOpenGLView()
    local screenSize = glView:getFrameSize()
    print(screenSize.width.. "@" ..screenSize.height)
    if screenSize.height == 960 and screenSize.width == 640 then
        print("iphone 4")
        imgBg:setScaleX(screenSize.width/size.width)
        imgBg:setScaleY(screenSize.height/size.height)
        self:setAnchorPoint(cc.p(0,0))
        self:setPosition(cc.p(0,0))
    elseif screenSize.height == 1024*2 and screenSize.width == 768*2 then
        print("ipad")
        -- self:setScaleX(screenSize.width/(size.width*2))
        -- self:setScaleY(screenSize.height/(size.height*2))
        -- -- layoutLogo:setPosition(cc.p(winSize.width/2,winSize.height-150))
        -- self:setAnchorPoint(cc.p(0,0))
        -- self:setPosition(cc.p(115,85))
    elseif screenSize.height == 1136 and screenSize.width == 640 then
        print("iphone 5")
    end
    local layoutBottom = self:getControl(Tag_ui_login.PANEL_LOGIN,Tag_ui_login.LAYOUT_BOTTOM)
    Utils.floatToBottom(layoutBottom) 

    local layoutTouch = layoutBottom:getChildByTag(Tag_ui_login.LAYOUT_TOUCH)
    layoutTouch:setOnTouchBeganScriptHandler(event_login)
	-- local btn_select_server = self:getControl(Tag_ui_login.PANEL_LOGIN, Tag_ui_login.BTN_SELECT_DNS)
	-- btn_select_server:setOnClickScriptHandler(event_select_server)

	local btn_startgame = layoutBottom:getChildByTag(Tag_ui_login.BTN_STARTGAME)
	btn_startgame:setOnClickScriptHandler(event_start_game)
    -- MusicManager.ManagerMusic(1,"login",true)
    local btnVideo = self:getControl(Tag_ui_login.PANEL_LOGIN,Tag_ui_login.BTN_JUMP)
    btnVideo:setOnClickScriptHandler(function( )
        Utils.replaceScene("BeginVideoUI",self)
    end)
    Utils.floatToTop(btnVideo)
    local function onNodeEvent(event)
        if event == "enter" then
    
        elseif "enterTransitionFinish"  == event then
            MusicManager.loginbackground()
            if ServerDataProxy:getInstance():get("switchLogin") == 1 then
                Utils.runUIScene("LogInPopup")
                ServerDataProxy:getInstance():set("switchLogin",0)
            end
        elseif "exit" == event then
            if GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.STAGE_1 or GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.STAGE_2 then
                MusicManager.battlebackground()
            else
               MusicManager.mainMusic()
           end
        end
    end
    self:registerScriptHandler(onNodeEvent)
    TouchEffect.addTouchEffect(self)
    self:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function() 
       Utils.runUIScene("AnnouncePopup") 
    end),nil))
end






