require "common/constants"
require "battle/unit/demon"

Enemy = class("Enemy")

----- local constants


----- local variables
local instance_ = nil
local layout_ = nil
local demonNum_ = 0
local demonDefeated_ = 0
local demonGrid_ = {}
local demonsInAction_ = {}
local nextWave_ = 0
local curWave_ = nil	--当前波的怪
local frontIndex_ = 0	--下一个改出场的怪在当前波中的次序（按冲在最前面理解）
local demonConfigs_ = nil
local demonMatrix_ = nil
local curMatrix_ = nil
local enemyCapacity_ = Constants.ENEMY_COL * Constants.ENEMY_ROW
local paused_ = false

----- local functions
local function initDemons()
	layout_ = CLayout:create()
	layout_:setAnchorPoint(cc.p(0, 0))
	layout_:setPosition(Constants.ENEMY_POS)

	demonMatrix_ = {
		{
			{0, 0, 1, 1, 1, 0, 0},
			{0, 0, 0, 1, 0, 0, 0},
			{0, 0, 0, 0, 0, 0, 0},
		},
		{
			{0, 1, 1, 1, 1, 1, 0},
			{0, 0, 0, 1, 0, 0, 0},
			{0, 0, 1, 0, 1, 0, 0},
		},
		{
			{0, 1, 1, 1, 1, 1, 0},
			{0, 0, 1, 1, 1, 0, 0},
			{0, 0, 0, 1, 0, 0, 0},
		},
	}
	demonConfigs_ = {
		{1, 4, 7, 16, 1, 16, 7, 4, 1, 16, 7, 4},
		{1, 4, 7, 16, 1, 16, 7, 4, 1, 16, 7, 4},
		{1, 4, 7, 16, 1, 16, 7, 4, 1, 16, 7, 4},
	}

	demonNum_ = 0
	for i,v in ipairs(demonConfigs_) do
		demonNum_ = demonNum_ + #v
	end

	demonGrid_ = {}
	demonsInAction_ = {}
	demonDefeated_ = 0

	nextWave_ = 1

end

local function getDemonPosition(index)
	local row = math.floor(index / Constants.MATRIX_COL)
	local col = index % Constants.MATRIX_COL
	return cc.p(col * Constants.UNIT_SIZE.width, row * Constants.UNIT_SIZE.height)
end

local function sendNextDemon(index)
	print("send next demon: "..frontIndex_.."/"..#curWave_)
	if frontIndex_ > #curWave_ then
		return false
	end

	local demon = DemonUnit:create(curWave_[frontIndex_])
	demon.index = index
	demon:setPosition(getDemonPosition(index))
	layout_:addChild(demon)
	layout_:reorderChild(demon, enemyCapacity_ - index)
	demon:enter()

	frontIndex_ = frontIndex_ + 1
	demonGrid_[index] = demon 

	return true
end

local function sendNextWave()
	if nextWave_ > #demonMatrix_ then
		return false
	end

	print("send next wave: "..nextWave_.."/"..#demonMatrix_)

	demonGrid_ = {}
	demonsInAction_ = {}

	curMatrix_ = {}
	for i, row in ipairs(demonMatrix_[nextWave_]) do
		for j, c in ipairs(row) do
			table.insert(curMatrix_, c)
		end
	end

	curWave_ = demonConfigs_[nextWave_]
	frontIndex_ = 1
	for i,c in ipairs(curMatrix_) do
		if c == 1 then
			sendNextDemon(i - 1)
		end
	end

	nextWave_ = nextWave_ + 1
	return true
end

----- object functions
function Enemy:create()
	instance_ = Enemy:new()
	initDemons()
	return instance_
end

function Enemy:getLayout()
	return layout_
end

function Enemy:tick()
	demonsInAction_ = {}
	local waveFinished = true
	for i = 0, enemyCapacity_ - 1 do
		local demon = demonGrid_[i]
		if demon then
			if (demon.isFinished) then
				demon:removeFromParent()
				demonGrid_[i] = nil
				demonDefeated_ = demonDefeated_ + 1
				sendNextDemon(i)
			else
				waveFinished = false
				if demon:isAlive() then
					table.insert(demonsInAction_, demon)
				end
			end
		end
	end

	if waveFinished then
		sendNextWave()
	end
	
	return demonDefeated_
end

function Enemy:getDemonsInAction()
	return demonsInAction_
end

function Enemy:getTotalDemonNum()
	return demonNum_
end