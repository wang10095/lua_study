StageRecord = class("StageRecord", function()
	return Model:create("StageRecord", {
			chapter = 0, --章节
			stage = 0, --关卡
			starNum = 0, --星数
			sweeptimes = 0,  --扫荡次数
			normal_or_elite = 0,  --普通还是精英
			dungeonType = 1,  --副本类型
			remainingtimes = 0, --剩余次数
			bag_prop = 6, 
			rewards = {}, --奖励次数 
			goldtimekeeping = 0, 
			diamondtimekeeping = 0,
			pets = {},
			battleId = 0,
			petExps = {},
			gold = 0,
			exp = 0,
			activity2Id = 0,
			activity2Level = 0, 
			isPopup = false,
			old_level = 0,
			old_exp = 0,
			level = 0,
			isScene = false,
			winStar = 0, --获胜后的星数
			battle_victory = 0,
			activity3_moveToNextStage = false,
		})
end)
StageRecord.capturePets = {}
local instance_ = nil

function StageRecord:getInstance()
	if not instance_ then
		print("instance is nil")
		instance_ = StageRecord:new()
	end
	return instance_
end

function StageRecord:reset()
	instance_ = StageRecord:new()
end