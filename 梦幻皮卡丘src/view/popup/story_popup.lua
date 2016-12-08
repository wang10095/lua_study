require "view/tagMap/Tag_popup_story"

StoryPopup = class("StoryPopup",function()
	return TuiBase:create()
end)

StoryPopup.__index = StoryPopup
local __instance = nil
local count = nil
local canTouch = false  --死否可以点击
local typing = false -- 正在播放打字效果
local videoTable = {}

function StoryPopup:create()
	local ret = StoryPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function StoryPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function StoryPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_story.PANEL_STORY then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function StoryPopup:onLoadScene()
	count = 1
	TuiManager:getInstance():parseScene(self,"panel_story",PATH_POPUP_STORY)
	local img9_BG = self:getControl(Tag_popup_story.PANEL_STORY,Tag_popup_story.IMG9_STORY_POPUP)

	local layoutStory = self:getControl(Tag_popup_story.PANEL_STORY, Tag_popup_story.LAYOUT_STORY)
	Utils.floatToBottom(layoutStory)
	local lab_content = layoutStory:getChildByTag(Tag_popup_story.LAB_CONTENT)
	local lab_NPC_name = layoutStory:getChildByTag(Tag_popup_story.LAB_NPC_NAME)
	lab_content:setString("")
	lab_NPC_name:setString("")
	local layout_left_npc = layoutStory:getChildByTag(Tag_popup_story.LAYOUT_LEFT_NPC)
	local layout_middle_npc = layoutStory:getChildByTag(Tag_popup_story.LAYOUT_MIDDLE_NPC)
	local layout_right_npc = layoutStory:getChildByTag(Tag_popup_story.LAYOUT_RIGHT_NPC)
	
	local proxy = StoryProxy:getInstance()
	local storyConfig = StoryProxy:getInstance().storyConfig
	local callbackFunc = StoryProxy:getInstance().callback
	local name_str = ""
	local player = Player:getInstance()
	local function finishDialog()
		lab_content:stopAllActions()
		lab_content:setString(name_str)
	end

	for i,v in ipairs(storyConfig) do
		if v["style"] == StoryManager.STYLE_TYPE.VIDEO  then
			table.insert(videoTable,i)
		end
	end
	print("story_popup")
	local countVideo = 1    
	local videoSpine =  nil
	local function nextDialog() -- 下一句
		if storyConfig[count]["style"] == StoryManager.STYLE_TYPE.ORDINARY or storyConfig[count]["style"] == StoryManager.STYLE_TYPE.RECODER then -- 普通对话
			layout_left_npc:setVisible(true)
			layout_middle_npc:setVisible(false)
			layout_right_npc:setVisible(true)
			layout_left_npc:removeAllChildren()
			layout_right_npc:removeAllChildren()
			local npcName = nil
			if storyConfig[count]["NPC"]==0 then --玩家在左
				local img = (player:get("sex")==1 and TextureManager.createImg("player/boy.png" )) or TextureManager.createImg("player/girl.png")
				Utils.addCellToParent(img,layout_left_npc)
				npcName = Player:getInstance():get("nickname")
			else                                 --npc在右
				if storyConfig[count]["style"] == StoryManager.STYLE_TYPE.RECODER  then --录音机
					local atlas = "spine/spine_story/spine_story_video.atlas"
					local json = "spine/spine_story/spine_story_video.json"
					spine = sp.SkeletonAnimation:create(json, atlas)
					spine:setScale(1.2)
					spine:setAnimation(0, "part4", true)
					Utils.addCellToParent(spine,layout_right_npc)
					spine:setPositionY(spine:getPositionY()-150)
				else
					if storyConfig[count]["NPC"] == 10 or storyConfig[count]["NPC"]==11 or storyConfig[count]["NPC"]==17 then
						local atlas,json
						if storyConfig[count]["NPC"]==10 then
							atlas = TextureManager.RES_PATH.SPINE_TOURNAMENT_SHOP .. ".atlas"
					     	json = TextureManager.RES_PATH.SPINE_TOURNAMENT_SHOP .. ".json"
					    elseif storyConfig[count]["NPC"] == 11 then
					    	atlas = TextureManager.RES_PATH.SPINE_TOURNAMENT_PVP2 .. ".atlas"
						    json = TextureManager.RES_PATH.SPINE_TOURNAMENT_PVP2 .. ".json"
					    elseif storyConfig[count]["NPC"] == 17 then
					    	atlas = TextureManager.RES_PATH.SPINE_TOURNAMENT_PVP1 .. ".atlas"
						    json = TextureManager.RES_PATH.SPINE_TOURNAMENT_PVP1 .. ".json"
						end
						local spine = sp.SkeletonAnimation:create(json, atlas)
						spine:setAnimation(0, "part1", true)
						spine:setScale(2)
						if storyConfig[count]["NPC"] == 17 then
							spine:setScaleX(-1)
						end
						Utils.addCellToParent(spine,layout_right_npc)
						spine:setPositionY(spine:getPositionY()-300)
					else
						local img = TextureManager.createImg("story_npcs/img_story_npc_" .. storyConfig[count]["NPC"] .. ".png")
						Utils.addCellToParent(img,layout_right_npc)
						if storyConfig[count]["NPC"] == 15 then
							img:setColor(cc.c3b(0,0,0))
						end
					end
				end
				npcName = ConfigManager.getNPCStoryConfig(storyConfig[count]["NPC"]).name
			end
			lab_NPC_name:setString("[" .. npcName .. "]") --设置人名
			name_str = storyConfig[count]["content"]
			name_str = string.gsub(name_str,'%%nickname',Player:getInstance():get("nickname"))
			typing = true
			for i=1,#name_str do  --字一个个出现
				local sequence = cc.Sequence:create(cc.DelayTime:create(i*0.03),cc.CallFunc:create(function() 
					lab_content:setString(string.sub(name_str,1,i))
					if i == #name_str then
						typing = false
					end
				end))
				lab_content:runAction(sequence)
			end
		elseif storyConfig[count]["style"] == StoryManager.STYLE_TYPE.VIDEO then -- 视频通话
			layout_left_npc:setVisible(false)
			layout_middle_npc:setVisible(true)
			layout_right_npc:setVisible(false)
			layout_middle_npc:removeAllChildren()
 
			local atlas = "spine/spine_story/spine_story_video.atlas"
			local json = "spine/spine_story/spine_story_video.json"
			local spine
			if count == videoTable[1] then
				spine = Spine.spineMix(layout_middle_npc,"story","video","part1","part2",false,true,1.2)
			else
				spine = sp.SkeletonAnimation:create(json, atlas)
				spine:setScale(1.2)
				spine:setAnimation(0, "part2", true)
				Utils.addCellToParent(spine,layout_middle_npc)
			end
			spine:setPositionY(spine:getPositionY()-150)
			countVideo = countVideo + 1
			npcName = ConfigManager.getNPCStoryConfig(storyConfig[count]["NPC"]).name
			videoSpine = spine
	
			lab_NPC_name:setString("[" .. npcName .. "]") --设置人名
			name_str = storyConfig[count]["content"]
			name_str = string.gsub(name_str,'%%nickname',Player:getInstance():get("nickname"))
			typing = true
			for i=1,#name_str do  --字一个个出现
				local sequence = cc.Sequence:create(cc.DelayTime:create(i*0.03),cc.CallFunc:create(function() 
					lab_content:setString(string.sub(name_str,1,i))
					if i == #name_str then
						typing = false
					end
				end))
				lab_content:runAction(sequence)
			end
		elseif proxy:get("storyType") == StoryManager.STYLE_TYPE.ANIMATION then -- 动画
		
		end
	end

	nextDialog()

	local function onTouchBegan(touch,event)
		return true
	end
	local function onTouchEnded(touch,event)
		if typing then
			finishDialog()
			typing = false
			return
		end
	
		if count >= #storyConfig then
			if videoSpine and countVideo > #videoTable then
				videoSpine:setAnimation(0,"part3",false)
				__instance:runAction(cc.Sequence:create(cc.DelayTime:create(0.4),cc.CallFunc:create(function()
					Utils.popUIScene(__instance)
                    if callbackFunc then
                        callbackFunc()
                        callbackFunc = nil
                    end
				end),nil))
			else
				Utils.popUIScene(__instance)
                if callbackFunc then
                    callbackFunc()
                    callbackFunc = nil
                end
			end
			--保存后端
			local player = Player:getInstance()
			if StoryProxy:getInstance():get("storyType") == 1 then   --保存场景剧情
				NetManager.sendCmd("savestorystatus",function(result)      
					player:set("view_story",player:get("view_story")+1) 
					StoryProxy:getInstance():set("storyType",0)
				end,player:get("view_story")+1,player:get("normalChapterId"))
			elseif StoryProxy:getInstance():get("storyType")==2 then    --保存章节剧情
				local nowChapter = player:get("normalChapterId")
				if  player:get("normalStageId")>=12 then
					nowChapter = nowChapter + 1
					StoryProxy:getInstance():set("storyType",0)
				end
				NetManager.sendCmd("savestorystatus",function(result) 
	        		player:set("chapter_story",nowChapter)
	        	end,player:get("view_story"),nowChapter)
			end
		else
			if videoSpine and countVideo > #videoTable then
				videoSpine:setAnimation(0,"part3",false)
				__instance:runAction(cc.Sequence:create(cc.DelayTime:create(0.4),cc.CallFunc:create(function() 
					count = count + 1
					nextDialog()
				end),nil))
			else
				count = count + 1
				nextDialog()
			end
		end
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )   
	listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )  
	local eventDispatcher = __instance:getEventDispatcher() -- 时间派发器 
	eventDispatcher:addEventListenerWithFixedPriority(listener, -2)

	local mask = CLayout:create()
	mask:setBackgroundColor(cc.c4b(0, 0, 0, 127))
	mask:setContentSize(cc.Director:getInstance():getWinSize())
	mask:setPosition(cc.p(320, 480))
	self:addChild(mask, -1)

	local function onNodeEvent(event)
		if "enter" == event then
			Stagedataproxy:getInstance():set("isPopup",true)
		end
		if "exit" == event then
			eventDispatcher:removeEventListener(listener)
			Stagedataproxy:getInstance():set("isPopup",false)
		end
	end
	self:registerScriptHandler(onNodeEvent)
end 

