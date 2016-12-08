require "view/tagMap/Tag_ui_pve"

PveUI = class("PveUI",function()
	return TuiBase:create()
end)

PveUI.__index = PveUI
local __instance = nil
local scheduleID
local scrol = nil
local btnLeftArrow ,btnRightArrow
local currentNormalChapter ,currentEliteChapter
local layoutNormaltitle,layoutElitetitle
local winSize
local arrowScrol = 0  -- 0为不滑动  1为向左滑动  2为向右滑动
local layout_pve_map
local chapterinfo = {}
local eliteChapterInfo = {}
local nowNormalChapter = 0
local nowEliteChapter = 0
local btnChestOpen,btnChestClose,layoutChest
local img_yun1,img_yun2,img_yun3,img_yun4
local yun1oldposition,yun2oldposition,yun3oldposition,yun4oldposition 
local yun1newposition,yun2newposition,yun3newposition,yun4newposition 
local scheduleIDEnergy = nil

function PveUI:create()
	local ret = PveUI.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function PveUI:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function PveUI:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_pve.PANEL_PVE then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function PveUI:unscheduleScript()
	if scheduleID then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID)
		scheduleID = nil
	end
end

local function event_normal_chapter()  --加载普通副本
	local mapCell = CPageViewCell:new()
	TuiManager:getInstance():parseCell(mapCell, "cell_normal_map" .. currentNormalChapter, PATH_UI_PVE)
	layout_pve_map:removeAllChildren()
	Utils.addCellToParent(mapCell,layout_pve_map)
	mapCell:setPositionY(mapCell:getPositionY()+400)

	local scrol = mapCell:getChildByTag(Tag_ui_pve["SCROL_NORMAL_MAP" .. currentNormalChapter])
	local size = cc.Director:getInstance():getWinSize()
	scrol:setContentSize(cc.size(scrol:getContentSize().width,size.height))
	local layer = scrol:getContainer()
	
	local Min = scrol:getMinOffset()
	scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
		local xx  = scrol:getContentOffset()
	       if xx.y < Min.y then
	           scrol:setContentOffset(cc.p(0,Min.y))
	       elseif xx.y > 0 then
	           scrol:setContentOffset(cc.p(0,0))
	       end
	end, 0, false)

	local layout_normal_map = layer:getChildByTag(Tag_ui_pve["LAYOUT_NORMAL_MAP" .. currentNormalChapter])
	local mapName = ConfigManager.getChpaterMapName(currentNormalChapter)
	local img_map = TextureManager.createImg("map/" .. mapName .. "_map.jpg")
	Utils.addCellToParent(img_map,layout_normal_map,true)

	for i=1,12 do  
		local alreadyPassedChapter = Player:getInstance():get("normalChapterId")
		local alreadyPassedStage = Player:getInstance():get("normalStageId")
		local  isTouchStage = true     --没有通过的关卡(除将要闯的)不能显示以及触摸
		local layoutStagePos = layer:getChildByTag(Tag_ui_pve["LAYOUT_NORMAL_" .. currentNormalChapter .."_STAGE_"..i])
		local pCell = CGridViewCell:new() 
		TuiManager:getInstance():parseCell(pCell, "cell_stage", PATH_UI_PVE) 
		Utils.addCellToParent(pCell,layoutStagePos)

		-----隐藏没有通过关卡 让将要闯的关卡的跳动
		local layoutStage = pCell:getChildByTag(Tag_ui_pve.LAYOUT_STAGE)
		local imgNormal = layoutStage:getChildByTag(Tag_ui_pve.IMG_NORMAL_BG)

		if PetAttributeDataProxy:getInstance():get("dropStage") == i then --从掉落中追踪过来
			local cs = scrol:getContainerSize()
			if i>=10 then
				scrol:setContentOffsetToTopInDuration(0.5)
			elseif i <=3 then
				scrol:setContentOffsetToBottom()
			else
				scrol:setContentOffsetInDuration(cc.p(0,-cs.height/12*i + winSize.height/2),i/12*1.0)
			end
			scrol:setBounceable(true)
			local jump = cc.JumpBy:create(0.4, cc.p(0,40), 0, 2)
			local action = cc.Sequence:create(jump, jump:reverse())
			layoutStage:runAction(cc.RepeatForever:create(action))
		end
		if GuideManager.main_guide_phase_ < 14 and  Player:getInstance():get("normalChapterId")==1 and Player:getInstance():get("normalStageId")<12  then
			if i > Player:getInstance():get("normalStageId")+1 then 
				layoutStage:setVisible(false)
				isTouchStage = false
			elseif i == Player:getInstance():get("normalStageId")+1 or i == 12 then
				local pos = cc.p(layoutStage:getPosition()) --当前关卡所在的位置
				local cs = scrol:getContainerSize()
				local Min = scrol:getMinOffset()
				if PetAttributeDataProxy:getInstance():get("dropStage") == 0 then
					if currentNormalChapter < alreadyPassedChapter or alreadyPassedStage == 12 then
						scrol:setContentOffsetToBottom()
					else
						if i>=10 then
							scrol:setContentOffsetToTop()
						elseif i <=3  then
							scrol:setContentOffsetToBottom()
						else
							scrol:setContentOffsetInDuration(cc.p(0,-cs.height/12*i + winSize.height/2),i/12*1.0)
						end
					end
					scrol:setBounceable(true)
					local jump = cc.JumpBy:create(0.5, cc.p(0,40), 0, 2)
					local action = cc.Sequence:create(jump, jump:reverse())
					if #chapterinfo < 12 then
						layoutStage:runAction(cc.RepeatForever:create(action))
					end
				end
			end
		else 
			local num = 0  --本章已经开启的关卡
			local nowChapter = Player:getInstance():get("normalChapterId")
			local nowStage = Player:getInstance():get("normalStageId")
			if nowStage >= 12 then
				nowChapter = nowChapter + 1
				nowStage = 1
			else
				nowStage = nowStage + 1
			end
			if currentNormalChapter <nowChapter then
				num = 12
			else
				num = nowStage
			end

			if i > num then 
				layoutStage:setVisible(false)
				isTouchStage = false
			elseif i == num  then
				local pos = cc.p(layoutStage:getPosition()) --当前关卡所在的位置
				local cs = scrol:getContainerSize()
				local Min = scrol:getMinOffset()
				if PetAttributeDataProxy:getInstance():get("dropStage") == 0 then
					if currentNormalChapter < alreadyPassedChapter or alreadyPassedStage == 12 then
						scrol:setContentOffsetToBottom()
					else
						if i>=10 then
							scrol:setContentOffsetToTop()
						elseif i <=3  then
							scrol:setContentOffsetToBottom()
						else
							scrol:setContentOffsetInDuration(cc.p(0,-cs.height/12*i + winSize.height/2),i/12*1.0)
						end
					end
					scrol:setBounceable(true)
					local jump = cc.JumpBy:create(0.5, cc.p(0,40), 0, 2)
					local action = cc.Sequence:create(jump, jump:reverse())
					if #chapterinfo < 12 then
						layoutStage:runAction(cc.RepeatForever:create(action))
					end
				end
			end
		end
		
		--------显示已经通过的关卡
		local imgBg = layoutStage:getChildByTag(Tag_ui_pve.IMG_NORMAL_BG)
		local stageConfig =  ConfigManager.getStageNormalConfig(currentNormalChapter,i)
		if stageConfig.boss_stage ==1 then
			imgBg:setPositionY(imgBg:getPositionY()+10)
			imgBg:setSpriteFrame("ui_pve/img_normal_last.png")
		end
		local rewardNormal = ConfigManager.getStageNormalConfig(currentNormalChapter,i)
		local imgPet = layoutStage:getChildByTag(Tag_ui_pve.IMG_STAGE_PET)
		imgPet:setTexture("pet/".. rewardNormal.model ..".png")		
		local imgStar1 = layoutStage:getChildByTag(Tag_ui_pve.IMG_STAGE_STAR1)
		local imgStar2 = layoutStage:getChildByTag(Tag_ui_pve.IMG_STAGE_STAR2)
		local imgStar3 = layoutStage:getChildByTag(Tag_ui_pve.IMG_STAGE_STAR3)	
		imgStar1:setVisible(false)
		imgStar2:setVisible(false)
		imgStar3:setVisible(false)

		for k,v in ipairs(chapterinfo) do
			if v[1]==i then
				if chapterinfo[k][2] == 1 then
					imgStar1:setVisible(true)
				elseif chapterinfo[k][2] == 2 then
				    imgStar1:setVisible(true)
				    imgStar2:setVisible(true)
				elseif chapterinfo[k][2] == 3 then
					imgStar1:setVisible(true)
				    imgStar2:setVisible(true)
				    imgStar3:setVisible(true)
				end
			end
		end

		local stageRecord = StageRecord:getInstance()
		local function onLoadStageInfoHandler(p_sender)
			stageRecord:set("dungeonType",Constants.DUNGEON_TYPE.NORMAL)
			stageRecord:set("chapter",currentNormalChapter)
			stageRecord:set("stage",i)

			local starNum = false
			for k,v in ipairs(chapterinfo) do
				if v[1]==i then
					starNum = true
					stageRecord:set("starNum",v[2])
				end
			end

			if starNum == false then
				stageRecord:set("starNum",0)
			end
			Utils.runUIScene("PvePopup")
			local function pveBattle()
				Utils.replaceScene("BattleUI",__instance)
			end
			NormalDataProxy:getInstance().pveBattle = pveBattle
		end

		local noMove = true
		local xx,yy = nil,nil

		local function onTouchBegan(p_sender, touch)
			local selfLocation = __instance:convertTouchToNodeSpace(touch)
			xx,yy = selfLocation.x,selfLocation.y
			local layoutLocation = layoutStage:convertTouchToNodeSpace(touch)

			local size = layoutStage:getContentSize()
			local rect = cc.rect(0,0,size.width,size.height)
			if cc.rectContainsPoint(rect, layoutLocation) then
				layoutStage:setScale(0.9)
			end
			return Constants.TOUCH_RET.TRANSIENT
		 end
		local function onTouchMoved( p_sender,touch )
			local selfLocation = __instance:convertTouchToNodeSpace(touch)
			local xxD = math.abs(math.floor(selfLocation.x-xx))
			local yyD = math.abs(math.floor(selfLocation.y-yy))
			if xxD>30 or yyD>30 then
				noMove = false
				layoutStage:setScale(1.0)
			end
			layoutStage:setScale(1.0)
			return Constants.TOUCH_RET.TRANSIENT
		end
		local function onTouchEnded(p_sender, touch, duration)
			if noMove and Stagedataproxy:getInstance():get("isPopup") == false then
				if GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.PVE2 then
					
				else
					onLoadStageInfoHandler()
				end
			end
			layoutStage:setScale(1.0)
			noMove = true
			return Constants.TOUCH_RET.TRANSIENT
		 end
		layoutStage:setOnTouchBeganScriptHandler(onTouchBegan)
		layoutStage:setOnTouchMovedScriptHandler(onTouchMoved)
		layoutStage:setOnTouchEndedScriptHandler(onTouchEnded)
	end
end  

local function event_elite_chapter()  --加载精英副本 
	local mapCell = CPageViewCell:new()
	TuiManager:getInstance():parseCell(mapCell, "cell_elite_map" .. currentEliteChapter, PATH_UI_PVE)
	layout_pve_map:removeAllChildren()
	Utils.addCellToParent(mapCell,layout_pve_map)
	mapCell:setPositionY(mapCell:getPositionY()+400)

	local layout_elite_map = mapCell:getChildByTag(Tag_ui_pve["LAYOUT_ELITE_MAP" .. currentEliteChapter])
	local mapName = ConfigManager.getChpaterMapName(currentEliteChapter)
	local img_map = TextureManager.createImg("map/" .. mapName .. "_map.jpg")
	Utils.addCellToParent(img_map,layout_elite_map,true)

	for i=1,4 do
		local layoutStagePos = mapCell:getChildByTag(Tag_ui_pve["LAYOUT_ELITE_" .. currentEliteChapter .."_STAGE_"..i])
		local Cell = CGridViewCell:new() 
		TuiManager:getInstance():parseCell(Cell, "cell_stage", PATH_UI_PVE) 
		Utils.addCellToParent(Cell,layoutStagePos)

		local isTouchStage = true 
		local layoutStage = Cell:getChildByTag(Tag_ui_pve.LAYOUT_STAGE)
		if PetAttributeDataProxy:getInstance():get("dropStage")==i then --从掉落中追踪过来
			local jump = cc.JumpBy:create(0.4, cc.p(0,40), 0, 2)
			local action = cc.Sequence:create(jump, jump:reverse())
			layoutStage:runAction(cc.RepeatForever:create(action))
		end
		-----隐藏没有通过关卡 让将要闯的关卡的跳动
		local num = 0  --本章已经开启的关卡
		local nowChapter = Player:getInstance():get("eliteChapterId")
		local nowStage = Player:getInstance():get("eliteStageId")
		if nowStage >= 4 then
			nowChapter = nowChapter + 1
			nowStage = 1
		else
			nowStage = nowStage + 1
		end

		if currentEliteChapter < nowChapter then
			num = 4
		else
			num = nowStage
		end
		
		if i > num  then
			layoutStage:setVisible(false)
			isTouchStage = false
		elseif i == num  then
			local jump = cc.JumpBy:create(0.4, cc.p(0,40), 0, 2)
			local action = cc.Sequence:create(jump, jump:reverse())
			if PetAttributeDataProxy:getInstance():get("dropStage")==0 then --从掉落中追踪过来
				layoutStage:runAction(cc.RepeatForever:create(action))
			end
		end
		--------显示已经通过的关卡
		local stageConfig =  ConfigManager.getStageEliteConfig(currentEliteChapter,i)
		local imgBg =  layoutStage:getChildByTag(Tag_ui_pve.IMG_NORMAL_BG)
		imgBg:setSpriteFrame("ui_pve/img_elite.png")
		imgBg:setPositionY(imgBg:getPositionY()+10)
		local imgPet = layoutStage:getChildByTag(Tag_ui_pve.IMG_STAGE_PET)
		
		imgPet:setTexture("pet/" .. stageConfig.model .. ".png")
		local imgStar1 = layoutStage:getChildByTag(Tag_ui_pve.IMG_STAGE_STAR1)
		local imgStar2 = layoutStage:getChildByTag(Tag_ui_pve.IMG_STAGE_STAR2)
		local imgStar3 = layoutStage:getChildByTag(Tag_ui_pve.IMG_STAGE_STAR3)		
		imgStar1:setVisible(false)
		imgStar2:setVisible(false)
		imgStar3:setVisible(false)

		for k,m in ipairs(eliteChapterInfo) do
			if m[1] == i then
				if m[2] == 1 then
					imgStar1:setVisible(true)
				elseif m[2] == 2 then
				    imgStar1:setVisible(true)
				    imgStar2:setVisible(true)
				elseif m[2] == 3 then
					imgStar1:setVisible(true)
				    imgStar2:setVisible(true)
				    imgStar3:setVisible(true)
				end
			end
		end

		local stageRecord = StageRecord:getInstance()	
		local function onLoadStageInfoHandler(p_sender)  --设置 类型 章节 关卡 星级
			stageRecord:set("dungeonType",Constants.DUNGEON_TYPE.ELITE)
			stageRecord:set("chapter",currentEliteChapter)
			stageRecord:set("stage",i)

			local starNum = false
			local exitnum = 0
			for k,v in ipairs(eliteChapterInfo) do
				if v[1]==i then
					starNum = true
					exitnum = k
					stageRecord:set("starNum",v[2])
					stageRecord:set("remainingtimes",v[3])
				end
			end
			if starNum == false then
				stageRecord:set("starNum",0)
				local elite_nums = ConfigManager.getStageCommonConfig('elite_nums')
				stageRecord:set("remainingtimes",elite_nums)
			end
			Utils.runUIScene("PvePopup")
			local function updateSweepNum(num)--更行扫荡次数
				if starNum then
					eliteChapterInfo[exitnum][3] = num
				end
			end
			NormalDataProxy:getInstance().updateSweepNum = updateSweepNum
			local function pveBattle()
				Utils.replaceScene("BattleUI",__instance)
			end
			NormalDataProxy:getInstance().pveBattle = pveBattle
		end

		local noMove = true
		local xx,yy = nil,nil
		local function onTouchBegan(p_sender, touch)
			local selfLocation = __instance:convertTouchToNodeSpace(touch)
			xx,yy = selfLocation.x,selfLocation.y
			local layoutLocation = layoutStage:convertTouchToNodeSpace(touch)
			local size = layoutStage:getContentSize()
			if Stagedataproxy:getInstance():get("isPopup") == false and yy>70 and isTouchStage and size and layoutLocation.x>0 and layoutLocation.x<size.width and layoutLocation.y>0 and layoutLocation.y<size.height then
				layoutStage:setScale(0.9)
			end
			return Constants.TOUCH_RET.TRANSIENT
		end 
		local function onTouchMoved( p_sender,touch )
			local selfLocation = __instance:convertTouchToNodeSpace(touch)

			local xxD = math.abs(math.floor(selfLocation.x-xx))
			local yyD = math.abs(math.floor(selfLocation.y-yy))
			if xxD >30 or yyD >30 then
				noMove = false
				layoutStage:setScale(1.0)
			end
			layoutStage:setScale(1.0)
			return Constants.TOUCH_RET.TRANSIENT
		end
		local function onTouchEnded(p_sender, touch, duration)
			if noMove and Stagedataproxy:getInstance():get("isPopup") == false then
				layoutStage:setScale(1.0)
				onLoadStageInfoHandler()
			end
			noMove = true
			return Constants.TOUCH_RET.TRANSIENT
		end  
		layoutStage:setOnTouchBeganScriptHandler(onTouchBegan)
		layoutStage:setOnTouchMovedScriptHandler(onTouchMoved)
		layoutStage:setOnTouchEndedScriptHandler(onTouchEnded)
	end
end

local function event_load_normal_stagestar( result )
	if currentNormalChapter <=0 then
		currentNormalChapter = 1
	end

	if currentNormalChapter > 15 then
		currentNormalChapter = 15
	end

	if nowNormalChapter <=1 then
		btnLeftArrow:setVisible(false)
		btnRightArrow:setVisible(false)
	elseif nowNormalChapter>1 and currentNormalChapter<=1 then
		btnLeftArrow:setVisible(false)
		btnRightArrow:setVisible(true)
	elseif currentNormalChapter == nowNormalChapter then
		btnLeftArrow:setVisible(true)
		btnRightArrow:setVisible(false)
	elseif currentNormalChapter < nowNormalChapter then
		btnLeftArrow:setVisible(true)
		btnRightArrow:setVisible(true)
	end

	local stageinfo	= result["stageinfo"] 
	local starNum = 0  --总星数
	chapterinfo = {}
	local index = 0
	for k,v in ipairs(stageinfo) do
		starNum = starNum + v["starnum"]
		table.insert(chapterinfo,{v["stage_id"],v["starnum"],v["remaintime"]})
	end
	local starRewardConfig = ConfigManager.getPveStarReward(1,currentNormalChapter)
	local open = false
	if starNum < starRewardConfig.star then
		btnChestOpen:setVisible(false)
		btnChestClose:setVisible(true)
	else
		open = true
		btnChestOpen:setVisible(true)
		btnChestClose:setVisible(false)
	end

	layoutChest:setOnTouchBeganScriptHandler(function() 
		if open then
			local function getstarreward( result )
				for i,v in ipairs(result["pets"]) do
					ItemManager.addPet(v)
				end
	    		ItemManager.updateItems(result["items"])
				TipManager.showTip("恭喜获得 钻石+" .. result["diamond"]-Player:getInstance():get("diamond"))
				Player:getInstance():set("diamond",result["diamond"])
				layoutChest:setVisible(false)
			end
			if StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.NORMAL  then
				NetManager.sendCmd("getstarreward",getstarreward,Constants.DUNGEON_TYPE.NORMAL,currentNormalChapter)
			else
				NetManager.sendCmd("getstarreward",getstarreward,Constants.DUNGEON_TYPE.ELITE,currentEliteChapter)
			end
		else
			if StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.NORMAL  then
				Stagedataproxy:getInstance():set("chapter",currentNormalChapter)
			else
				Stagedataproxy:getInstance():set("chapter",currentEliteChapter)
			end
			Utils.runUIScene("ChestRewardPopup") --预览奖励
		end
		return false
	end)

	if result["chest_reward"]==1 then
		layoutChest:setVisible(false)
	else
		layoutChest:setVisible(true)
	end
	__instance.labChestNum:setString(starNum.."/36")  --总星数	
	__instance:unscheduleScript()
	layoutNormaltitle:setVisible(true)
	layoutElitetitle:setVisible(false)
	local labNormalTitle = layoutNormaltitle:getChildByTag(Tag_ui_pve.LAB_NORMAL_TITLE_TIP)
	local chapterText = TextManager.getChapterName(currentNormalChapter)
	labNormalTitle:setString(chapterText.chapter_name)

	event_normal_chapter()
	__instance:yunDisperse()
end

local function event_load_elite_stagestar( result )
	if currentEliteChapter <=0 then
		currentEliteChapter = 1
	end

	if currentEliteChapter > 15 then
		currentEliteChapter = 15
	end
	
	if nowEliteChapter <=1 then
		btnLeftArrow:setVisible(false)
		btnRightArrow:setVisible(false)
	elseif nowEliteChapter >1 and currentEliteChapter<=1 then
		btnLeftArrow:setVisible(false)
		btnRightArrow:setVisible(true)
	elseif currentEliteChapter == nowEliteChapter then
		btnLeftArrow:setVisible(true)
		btnRightArrow:setVisible(false)
	elseif currentEliteChapter < nowEliteChapter then
		btnLeftArrow:setVisible(true)
		btnRightArrow:setVisible(true)
	end

	eliteChapterInfo = {}
	local stageinfo	= result["stageinfo"] 
	local starNum = 0  --总星数
	for k,v in pairs(stageinfo) do
		starNum = starNum + v["starnum"]
		table.insert(eliteChapterInfo,{v["stage_id"],v["starnum"],v["remaintime"]})
	end

	local starRewardConfig = ConfigManager.getPveStarReward(2,currentEliteChapter)
	local open = false
	if starNum < starRewardConfig.star then
		btnChestOpen:setVisible(false)
		btnChestClose:setVisible(true)
	else
		open = true
		btnChestOpen:setVisible(true)
		btnChestClose:setVisible(false)
	end

	layoutChest:setOnTouchBeganScriptHandler(function() 
		if open then
			local function getstarreward( result )
				for i,v in ipairs(result["pets"]) do
					ItemManager.addPet(v)
				end
	    		ItemManager.updateItems(result["items"])
				TipManager.showTip("恭喜获得 钻石+" .. result["diamond"]-Player:getInstance():get("diamond"))
				Player:getInstance():set("diamond",result["diamond"])
				layoutChest:setVisible(false)
			end
			if StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.NORMAL  then
				NetManager.sendCmd("getstarreward",getstarreward,Constants.DUNGEON_TYPE.NORMAL,currentNormalChapter)
			else
				NetManager.sendCmd("getstarreward",getstarreward,Constants.DUNGEON_TYPE.ELITE,currentEliteChapter)
			end
		else
			if StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.NORMAL  then
				Stagedataproxy:getInstance():set("chapter",currentNormalChapter)
			else
				Stagedataproxy:getInstance():set("chapter",currentEliteChapter)
			end
			Utils.runUIScene("ChestRewardPopup") --预览奖励
		end
		return false
	end)

	if result["chest_reward"]==1 then
		layoutChest:setVisible(false)
	else
		layoutChest:setVisible(true)
	end
	
	__instance.labChestNum:setString(starNum.."/12")  --总星数
	__instance:unscheduleScript()
	layoutNormaltitle:setVisible(false)
	layoutElitetitle:setVisible(true)
	local labEliteTitle = layoutElitetitle:getChildByTag(Tag_ui_pve.LAB_ELITE_TITLE_TIP)
	local chapterText = TextManager.getChapterName(currentEliteChapter)
	labEliteTitle:setString(chapterText.chapter_name)

	event_elite_chapter()
	__instance:yunDisperse()
end

function PveUI:yunDisperse()
	img_yun1:stopAllActions()
	img_yun2:stopAllActions()
	img_yun3:stopAllActions()
	img_yun4:stopAllActions()
	img_yun1:setPosition(yun1newposition)
	img_yun2:setPosition(yun2newposition)
	img_yun3:setPosition(yun3newposition)
	img_yun4:setPosition(yun4newposition)
	img_yun1:runAction(cc.MoveTo:create(0.5,yun1oldposition))
	img_yun2:runAction(cc.MoveTo:create(0.5,yun2oldposition))
	img_yun3:runAction(cc.MoveTo:create(0.5,yun3oldposition))
	img_yun4:runAction(cc.MoveTo:create(0.5,yun4oldposition))
end

local function onLoadNormalStage()
	currentNormalChapter = nowNormalChapter
	StageRecord:getInstance():set("dungeonType",Constants.DUNGEON_TYPE.NORMAL) --设置副本类型
	NetManager.sendCmd("loadstagestar",event_load_normal_stagestar,Constants.DUNGEON_TYPE.NORMAL,currentNormalChapter)
end

local function onLoadElitestage()
	currentEliteChapter = nowEliteChapter
	StageRecord:getInstance():set("dungeonType",Constants.DUNGEON_TYPE.ELITE)  --设置副本类型 
	NetManager.sendCmd("loadstagestar",event_load_elite_stagestar,Constants.DUNGEON_TYPE.ELITE,currentEliteChapter)
end
--返回
local function event_return(p_sender)
	local proxy = PetAttributeDataProxy:getInstance()
	if proxy:get("isDrop") == true then
		proxy:set("isDrop",false)
		proxy:set("dropStage",0)
		Utils.popScene()
		Utils.runUIScene("ItemDropPopup")
		if NormalDataProxy:getInstance().updateItem then
			NormalDataProxy:getInstance().updateItem()
		end
		NormalDataProxy:getInstance().updateItem = nil
	elseif NormalDataProxy:getInstance():get("isDaliyPursue") then
		Utils.popScene()
		Utils.runUIScene("DailyPopup")
	else
		Utils.replaceScene("MainUI",__instance)
	end
end

--向左滑动
function PveUI:event_left_arrow()
	arrowScrol = 1
	if StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.NORMAL  then
		if currentNormalChapter <= 1 then
			arrowScrol = 0
			return
		end
		img_yun1:runAction(cc.MoveTo:create(0.3,yun1newposition))
		img_yun2:runAction(cc.MoveTo:create(0.3,yun2newposition))
		img_yun3:runAction(cc.MoveTo:create(0.3,yun3newposition))
		img_yun4:runAction(cc.MoveTo:create(0.3,yun4newposition))
		currentNormalChapter = currentNormalChapter - 1
		NetManager.sendCmd("loadstagestar",event_load_normal_stagestar,Constants.DUNGEON_TYPE.NORMAL,currentNormalChapter)
	else
		if currentEliteChapter <= 1 then
			arrowScrol = 0
			return
		end
		img_yun1:runAction(cc.MoveTo:create(0.3,yun1newposition))
		img_yun2:runAction(cc.MoveTo:create(0.3,yun2newposition))
		img_yun3:runAction(cc.MoveTo:create(0.3,yun3newposition))
		img_yun4:runAction(cc.MoveTo:create(0.3,yun4newposition))
		currentEliteChapter = currentEliteChapter - 1
		NetManager.sendCmd("loadstagestar",event_load_elite_stagestar,Constants.DUNGEON_TYPE.ELITE,currentEliteChapter)
	end	
end
--向右滑动 
function PveUI:event_right_arrow()
	arrowScrol = 2
	if StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.NORMAL  then
		if currentNormalChapter >= nowNormalChapter then
			arrowScrol = 0
			return
		end
		img_yun1:runAction(cc.MoveTo:create(0.3,yun1newposition))
		img_yun2:runAction(cc.MoveTo:create(0.3,yun2newposition))
		img_yun3:runAction(cc.MoveTo:create(0.3,yun3newposition))
		img_yun4:runAction(cc.MoveTo:create(0.3,yun4newposition))
		currentNormalChapter = currentNormalChapter + 1
		NetManager.sendCmd("loadstagestar",event_load_normal_stagestar,Constants.DUNGEON_TYPE.NORMAL,currentNormalChapter)
	else
		if currentEliteChapter >= nowEliteChapter then
			arrowScrol = 0
			return
		end
		img_yun1:runAction(cc.MoveTo:create(0.3,yun1newposition))
		img_yun2:runAction(cc.MoveTo:create(0.3,yun2newposition))
		img_yun3:runAction(cc.MoveTo:create(0.3,yun3newposition))
		img_yun4:runAction(cc.MoveTo:create(0.3,yun4newposition))
		currentEliteChapter = currentEliteChapter + 1
		NetManager.sendCmd("loadstagestar",event_load_elite_stagestar,Constants.DUNGEON_TYPE.ELITE,currentEliteChapter)
	end	
end

function PveUI:onLoadScene()
	winSize = cc.Director:getInstance():getVisibleSize()
	TuiManager:getInstance():parseScene(self,"panel_pve",PATH_UI_PVE)

	local layoutTop = self:getControl(Tag_ui_pve.PANEL_PVE,Tag_ui_pve.LAYOUT_TOP)
	Utils.floatToTop(layoutTop)
	local layout_addenergy = layoutTop:getChildByTag(Tag_ui_pve.LAYOUT_ADDENERGY)

	local btnEnergy = layout_addenergy:getChildByTag(Tag_ui_pve.BTN_ENERGY)
	layout_pve_map = self:getControl(Tag_ui_pve.PANEL_PVE,Tag_ui_pve.LAYOUT_PVE_MAP)
	layout_pve_map:removeAllChildren()
	local player = Player:getInstance()
	layout_addenergy:setOnTouchBeganScriptHandler(function()
		Utils.buyEnergy()
		return false
	end)

	layoutNormaltitle = layoutTop:getChildByTag(Tag_ui_pve.LAYOUT_NORMAL_TITLE)
	layoutElitetitle = layoutTop:getChildByTag(Tag_ui_pve.LAYOUT_ELITE_TITLE)

	layoutChest = layoutTop:getChildByTag(Tag_ui_pve.LAYOUT_CHEST)
	btnChestOpen = layoutChest:getChildByTag(Tag_ui_pve.BTN_CHEST_OPEN) --宝箱开启
	btnChestClose = layoutChest:getChildByTag(Tag_ui_pve.BTN_CHEST_CLOSE)   --宝箱未开启

   	local atlas = "spine/spine_pve/spine_chest_open.atlas"
	local json  = "spine/spine_pve/spine_chest_open.json"
	local spine = sp.SkeletonAnimation:create(json, atlas)
	spine:setAnimation(0, "part1", true)
	Utils.addCellToParent(spine,btnChestOpen)

	local layoutFunc = self:getControl(Tag_ui_pve.PANEL_PVE,Tag_ui_pve.LAYOUT_FUNCTION)
	Utils.floatToBottom(layoutFunc)
	local btnReturn = layoutFunc:getChildByTag(Tag_ui_pve.BTN_RETURN)
	btnReturn:setOnClickScriptHandler(event_return)

	if player:get("normalStageId") >= 12  and player:get("normalChapterId")<15 then
		nowNormalChapter = player:get("normalChapterId") + 1
	else
		nowNormalChapter = player:get("normalChapterId")
	end

	if player:get("eliteStageId")>=4 and player:get("eliteChapterId")<player:get("normalChapterId")  and player:get("eliteChapterId")<15  then
		nowEliteChapter = player:get("eliteChapterId") + 1
	else
		nowEliteChapter = player:get("eliteChapterId")
	end
	
	local eliteConfig = ConfigManager.getStageCommonConfig('elite_openlevel')
	local tgvNormalstage = layoutFunc:getChildByTag(Tag_ui_pve.TGV_NORMAL)
	local tgvElitestage = layoutFunc:getChildByTag(Tag_ui_pve.TGV_ELITE)
	if Player:getInstance():get("level") < eliteConfig then
		tgvNormalstage:setVisible(false)
		tgvElitestage:setVisible(false)
	end
	if StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.NORMAL  then
		tgvNormalstage:setChecked(true)
		if StageRecord:getInstance():get("chapter") == 0 then
			if player:get("normalStageId") >= 12 and player:get("normalChapterId")<15  then
				currentNormalChapter = player:get("normalChapterId")+1
				nowNormalChapter = currentNormalChapter
			else
				currentNormalChapter = Player:getInstance():get("normalChapterId")
				nowNormalChapter = currentNormalChapter
			end
		else
			currentNormalChapter = StageRecord:getInstance():get("chapter")
			if currentNormalChapter ==  player:get("normalChapterId") and  player:get("normalStageId") >= 12 and currentNormalChapter<15 then
				currentNormalChapter = currentNormalChapter + 1
			end
		end
		NetManager.sendCmd("loadstagestar",event_load_normal_stagestar,Constants.DUNGEON_TYPE.NORMAL,currentNormalChapter)
	else
		tgvElitestage:setChecked(true)
		if StageRecord:getInstance():get("chapter")==0 then
			if player:get("eliteStageId")>=4 and player:get("eliteChapterId")<player:get("normalChapterId") and player:get("eliteChapterId")<15 then
				currentEliteChapter = player:get("eliteChapterId")+1
				nowEliteChapter = currentEliteChapter
			else
				currentEliteChapter = player:get("eliteChapterId")
				nowEliteChapter = currentEliteChapter
			end
		else
			currentEliteChapter = StageRecord:getInstance():get("chapter")
			if currentEliteChapter == player:get("eliteChapterId") and player:get("eliteStageId") >= 4 and player:get("eliteChapterId")<player:get("normalChapterId") and currentEliteChapter<15 then
				currentEliteChapter = currentEliteChapter + 1
			end
		end
		NetManager.sendCmd("loadstagestar",event_load_elite_stagestar,Constants.DUNGEON_TYPE.ELITE,currentEliteChapter)
	end	
	tgvNormalstage:setOnClickScriptHandler(onLoadNormalStage) --点击进入普通副本
	tgvElitestage:setOnClickScriptHandler(onLoadElitestage)--点击进入精英副本
	--领取星级奖励 
	__instance.labChestNum = layoutChest:getChildByTag(Tag_ui_pve.LAB_STAR_NUM)--已经获得的星数
	__instance.energy = layout_addenergy:getChildByTag(Tag_ui_pve.LAB_ENERGY_NUM)
	local maxEnergy = ConfigManager.getUserConfig(Player:getInstance():get("level")).max_energy
	__instance.energy:setString(Player:getInstance():get("energy") .. '/'  .. maxEnergy)
	local function updateEnergy()
		if __instance.energy then
			__instance.energy:setString(Player:getInstance():get("energy") .. '/'  .. maxEnergy)
		end
	end
	NormalDataProxy:getInstance().updateEnergy = updateEnergy
	--左右按钮 
	btnLeftArrow = __instance:getControl(Tag_ui_pve.PANEL_PVE,Tag_ui_pve.BTN_LEFTARROW)
	btnRightArrow = __instance:getControl(Tag_ui_pve.PANEL_PVE,Tag_ui_pve.BTN_RIGHTARROW)
	btnLeftArrow:setOnClickScriptHandler(self.event_left_arrow)
	btnRightArrow:setOnClickScriptHandler(self.event_right_arrow)

	local sequence1 =  cc.Sequence:create(cc.MoveBy:create(0.25,cc.p(-20,0)),cc.MoveBy:create(0.25,cc.p(20,0)),nil)
	btnLeftArrow:runAction(cc.RepeatForever:create(sequence1))
	local sequence2 =  cc.Sequence:create(cc.MoveBy:create(0.25,cc.p(20,0)),cc.MoveBy:create(0.25,cc.p(-20,0)),nil)
	btnRightArrow:runAction(cc.RepeatForever:create(sequence2))

	img_yun1 = __instance:getControl(Tag_ui_pve.PANEL_PVE,Tag_ui_pve.IMG_YUN1)
	img_yun2 = __instance:getControl(Tag_ui_pve.PANEL_PVE,Tag_ui_pve.IMG_YUN2)
	img_yun3 = __instance:getControl(Tag_ui_pve.PANEL_PVE,Tag_ui_pve.IMG_YUN3)
	img_yun4 = __instance:getControl(Tag_ui_pve.PANEL_PVE,Tag_ui_pve.IMG_YUN4)
	winSize = cc.Director:getInstance():getWinSize()
	 yun1oldposition = {x = img_yun1:getPositionX(),y = img_yun1:getPositionY()}
	 yun2oldposition = {x = img_yun2:getPositionX(),y = img_yun2:getPositionY()}
	 yun3oldposition = {x = img_yun3:getPositionX(),y = img_yun3:getPositionY()}
	 yun4oldposition = {x = img_yun4:getPositionX(),y = img_yun4:getPositionY()}
	 yun1newposition = {x = 0-winSize.width/4+30,y = 0+winSize.height/4}
	 yun2newposition = {x = 0+winSize.width/4+30,y = 0+winSize.height/4}
	 yun3newposition = {x = 0-winSize.width/4+30,y = 0-winSize.height/4+30}
	 yun4newposition = {x = 0+winSize.width/4+30,y = 0-winSize.height/4+30}
	img_yun1:setPosition(yun1newposition)
	img_yun2:setPosition(yun2newposition)
	img_yun3:setPosition(yun3newposition)
	img_yun4:setPosition(yun4newposition)

	local function onNodeEvent(event)
		if "enter" == event then
			local player = Player:getInstance()
			local maxEnergy = ConfigManager.getUserConfig(player:get("level")).max_energy
			if player:get("energy")<maxEnergy then
				local energy_recover_time = ConfigManager.getUserCommonConfig('energy_recover_time')
				scheduleIDEnergy = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
					player:set("energy",player:get("energy")+1)
					if NormalDataProxy:getInstance().updateEnergy then
						NormalDataProxy:getInstance().updateEnergy()
					end
					if player:get("energy")>=maxEnergy then
						cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleIDEnergy)
						scheduleIDEnergy = nil
					end
				end,energy_recover_time, false)
			end
			
		elseif "enterTransitionFinish"  == event then
			-- if GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.PVE_STAGE3 then
			-- 	local function event_enter_view()
			-- 		Utils.dispatchCustomEvent("event_enter_view",{view = "PveUI",phase = GuideManager.MAIN_GUIDE_PHASES.PVE_STAGE3 ,scene = self})
			-- 	end
			-- 	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(event_enter_view)))
			-- end
			local eliteConfig = ConfigManager.getStageCommonConfig('elite_openlevel')
			GuideManager.func_guide_status_ = GuideManager.funcGuideCheaked()
			if Player:getInstance():get("level") >= eliteConfig and GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.ELITE_STAGE1) == false then
				Utils.dispatchCustomEvent("enter_view",{callback = function ( )
					Utils.dispatchCustomEvent("event_elite_stage",{view = "PveUI",phase = GuideManager.FUNC_GUIDE_PHASES.ELITE_STAGE ,scene=self})
				end, params = {view = "func", phase = GuideManager.FUNC_GUIDE_PHASES.ELITE_STAGE}})
			end

			local  nowChapter = Player:getInstance():get("normalChapterId")
			if Player:getInstance():get("normalStageId") >=12 and Player:getInstance():get("normalChapterId")<15 then
				nowChapter = nowChapter + 1
			end
			
			if GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.PVE2 then
				Utils.dispatchCustomEvent("event_enter_view",{view = "PveUI",phase = GuideManager.MAIN_GUIDE_PHASES.PVE2 ,scene = self})
			end

			if Player:getInstance():get("normalStageId") == 2 and Player:getInstance():get("normalChapterId") == 1  then
				local function getNewPet()
					if GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.PVE_STAGE3 then
						local function pvegetPet()
							Utils.dispatchCustomEvent("event_enter_view",{view = "PveUI",phase = GuideManager.MAIN_GUIDE_PHASES.PVE_STAGE3 ,scene = self})
						end
						local config = ConfigManager.getGuidePetConfig(7)
						WildDataProxy:getInstance():set("newPet_mid",config.mid)
						WildDataProxy:getInstance():set("newPet_form",1)
						GuideManager.guide_pet = 3

						local listener = cc.EventListenerCustom:create("new_pet_3", pvegetPet)
					    local dispatcher = cc.Director:getInstance():getEventDispatcher()
					    dispatcher:addEventListenerWithFixedPriority(listener, 1)
					    
						Utils.runUIScene("NewPetPopup")
					end
					self:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
						Stagedataproxy:getInstance():set("isPopup",false)
					end)))
				end
				Utils.dispatchCustomEvent("enter_view",{callback = getNewPet, params = {view = "stage_map", chapter=nowChapter}})
			elseif Player:getInstance():get("normalStageId") >= 12 then
				Utils.dispatchCustomEvent("enter_view",{callback = nil, params = {view = "stage_map", chapter=nowChapter}})
			end
		elseif "exit" == event then
			__instance:unscheduleScript()
			if scheduleIDEnergy then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleIDEnergy)
				scheduleIDEnergy = nil
			end
		end
	end
	
	self:registerScriptHandler(onNodeEvent)
	TouchEffect.addTouchEffect(self)
	
end 

