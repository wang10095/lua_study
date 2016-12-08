require "view/tagMap/Tag_ui_main"

MainUI = class("MainUI",function()
	return TuiBase:create()
end)

MainUI.__index = MainUI
local __instance = nil
local currentPosition = nil
local canClick = false
local scheduleID
local imgTitle

function MainUI:create()	
	local ret = MainUI.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	-- ret:setOnEnterSceneScriptHandler(function() print("onEnter") GuideManager.runWithGuide(Constants.GUIDE_TYPE.MAIL) end)
	return ret
end

function MainUI:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function MainUI:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_main.PANEL_MAIN then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function MainUI:Schedule()
	if scheduleID then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID)
	end
	canClick = false
	scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
		canClick = true
	end,1.5, false)
end

local function event_mail(p_sender)
	-- MusicManager.playBtnClickEffect()
	local function loadmail( result )
		Maildataproxy:getInstance().mailList = result["mail"]
		Utils.runUIScene("MailPopup")
	end
	NetManager.sendCmd("loadmail",loadmail)
end

local function event_setting(p_sender)
	-- MusicManager.playBtnClickEffect()
	Utils.runUIScene("SettingPopup")
end

local function event_atlas(p_sender)
	local function loadatlas( result )
		AtlasDataProxy.atlasList = result["pet"]
		Utils.replaceScene("AtlasUI")
	end
	NetManager.sendCmd("loadatlas",loadatlas)
end

local function event_ranking(p_sender)
	-- MusicManager.playBtnClickEffect() 
	RankDataProxy:getInstance():set("rank_type",Constants.RANK_TYPE.NORMAL)
	Utils.replaceScene("RankUI")
end

local function event_bag(p_sender)
	-- MusicManager.playBtnClickEffect()
	Utils.runUIScene("BagPopup")
end

local function loadbuylist( result )
	Shopdataproxy.goodsList = result["list"]
	Shopdataproxy:getInstance().refreshList[Constants.SHOP_TYPE.NORMAL_SHOP] = result["refreshTimes"]
	Shopdataproxy:getInstance():set("shop_type",Constants.SHOP_TYPE.NORMAL_SHOP)
	Utils.replaceScene("ShopUI")
end 

function MainUI:onLoadScene()

	cc.Director:getInstance():getTextureCache():removeAllTextures()

	__instance:Schedule()
	local normalProxy = NormalDataProxy:getInstance()
	local hoomName = {'pokemon','breedhouse','shop'}
	local hoom = {'PetListUI','PetBreedHouse','ShopUI'}
	local hoomSpine = {'pokemon','breedhouse','store'}
	TuiManager:getInstance():parseScene(self,"panel_main",PATH_UI_MAIN)

	playerCell = PlayerCell:create()
	self:addChild(playerCell)
	TouchEffect.addTouchEffect(self)
	
	local petContent = ItemManager.getItemsByType(1)
	local inheritPet = {} --传承者
	local ownerPet = {}   --继承者
	local breedGuide = false
	local inheritLevelLimit = ConfigManager.getPetCommonConfig('inherit_level_limit')
	for i,v in ipairs(petContent) do
		if v:get("level") > inheritLevelLimit then
			table.insert(inheritPet,v)
			print("***** "..v:get("mid"),v:get("level"))
		end
		if v:get("level") == 1 and v:get("aptitude") > 1 and v:get("rank") == 1 and 
		   v:get("skillLevels")[1] == 1 and v:get("skillLevels")[2] == 1   and v:get("star") == 1 then
			print("----- "..v:get("mid"),v:get("level"))
			table.insert(ownerPet,v)
		end
	end
	print("＝＝＝＝＝ "..#ownerPet)
	for j,k in ipairs(inheritPet) do
		if ownerPet ~= nil then
			for m,n in ipairs(ownerPet) do
				if n:get("mid")== k:get("mid") and n:get("aptitude") > k:get("aptitude") and GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.INHERIT) == false then
					print("%%%%%%%%%")
					breedGuide = true
					break
				end
			end
		end
	end
	if breedGuide then
		normalProxy:set("currentHoom",2)
	elseif GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.PET_SKILL) == false and Player.getInstance():get("level") >= ConfigManager.getPetCommonConfig('skill_openlevel') then
		normalProxy:set("currentHoom",1)
	end

	local layout_hoom = self:getControl(Tag_ui_main.PANEL_MAIN, Tag_ui_main.LAYOUT_HOOM)
	Spine.spineMix(layout_hoom,"main",hoomSpine[normalProxy:get("currentHoom")],"part1","part2",false,true)
	currentPosition = layout_hoom:getPositionX()

	local img_hoom_name = self:getControl(Tag_ui_main.PANEL_MAIN, Tag_ui_main.IMG_POKEMON_NAME)

	img_hoom_name:setSpriteFrame("ui_main/img_" ..  hoomName[normalProxy:get("currentHoom")] .. "_name.png")
	local xx,yy
	local noMove = 0  --0 点击进入  -1是向左滑动  1是向右滑动
	
	local function onTouchBegan( p_sender,touch )
		print("onTouchBegan")
		local selfLocation = __instance:convertTouchToNodeSpace(touch)
		xx,yy = selfLocation.x,selfLocation.y
		local size = layout_hoom:getContentSize()
		local location  = layout_hoom:convertTouchToNodeSpace(touch)
		-- if normalProxy:get("isPopup")==false and  size and location.x>0 and location.y>0 and location.x<size.width and location.y<size.height then
		if Stagedataproxy:getInstance():get("isPopup")==false and  size then
			-- return true
		end
		return Constants.TOUCH_RET.TRANSIENT
	end
	
	local function onTouchMoved( p_sender,touch )
		print("onTouchMoved")
		local selfLocation = __instance:convertTouchToNodeSpace(touch)
		local distancex = selfLocation.x-xx
		if math.abs(math.floor(distancex)) >30 and distancex<0 then --向
			noMove = -1
		elseif math.abs(math.floor(distancex)) >30 and distancex>0 then
			noMove = 1
		end
		return Constants.TOUCH_RET.TRANSIENT
	end
	local function onTouchEnded(p_sender, touch, duration)
		print("onTouchEnded")
		local winSize = cc.Director:getInstance():getWinSize()
		local location  = layout_hoom:convertTouchToNodeSpace(touch)
		local size = layout_hoom:getContentSize()
		if noMove == 0 and canClick == true and location.x>0 and location.y>-30 and location.x<size.width and location.y<size.height then
			layout_hoom:setScale(0.95)
			if normalProxy:get("currentHoom") == #hoomName then
				NetManager.sendCmd("loadbuylist",loadbuylist,Constants.SHOP_TYPE.NORMAL_SHOP)			 	
			else
				Utils.replaceScene(hoom[normalProxy:get("currentHoom")],__instance)	
			end
		elseif noMove == -1 then  --向左滑动
			__instance:Schedule()
			normalProxy:set("currentHoom",normalProxy:get("currentHoom")-1)
			if normalProxy:get("currentHoom")<=0 then
				normalProxy:set("currentHoom",#hoomName)
			end 
			local move = cc.MoveBy:create(0.2,cc.p(-winSize.width,0))
			local delay = cc.DelayTime:create(0.1)
			local callfunc = cc.CallFunc:create(function() 
				if normalProxy:get("currentHoom") == 1 then
					PromtManager.addRedSpot(imgTitle,2,"UP_SKILL_LEVEL") --添加红点监听	
					PromtManager.addRedSpot(imgTitle,2,"TRAIN") --添加红点监听	
					PromtManager.addRedSpot(imgTitle,2,"UPSTAR") --添加红点监听		
				else
					imgTitle:removeAllChildren()
				end
				layout_hoom:removeAllChildren()
				layout_hoom:setPositionX(currentPosition)
				img_hoom_name:setSpriteFrame("ui_main/img_" ..  hoomName[normalProxy:get("currentHoom")] .. "_name.png")
				Spine.spineMix(layout_hoom,"main",hoomSpine[normalProxy:get("currentHoom")],"part1","part2",false,true)
			 end)
			layout_hoom:runAction(cc.Sequence:create(move,delay,callfunc,nil))
		elseif noMove == 1 then --向右滑动 
			__instance:Schedule()
			normalProxy:set("currentHoom",normalProxy:get("currentHoom")+1)
			if normalProxy:get("currentHoom") > #hoomName then
				normalProxy:set("currentHoom",1)
			end
			local move = cc.MoveBy:create(0.2,cc.p(winSize.width,0))
			local delay = cc.DelayTime:create(0.1)
			local callfunc = cc.CallFunc:create(function() 
				if normalProxy:get("currentHoom") == 1 then
					PromtManager.addRedSpot(imgTitle,2,"UP_SKILL_LEVEL") --添加红点监听	
					PromtManager.addRedSpot(imgTitle,2,"TRAIN") --添加红点监听	
					PromtManager.addRedSpot(imgTitle,2,"UPSTAR") --添加红点监听	
				else
					imgTitle:removeAllChildren()
				end
				layout_hoom:removeAllChildren()
				layout_hoom:setPositionX(currentPosition)
				img_hoom_name:setSpriteFrame("ui_main/img_" ..  hoomName[normalProxy:get("currentHoom")] .. "_name.png")
				Spine.spineMix(layout_hoom,"main",hoomSpine[normalProxy:get("currentHoom")],"part1","part2",false,true)
			 end)
			layout_hoom:runAction(cc.Sequence:create(move,delay,callfunc,nil))
		end
		-- layout_hoom:setScale(1.0)
		noMove = 0
		return Constants.TOUCH_RET.TRANSIENT
	end
	layout_hoom:setOnTouchBeganScriptHandler(onTouchBegan)
	layout_hoom:setOnTouchMovedScriptHandler(onTouchMoved)
	layout_hoom:setOnTouchEndedScriptHandler(onTouchEnded)

	-- local listener = cc.EventListenerTouchOneByOne:create()
	-- listener:setSwallowTouches(false)
	-- listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )   
	-- listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
	-- listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )  
	-- local eventDispatcher = layout_hoom:getEventDispatcher() -- 时间派发器 
	-- eventDispatcher:addEventListenerWithSceneGraphPriority(listener,layout_hoom)


	local layout_light = self:getControl(Tag_ui_main.PANEL_MAIN, Tag_ui_main.LAYOUT_LIGHT)
	Spine.addSpine(layout_light,"main","light","part1",true)

	local layoutCloud1 = self:getControl(Tag_ui_main.PANEL_MAIN,Tag_ui_main.LAYOUT_CLOUD1)
	local layoutCloud2 = self:getControl(Tag_ui_main.PANEL_MAIN,Tag_ui_main.LAYOUT_CLOUD2)
	local cloud1 = TextureManager.createImg("ui_main/yun2.png")
	local cloud2 = TextureManager.createImg("ui_main/yun1.png")
	Utils.addCellToParent(cloud1,layoutCloud1)
	Utils.addCellToParent(cloud2,layoutCloud2)
	local Pos1 = cc.p(layoutCloud1:getPosition())
    local Pos2 = cc.p(layoutCloud2:getPosition())
    local function CallFucnCallback1 ()
    	layoutCloud1:setPosition(cc.p(768,Pos1.y))
    end
    local function CallFucnCallback2()
    	layoutCloud2:setPosition(cc.p(768,Pos2.y))
    end
	layoutCloud1:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(40, cc.p(-500,Pos1.y)),cc.CallFunc:create(CallFucnCallback1))))
	layoutCloud2:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(60, cc.p(-500,Pos2.y)),cc.CallFunc:create(CallFucnCallback2))))

	local layoutButtom = self:getControl(Tag_ui_main.PANEL_MAIN, Tag_ui_main.LAYOUT_BUTTOM)
	Utils.floatToBottom(layoutButtom)
	local btnArena = layoutButtom:getChildByTag(Tag_ui_main.BTN_ARENA)
	local btnPve = layoutButtom:getChildByTag(Tag_ui_main.BTN_PVE)
	local btnExplore = layoutButtom:getChildByTag(Tag_ui_main.BTN_EXPLORE)
	btnArena:setOnClickScriptHandler(function()
		-- MusicManager.playBtnClickEffect()
		Utils.replaceScene("DungeonUI",__instance)
	end)
	btnPve:setOnClickScriptHandler(function() 
		-- MusicManager.playBtnClickEffect()
		StageRecord:getInstance():set("dungeonType", Constants.DUNGEON_TYPE.NORMAL) --设置副本类型  普通 
		Utils.replaceScene("PveUI",__instance)	
	end)
	btnExplore:setOnClickScriptHandler(function() 
		-- MusicManager.playBtnClickEffect()
		Utils.replaceScene("ExploreUI",__instance)
	end)

	local scrol_right = layoutButtom:getChildByTag(Tag_ui_main.SCROL_RIGHT)
	scrol_right:setDragable(false)
	local layer = scrol_right:getContainer()
	local layout_right = layer:getChildByTag(Tag_ui_main.LAYOUT_RIGHT)

	local btnArrawUp = layoutButtom:getChildByTag(Tag_ui_main.BTN_ARROW_UP)
	local btnArrawDown = layoutButtom:getChildByTag(Tag_ui_main.BTN_ARROW_DOWN)

	if normalProxy:get("isOpen") == false then
		scrol_right:setContentOffset(cc.p(0,-600))
		btnArrawUp:setVisible(true)
		btnArrawDown:setVisible(false)
	else
		scrol_right:setContentOffset(cc.p(0,0))
		btnArrawUp:setVisible(false)
		btnArrawDown:setVisible(true)
	end
	local function event_scrol()
		if normalProxy:get("isOpen") == false then
			normalProxy:set("isOpen",true)                                                                          
			scrol_right:setContentOffsetInDuration(cc.p(0,0),0.2)
			btnArrawUp:setVisible(false)
			btnArrawDown:setVisible(true)
		else
			normalProxy:set("isOpen",false)
			scrol_right:setContentOffsetInDuration(cc.p(0,-600),0.2)
			btnArrawUp:setVisible(true)
			btnArrawDown:setVisible(false)
		end
	end
	btnArrawUp:setOnClickScriptHandler(event_scrol)
	btnArrawDown:setOnClickScriptHandler(event_scrol)
	PromtManager.addRedSpot(btnArrawUp,1,"MAIL") --添加红点监听
	PromtManager.addRedSpot(btnArrawDown,1,"MAIL") --添加红点监听


	local btnMail = layout_right:getChildByTag(Tag_ui_main.BTN_MAIL)
	local btnBag = layout_right:getChildByTag(Tag_ui_main.BTN_BAG)
	local btnRank = layout_right:getChildByTag(Tag_ui_main.BTN_RANK)
	local btnAtlas = layout_right:getChildByTag(Tag_ui_main.BTN_ATLAS)
	local btnSetting = layout_right:getChildByTag(Tag_ui_main.BTN_SETTING)
	btnMail:setOnClickScriptHandler(event_mail)
	btnBag:setOnClickScriptHandler(event_bag)
	btnRank:setOnClickScriptHandler(event_ranking)
	btnAtlas:setOnClickScriptHandler(event_atlas)
	btnSetting:setOnClickScriptHandler(event_setting)
	PromtManager.addRedSpot(btnMail,1,"MAIL") --添加红点监听

	imgTitle = self:getControl(Tag_ui_main.PANEL_MAIN,Tag_ui_main.IMG_TITLE)
	imgTitle:removeAllChildren()
	if normalProxy:get("currentHoom")==1 then
		PromtManager.addRedSpot(imgTitle,2,"UP_SKILL_LEVEL") --添加红点监听	
		PromtManager.addRedSpot(imgTitle,2,"TRAIN") --添加红点监听	
		PromtManager.addRedSpot(imgTitle,2,"UPSTAR") --添加红点监听	
	end
	
	local function onNodeEvent(event)
		if "enterTransitionFinish"  == event then
			self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function(  )
				Stagedataproxy:getInstance():set("isPopup",false)
			end)))
			if GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.FINISH_WILD or (GuideManager.main_guide_phase_ >= GuideManager.MAIN_GUIDE_PHASES.PVE1 and GuideManager.main_guide_phase_ <= GuideManager.MAIN_GUIDE_PHASES.PVE3) then
				local callfunc = function ()
					Utils.dispatchCustomEvent("event_enter_view",{view = "MainUI",phase = GuideManager.MAIN_GUIDE_PHASES.PVE1,scene = self})
				end
				Utils.dispatchCustomEvent("enter_view",{callback = callfunc, params = {view = "view", scene = 7}})
			end
			
			if GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.WILD then
				Utils.dispatchCustomEvent("enter_view",{callback = function ( )
					Utils.dispatchCustomEvent("event_enter_view",{view = "MainUI",phase = GuideManager.MAIN_GUIDE_PHASES.WILD,scene = self})
					GuideManager.main_guide_phase_  = GuideManager.MAIN_GUIDE_PHASES.GOLD_CAPTURE
				end, params = {view = "view", scene = 4}})
			end

			local activity1Common = ConfigManager.getActivty1CommonConfig('level_limit')
			local activity2Common = ConfigManager.getActivty2CommonConfig('openlevel')
			local activity3Common = ConfigManager.getActivty3CommonConfig('level_limit')
			local goldhandCommon = ConfigManager.getGoldhandCommonConfig('openlevel')
			local pvpOPenLevel = ConfigManager.getPvp1CommonConfig('openlevel')
			
			GuideManager.func_guide_status_ = GuideManager.funcGuideCheaked()
			
			if Player:getInstance():get("level") == activity1Common and GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.BATTLE_PALACE) == false  then
				Utils.dispatchCustomEvent("event_activity",{view = "MainUI",phase = GuideManager.FUNC_GUIDE_PHASES.ACTIVITY1,scene = self})
			elseif Player:getInstance():get("level") == activity2Common and GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.BATTLE_ROULETTE) == false then
				Utils.dispatchCustomEvent("event_activity",{view = "MainUI",phase = GuideManager.FUNC_GUIDE_PHASES.ACTIVITY2,scene = self})
			elseif Player:getInstance():get("level") == activity3Common and GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.PYRAMID) == false then
				Utils.dispatchCustomEvent("event_activity",{view = "MainUI",phase = GuideManager.FUNC_GUIDE_PHASES.ACTIVITY3,scene = self})
			elseif Player:getInstance():get("level") == goldhandCommon  then
				Utils.dispatchCustomEvent("event_goldhand",{view = "MainUI",phase = GuideManager.FUNC_GUIDE_PHASES.GOLD_HAND,scene = self})
			elseif Player:getInstance():get("level") == pvpOPenLevel and GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.DEFANCE_TEAM) == false then
				print("CHAMPION GUIDE")
				Utils.dispatchCustomEvent("enter_view",{callback = function ( )
					Utils.dispatchCustomEvent("event_champion",{view = "MainUI",phase = GuideManager.FUNC_GUIDE_PHASES.CHAMPION,scene = self})
				end, params = {view = "func", phase = GuideManager.FUNC_GUIDE_PHASES.CHAMPION}})
			elseif GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.PET_TRAIN) == false and Player.getInstance():get("normalStageId") == 4 then
				print("PET_TRAIN GUIDE")
				Utils.dispatchCustomEvent("enter_view",{callback = function ( )
					Utils.dispatchCustomEvent("event_train",{view = "MainUI",phase = GuideManager.FUNC_GUIDE_PHASES.PET_TRAIN,scene = self})
				end, params = {view = "func", phase = GuideManager.FUNC_GUIDE_PHASES.PET_TRAIN}})
			elseif GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.PET_SKILL) == false and Player.getInstance():get("level") >= ConfigManager.getPetCommonConfig('skill_openlevel') then
				print("PET_SKILL GUIDE")
				Utils.dispatchCustomEvent("enter_view",{callback = function ( )
					Utils.dispatchCustomEvent("event_upskill",{view = "MainUI",phase = GuideManager.FUNC_GUIDE_PHASES.PET_SKILL,scene = self})
				end, params = {view = "func", phase = GuideManager.FUNC_GUIDE_PHASES.PET_SKILL}})
			elseif GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.PET_LEVEL) == false and Player.getInstance():get("level") >= 8 then
				print("PET_LEVEL GUIDE")
				Utils.dispatchCustomEvent("enter_view",{callback = function ( )
					Utils.dispatchCustomEvent("event_pet_level",{view = "MainUI",phase = GuideManager.FUNC_GUIDE_EXTRA.PET_LEVEL_MAIN,scene = self})
				end, params = {view = "func", phase = GuideManager.FUNC_GUIDE_EXTRA.PET_LEVEL_MAIN}})
			end
			if breedGuide == true and GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.INHERIT) == false then
				print("$$$$$$$$$$$")
				print("  "..GuideManager.FUNC_GUIDE_PHASES.BREEDHOUSE)
				Utils.dispatchCustomEvent("enter_view",{callback = function ( )
					Utils.dispatchCustomEvent("event_breed",{view = "MainUI",phase = GuideManager.FUNC_GUIDE_PHASES.BREEDHOUSE,scene = self})
					GuideManager.main_guide_phase_ = GuideManager.FUNC_GUIDE_PHASES.BREED
				end, params = {view = "func", phase = GuideManager.FUNC_GUIDE_PHASES.BREEDHOUSE}})
			end
			MusicManager.mainbackground()

		elseif "exit" == event then
			-- MusicManager.stopMainbackground()
			if scheduleID then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID)
			end
		end
	end
	self:registerScriptHandler(onNodeEvent)
	PromtManager.checkAll()
end 




