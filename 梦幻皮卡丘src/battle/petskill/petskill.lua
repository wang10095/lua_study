--[[
targets: 目标数
	1. 所有
	2. min to max 	2:min:max
range: 攻击范围 
	1. 单体
	2. 全屏
	3. 目标及所在列（穿刺）
	4. 目标及所在行
	5. 目标及左右
	6. 目标及上下
	7. 目标及上下左右
	8. 目标及四周
aim_type: 选择目标方式
	1. 随机
	2. 列首随机
	3. 行首随机
	4. 列首相邻
	5. 行首相邻
	6. 固定行中随机
	7. 固定列中随机
	8. 随机行中随机
	9. 随机列中随机
	10. 横向相邻
	11. 纵向相邻

targets 决定特效播放次数
range 决定攻击范围
aim_type 决定targets的选取方式

1. 全屏
	a. targets = 1
	b. range = 2
	c. 传给特效的是所有目标 （与a不矛盾，全屏特效可能只播放一次，也可能是全屏单体特效)
2. 随机n列
	a. targets = 2:n
	b. range = 3
	c. aim_type = 2
3. 随机n至m个
	a. target = 2:n:m
	b. range = 1
	c. aim_type = 1

--]]

local PET_SKILL_STATE = {
	INITED = 1,
	PLAY_CAST = 2,
	PLAY_EFFECT = 3,
	FINISHED = 4,
}

PetSkill = class("PetSkill")

PetSkill.state = 0
PetSkill.pet = nil
PetSkill.container = nil
PetSkill.effect = nil
PetSkill.targets = nil

local PetSkillConfig = {
	target_num = 3,
	range = 1,
	aim_type = 1
}

local function skillFinishCallFunc(sender, tb)
end

--[[
	此方法从数组availTargets中随机选出n个目标，可用于以下场景
	1. aim_type == 1，availTargets为所有怪物
	2. aim_type == 2，（固定行中随机）在selectTargets中筛选出备选目标后以availTargets传入
	3. aim_type == 3/4/5 类似2
--]]
local function selectRandomTargets(availTargets, n)
end

function PetSkill:selectTargets(availTargets)
	-- 全屏技能返回所有目标
	if self.range == 2 then
		return availTargets
	end

	local targets = {}
	-- todo: 根据targets和aim_type选出目标
	if self.aim_type == 1 then
		-- 随机目标
		return selectRandomTargets(availTargets, self.n)
	elseif self.aim_type == 2 then
		-- 固定行中随机
		local rowTargets = {}
		-- todo，将某一列中的怪物填入rowTargets中
		return selectRandomTargets(rowTargets, self.n)
	elseif self.aim_type == 3 then
	elseif self.aim_type == 4 then

	end
	return targets
end

function PetSkill:create(pet, container)
	local skill = PetSkill:new()
	skill.config = PetSkillConfig
	skill.pet = pet
	skill.container = container
	skill.effect = require("battle/petskill/skilleffect_1.lua")
	skill.state = PET_SKILL_STATE.INITED
	return skill
end

function PetSkill:createStartAnim()
	local anim = {}
	local winSize = cc.Director:getInstance():getWinSize()
	anim.mask = CLayout:create(winSize)
    anim.mask:setBackgroundColor(cc.c4b(0, 0, 0, 153))
    anim.mask:setAnchorPoint(0, 0)
    local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(function(touch, event)
				return true
			end,
		cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = anim.mask:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, anim.mask)

    local atlas = string.format("spine/spine_skill/spine_skill_name.atlas")
	local json = string.format("spine/spine_skill/spine_skill_name.json")
    anim.spine = sp.SkeletonAnimation:create(json, atlas, 1)
    anim.spine:setPosition(cc.p(winSize.width/2, winSize.height/2))
    anim.mask:addChild(anim.spine)
    anim.name = CLabel:createWithTTF("技能名称", "fonts/FZCuYuan/M03S.ttf", 28)
    anim.name:setTextColor(cc.c4b(255, 246, 206, 255))
    anim.name:setPosition(cc.p(winSize.width/2, winSize.height/2))
    anim.mask:addChild(anim.name)
    return anim
end

function PetSkill:playStartAnim()
	local ps = self;
	local anim = self:createStartAnim()
	self.container:addChild(anim.mask)
	anim.spine:setAnimation(0, "animation", false)
	anim.mask:runAction(cc.Sequence:create(
			cc.DelayTime:create(0.5),
			cc.FadeOut:create(0.3),
			cc.CallFunc:create(function(sender)
				anim.mask:removeFromParent()
				ps:playEffect(ps)
			end)
		))
end

function PetSkill:playEffect()
	self.effect:play(self)
end

function PetSkill:start(availTargets)
	print("skill target", availTargets)
	if not self.startAnim then
		self:createStartAnim()
	end
	self.targets = availTargets
	self:playStartAnim()
end

-- 有的技能使用后会产生buff(回血，加工，加防等)
function PetSkill:getBuff()
end

function PetSkill:hitTargets(targets)
	--todo: 根据攻击范围及其它技能配置确定具体攻击目标
	for i,target in ipairs(targets) do
		target:hit(50)
	end
end