require "view/tagMap/Tag_ui_roulette"

RouletteUI = class("RouletteUI",function()
	return TuiBase:create()
end)

RouletteUI.__index = RouletteUI
local __instance = nil
local width = 185
local remainNum = nil
local layoutRoulette = nil
local layoutRouletteExplore = nil
local alwaysVisible = true
local exploreing = false
local isLoad = false
local btnExplore

function  RouletteUI:create()
	local ret = RouletteUI.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function RouletteUI:getPanel(tagPanel)  
	local ret = nil
	if tagPanel == Tag_ui_roulette.PANEL_ROULETTE then
		ret = self:getChildByTag(tagPanel)
	end
	return ret   
end

function RouletteUI:getControl(tagPanel, tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function RouletteUI:event_return()
	if NormalDataProxy:getInstance():get("isDaliyPursue") then
		Utils.popScene()
		Utils.runUIScene("DailyPopup")
		return
	end
	Utils.replaceScene("ExploreUI",__instance)
end

local function callback_explore(result)
	img9Gray:setVisible(true)
	local statusId = result["exploreResult"]["id"]
	local activity2Config = ConfigManager.getActivity2StatusConfig(statusId)
	layoutEnemyinfo = __instance.layoutRouletteExplore:getChildByTag(Tag_ui_roulette.LAYOUT_ENEMYINFO)
	__instance.statu = 2
	if isLoad == false then
		remainNum:setString(result["remainTimes"]-1)
		remainNum:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,1.5),cc.ScaleTo:create(0.2,1.0),nil))
	else
		remainNum:setString(result["remainTimes"])
		isLoad = false
	end
	if result["exploreResult"]["id"] == nil then
		__instance.layoutRoulette:setVisible(true)
		__instance.layoutRouletteExplore:setVisible(false)
		btnExplore:setEnabled(true)
		return
	else
		__instance.layoutRouletteExplore:setVisible(true)
		btnExplore:setEnabled(false)
	end
	local winSize = cc.Director:getInstance():getWinSize()
	local height = 580-(winSize.height-1136)/2
	layoutEnemyinfo:runAction(cc.Sequence:create(cc.MoveBy:create(0.4,cc.p(0,height)),cc.MoveBy:create(0.2,cc.p(0,-40)),nil))

	local layoutPet = __instance.layoutRouletteExplore:getChildByTag(Tag_ui_roulette.LAYOUT_PET)
	layoutPet:removeAllChildren()
	local pet = TextureManager.createImg(TextureManager.RES_PATH.PET_PORTRAIT, activity2Config.enemyModel)
	Utils.addCellToParent(pet,layoutPet)
	layoutPet:setScale(1)
	layoutPet:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3,1.4),cc.ScaleTo:create(0.1,1)))

	local lab_enemy_info = layoutEnemyinfo:getChildByTag(Tag_ui_roulette.LAB_ENEMY_INFO)
	lab_enemy_info:setString("遇到怪物")
	local lab_explore_info = layoutEnemyinfo:getChildByTag(Tag_ui_roulette.LAB_EXPLORE_INFO)
	local statusConfig = TextManager.getActivity2Status(statusId) 
	lab_explore_info:setString(statusConfig.name .. ":" .. statusConfig.desc)	

	local img9_content_roulette = layoutEnemyinfo:getChildByTag(Tag_ui_roulette.IMG9_CONTENT_ROULETTE)
	img9_content_roulette:setOpacity(127)
	local img9_roulette_bg2 = layoutEnemyinfo:getChildByTag(Tag_ui_roulette.IMG9_ROULETTE_BG2)
	img9_roulette_bg2:setOpacity(216)
	local scrollDifficulty = layoutEnemyinfo:getChildByTag(Tag_ui_roulette.SCROL_DIFFICULTY)
	local layer = scrollDifficulty:getContainer()
	local count = result["exploreResult"]["max_level"]
	local layout_enermy = layer:getChildByTag(Tag_ui_roulette.LAYOUT_DIFFICULTY)
	-- count = 9                              
	for i=1,count do
		local layout_difficulty = layout_enermy:getChildByTag(Tag_ui_roulette["LAYOUT_DIFFICULTY" .. i])
		local button = layout_difficulty:getChildByTag(Tag_ui_roulette["BTN_DIFF" .. i])
		local imageCount 
		if i<=3 then
			imageCount = 1
		elseif i>3 and i<=6 then
			imageCount = 2
		else
			imageCount = 3
		end
		button:setNormalSpriteFrameName("ui_roulette/btn_difficulty" .. imageCount .. "_normal.png");
		button:setSelectedSpriteFrameName("ui_roulette/btn_difficulty" .. imageCount .. "_select.png");
		button:setOnClickScriptHandler(function()
			-- print("===sss==" .. i )
			button:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05,0.8),cc.ScaleTo:create(0.01,1)))
			local stageRecord = StageRecord:getInstance()
      		stageRecord:set("dungeonType", Constants.DUNGEON_TYPE.ACTIVITY2) --活动2
      		stageRecord:set("stage", activity2Config.dungeons[i])
      		stageRecord:set("activity2Id", statusId)
       	 	stageRecord:set("activity2Level", i)  --选择难度 
        	Utils.replaceScene("BattleUI",__instance)
        	if scheduleID then
        		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID)
        	end
		end)
		local label = layout_difficulty:getChildByTag(Tag_ui_roulette["LAB_DIFF" .. i])
		local name = TextManager.getActivity2DifficultyName(i)
		label:setString(name)
	end
	for i=count+1,9 do
		local layout_difficulty = layout_enermy:getChildByTag(Tag_ui_roulette["LAYOUT_DIFFICULTY" .. i])
		layout_difficulty:setVisible(false)
	end

	local btnArrowLeft = layoutEnemyinfo:getChildByTag(Tag_ui_roulette.BTN_EXPLORE_LEFT)
	local btnArrowRight = layoutEnemyinfo:getChildByTag(Tag_ui_roulette.BTN_EXPLORE_RIGHT)
	if count <=3 then
		btnArrowLeft:setVisible(false)
		btnArrowRight:setVisible(false)
		alwaysVisible = false
		scrollDifficulty:setDragable(false)
	end
	scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
		local xx  = scrollDifficulty:getContentOffset().x
        if xx>0-5 then
        	if alwaysVisible then
        		btnArrowLeft:setVisible(false)
				btnArrowRight:setVisible(true)
        	end
        	if xx>0 then
        		scrollDifficulty:setContentOffset(cc.p(0,0))
        	end
        elseif xx< -(width*(count-3))+5 then
        	if alwaysVisible then
        		btnArrowLeft:setVisible(true)
				btnArrowRight:setVisible(false)
        	end
        	if xx< -(width*(count-3)) then
	        	scrollDifficulty:setContentOffset(cc.p(-width*(count-3),0))	
        	end
        else
        	if alwaysVisible then
        		btnArrowLeft:setVisible(true)
				btnArrowRight:setVisible(true)
        	end
        end
	end, 0, false)

	local beganX = nil
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(function(touch,event)
		local xx = scrollDifficulty:getContentOffset().x
		beganX = xx
		local location = scrollDifficulty:convertTouchToNodeSpace(touch)
		if location.x>0 and location.y>0 and location.x<scrollDifficulty:getContentSize().width and location.y<scrollDifficulty:getContentSize().height then
			return true
		else
			return false
		end
		
	end,cc.Handler.EVENT_TOUCH_BEGAN )   
	listener:registerScriptHandler(function(touch,event)
		local xx = scrollDifficulty:getContentOffset().x
		local count = math.floor(math.abs(math.floor(xx))/width)
		local distance = math.abs(math.floor(xx))%width
		if distance ~=0  then
			if xx > beganX  then
				if distance/width>0.5 then
					scrollDifficulty:setContentOffsetInDuration(cc.p(-(width*(count+1)),0),0.3)	
				else
					scrollDifficulty:setContentOffsetInDuration(cc.p(-(width*count),0),0.3)
				end
			else
				if distance/width>0.5 then
					scrollDifficulty:setContentOffsetInDuration(cc.p(-(width*(count+1)),0),0.3)
				else
					scrollDifficulty:setContentOffsetInDuration(cc.p(-(width*count),0),0.3)
				end
			end
		end
	end,cc.Handler.EVENT_TOUCH_ENDED)  
	local eventDispatcher = scrollDifficulty:getEventDispatcher() -- 时间派发器 
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, scrollDifficulty)
	
	btnArrowLeft:setOnClickScriptHandler(function()
		local xx = scrollDifficulty:getContentOffset().x
		if math.abs(math.floor(xx))%width == 0 then
			scrollDifficulty:setContentOffsetInDuration(cc.p(xx+width,0),0.3)
		end
	end)

	btnArrowRight:setOnClickScriptHandler(function()
		local xx = scrollDifficulty:getContentOffset().x
		if math.abs(math.floor(xx))%width == 0 then
			scrollDifficulty:setContentOffsetInDuration(cc.p(xx-width,0),0.3)
		end
	end)
end

local function event_explore()
	btnExplore:setEnabled(false)
	if tonumber(remainNum:getString()) <=0  then
        TipManager.showTip("今日次数已用完")
    	btnExplore:setEnabled(true)
		return
	end

	local function CallFucnCallback()
		__instance.skeletonMove:setTimeScale(0.8)
		__instance.skeletonMove:addAnimation(0, "part".. __instance.part , false)
		__instance.skeletonPeople:setAnimation(0, "back_walk", true)
	end
	local function sendRequire()
		__instance.skeletonPeople:setAnimation(0, "back_breath", true)
   		
		NetManager.sendCmd("activity2explore",callback_explore)
		
		img9Gray:setVisible(true)
		if __instance.part < 3 then
			__instance.part = __instance.part +1 
		elseif __instance.part == 3 then
			__instance.part =1 
		end
		__instance.first = __instance.first +1 
	end
	__instance.layoutRoulette:runAction(cc.Sequence:create(cc.CallFunc:create(CallFucnCallback),cc.DelayTime:create(2),cc.CallFunc:create(sendRequire)))
end

function RouletteUI:onLoadScene()
    TuiManager:getInstance():parseScene(self,"panel_roulette",PATH_UI_ROULETTE)
    self.statu = 1
    self.part = 1
    self.first = 1
    
    local layout_roulette_top = self:getControl(Tag_ui_roulette.PANEL_ROULETTE,Tag_ui_roulette.LAYOUT_ROULETTE_TOP)
	Utils.floatToTop(layout_roulette_top)

    local json1 = TextureManager.RES_PATH.SPINE_ACTIVITY1_BOY .. ".json"
    local atlas1 = TextureManager.RES_PATH.SPINE_ACTIVITY1_BOY .. ".atlas"
    self.skeletonPeople = sp.SkeletonAnimation:create(json1, atlas1)
    self.skeletonPeople:setScale(2)
    local json2 = TextureManager.RES_PATH.SPINE_ACTIVITY2_EXPLORE .. ".json"
    local atlas2 = TextureManager.RES_PATH.SPINE_ACTIVITY2_EXPLORE .. ".atlas"
    self.skeletonMove = sp.SkeletonAnimation:create(json2, atlas2)
    self.skeletonMove:setAnimation(0, "part1", false)
    self.skeletonMove:setTimeScale(6)

    local layoutButtom = self:getControl(Tag_ui_roulette.PANEL_ROULETTE,Tag_ui_roulette.LAYOUT_ROULETTE_BUTTOM)
    Utils.floatToBottom(layoutButtom)
    local btnReturn = layoutButtom:getChildByTag(Tag_ui_roulette.BTN_ROULETTE_BACK)
    btnReturn:setOnClickScriptHandler(self.event_return)
    remainNum = layoutButtom:getChildByTag(Tag_ui_roulette.LAB_ROULETTE_EXPLORE_NUM)
    self.layoutRoulette = self:getControl(Tag_ui_roulette.PANEL_ROULETTE, Tag_ui_roulette.LAYOUT_ROULETTE)
   	self.layoutRouletteExplore = self:getControl(Tag_ui_roulette.PANEL_ROULETTE, Tag_ui_roulette.LAYOUT_ROULETTE_EXPLORE)
   	btnExplore = self.layoutRoulette:getChildByTag(Tag_ui_roulette.BTN_ROULETTE_EXPLORE)
   	btnExplore:setOnClickScriptHandler(event_explore)
	btnExplore:setEnabled(false)
   	img9Gray = self.layoutRouletteExplore:getChildByTag(Tag_ui_roulette.IMG9_GRAY_ROULETTE)
   	img9Gray:setVisible(false)
   	layoutPeople = self.layoutRoulette:getChildByTag(Tag_ui_roulette.LAYOUT_PEOPLE)
   	self.skeletonPeople:setAnimation(0, "back_breath", true)
   	layoutPeople:addChild(self.skeletonPeople)
   	layoutMove = self.layoutRoulette:getChildByTag(Tag_ui_roulette.LAYOUT_MOVE)
   	layoutMove:addChild(self.skeletonMove)   	
   	self.layoutRouletteExplore:setVisible(false)

	local function onNodeEvent(event)
		if "enter" == event then
			isLoad = true
			NetManager.sendCmd("loadactivity2status",callback_explore)
			TouchEffect.addTouchEffect(self) 
		end
		if "exit" == event then
			if scheduleID then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID)
			end
		end
	end
	self:registerScriptHandler(onNodeEvent)
end
