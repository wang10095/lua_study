module("StoryManager", package.seeall)

local STORY_TYPE = { --类型
	VIEW_STORY   =1,    --场景
	CHAPTER_STORY=2, --章节
	STAGE_STORY_START  =3,   --关卡开始
	STAGE_STORY_END =4,    --关卡结束
	STORY_FUNC = 5,
}  

STYLE_TYPE = { --对话类型
	ORDINARY  = 1,
	RECODER   = 2,
	VIDEO     = 3,
	ANIMATION = 4,
}

story_blocked = false --是否播放剧情
local story_type = nil -- 剧情类型
local container = nil 

local mask = nil

local function getMask()
	if mask == nil then
		--
	end
	return mask
end

-- 检查需要播放剧情
-- return true: 播放, false: 不播放
local function checkStory(storyConfig,params)
	local player = Player:getInstance()
    local stageRecord = StageRecord:getInstance()

	if story_type == STORY_TYPE.VIEW_STORY then      --场景剧情
		print("view_story = "..player:get("view_story"))
	    if storyConfig ~= nil and  player:get("level") == storyConfig[1].level and  params.scene == player:get("view_story")+1 then
	    	StoryProxy:getInstance():set("storyType", 1)
	    	return true
	    end
	elseif story_type == STORY_TYPE.CHAPTER_STORY then  --章节的剧情
		local currentChapter = player:get("normalChapterId")
		if player:get("normalStageId") >= 12 and player:get("normalChapterId") <15 then
			currentChapter = currentChapter + 1
		end
	    if stageRecord:get("dungeonType") == Constants.DUNGEON_TYPE.NORMAL then
	        if  currentChapter >= player:get("chapter_story") and storyConfig~=nil  then
	        	StoryProxy:getInstance():set("storyType",2)
	            return true
	        end
	    end
	elseif story_type == STORY_TYPE.STAGE_STORY_START then  --战斗开始剧情
	    if stageRecord:get("dungeonType") == Constants.DUNGEON_TYPE.NORMAL then
	    	if (GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.STAGE_1
	    	   or GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.STAGE_2) 
	    	   and player:get("normalStageId") <=3 and storyConfig~=nil then
	    		return true
	    	end
	        if  player:get("normalChapterId") == stageRecord:get("chapter") and player:get("normalStageId")+1 == stageRecord:get("stage") and storyConfig~=nil  then
				return true
	        end
	    end
	elseif story_type == STORY_TYPE.STAGE_STORY_END then    --战斗结束剧情
        if stageRecord:get("dungeonType") == Constants.DUNGEON_TYPE.NORMAL then
        	if (GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.STAGE_1+1
	    	   or GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.STAGE_2+1) and storyConfig~=nil then
	    		return true
	    	end
            if  player:get("normalChapterId") == stageRecord:get("chapter") and player:get("normalStageId")+1 == stageRecord:get("stage") and storyConfig~=nil  then
              	return true
            end
        end
    elseif story_type == STORY_TYPE.STORY_FUNC then
    	return true
	end

	return false
end

local storyFunc = {
	function()	-- 普通对话

	end,
	function()  -- 录音机

	end,
	function()	-- 视频通话

	end,
	function()	-- 动画

	end,
}

-- 显示下一句对话
-- local function nextDialog()
-- end

-- 开始剧情
local function startStory(storyConfig, callbackFunc)
	-- 初始化本段剧情
	print("初始化本段剧情")
	StoryProxy:getInstance().storyConfig = storyConfig
	StoryProxy:getInstance().callback = callbackFunc
	Utils.runUIScene("StoryPopup") --在此弹出窗中进行对话
	-- nextDialog()	-- 开始对话
end

local function enterViewHandler(callbackFunc, params) --进入场景剧情
	local storyConfig = nil 
	print("story guide ") 
	if params.view == "battle" then
		story_type = STORY_TYPE.STAGE_STORY_START --设置剧情类型  战斗开始
		storyConfig = ConfigManager.getStageStoryConfig(params.chapter, params.stage, 0)
	elseif params.view == "stage_map" then
		story_type = STORY_TYPE.CHAPTER_STORY --设置剧情类型  开始新的章节
		storyConfig = ConfigManager.getChapterStoryConfig(params.chapter)
	elseif params.view == "view" then
		story_type = STORY_TYPE.VIEW_STORY --设置剧情类型   开启新的场景 
		storyConfig = ConfigManager.getViewStoryConfig(params.scene)
	elseif params.view == "func" then
		story_type = STORY_TYPE.STORY_FUNC --设置剧情类型   开启新的功能
		print("story = "..params.phase)
		storyConfig = ConfigManager.getFuncStoryConfig(params.phase)
	end
	if checkStory(storyConfig,params) == true then
		print("start Story")
		startStory(storyConfig, callbackFunc)
	else
		if callbackFunc then
			callbackFunc()
		end
	end

end

local function battleEndHandler(callbackFunc, params) --战斗结束剧情
	story_type = STORY_TYPE.STAGE_STORY_END  
	local storyConfig = ConfigManager.getStageStoryConfig(params.chapter, params.stage, 1)
	if checkStory(storyConfig,params) == true then
		startStory(storyConfig, callbackFunc)
	else
		if callbackFunc then
			callbackFunc()
		end
	end

end

local function event_enter_view(event)
	enterViewHandler(event._usedata.callback, event._usedata.params)
end

local function event_battle_end(event)
	battleEndHandler(event._usedata.callback, event._usedata.params)
end

local event_handlers = {
	enter_view = event_enter_view,
	battle_end = event_battle_end,
}

function initStoryManager()
	-- 初始化自定义事件监听
    for eventName,handler in pairs(event_handlers) do
    	Utils.addCustomEventListener(eventName, handler)
    end
end