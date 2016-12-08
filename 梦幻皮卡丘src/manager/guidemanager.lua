module("GuideManager", package.seeall)

main_guide_phase_ = 1	-- 主线引导进度
func_guide_status_ = 0 -- 功能引导状态
guide_pet = 0
battle_shuffle = false
monsterId = 0
local cur_step_ = nil	--当前引导的步骤数
-- local mask = nil
local listener = nil
local eventDispatcher = nil
-- local slipper = nil
local container = nil
local scene = nil
local touchSize = nil
local addMask = function ()
end
local nextStep = function ()
end
local finishGuide = function ()
end

local GUIDE_UI_TAGS = {
	MASK = 1,
	TIP = 2,
	TIP_NPC = 3,
	ARROW = 4,
}

local MASK_TYPE = {
	NONE = 0,
	OPAQUE = 1,	-- 不透明
	TRANSPARENT = 2, -- 透明
}

GUIDE_TYPE = {
	MAIN = 1,
	FUNC = 2,
	EXTRA = 3,
}

MAIN_GUIDE_PHASES = {
	SET_NICKNAME = 1, 
	CHOOSE_FIRST_PET = 2,
	STAGE_1 = 3,
	STAGE_1_END = 4,
	WILD = 5,
	GOLD_CAPTURE = 6,
	DIAMOND_CAPTURE = 7,
	FINISH_WILD = 8,
	PVE1 = 9,
	PVE2 = 10,
	PVE3 = 11,
	STAGE_2 = 12,
	CAPTURE = 13,
	PVE_STAGE3 = 14,
	PVE_POPUP = 15,
	STAGE_3 = 16,
	START_BATTLE = 17,
}

FUNC_GUIDE_PHASES = {
	TREASURE_CHEST = 2,  --
	GREEDY_CAT = 3,
	BLOCK_UNIT = 4,
	ELITE_STAGE = 5,
	ACTIVITY1 = 6,
	BATTLE_PALACE = 7,
	ACTIVITY2 = 8,
	BATTLE_ROULETTE = 9, --对战轮盘
	ACTIVITY3 = 10,
	PYRAMID = 11, --战斗金字塔
    PET_TRAIN = 12,
    PET_SKILL = 13,
    PET_UPSTAR = 14,
    CHAMPION = 15,
    GOLD_HAND = 16,     --聚宝
    ELITE_STAGE1 = 17,  --精英关
    GOLDHAND_ONCE = 18, --聚宝一次
    DUNGEON = 19,
    PVP1 = 20,
    DEFANCE_TEAM = 21,
    PETLIST = 22,
    PETATTRIBUTE = 23,
    PET_SKILL_MAIN = 24,
    PET_SKILL_LIST = 25,
    BREEDHOUSE = 26,
    BREED = 27,
    BREED_HRIR = 28,
    BREED_CHOSE_INHERIT = 29,
    BREED_INHERIT = 30,
    INHERIT = 31,
    PET_LEVEL = 32,
}

FUNC_GUIDE_EXTRA = {
	PET_LEVEL_MAIN = 33,
	PET_LIST = 34,
	PET_APTITUDE = 35,
}

local guide_handlers_ = nil

-- 通过func_guide_status_检查功能引导是否已经完成
function isFuncGuideFinished(phase)
	if func_guide_status_ == 0 then
		return false
	else
		local Funcfinish = {}
		for i=1,32 do
			Funcfinish[i] = 1
		end
		local status = Utils.bit:d2b(func_guide_status_) 
		for k,v in pairs(status) do
			for i,j in pairs(Funcfinish) do 
				if phase == k and phase == i then
					if Utils.bit:_and(v,j) == 0 then
						print("该功能引导已经完成")
						return true
					else
						print("该功能引导没有完成")
						return false
					end
				end
			end
		end
	end
end

function changeFuncGuideStatus( phase )
	print("funcGuide changeFuncGuideStatus")
	
	local status = Utils.bit:d2b(func_guide_status_)
	if status == 0 then
		for i=1,32 do
			status[i] = 1 
		end
	end
	for i,j in pairs( status ) do
		if i == phase and j == 1 then
			status[i] = 0
		end
	end
	func_guide_status_ = Utils.bit:b2d(status)
	return Utils.bit:b2d(status)
	
end

function funcGuideCheaked()
	
	local status = Utils.bit:d2b(func_guide_status_)
	if status == 0 then
		for i=1,32 do
			status[i] = 1 
		end
	end
	
	if isFuncGuideFinished(FUNC_GUIDE_PHASES.ACTIVITY1) == true and isFuncGuideFinished(FUNC_GUIDE_PHASES.BATTLE_PALACE) ==false   then
		status[FUNC_GUIDE_PHASES.ACTIVITY1] = 1
	end
	if isFuncGuideFinished(FUNC_GUIDE_PHASES.ACTIVITY2) == true and isFuncGuideFinished(FUNC_GUIDE_PHASES.BATTLE_ROULETTE) ==false   then
		status[FUNC_GUIDE_PHASES.ACTIVITY2] = 1
	end
	if isFuncGuideFinished(FUNC_GUIDE_PHASES.ACTIVITY3) == true and isFuncGuideFinished(FUNC_GUIDE_PHASES.PYRAMID) ==false   then
		status[FUNC_GUIDE_PHASES.ACTIVITY3] = 1
	end
	if isFuncGuideFinished(FUNC_GUIDE_PHASES.GOLD_HAND) == true and isFuncGuideFinished(FUNC_GUIDE_PHASES.GOLDHAND_ONCE) ==false   then
		status[FUNC_GUIDE_PHASES.GOLD_HAND] = 1
	end
	if isFuncGuideFinished(FUNC_GUIDE_PHASES.ELITE_STAGE) == true and isFuncGuideFinished(FUNC_GUIDE_PHASES.ELITE_STAGE1) ==false   then
		status[FUNC_GUIDE_PHASES.ELITE_STAGE] = 1
	end
	if (isFuncGuideFinished(FUNC_GUIDE_PHASES.PET_TRAIN) == true or isFuncGuideFinished(FUNC_GUIDE_PHASES.PETLIST) == true) and isFuncGuideFinished(FUNC_GUIDE_PHASES.PETATTRIBUTE) == false then
		status[FUNC_GUIDE_PHASES.PET_TRAIN] = 1
		status[FUNC_GUIDE_PHASES.PETLIST] = 1
	end
	if (isFuncGuideFinished(FUNC_GUIDE_PHASES.CHAMPION) == true or isFuncGuideFinished(FUNC_GUIDE_PHASES.DUNGEON) == true or isFuncGuideFinished(FUNC_GUIDE_PHASES.PVP1) == true) and isFuncGuideFinished(FUNC_GUIDE_PHASES.DEFANCE_TEAM) == false then
		status[FUNC_GUIDE_PHASES.CHAMPION] = 1
		status[FUNC_GUIDE_PHASES.DUNGEON] = 1
		status[FUNC_GUIDE_PHASES.PVP1] = 1
	end
	if (isFuncGuideFinished(FUNC_GUIDE_PHASES.PET_SKILL_MAIN) == true or isFuncGuideFinished(FUNC_GUIDE_PHASES.PET_SKILL_LIST) == true) and isFuncGuideFinished(FUNC_GUIDE_PHASES.PET_SKILL) == false then
		status[FUNC_GUIDE_PHASES.PET_SKILL_MAIN] = 1
		status[FUNC_GUIDE_PHASES.PET_SKILL_LIST] = 1
		status[FUNC_GUIDE_PHASES.PET_SKILL] = 1
	end

	if (isFuncGuideFinished(FUNC_GUIDE_PHASES.BREEDHOUSE) == true 
		or isFuncGuideFinished(FUNC_GUIDE_PHASES.BREED) == true
		or isFuncGuideFinished(FUNC_GUIDE_PHASES.BREED_HRIR) == true 
		or isFuncGuideFinished(FUNC_GUIDE_PHASES.BREED_CHOSE_INHERIT)== true
		or isFuncGuideFinished(FUNC_GUIDE_PHASES.BREED_INHERIT)== true )
	    and isFuncGuideFinished(FUNC_GUIDE_PHASES.INHERIT)== false then
	    
		status[FUNC_GUIDE_PHASES.BREEDHOUSE] = 1
		status[FUNC_GUIDE_PHASES.BREED] = 1
		status[FUNC_GUIDE_PHASES.BREED_HRIR] = 1
		status[FUNC_GUIDE_PHASES.BREED_CHOSE_INHERIT] = 1
		status[FUNC_GUIDE_PHASES.BREED_INHERIT] = 1
		status[FUNC_GUIDE_PHASES.INHERIT] = 1
	end
	func_guide_status_ = Utils.bit:b2d(status)

	return Utils.bit:b2d(status)
end

local function initContainer()
	local winSize = cc.Director:getInstance():getVisibleSize()

	container = CLayout:create()
	container:setContentSize(winSize)
	container:setAnchorPoint(cc.p(0.5, 0.5))
	container:setPosition(cc.p(winSize.width/2, winSize.height/2))
	-- container:setZorder(255)
	-- container:
	container:retain()
	
end

-- @params	tip: 提示内容, tip_pos: 提示框位置, tip_npc: npc图片名（或类型), npc_pos: npc位置
local function addTip(tip, tip_pos, tip_npc, tip_npc_pos)
	-- if container:getChildByTag(GUIDE_UI_TAGS.TIP) ~= nil then
	-- 	container:removeChildByTag(GUIDE_UI_TAGS.TIP)
	-- end
end

local function addArrow(arrow_type, arrow_pos)
	-- if container:getChildByTag(GUIDE_UI_TAGS.TIP_NPC) ~= nil then
	-- 	container:removeChildByTag(GUIDE_UI_TAGS.TIP_NPC)
	-- end
end

local function guidePetTeam(guideType,guidePhase,pos,scale,rotation,moveByPos)

	-- local config = ConfigManager.getGuideConfig(guideType, guidePhase)
	local glView = cc.Director:getInstance():getOpenGLView()
    local screenSize = glView:getFrameSize()
	local size = cc.size(400,150)
	local pos1 = cc.p(400,350)
	if screenSize.width == 640 and screenSize.height == 960 then
		pos1 = cc.p(400,420)
		pos.y = pos.y + 60
	elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
		pos1 = cc.p(400,400) 
		pos.y = pos.y + 30
	end
	local img9Scale = TextureManager.createImg9(size,TextureManager.RES_PATH.GUIDETIPS_SCALE9)
	img9Scale:setPosition(cc.p(pos1))
	container:addChild(img9Scale,3)

	local label = CCLabelTTF:create("长按神奇宝贝拖动到战场上","fonts/FZCuYuan/M03S.ttf",30) 
	if cur_step_.count >= 2 then
		label:setString("上阵5个神奇宝贝后就\n可以开始战斗啦")
	elseif cur_step_.count < 3 and guideType == 2 then
		label:setString("达到5级的神奇宝贝\n才能防守与战斗！")
	elseif cur_step_.count < 3 and guideType == 2 then
		label:setString("必须上阵5个神奇宝贝\n才能防守与战斗！")
	end
	label:setPosition(pos1)
	label:setColor(cc.c3b(208,108,40))
	container:addChild(label,3)

	local layout = CLayout:create(size)
	layout:setPosition(cc.p(pos.x-200,pos.y-140))
	container:addChild(layout,1)

	local hand_normal = TextureManager.createImg(TextureManager.RES_PATH.HAND_NORMAL)
	hand_normal:setPosition(cc.p(pos.x-230,pos.y-160))
	container:addChild(hand_normal,3)

	local hand_select = TextureManager.createImg(TextureManager.RES_PATH.HAND_SELECT)
	hand_select:setPosition(cc.p(pos.x-230,pos.y-160))
	container:addChild(hand_select,3)
	hand_select:setVisible(false)
	local function click( )
		hand_normal:setVisible(false)
		hand_select:setVisible(true)
		local json2 = TextureManager.RES_PATH.SPINE_GUIDE_POINT..".json"
		local atlas2 = TextureManager.RES_PATH.SPINE_GUIDE_POINT..".atlas"
		local point = sp.SkeletonAnimation:create(json2, atlas2, 0.4)
		-- point:setTimeScale(0.7)
		point:setAnimation(0, "part1", false)
		point:setPosition(cc.p(size.width/2-50,size.height/2))
		layout:addChild(point)
		local function remove()
			point:removeFromParent()
		end
		point:runAction(cc.Sequence:create(cc.DelayTime:create(0.6),cc.CallFunc:create(remove)))
	end

	local actionBy = cc.MoveBy:create(0.8, moveByPos)
	local function restart( )
		hand_normal:setVisible(true)
		hand_select:setVisible(false)
	end
	local actionByBack = actionBy:reverse()
	local sequence = cc.Sequence:create(actionBy,cc.DelayTime:create(0.5),cc.CallFunc:create(restart),actionByBack)
	
	local action = cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(click),cc.DelayTime:create(0.5),sequence)
	-- hand_select:runAction( cc.Sequence:create(action,cc.CallFunc:create(nextStep)))
	hand_select:runAction(cc.RepeatForever:create(action))

end

local function handClickAction(guideType, guidePhase,delayTime,x,y)
	local config = ConfigManager.getGuideConfig(guideType, main_guide_phase_)
	local pos = cc.p(config.tip_pos[cur_step_.count][1],config.tip_pos[cur_step_.count][2])
	local size = container:getContentSize()
	local hand_normal = TextureManager.createImg(TextureManager.RES_PATH.HAND_NORMAL)
	local hand_select = TextureManager.createImg(TextureManager.RES_PATH.HAND_SELECT)
	hand_normal:setPosition(cc.p(size.width/2,size.height/2))
	-- hand_normal:setPosition(cc.p(pos.x+ x,pos.y- y))
	hand_select:setPosition(cc.p(pos.x+ x,pos.y- y))
	container:addChild(hand_normal,3)
	container:addChild(hand_select,4)
	hand_select:setVisible(false)
	hand_normal:setVisible(true)
	local moveTo = cc.MoveTo:create(0.5,cc.p(pos.x+ x,pos.y- y))
	hand_normal:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime),moveTo,cc.CallFunc:create(function( )
		local function click1( )
			hand_normal:setVisible(false)
			hand_select:setVisible(true)
		end
		local function click2()
			hand_normal:setVisible(true)
			hand_select:setVisible(false)
		end
		local action1 = cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(click1),cc.DelayTime:create(0.2),cc.CallFunc:create(click2))
		local repeatForever1 = cc.RepeatForever:create(action1)
		hand_normal:runAction(repeatForever1)
	end)))
	hand_normal:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime),cc.CallFunc:create(function( )
		local function normal1()
			hand_select:setVisible(true)
			hand_normal:setVisible(false)
		end
		local function normal2()
			hand_select:setVisible(false)
			hand_normal:setVisible(true)
		end
		local action2 = cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(normal1),cc.DelayTime:create(0.2),cc.CallFunc:create(normal2))
		
		local repeatForever2 = cc.RepeatForever:create(action2)
		hand_select:runAction(repeatForever2)
	end)))
end

local function functionHandClick(guideType, guidePhase,pos,delayTime,x,y)
	local config = ConfigManager.getGuideConfig(guideType, guidePhase)
	-- local pos = cc.p(config.tip_pos[cur_step_.count][1],config.tip_pos[cur_step_.count][2])
	local size = container:getContentSize()

	local hand_normal = TextureManager.createImg(TextureManager.RES_PATH.HAND_NORMAL)
	local hand_select =TextureManager.createImg(TextureManager.RES_PATH.HAND_SELECT)
	hand_normal:setPosition(cc.p(size.width/2,size.height/2))
	-- hand_normal:setPosition(cc.p(pos.x+ x,pos.y- y))
	hand_select:setPosition(cc.p(pos.x+ x,pos.y- y))
	container:addChild(hand_normal,3)
	container:addChild(hand_select,4)
	hand_select:setVisible(false)
	hand_normal:setVisible(true)
	local moveTo = cc.MoveTo:create(0.5,cc.p(pos.x+ x,pos.y- y))
	hand_normal:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime),moveTo,cc.CallFunc:create(function( )
		local function click1( )
			hand_normal:setVisible(false)
			hand_select:setVisible(true)
		end
		local function click2()
			hand_normal:setVisible(true)
			hand_select:setVisible(false)
		end
		local action1 = cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(click1),cc.DelayTime:create(0.2),cc.CallFunc:create(click2))
		local repeatForever1 = cc.RepeatForever:create(action1)
		hand_normal:runAction(repeatForever1)
	end)))
	hand_normal:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime),cc.CallFunc:create(function( )
		local function normal1()
			hand_select:setVisible(true)
			hand_normal:setVisible(false)
		end
		local function normal2()
			hand_select:setVisible(false)
			hand_normal:setVisible(true)
		end
		local action2 = cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(normal1),cc.DelayTime:create(0.2),cc.CallFunc:create(normal2))
		
		local repeatForever2 = cc.RepeatForever:create(action2)
		hand_select:runAction(repeatForever2)
	end)))
end

local function defaultGuideHandler(guideType,guidePhase)
	guide_handlers_ = guide_handlers_ or {}
	guide_handlers_[GUIDE_TYPE.MAIN][MAIN_GUIDE_PHASES.STAGE_3] = function()
			-- 手指图片从宠物列表的宠物上移动到目标位置等操作
		if cur_step_.count == 1 then
			local pos1 = cc.p(350,345) 
			local moveByPos1 = cc.p(100,500)
			guidePetTeam(guideType,guidePhase,pos1,0.95,80,moveByPos1)
			
		elseif cur_step_.count == 2 then
			local pos2 = cc.p(470,345)
			local moveByPos2 = cc.p(-30,370)
			guidePetTeam(guideType,guidePhase,pos2,0.7,90,moveByPos2)

		elseif cur_step_.count == 3 then
			local pos3 = cc.p(590,350)
			local moveByPos3= cc.p(-150,250)
			guidePetTeam(guideType,guidePhase,pos3,0.5,120,moveByPos3)
			
		elseif cur_step_.count == 4 then

			local size = cc.size(400,150)
			local pos1 = cc.p(700,345) 
			local moveByPos4 = cc.p(-405,500)
			guidePetTeam(guideType, guidePhase,pos1,0.6,120,moveByPos4)

		elseif cur_step_.count == 5 then

			local size = cc.size(400,150)
			local pos1 = cc.p(820,345) 
			local moveByPos5 = cc.p(-505,360)
			guidePetTeam(guideType, guidePhase,pos1,0.6,120,moveByPos5)
		end
	end

	return guide_handlers_
end

local function getGuideHandler(guideType, guidePhase)
	local winSize = cc.Director:getInstance():getVisibleSize()
	-- print("winsize "..winSize.width .."@".. winSize.height)
	guide_handlers_ = guide_handlers_ or {}
	local glView = cc.Director:getInstance():getOpenGLView()
    local screenSize = glView:getFrameSize()

    print(screenSize.width .."@@@@@@@"..screenSize.height)

	if guide_handlers_[GUIDE_TYPE.MAIN] == nil then
		guide_handlers_[GUIDE_TYPE.MAIN] = {}

		-- 设置昵称
		guide_handlers_[GUIDE_TYPE.MAIN][MAIN_GUIDE_PHASES.SET_NICKNAME] = function()
		end
		guide_handlers_[GUIDE_TYPE.MAIN][MAIN_GUIDE_PHASES.STAGE_2] = function()
			if cur_step_.count == 5 then
				local size = cc.size(400,150)
				local pos = cc.p(200,500) 
				local img9Scale = TextureManager.createImg9(size,TextureManager.RES_PATH.GUIDETIPS_SCALE9)
				img9Scale:setPosition(cc.p(pos))
				container:addChild(img9Scale,2)

				local label = CCLabelTTF:create("积累的能量足够时，会\n释放更强大的技能呢","fonts/FZCuYuan/M03S.ttf",30)
				label:setPosition(pos)
				label:setColor(cc.c3b(208,108,40))
				container:addChild(label,3)
			end
			print("删除各种提示")
		end
		
		guide_handlers_[GUIDE_TYPE.MAIN][MAIN_GUIDE_PHASES.STAGE_1] = function()

			print("添加各种提示")
			-- local guideTexts = TextManager.getGuideTexts(guideType, guidePhase,cur_step_.count)
			local size = cc.size(400,180)
			local pos = cc.p(420,400)
			if screenSize.width == 640 and screenSize.height == 960 then
				pos = cc.p(440,500)
			elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
				pos = cc.p(440,500) 
			end
			
			-- local pos = scene:convertToNodeSpace(pos_)
			local img9Scale = TextureManager.createImg9(size,TextureManager.RES_PATH.GUIDETIPS_SCALE9)
			img9Scale:setPosition(cc.p(pos))
			container:addChild(img9Scale,2)
			local label = CCLabelTTF:create("跟着手势配对3个或三个以\n上相同的水果，就可以成\n功消除一次呢","fonts/FZCuYuan/M03S.ttf",24)
			label:setPosition(pos)
			label:setColor(cc.c3b(208,108,40))
			container:addChild(label,3)
			local size_ = container:getContentSize()
			local hand_normal = TextureManager.createImg(TextureManager.RES_PATH.HAND_NORMAL)
			local hand_select = TextureManager.createImg(TextureManager.RES_PATH.HAND_SELECT)
			hand_normal:setPosition(cc.p(size_.width/2,size_.height/2))
			local moveTo
			if screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
				-- hand_normal:setPosition(cc.p(310,200))
				hand_select:setPosition(cc.p(310,200))
				moveTo = cc.MoveTo:create(0.5,cc.p(310,200))
			elseif screenSize.width == 640 and screenSize.height == 960 then
				-- hand_normal:setPosition(cc.p(310,200))
				hand_select:setPosition(cc.p(310,200))
				moveTo = cc.MoveTo:create(0.5,cc.p(310,200))
			else
				-- hand_normal:setPosition(cc.p(310,130))
				hand_select:setPosition(cc.p(310,130))
				moveTo = cc.MoveTo:create(0.5,cc.p(310,130))
			end
			hand_normal:setVisible(true)
			container:addChild(hand_normal,3)
			container:addChild(hand_select,3)
			
			hand_select:setVisible(false)

			local actionBy = cc.MoveBy:create(0.65, cc.p(0, -100))
			local actionByBack = actionBy:reverse()
			hand_normal:runAction(moveTo)
			local sequence = cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function ( )
				hand_normal:setVisible(true)
				hand_select:setVisible(false)

			end),cc.DelayTime:create(0.5),cc.CallFunc:create(function( )
				hand_normal:setVisible(false)
				hand_select:setVisible(true)
			end),actionBy,cc.DelayTime:create(0.2),cc.CallFunc:create(function( )
				hand_normal:setVisible(false)
				hand_select:setVisible(false)
			end),actionByBack,cc.DelayTime:create(0.2))
			hand_select:runAction(cc.RepeatForever:create(sequence))
			-- local rep = cc.RepeatForever:create(sequence)
			-- hand_normal:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),moveTo,rep))

			local layout = CLayout:create(size)
			layout:setPosition(cc.p(pos.x+30,pos.y-160))
			container:addChild(layout,2)
			local action = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function (  )
				local json = TextureManager.RES_PATH.SPINE_GUIDE_DRAG..".json"
				local atlas = TextureManager.RES_PATH.SPINE_GUIDE_DRAG..".atlas"
				drag = sp.SkeletonAnimation:create(json, atlas, 0.4)
				-- drag:setTimeScale(0.6)
				drag:setAnimation(0, "part1", false)
				if screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
					drag:setPosition(cc.p(size.width/2-216,size.height/2-20))
				elseif screenSize.width %640 == 0 and screenSize.height %960 == 0 then
					drag:setPosition(cc.p(size.width/2-216,size.height/2-20))
				else
					drag:setPosition(cc.p(size.width/2-196,size.height/2-10))
				end
				layout:addChild(drag)
				drag:setRotation(90)
			end),cc.DelayTime:create(1.7),cc.CallFunc:create(function( )
				layout:removeAllChildren()
			end))
			layout:runAction(cc.RepeatForever:create(action))

		end
		-- 选择第一个宠物
		guide_handlers_[GUIDE_TYPE.MAIN][MAIN_GUIDE_PHASES.CHOOSE_FIRST_PET] = function()
			
		end
		guide_handlers_[GUIDE_TYPE.MAIN][MAIN_GUIDE_PHASES.GOLD_CAPTURE] = function()
			local distence = 100
			if screenSize.width %640 == 0 and screenSize.height %960 == 0 then
				distence = -50
				if cur_step_.count == 1 then
					handClickAction(guideType, guidePhase,0,150,-50)
				elseif cur_step_.count == 2 then
					handClickAction(guideType, guidePhase,0,150,distence+50)
				end
			elseif screenSize.width % 768 == 0 and screenSize.height%1024 == 0 then
				distence = 30
				if cur_step_.count == 1 then
					handClickAction(guideType, guidePhase,0,150,-30)
				elseif cur_step_.count == 2 then
					handClickAction(guideType, guidePhase,0,150,distence)
				end
			else
				if cur_step_.count == 1 then
					handClickAction(guideType, guidePhase,0,150,0)
				elseif cur_step_.count == 2 then
					handClickAction(guideType, guidePhase,0,150,distence)
				end
			end
		end
		guide_handlers_[GUIDE_TYPE.MAIN][MAIN_GUIDE_PHASES.DIAMOND_CAPTURE] = function()
			local distence = 100
			if screenSize.width %640 == 0 and screenSize.height %960 == 0 then
				distence = -50
				if cur_step_.count == 1 then
					handClickAction(guideType, guidePhase,0,150,distence)
				elseif cur_step_.count == 2 then
					handClickAction(guideType, guidePhase,0,150,distence+50)
				-- else
				-- 	handClickAction(guideType, guidePhase,5,150,distence+50)
				end
			elseif screenSize.width % 768 == 0 and screenSize.height%1024 == 0 then
				distence = 30
				if cur_step_.count == 1 then
					handClickAction(guideType, guidePhase,0,150,-30)
				elseif cur_step_.count == 2 then
					handClickAction(guideType, guidePhase,0,150,distence)
				-- else
				-- 	handClickAction(guideType, guidePhase,5,150,distence)
				end
			else
				if cur_step_.count == 1 then
					handClickAction(guideType, guidePhase,0.3,150,0)
				elseif cur_step_.count == 2 then
					handClickAction(guideType, guidePhase,0.1,150,distence)
				-- else
				-- 	handClickAction(guideType, guidePhase,5,150,distence)
				end
			end
		end
		guide_handlers_[GUIDE_TYPE.MAIN][MAIN_GUIDE_PHASES.FINISH_WILD] = function()
			local distence = 100
			if screenSize.width %640 == 0 and screenSize.height %960 == 0 then
				handClickAction(guideType, guidePhase,0.2,150,distence+50)
			elseif screenSize.width % 768 == 0 and screenSize.height%1024 == 0 then
				handClickAction(guideType, guidePhase,0.2,150,distence)
			else
				handClickAction(guideType, guidePhase,0.2,150,distence)
			end
		end
		--pve
		guide_handlers_[GUIDE_TYPE.MAIN][MAIN_GUIDE_PHASES.PVE1] = function()
			local distence = 70
			if screenSize.width %640 == 0 and screenSize.height %960 == 0 then
				distence = 0
			elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
				distence = 20
			end
			handClickAction(guideType, guidePhase,0.3,120,distence)
		end
		
		guide_handlers_[GUIDE_TYPE.MAIN][MAIN_GUIDE_PHASES.PVE2] = function()
			local distence = 70
			if screenSize.width %640 == 0 and screenSize.height %960 == 0 then
				distence = 70
			elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
				distence = 80
			end
			handClickAction(guideType, guidePhase,0.3,110,distence)
		end

		guide_handlers_[GUIDE_TYPE.MAIN][MAIN_GUIDE_PHASES.PVE3] = function()
			-- handClickAction(guideType, guidePhase,0.1,137,115)
			local distence = 80
			if screenSize.width %640 == 0 and screenSize.height %960 == 0 then
				distence = 80
			elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
				distence = 80
			end
			handClickAction(guideType, guidePhase,0.3,135,distence)
		end

		guide_handlers_[GUIDE_TYPE.MAIN][MAIN_GUIDE_PHASES.WILD] = function ( )
			-- handClickAction(guideType, guidePhase,0.3,30,130)
			local distence = 60
			if screenSize.width %640 == 0 and screenSize.height %960 == 0 then
				distence = 130
			elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
				distence = 100
			end
			handClickAction(guideType, guidePhase,0.1,80,distence)
		end

		guide_handlers_[GUIDE_TYPE.MAIN][MAIN_GUIDE_PHASES.CAPTURE] = function ( )
			local distence = 100
			if screenSize.width %640 == 0 and screenSize.height %960 == 0 then
				distence = 110
			elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
				distence = 110
			end
			handClickAction(guideType, guidePhase,0.1,110,distence)
		end

		guide_handlers_[GUIDE_TYPE.MAIN][MAIN_GUIDE_PHASES.PVE_STAGE3] = function ( )
			local distence = 70
			if screenSize.width %640 == 0 and screenSize.height %960 == 0 then
				distence = 70
			elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
				distence = 80
			end
			handClickAction(guideType, guidePhase,0.3,110,distence)
		end
		guide_handlers_[GUIDE_TYPE.MAIN][MAIN_GUIDE_PHASES.PVE_POPUP] = function ( )
			local distence = 80
			if screenSize.width %640 == 0 and screenSize.height %960 == 0 then
				distence = 80
			elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
				distence = 80
			end
			handClickAction(guideType, guidePhase,0.3,135,distence)
		end
		guide_handlers_[GUIDE_TYPE.MAIN][MAIN_GUIDE_PHASES.START_BATTLE] = function ( )
			local distence = 80
			if screenSize.width %640 == 0 and screenSize.height %960 == 0 then
				distence = 0
			elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
				distence = 20
			end
			handClickAction(guideType, guidePhase,0.3,135,distence)
		end
		-- 第四关排兵布阵
		guide_handlers_[GUIDE_TYPE.MAIN][MAIN_GUIDE_PHASES.STAGE_3] = function()
			-- 手指图片从宠物列表的宠物上移动到目标位置等操作
			
			if cur_step_.count == 1 then
				local pos1 = cc.p(350,335) 
				local moveByPos1 = cc.p(100,500)
				guidePetTeam(guideType,guidePhase,pos1,0.95,80,moveByPos1)
				
			elseif cur_step_.count == 2 then
				local pos2 = cc.p(470,335)
				local moveByPos2 = cc.p(-30,370)
				guidePetTeam(guideType,guidePhase,pos2,0.7,90,moveByPos2)

			elseif cur_step_.count == 3 then
				local pos3 = cc.p(590,335)
				local moveByPos3= cc.p(-150,250)
				guidePetTeam(guideType,guidePhase,pos3,0.5,120,moveByPos3)
				
			elseif cur_step_.count == 4 then

				local size = cc.size(400,150)
				local pos1 = cc.p(700,335) 
				local moveByPos4 = cc.p(-405,500)
				guidePetTeam(guideType, guidePhase,pos1,0.6,120,moveByPos4)

			elseif cur_step_.count == 5 then

				local size = cc.size(400,150)
				local pos1 = cc.p(820,335) 
				local moveByPos5 = cc.p(-505,360)
				guidePetTeam(guideType, guidePhase,pos1,0.6,120,moveByPos5)
			else
				handClickAction(guideType, guidePhase,0.3,100,80)
			end
		end
	end

	if guide_handlers_[GUIDE_TYPE.FUNC] == nil then

		guide_handlers_[GUIDE_TYPE.FUNC] = {}
		
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.GREEDY_CAT] = function()
			local size = cc.size(400,150)
			local pos = cc.p(420,350) 
			local img9Scale = TextureManager.createImg9(size,TextureManager.RES_PATH.GUIDETIPS_SCALE9)
			img9Scale:setPosition(cc.p(pos))
			container:addChild(img9Scale,2)
			local label = CCLabelTTF:create("贪财猫受到攻击会掉落金币\n在它逃跑前多攻击几次","fonts/FZCuYuan/M03S.ttf",24)
			label:setPosition(pos)
			label:setColor(cc.c3b(208,108,40))
			container:addChild(label,3)
		end

		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.TREASURE_CHEST] = function()

			local arrow =TextureManager.createImg(TextureManager.RES_PATH.IMG_ARROW)
			arrow:setPosition(cc.p(360,25))
			container:addChild(arrow,4)
			Utils.floatToBottom(arrow)
			arrow:setVisible(false)
			arrow:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function( )
				local size = cc.size(370,140)
				local pos = cc.p(420,400) 
				local img9Scale = TextureManager.createImg9(size,TextureManager.RES_PATH.GUIDETIPS_SCALE9)
				img9Scale:setPosition(cc.p(pos))
				container:addChild(img9Scale,2)
				local label = CCLabelTTF:create("在当前回合内让钥匙落到最\n下方就可以开启宝箱啦","fonts/FZCuYuan/M03S.ttf",25)
				label:setPosition(pos)
				label:setColor(cc.c3b(208,108,40))
				container:addChild(label,3)
				arrow:setVisible(true)
			end)))
			arrow:runAction(cc.RepeatForever:create(cc.Blink:create(4,5)))
		end

		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.BLOCK_UNIT] = function()
			local size = cc.size(400,180)
			local pos = cc.p(420,400) 
			local img9Scale = TextureManager.createImg9(size,TextureManager.RES_PATH.GUIDETIPS_SCALE9)
			img9Scale:setPosition(cc.p(pos))
			container:addChild(img9Scale,2)
			local label = CCLabelTTF:create("冰冻的水果无法移动哦\n消除可以解冻","fonts/FZCuYuan/M03S.ttf",24)
			label:setPosition(pos)
			label:setColor(cc.c3b(208,108,40))
			container:addChild(label,3)
		end

		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.BATTLE_ROULETTE] = function ( )
			local size = cc.size(400,180)
			local pos = cc.p(420,400) 
			local img9Scale = TextureManager.createImg9(size,TextureManager.RES_PATH.GUIDETIPS_SCALE9)
			img9Scale:setPosition(cc.p(pos))
			container:addChild(img9Scale,2)
			local label = CCLabelTTF:create("冰冻的水果无法移动哦\n消除可以解冻","fonts/FZCuYuan/M03S.ttf",24)
			label:setPosition(pos)
			label:setColor(cc.c3b(208,108,40))
			container:addChild(label,3)
		end

		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.ACTIVITY1] = function ( )
			local pos = cc.p(440,10)
			if screenSize.width == 640 and screenSize.height == 960 then
				functionHandClick(guideType, guidePhase,pos,0.1,130,-5)
			elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
				functionHandClick(guideType, guidePhase,pos,0.1,120,10)
			else
				functionHandClick(guideType, guidePhase,pos,0.1,120,80)
			end
			
		end
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.BATTLE_PALACE] = function ( )
	 		local pos = cc.p(380,270)
			functionHandClick(guideType, guidePhase,pos,0.1,140,40)
		end
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.ACTIVITY2] = function ( )
	 		local pos = cc.p(440,10)
			if screenSize.width == 640 and screenSize.height == 960 then
				functionHandClick(guideType, guidePhase,pos,0.1,130,-5)
			elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
				functionHandClick(guideType, guidePhase,pos,0.1,120,10)
			else
				functionHandClick(guideType, guidePhase,pos,0.1,120,80)
			end
		end
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.BATTLE_ROULETTE] = function ( )
	 		local pos = cc.p(400,550)
			functionHandClick(guideType, guidePhase,pos,0.1,140,40)
		end
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.ACTIVITY3] = function ( )
	 		local pos = cc.p(440,10)
			if screenSize.width == 640 and screenSize.height == 960 then
				functionHandClick(guideType, guidePhase,pos,0.1,130,-5)
			elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
				functionHandClick(guideType, guidePhase,pos,0.1,120,10)
			else
				functionHandClick(guideType, guidePhase,pos,0.1,120,80)
			end
		end
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.PYRAMID] = function ( )
	 		local pos = cc.p(110,400)
			functionHandClick(guideType, guidePhase,pos,0.1,140,40)
		end
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.ELITE_STAGE] = function ( )
			if cur_step_.count == 1 then
		 		local pos = cc.p(505,10)
		 		if screenSize.width == 640 and screenSize.height == 960 then
					functionHandClick(guideType, guidePhase,pos,0.1,95,-5)
		 		elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
		 			functionHandClick(guideType, guidePhase,pos,0.1,95,20)
		 		else
					functionHandClick(guideType, guidePhase,pos,0.1,95,70)
				end
			else
				local pos = cc.p(150,180)
				if screenSize.width == 640 and screenSize.height == 960 then
					functionHandClick(guideType, guidePhase,pos,0.5,140,10)

		 		elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
		 			functionHandClick(guideType, guidePhase,pos,0.5,140,20)
		 		else
					functionHandClick(guideType, guidePhase,pos,0.5,140,40)
				end
			end
		end
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.ELITE_STAGE1] = function ( )
	 		local pos = cc.p(190,290)
	 		if screenSize.width == 640 and screenSize.height == 960 then
				functionHandClick(guideType, guidePhase,pos,0.2,140,85)

			elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then

				functionHandClick(guideType, guidePhase,pos,0.2,150,75)
			else
				functionHandClick(guideType, guidePhase,pos,0.2,140,65)
			end
			
		end
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.GOLD_HAND] = function ( )
	 		local pos = cc.p(200,1050)
	 		if screenSize.width == 640 and screenSize.height == 960 then

				functionHandClick(guideType, guidePhase,pos,0.2,140,155)
			elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
				functionHandClick(guideType, guidePhase,pos,0.2,140,125)
			else
				functionHandClick(guideType, guidePhase,pos,0.2,140,65)
			end
		end
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.GOLDHAND_ONCE] = function ( )
	 		local pos = cc.p(80,315)
	 		if screenSize.width == 640 and screenSize.height == 960 then
				functionHandClick(guideType, guidePhase,pos,0.2,140,65)
			elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
				functionHandClick(guideType, guidePhase,pos,0.2,140,65)
			else
				functionHandClick(guideType, guidePhase,pos,0.2,140,65)
			end
		end
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.CHAMPION] = function ( )
	 		local pos = cc.p(10,20)
	 		if screenSize.width == 640 and screenSize.height == 960 then
	 			functionHandClick(guideType, guidePhase,pos,0.2,120,-5)
	 		elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
	 			functionHandClick(guideType, guidePhase,pos,0.2,120,35)
	 		else
	 			functionHandClick(guideType, guidePhase,pos,0.2,120,65)
	 		end
		end
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.DUNGEON] = function ( )
	 		local pos = cc.p(10,300)
	 		if screenSize.width == 640 and screenSize.height == 960 then
	 			functionHandClick(guideType, guidePhase,pos,0.2,120,-30)
	 		elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
	 			functionHandClick(guideType, guidePhase,pos,0.2,120,-30)
	 		else
	 			functionHandClick(guideType, guidePhase,pos,0.2,120,0)
	 		end
		end
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.PVP1] = function ( )
	 		local pos = cc.p(455,10)
	 		if screenSize.width == 640 and screenSize.height == 960 then
	 			functionHandClick(guideType, guidePhase,pos,0.2,135,-5)
	 		elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
	 			functionHandClick(guideType, guidePhase,pos,0.2,135,35)
	 		else
	 			functionHandClick(guideType, guidePhase,pos,0.2,135,85)
	 		end
		end
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.DEFANCE_TEAM] = function ( )
			if cur_step_.count == 1 then
				local pos1 = cc.p(350,335) 
				local moveByPos1 = cc.p(240,600)
				guidePetTeam(guideType,guidePhase,pos1,0.95,80,moveByPos1)
				
			elseif cur_step_.count == 2 then
				local pos2 = cc.p(470,335)
				local moveByPos2 = cc.p(125,470)
				guidePetTeam(guideType,guidePhase,pos2,0.7,90,moveByPos2)

			elseif cur_step_.count == 3 then
				local pos3 = cc.p(590,335)
				local moveByPos3= cc.p(10,320)
				guidePetTeam(guideType,guidePhase,pos3,0.5,120,moveByPos3)
				
			elseif cur_step_.count == 4 then

				local pos1 = cc.p(700,335) 
				local moveByPos4 = cc.p(80,600)
				guidePetTeam(guideType, guidePhase,pos1,0.6,120,moveByPos4)

			elseif cur_step_.count == 5 then

				local pos1 = cc.p(820,335) 
				local moveByPos5 = cc.p(-15,470)
				guidePetTeam(guideType, guidePhase,pos1,0.6,120,moveByPos5)
			else
				local pos = cc.p(370,10)
				if screenSize.width == 640 and screenSize.height == 960 then
					functionHandClick(guideType, guidePhase,pos,0.2,135,0)
				elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
					functionHandClick(guideType, guidePhase,pos,0.2,135,20)
				else
					functionHandClick(guideType, guidePhase,pos,0.2,135,80)
				end
			end
		end
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.PET_TRAIN] = function ( )
	 		local pos = cc.p(255,350)
			functionHandClick(guideType, guidePhase,pos,0.2,135,85)
		end
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.PETLIST] = function ( )
	 		local pos = cc.p(35,480)
			functionHandClick(guideType, guidePhase,pos,0.2,135,0)
		end

		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.PET_UPSTAR] = function ( )
	 		if cur_step_.count == 1 then
				local pos = cc.p(430,10)
				if screenSize.width == 640 and screenSize.height == 960 then
					functionHandClick(guideType, guidePhase,pos,0.2,80,-5)

				elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then

					functionHandClick(guideType, guidePhase,pos,0.2,80,25)
				else

					functionHandClick(guideType, guidePhase,pos,0.2,80,85)
				end
			else
				local pos = cc.p(470,160)
				if screenSize.width == 640 and screenSize.height == 960 then
					functionHandClick(guideType, guidePhase,pos,0.2,130,-5)

				elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then

					functionHandClick(guideType, guidePhase,pos,0.2,80,25)
				else
					functionHandClick(guideType, guidePhase,pos,0.2,80,85)
				end
			end
		end
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.PET_SKILL_MAIN] = function ( )
	 		local pos = cc.p(255,350)
			functionHandClick(guideType, guidePhase,pos,0.2,135,85)
		end

		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.PET_SKILL_LIST] = function ( )
	 		local pos = cc.p(35,480)
			functionHandClick(guideType, guidePhase,pos,0.2,135,0)
		end

		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.PET_SKILL] = function ( )
	 		if cur_step_.count == 1 then
				local pos = cc.p(260,10)
				if screenSize.width == 640 and screenSize.height == 960 then
					functionHandClick(guideType, guidePhase,pos,0.2,130,-5)

				elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then

					functionHandClick(guideType, guidePhase,pos,0.2,140,35)
				else

					functionHandClick(guideType, guidePhase,pos,0.2,140,95)
				end
				
			else
				local pos = cc.p(295,290)
				if screenSize.width == 640 and screenSize.height == 960 then
					functionHandClick(guideType, guidePhase,pos,0.2,20,0)

				elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then

					functionHandClick(guideType, guidePhase,pos,0.2,25,40)
				else
					functionHandClick(guideType, guidePhase,pos,0.2,20,95)
				end
				
			end
		end
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.PETATTRIBUTE] = function ( )
			
			local pos = cc.p(430,160)
			if screenSize.width == 640 and screenSize.height == 960 then
				functionHandClick(guideType, guidePhase,pos,0.2,130,15)

			elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then

				functionHandClick(guideType, guidePhase,pos,0.2,130,50)
			else
				functionHandClick(guideType, guidePhase,pos,0.2,130,85)
			end
		end
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.BREEDHOUSE] = function ( )
	 		local pos = cc.p(255,350)
			functionHandClick(guideType, guidePhase,pos,0.2,135,85)
		end
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.BREED] = function ( )
			if cur_step_.count == 1 then
		 		local pos = cc.p(455,30)
		 		if screenSize.width == 640 and screenSize.height == 960 then
					functionHandClick(guideType, guidePhase,pos,0.2,135,45)
				elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
					functionHandClick(guideType, guidePhase,pos,0.2,135,55)
				else
					functionHandClick(guideType, guidePhase,pos,0.2,135,95)
				end
			elseif cur_step_.count == 2 then
				local pos = cc.p(280,550)
				if screenSize.width == 640 and screenSize.height == 960 then
					functionHandClick(guideType, guidePhase,pos,0.2,75,5)
				elseif screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
					functionHandClick(guideType, guidePhase,pos,0.2,75,5)
				else
					functionHandClick(guideType, guidePhase,pos,0.2,75,5)
				end
			end
		end
		
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.BREED_HRIR] = function ( )
	 		local pos = cc.p(250,750)
			functionHandClick(guideType, guidePhase,pos,0.2,135,55)
		end
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.BREED_INHERIT] = function ( )
	 		local pos = cc.p(250,750)
			functionHandClick(guideType, guidePhase,pos,0.2,135,55)
		end
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.BREED_CHOSE_INHERIT] = function ( )
	 		local pos = cc.p(360,550)
			functionHandClick(guideType, guidePhase,pos,0.2,135,5)
		end
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.INHERIT] = function ( )
	 		local pos = cc.p(220,270)
			functionHandClick(guideType, guidePhase,pos,0.2,135,85)
		end
		guide_handlers_[GUIDE_TYPE.FUNC][FUNC_GUIDE_PHASES.PET_LEVEL] = function ( )
	 		local pos = cc.p(150,595)
			functionHandClick(guideType, guidePhase,pos,0.2,135,85)
		end
	end
	
	if guide_handlers_[GUIDE_TYPE.EXTRA] == nil then

		guide_handlers_[GUIDE_TYPE.EXTRA] = {}

		guide_handlers_[GUIDE_TYPE.EXTRA][FUNC_GUIDE_EXTRA.PET_LEVEL_MAIN] = function ( )
	 		local pos = cc.p(255,350)
			functionHandClick(guideType, guidePhase,pos,0.2,135,85)
		end

		guide_handlers_[GUIDE_TYPE.EXTRA][FUNC_GUIDE_EXTRA.PET_LIST] = function ( )
	 		local pos = cc.p(35,480)
			functionHandClick(guideType, guidePhase,pos,0.2,135,0)
		end

		guide_handlers_[GUIDE_TYPE.EXTRA][FUNC_GUIDE_EXTRA.PET_APTITUDE] = function ( )
	 		local pos = cc.p(460,380)
			functionHandClick(guideType, guidePhase,pos,0.2,135,80)
		end
	end
	return guide_handlers_[guideType][guidePhase]
end

local function funcGuideMaks(maskType,step,rect_scale,RectPos,guideType,guidePhase)
	print("maskType = "..maskType.." step = "..step)
	print(rect_scale[step][1].."#####"..rect_scale[step][2].."******"..guideType)
	-- if container:getChildByTag(GUIDE_UI_TAGS.MASK) ~= nil then
	-- 	container:removeChildByTag(GUIDE_UI_TAGS.MASK)
	-- end
	local pos = cc.p(RectPos[step][1], RectPos[step][2])
	local glView = cc.Director:getInstance():getOpenGLView()
    local screenSize = glView:getFrameSize()
    if screenSize.width%768 == 0 and screenSize.height%1024 == 0 and guideType == 2 then
    	if guidePhase ==FUNC_GUIDE_PHASES.ACTIVITY1 or guidePhase ==FUNC_GUIDE_PHASES.ACTIVITY2 or guidePhase ==FUNC_GUIDE_PHASES.ACTIVITY3 then
    		RectPos = {{455,0}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.BATTLE_PALACE then
    		RectPos={{360,200}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.PETLIST  then
    		RectPos={{0,470}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.BATTLE_ROULETTE  then
    		RectPos={{370,510}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.PYRAMID then
    		RectPos={{50,360}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.ELITE_STAGE1 then
    		RectPos={{190,250}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.DEFANCE_TEAM and step == 6 then
    		RectPos[step] = {340,10}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.GOLD_HAND then
    		RectPos = {{265,970}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.GOLDHAND_ONCE then
    		RectPos = {{70,285}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.BREED and step == 2 then
    		RectPos[step] = {230,550}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.BREED_HRIR then
    		RectPos = {{10,700}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.BREED_CHOSE_INHERIT then
    		RectPos = {{370,545}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.BREED_INHERIT then
    		RectPos = {{10,700}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.INHERIT then
    		RectPos = {{250,245}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.CHAMPION then
    		RectPos = {{-10,-5}}
    	end
    elseif screenSize.width%640 == 0 and screenSize.height%960 == 0 and guideType == 2 then
    	if guidePhase == FUNC_GUIDE_PHASES.ELITE_STAGE and step == 2 then
    		RectPos[step] = {150,230}
    	elseif guidePhase == FUNC_GUIDE_PHASES.ELITE_STAGE1 then
    		RectPos = {{200,155}}
    	elseif guidePhase == FUNC_GUIDE_PHASES.PET_TRAIN then
    		RectPos = {{80,150}}
    	elseif guidePhase == FUNC_GUIDE_PHASES.PETLIST then
    		RectPos = {{0,420}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.ACTIVITY1 or guidePhase ==FUNC_GUIDE_PHASES.ACTIVITY2 or guidePhase ==FUNC_GUIDE_PHASES.ACTIVITY1 then
    		RectPos = {{465,0}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.BATTLE_PALACE then
    		RectPos = {{350,210}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.BATTLE_ROULETTE then
    		RectPos = {{370,500}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.PYRAMID then
    		RectPos = {{60,330}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.GOLD_HAND then
    		RectPos = {{265,905}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.GOLDHAND_ONCE then
    		RectPos = {{70,250}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.BREED and step == 2 then
    		RectPos[step] = {230,540}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.BREED_HRIR then
    		RectPos = {{10,680}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.BREED_CHOSE_INHERIT then
    		RectPos = {{370,535}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.BREED_INHERIT then
    		RectPos = {{10,680}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.INHERIT then
    		RectPos = {{250,245}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.CHAMPION then
    		RectPos = {{-10,-5}}
    	end
    end
	
	local winSize = cc.Director:getInstance():getVisibleSize()	
	
 	local mask = cc.ClippingNode:create()
 	mask:setInverted(true)
	mask:setContentSize(winSize)
	-- mask:setScale(2)
	mask:setAnchorPoint(cc.p(0.5,0.5))
	mask:setPosition(cc.p(winSize.width/2, winSize.height/2))
	mask:setAlphaThreshold(0.65)
	-- local slipper = CImageView:create(TextureManager.RES_PATH.IMG_GUIDE)
	local slipper = TextureManager.createImg(TextureManager.RES_PATH.IMG_GUIDE)
	slipper:setAnchorPoint(cc.p(0,0))
	slipper:setPosition(cc.p(pos.x, pos.y))
	slipper:setScaleX(rect_scale[step][1])
	slipper:setScaleY(rect_scale[step][2])
	mask:setStencil(slipper)
	mask:addChild(slipper)
	mask:retain()
	local bg = CLayout:create()
	bg:setContentSize(winSize)
	bg:setPosition(cc.p(winSize.width/2,winSize.height/2))
	bg:setScale(2)
	mask:addChild(bg)
	container:addChild(mask,1)
	Utils.floatToBottom(mask)
	
	local function onTouchBegan(touch,event)
		print(mask)
		print(slipper)
		local size = slipper:getBoundingBox()
		local location = mask:convertTouchToNodeSpace(touch)
		local rect = cc.rect(RectPos[step][1],RectPos[step][2],size.width,size.height)
		if location and cc.rectContainsPoint(rect, location) then
			print("in node")
			nextStep()
		end
		return true
	end

	local function onTouchMoved( touch,event )
	end
	local function onTouchEnded(touch, event)
	end
	
	local listener = cc.EventListenerTouchOneByOne:create()
	-- listener:setSwallowTouches(true)
	listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )   
	listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
	listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED ) 
    local eventDispatcher = mask:getEventDispatcher() -- 时间派发器 
    -- 绑定触摸事件到层当中  
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, mask)
end

nextStep = function ()
	if cur_step_ == nil then
		return
	end
	cur_step_.count = cur_step_.count + 1

	local config = cur_step_.config
	if cur_step_.count > #config.steps and guideType ~= GUIDE_TYPE.EXTRA then
		finishGuide(cur_step_.guideType, cur_step_.phase)
		cur_step_ = nil
		return
	end

	if container == nil then
		initContainer()
	else
		container:removeAllChildren()
		
		container:removeFromParent()
		initContainer()
	end
	
	-- scene = CSceneManager:getInstance():getRunningScene()
	scene:addChild(container,255)
	
	if config.guide_type[cur_step_.count] == 4 then
		funcGuideMaks(config.guide_type[cur_step_.count], cur_step_.count,config.rect_scale,config.tip_pos,cur_step_.guideType,cur_step_.phase)
	else
		addMask(config.guide_type[cur_step_.count], cur_step_.count,config.rect_scale,config.tip_pos,cur_step_.guideType,cur_step_.phase)
	end

	addTip(config.tip, config.tip_pos, config.tip_npc, config.tip_npc_pos)

	addArrow(config.arrow_type, config.arrow_pos)

	local guideHandler = getGuideHandler(cur_step_.guideType, cur_step_.phase) or defaultGuideHandler
	guideHandler()

end

addMask = function (maskType,step,rect_scale,RectPos,guideType,guidePhase)
	print("maskType = "..maskType.." step = "..step)
	print(rect_scale[step][1].."#####"..rect_scale[step][2])
	-- if container:getChildByTag(GUIDE_UI_TAGS.MASK) ~= nil then
	-- 	container:removeChildByTag(GUIDE_UI_TAGS.MASK)
	-- end
	local glView = cc.Director:getInstance():getOpenGLView()
    local screenSize = glView:getFrameSize()
    if screenSize.width%768 == 0 and screenSize.height%1024 == 0 then
    	if guidePhase == MAIN_GUIDE_PHASES.STAGE_2 and step == 5 then
    		RectPos[step] = {110,585}
    	elseif guidePhase == MAIN_GUIDE_PHASES.CAPTURE then
    		RectPos = {{400,140}}
    	elseif guidePhase == MAIN_GUIDE_PHASES.WILD then
    		RectPos = {{25,700}}
    	elseif guidePhase == MAIN_GUIDE_PHASES.PVE2 then
    		RectPos = {{300,220}}
    	elseif guidePhase == MAIN_GUIDE_PHASES.PVE3  then
    		RectPos = {{200,250}}
    	elseif guidePhase == MAIN_GUIDE_PHASES.PVE_POPUP then
    		RectPos = {{200,250}}
    	end
    
    elseif screenSize.width%640 == 0 and screenSize.height%960 == 0 then
    	if guidePhase == MAIN_GUIDE_PHASES.STAGE_2 and step == 5  then
    		RectPos[step] = {110,560}
    	elseif guidePhase == MAIN_GUIDE_PHASES.CAPTURE then
    		RectPos = {{370,80}}
    	elseif guidePhase == MAIN_GUIDE_PHASES.WILD then
    		RectPos = {{25,630}}
    	elseif guidePhase == MAIN_GUIDE_PHASES.PVE1 then
    		RectPos = {{220,5}}
    	elseif guidePhase == MAIN_GUIDE_PHASES.PVE2 then
    		RectPos = {{300,200}}
    	elseif guidePhase == MAIN_GUIDE_PHASES.PVE3 then
    		RectPos = {{200,210}}
    	elseif guidePhase == MAIN_GUIDE_PHASES.PVE_POPUP then
    		RectPos = {{200,210}}
    	end
    end
    if screenSize.width%768 == 0 and screenSize.height%1024 == 0 and guideType == 2 then
    	if guidePhase ==FUNC_GUIDE_PHASES.ACTIVITY1 or guidePhase ==FUNC_GUIDE_PHASES.ACTIVITY2 or guidePhase ==FUNC_GUIDE_PHASES.ACTIVITY3 then
    		RectPos = {{455,0}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.BATTLE_PALACE then
    		RectPos={{360,200}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.PETLIST  then
    		RectPos={{0,470}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.BATTLE_ROULETTE  then
    		RectPos={{370,510}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.PYRAMID then
    		RectPos={{50,360}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.ELITE_STAGE1 then
    		RectPos={{190,250}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.DEFANCE_TEAM and step == 6 then
    		RectPos[step] = {340,10}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.GOLD_HAND then
    		RectPos = {{265,970}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.GOLDHAND_ONCE then
    		RectPos = {{70,285}}
    	elseif guidePhase == FUNC_GUIDE_PHASES.PET_SKILL_MAIN then
    		RectPos = {{80,210}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.PET_SKILL_LIST  then
    		RectPos={{0,470}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.PET_SKILL and step == 1  then
    		RectPos[step]={290,0}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.PET_SKILL and step == 2  then
    		RectPos[step]={247,300}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.CHAMPION then
    		RectPos = {{-10,-5}}
    	end
    elseif screenSize.width%640 == 0 and screenSize.height%960 == 0 and guideType == 2 then
    	if guidePhase == FUNC_GUIDE_PHASES.ELITE_STAGE and step == 2 then
    		RectPos[step] = {150,230}
    	elseif guidePhase == FUNC_GUIDE_PHASES.ELITE_STAGE1 then
    		RectPos = {{200,155}}
    	elseif guidePhase == FUNC_GUIDE_PHASES.PET_TRAIN then
    		RectPos = {{80,150}}
    	elseif guidePhase == FUNC_GUIDE_PHASES.PETLIST then
    		RectPos = {{0,420}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.ACTIVITY1 or guidePhase ==FUNC_GUIDE_PHASES.ACTIVITY2 or guidePhase ==FUNC_GUIDE_PHASES.ACTIVITY1 then
    		RectPos = {{465,0}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.BATTLE_PALACE then
    		RectPos = {{350,210}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.BATTLE_ROULETTE then
    		RectPos = {{370,500}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.PYRAMID then
    		RectPos = {{60,330}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.GOLD_HAND then
    		RectPos = {{265,905}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.GOLDHAND_ONCE then
    		RectPos = {{70,250}}
    	elseif guidePhase == FUNC_GUIDE_PHASES.PET_SKILL_MAIN then
    		RectPos = {{80,180}}
    	elseif guidePhase == FUNC_GUIDE_PHASES.PET_SKILL_LIST then
    		RectPos = {{0,435}}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.PET_SKILL and step == 1  then
    		RectPos[step]={290,0}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.PET_SKILL and step == 2  then
    		RectPos[step]={247,300}
    	elseif guidePhase ==FUNC_GUIDE_PHASES.CHAMPION then
    		RectPos = {{-10,-5}}
    	end
    end
	local pos = cc.p(RectPos[step][1], RectPos[step][2])
	local winSize = cc.Director:getInstance():getVisibleSize()	
	
 	local mask = cc.ClippingNode:create()
 	mask:setInverted(true)
	mask:setContentSize(winSize)
	-- mask:setScale(2)
	mask:setAnchorPoint(cc.p(0.5,0.5))
	mask:setPosition(cc.p(winSize.width/2, winSize.height/2))
	mask:setAlphaThreshold(0.65)
	
	local slipper = TextureManager.createImg(TextureManager.RES_PATH.IMG_GUIDE)
	slipper:setAnchorPoint(cc.p(0,0))
	slipper:setPosition(cc.p(pos.x, pos.y))
	slipper:setScaleX(rect_scale[step][1])
	slipper:setScaleY(rect_scale[step][2])
	
	mask:setStencil(slipper)
	mask:addChild(slipper)
	-- mask:retain()
	local bg = CLayout:create()
	bg:setContentSize(winSize)
	bg:setPosition(cc.p(winSize.width/2,winSize.height/2))
	bg:setScale(2)
	bg:setBackgroundColor(cc.c4b(0, 0, 0, 135))
	mask:addChild(bg)
	container:addChild(mask,1)
	Utils.floatToBottom(mask)

	local configGuide = ConfigManager.getGuideConfig(guideType,guidePhase)
	local groundCo = configGuide.mask_type
	
	print("BackgroundColor "..groundCo)

	if maskType == 1 or maskType == 2  then
		bg:setBackgroundColor(cc.c4b(0, 0, 0, 135))
	elseif maskType == 3 then
		bg:setBackgroundColor(cc.c4b(0, 0, 0, 0))
	end

	local function onTouchBegan(touch,event)
		print(mask)
		print(slipper)
		local size = slipper:getBoundingBox()
		local location = mask:convertTouchToNodeSpace(touch)
		local rect = cc.rect(RectPos[step][1],RectPos[step][2],size.width,size.height)
		if (maskType == 1 or maskType == 3) and location and cc.rectContainsPoint(rect, location) then
			print("in node")
			nextStep()
			return false
		elseif maskType == 5 then
			print("持续存在一段时间")
			nextStep()
		elseif maskType == 2 then
			mask:runAction(cc.Sequence:create(cc.DelayTime:create(1.4),cc.CallFunc:create(function ( )
				nextStep()
			end)))
		end
		return true
	end

	local function onTouchMoved( touch,event )
	end
	local function onTouchEnded(touch, event)
	end
	
	if(listener ~= nil) then
		eventDispatcher:removeEventListener(listener)
		listener = nil
	end
	listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )   
	listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
	listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED ) 
    eventDispatcher = mask:getEventDispatcher() -- 时间派发器 
    -- 绑定触摸事件到层当中  
    eventDispatcher:addEventListenerWithFixedPriority(listener, -1)
end

local function startGuide(guideType, guidePhase)
	if guideType == GUIDE_TYPE.MAIN and guidePhase ~= main_guide_phase_ then
		return
	elseif isFuncGuideFinished(guidePhase) then
		return
	end
	print(" guideType = "..guideType)
	print(" guidePhase = "..guidePhase)	
					
	cur_step_ = {
		guideType = guideType,
		phase = guidePhase,
		config = ConfigManager.getGuideConfig(guideType, guidePhase),
		count = 0,
	}
	nextStep()
end

finishGuide = function (guideType, guidePhase)
	if guideType == GUIDE_TYPE.MAIN then
		main_guide_phase_ = guidePhase
		main_guide_phase_ = main_guide_phase_ + 1
	else
		print("func_guide_status_ ".. guidePhase)
		func_guide_status_ = changeFuncGuideStatus( guidePhase )
	end
	print(main_guide_phase_ .." guideStatus "..func_guide_status_)
	if listener ~= nil then
		eventDispatcher:removeEventListener(listener)
		listener = nil
	end
	-- 销毁container
	if container ~= nil then
		container:removeAllChildren()
		container:removeFromParent()
		container:release()
		container = nil
	end

	local function saveguidestatus( result )
		
	end
	NetManager.sendCmd("saveguidestatus",saveguidestatus,main_guide_phase_,func_guide_status_)
end

local function loadAllHandler(event)
	-- todo: 获得引导进度
	local mainGuide = event._usedata.mainGuide
	local funcGuide = event._usedata.funcGuide
	if mainGuide == 0 then
		main_guide_phase_ = 1
	else
		main_guide_phase_ = mainGuide
	end
	if funcGuide == 0 then
		func_guide_status_ = 4294967295
	else
		func_guide_status_ = funcGuide
		func_guide_status_ = funcGuideCheaked()
	end
	
	print("mainGuide = "..mainGuide)
	print("funcGuide = "..funcGuide)
	print(main_guide_phase_)
	print(func_guide_status_)
	
	local nextScene = "MainUI"

	if main_guide_phase_ < MAIN_GUIDE_PHASES.STAGE_1 then
		nextScene = "PresetUI"
	elseif main_guide_phase_ == MAIN_GUIDE_PHASES.GOLD_CAPTURE or main_guide_phase_ == MAIN_GUIDE_PHASES.DIAMOND_CAPTURE then
		-- main_guide_phase_ = MAIN_GUIDE_PHASES.GOLD_CAPTURE
		nextScene = "WildUI"
	elseif main_guide_phase_ == MAIN_GUIDE_PHASES.FINISH_WILD or main_guide_phase_ == MAIN_GUIDE_PHASES.PVE1  then
		main_guide_phase_ = MAIN_GUIDE_PHASES.PVE1
		nextScene = "MainUI"
	elseif main_guide_phase_ == MAIN_GUIDE_PHASES.STAGE_1 or main_guide_phase_ == MAIN_GUIDE_PHASES.STAGE_1_END then
		main_guide_phase_ = MAIN_GUIDE_PHASES.STAGE_1
		local stageRecord = StageRecord:getInstance()
		stageRecord:set("dungeonType", 1)
		stageRecord:set("chapter", 1)
		stageRecord:set("stage", 1)
		nextScene = "BattleUI"
	elseif main_guide_phase_ == MAIN_GUIDE_PHASES.STAGE_2 or main_guide_phase_ == MAIN_GUIDE_PHASES.PVE2 or main_guide_phase_ == MAIN_GUIDE_PHASES.PVE3 then
		main_guide_phase_ = MAIN_GUIDE_PHASES.STAGE_2
		local stageRecord = StageRecord:getInstance()
		stageRecord:set("dungeonType", 1)
		stageRecord:set("chapter", 1)
		stageRecord:set("stage", 2)
		nextScene = "BattleUI"
	elseif main_guide_phase_ == MAIN_GUIDE_PHASES.STAGE_3 or  main_guide_phase_ == MAIN_GUIDE_PHASES.START_BATTLE then
		main_guide_phase_ = MAIN_GUIDE_PHASES.STAGE_3
		local stageRecord = StageRecord:getInstance()
		stageRecord:set("dungeonType", 1)
		stageRecord:set("chapter", 1)
		stageRecord:set("stage", 3)
		nextScene = "BattleUI"
	elseif main_guide_phase_ == MAIN_GUIDE_PHASES.CAPTURE then
		main_guide_phase_ = MAIN_GUIDE_PHASES.STAGE_2
		local stageRecord = StageRecord:getInstance()
		stageRecord:set("dungeonType", 1)
		stageRecord:set("chapter", 1)
		stageRecord:set("stage", 2)
		nextScene = "BattleUI"
	elseif main_guide_phase_ == MAIN_GUIDE_PHASES.WILD then
		nextScene = "MainUI"
	elseif main_guide_phase_ == MAIN_GUIDE_PHASES.PVE_STAGE3 or main_guide_phase_ == MAIN_GUIDE_PHASES.PVE_POPUP  then
		main_guide_phase_ = MAIN_GUIDE_PHASES.PVE_STAGE3
		nextScene ="PveUI"
	end
	Utils.replaceScene(nextScene)
end

local function enterViewHandler(event)
	local view = event._usedata.view
	local phase = event._usedata.phase

	if main_guide_phase_ >= MAIN_GUIDE_PHASES.STAGE_1 and main_guide_phase_ <= MAIN_GUIDE_PHASES.STAGE_3  then
		battle_shuffle = true
	end
	local curScene = event._usedata.scene
	if curScene == nil then
		return 
	else
		scene = curScene
	end
	
	print("enterViewHandler ")
	print("main_guide_phase_ "..phase)

	if view == "PresetUI" then
		if main_guide_phase_ == MAIN_GUIDE_PHASES.CHOOSE_FIRST_PET then
			-- startGuide(GUIDE_TYPE.MAIN, MAIN_GUIDE_PHASES.CHOOSE_FIRST_PET)
		else
			-- startGuide(GUIDE_TYPE.MAIN, MAIN_GUIDE_PHASES.SET_NICKNAME)
		end
	elseif view == "WildUI" then

		startGuide(GUIDE_TYPE.MAIN, phase)
		
	elseif view == "BattleUI" then
			
		if main_guide_phase_ == MAIN_GUIDE_PHASES.CAPTURE then
			main_guide_phase_ = MAIN_GUIDE_PHASES.STAGE_2
			startGuide(GUIDE_TYPE.MAIN, main_guide_phase_)
		else
			startGuide(GUIDE_TYPE.MAIN, main_guide_phase_)
		end

	elseif view == "MainUI" then 
		main_guide_phase_ = event._usedata.phase
		startGuide(GUIDE_TYPE.MAIN, main_guide_phase_)
	elseif view == "PveUI" then
		main_guide_phase_ = event._usedata.phase
		startGuide(GUIDE_TYPE.MAIN, main_guide_phase_)
	elseif view == "CaptureUI" then
		main_guide_phase_ = event._usedata.phase
		startGuide(GUIDE_TYPE.MAIN, main_guide_phase_)
	end
end

local function levelUpHandler(event)
end

local function battleEndHandler(event)
end

local function monsterHandler( event )
	local view = event._usedata.view
	local curScene = event._usedata.scene
	if curScene == nil then
		return 
	else
		scene = curScene
	end
	monsterId = event._usedata.id

	print("monsterId = "..monsterId)

	if view == "BattleUI" then
		if monsterId >= 2001 and monsterId <= 2039 and isFuncGuideFinished(FUNC_GUIDE_PHASES.GREEDY_CAT)==false then

			startGuide(GUIDE_TYPE.FUNC, FUNC_GUIDE_PHASES.GREEDY_CAT)
			
		elseif monsterId >= 2040 and isFuncGuideFinished(FUNC_GUIDE_PHASES.TREASURE_CHEST)==false then

			startGuide(GUIDE_TYPE.FUNC, FUNC_GUIDE_PHASES.TREASURE_CHEST)
		end
	end
end

local function blockUnitHandler( event )
	local view = event._usedata.view
	local curScene = event._usedata.scene
	if curScene == nil then
		return 
	else
		scene = curScene
	end
	if view == "BattleUI" and isFuncGuideFinished(FUNC_GUIDE_PHASES.TREASURE_CHEST) == false then
		startGuide(GUIDE_TYPE.FUNC, FUNC_GUIDE_PHASES.BLOCK_UNIT)
	end
end

local function activityHandler( event )
	local view = event._usedata.view
	local phase = event._usedata.phase
	local curScene = event._usedata.scene
	scene = curScene
	print("BATTLE_ROULETTE ")

	if view == "MainUI" and isFuncGuideFinished(phase) == false then
		print("activity guide")
		startGuide(GUIDE_TYPE.FUNC,phase)
	elseif view == "ExploreUI" and isFuncGuideFinished(phase) == false then
		startGuide(GUIDE_TYPE.FUNC,phase)
	end
end
local function eliteStageHandler( event )
	local view = event._usedata.view
	local phase = event._usedata.phase
	local curScene = event._usedata.scene
	scene = curScene
	if view == "PveUI" and isFuncGuideFinished(phase) == false then
		print("activity guide")
		startGuide(GUIDE_TYPE.FUNC,phase)
	elseif view == "PvePopup" and isFuncGuideFinished(phase) == false then
		startGuide(GUIDE_TYPE.FUNC,phase)
	end
end

local function goldhandhandler( event )
	local view = event._usedata.view
	local phase = event._usedata.phase
	local curScene = event._usedata.scene
	scene = curScene
	if view == "MainUI" and isFuncGuideFinished(FUNC_GUIDE_PHASES.GOLD_HAND) == false then
		print("activity guide")
		startGuide(GUIDE_TYPE.FUNC,FUNC_GUIDE_PHASES.GOLD_HAND)
	elseif view == "GoldhandPopup" and isFuncGuideFinished(FUNC_GUIDE_PHASES.GOLDHAND_ONCE) == false then
		startGuide(GUIDE_TYPE.FUNC,FUNC_GUIDE_PHASES.GOLDHAND_ONCE)
	end
end 
local function championHandler (event)
	local view = event._usedata.view
	local phase = event._usedata.phase
	local curScene = event._usedata.scene
	scene = curScene
	if view == "MainUI" and isFuncGuideFinished(FUNC_GUIDE_PHASES.CHAMPION) == false then
		print("activity guide")
		startGuide(GUIDE_TYPE.FUNC,FUNC_GUIDE_PHASES.CHAMPION)
	elseif view == "DungeonUI" and isFuncGuideFinished(FUNC_GUIDE_PHASES.DUNGEON) == false then
		startGuide(GUIDE_TYPE.FUNC,FUNC_GUIDE_PHASES.DUNGEON)
	elseif view == "SilverChampionshipUI" and isFuncGuideFinished(FUNC_GUIDE_PHASES.PVP1) == false then
		startGuide(GUIDE_TYPE.FUNC,FUNC_GUIDE_PHASES.PVP1)
	elseif view == "DefenseTeamUI" and isFuncGuideFinished(FUNC_GUIDE_PHASES.DEFANCE_TEAM) == false then
		startGuide(GUIDE_TYPE.FUNC,FUNC_GUIDE_PHASES.DEFANCE_TEAM)
	end
end

local function trainHandler( event )
	local view = event._usedata.view
	local phase = event._usedata.phase
	local curScene = event._usedata.scene
	scene = curScene

	if view == "MainUI" and isFuncGuideFinished(FUNC_GUIDE_PHASES.PET_TRAIN) == false then
		startGuide(GUIDE_TYPE.FUNC,FUNC_GUIDE_PHASES.PET_TRAIN)
	elseif view == "PetListUI" and isFuncGuideFinished(FUNC_GUIDE_PHASES.PETLIST) == false then
		startGuide(GUIDE_TYPE.FUNC,FUNC_GUIDE_PHASES.PETLIST)
	elseif view == "PetAttributeUI" and isFuncGuideFinished(FUNC_GUIDE_PHASES.PETATTRIBUTE) == false then
		startGuide(GUIDE_TYPE.FUNC,FUNC_GUIDE_PHASES.PETATTRIBUTE)
	end
end

local function upstarHandler( event )
	local view = event._usedata.view
	local phase = event._usedata.phase
	local curScene = event._usedata.scene
	scene = curScene

	if view == "PetAttributeUI" and isFuncGuideFinished(FUNC_GUIDE_PHASES.PET_UPSTAR) == false then
		startGuide(GUIDE_TYPE.FUNC,FUNC_GUIDE_PHASES.PET_UPSTAR)
	end

end
local function upskillHandler( event )
	local view = event._usedata.view
	local phase = event._usedata.phase
	local curScene = event._usedata.scene
	scene = curScene
	if view == "MainUI" and isFuncGuideFinished(FUNC_GUIDE_PHASES.PET_SKILL_MAIN) == false then
		startGuide(GUIDE_TYPE.FUNC,FUNC_GUIDE_PHASES.PET_SKILL_MAIN)
	elseif view == "PetListUI" and isFuncGuideFinished(FUNC_GUIDE_PHASES.PET_SKILL_LIST) == false then
		startGuide(GUIDE_TYPE.FUNC,FUNC_GUIDE_PHASES.PET_SKILL_LIST)
	elseif view == "PetAttributeUI" and isFuncGuideFinished(FUNC_GUIDE_PHASES.PET_SKILL) == false then
		startGuide(GUIDE_TYPE.FUNC,FUNC_GUIDE_PHASES.PET_SKILL)
	end
end
local function breedhandler( event )
	local view = event._usedata.view
	local phase = event._usedata.phase
	local curScene = event._usedata.scene
	scene = curScene
	print("breedhandler ")
	if view == "MainUI" and isFuncGuideFinished(FUNC_GUIDE_PHASES.BREEDHOUSE) == false then
		startGuide(GUIDE_TYPE.FUNC,FUNC_GUIDE_PHASES.BREEDHOUSE)
	elseif view == "PetBreedHouse" and isFuncGuideFinished(FUNC_GUIDE_PHASES.BREED) == false then
		startGuide(GUIDE_TYPE.FUNC,FUNC_GUIDE_PHASES.BREED)
	elseif view == "BreedSelectPetPopup" and isFuncGuideFinished(FUNC_GUIDE_PHASES.BREED_HRIR) == false then
		startGuide(GUIDE_TYPE.FUNC,FUNC_GUIDE_PHASES.BREED_HRIR)
	elseif view == "PetBreedHouse" and isFuncGuideFinished(FUNC_GUIDE_PHASES.BREED_CHOSE_INHERIT) == false then
		startGuide(GUIDE_TYPE.FUNC,FUNC_GUIDE_PHASES.BREED_CHOSE_INHERIT)
	elseif view == "BreedSelectPetPopup" and isFuncGuideFinished(FUNC_GUIDE_PHASES.BREED_INHERIT) == false then
		startGuide(GUIDE_TYPE.FUNC,FUNC_GUIDE_PHASES.BREED_INHERIT)
	elseif view == "PetBreedHouse" and isFuncGuideFinished(FUNC_GUIDE_PHASES.INHERIT) == false then
		startGuide(GUIDE_TYPE.FUNC,FUNC_GUIDE_PHASES.INHERIT)
	end
end

local function petLevelUpHandler( event )
	local view = event._usedata.view
	local phase = event._usedata.phase
	local curScene = event._usedata.scene
	scene = curScene
	if view == "MainUI" and isFuncGuideFinished(FUNC_GUIDE_PHASES.PET_LEVEL) == false  then
		startGuide(GUIDE_TYPE.EXTRA,FUNC_GUIDE_EXTRA.PET_LEVEL_MAIN)
	elseif view == "PetListUI" and isFuncGuideFinished(FUNC_GUIDE_PHASES.PET_LEVEL) == false  then
		startGuide(GUIDE_TYPE.EXTRA,FUNC_GUIDE_EXTRA.PET_LIST)
	elseif view == "PetAttributeUI" and isFuncGuideFinished(FUNC_GUIDE_PHASES.PET_LEVEL) == false  then
		startGuide(GUIDE_TYPE.EXTRA,FUNC_GUIDE_EXTRA.PET_APTITUDE)
	elseif view == "UseItemPopup" and isFuncGuideFinished(FUNC_GUIDE_PHASES.PET_LEVEL) == false  then
		startGuide(GUIDE_TYPE.FUNC,FUNC_GUIDE_PHASES.PET_LEVEL)
	end
end

local event_handlers = {
	event_load_all = loadAllHandler,
	event_enter_view = enterViewHandler,
	event_level_up = levelUpHandler,
	event_battle_end = battleEndHandler,
	-- todo: 其他需要事件，如排兵布阵放置宠物时，进入消除阶段时，进入战斗阶段时等
	event_monster = monsterHandler, 
	event_block_unit = blockUnitHandler,
	event_activity = activityHandler,
	event_elite_stage = eliteStageHandler,
	event_goldhand = goldhandhandler,
	event_champion = championHandler,
	event_train = trainHandler,
	event_upstar = upstarHandler,
	event_upskill = upskillHandler,
	event_breed = breedhandler,
	event_pet_level = petLevelUpHandler,
}

function getMainGuidePhase()
	return main_guide_phase_
end

function initGuide()
	for eventName, handler in pairs(event_handlers) do
		Utils.addCustomEventListener(eventName, handler)
	end
end
