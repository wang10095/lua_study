require "common/constants"
require "battle/unit/eliminate_unit"
require "battle/unit/special_unit"
require "battle/unit/unit_block"
require "common/debug"

Matrix = class("Matrix")

---------- local constants
local SWITCH_TIME = 0.15

---------- local variables
local instance_ = nil
local container_ = nil
local layout_ = nil
local units_ = {}
local matrixCapacity_ = Constants.MATRIX_COL * Constants.MATRIX_ROW
local colors_ = nil

local selectedUnit_ = nil
local touchStartUnit_ = nil
local touchStartPos_ = nil
local touchOutPos_ = nil
local hlinks_ = {}
local vlinks_ = {}
local hlinkIndexes_ = {}
local vlinkIndexes_ = {}
local backup_units_ = nil
local paused_ = false
local freezed_ = false
local lastActionTime_ = 0
local switchableIndexies_ = {}
local stepInProgress_ = false
local matchCount_ = 0
local hintAnim_ = nil
local firstEliminate = true

local specialUnitListener_ = nil
local petUnitActListener_ = nil
local blockListener_ = nil

----------- local functions

local function update(delay)
	if instance_ ~= nil then
		instance_:tick()
	end
end

local tickEntry = nil

local function printPoint(p)
	print("{" .. p.x .. ", " .. p.y .. "}")
end

local function printMatrix()
	print("**************************************")
	for i = 0, Constants.MATRIX_ROW - 1 do
		local row = Constants.MATRIX_ROW - 1 - i
		local s = ""
		for j = 0, Constants.MATRIX_COL - 1 do
			local idx = 0
			if units_[row * Constants.MATRIX_COL + j] then
				idx = units_[row * Constants.MATRIX_COL + j].colorIndex
				-- idx = units_[i * Constants.MATRIX_COL + j].isLocked
			end
			s = s .. "  " .. idx
		end
		print(s)
	end
	print("**************************************")
end

local function isSameRow(index1, index2)
	return math.floor(index1 / Constants.MATRIX_COL) == math.floor(index2 / Constants.MATRIX_COL)
end

local function hmatch(i, j)
	return units_[i] and units_[j] 
		and isSameRow(j, i) 
		and (not units_[i].isLocked) and (not units_[j].isLocked) 
		and units_[i].colorIndex == units_[j].colorIndex
end

local function vmatch(i, j)
	return units_[i] and units_[j] 
		and j >= 0 and j < matrixCapacity_ 
		and (not units_[i].isLocked) and (not units_[j].isLocked) 
		and units_[i].colorIndex == units_[j].colorIndex
end

local function getUnitPosition(idx)
	local row = math.floor(idx / Constants.MATRIX_COL)
	local col = idx % Constants.MATRIX_COL
	return cc.p(col * Constants.UNIT_SIZE.width, row * Constants.UNIT_SIZE.height)
end

local function getAvailableColorsAt(index)
	local availColors = {}
	for i=1, 6 do
		table.insert(availColors, 0)
	end
	for i,v in ipairs(colors_) do
		availColors[v] = 1
	end

    --判断纵向的可用类型
    local j = index - Constants.MATRIX_COL --当前位置纵向的上一个节点
    if j >= 0 and units_[j] ~= nil then
        local j2 = j - Constants.MATRIX_COL
        local colorJ = units_[j].colorIndex
        if j2 >= 0 and units_[j2].colorIndex == colorJ then
            availColors[colorJ] = 0
        end
    end
    
    --判断横向的可用类型
    j = index - 1;
    if j >= 0 
    	and units_[j] ~= nil
    	and isSameRow(j, index) then
        local colorJ = units_[j].colorIndex
        local j2 = index - 2
        if j2 >= 0 
        	and units_[j2] ~= nil
        	and isSameRow(j2, index) 
        	and units_[j2].colorIndex == colorJ then
            availColors[colorJ] = 0
        end
        
        j2 = index + 1;
        if j2 >= 0 
        	and units_[j2] ~= nil
        	and isSameRow(j2, index) 
        	and units_[j2].colorIndex == colorJ then
            availColors[colorJ] = 0
        end
    end
    j = index + 1;
    if j <= matrixCapacity_
    	and units_[j] ~= nil
    	and isSameRow(j, index) then
        local colorJ = units_[j].colorIndex
        local j2 = index + 2
        if j2 <= matrixCapacity_
        	and units_[j2] ~= nil
        	and units_[j2] ~= nil
        	and isSameRow(j2, index) 
        	and units_[j2].colorIndex == colorJ then 
            availColors[colorJ] = 0
        end
    end

    local ret = {}
    for i,v in ipairs(availColors) do
    	if v ~= nil and v > 0 then
    		table.insert(ret, i)
    	end
    end
    return ret
end


local function checkMatch(unit, i)
	-- print("check match:", unit.colorIndex, i)
	local colorIndex = unit.colorIndex

	local function hmatch(j)
		return (j ~= unit.index) and units_[j] and isSameRow(j, i) and (not units_[j].isLocked) and (colorIndex == units_[j].colorIndex) and (not units_[j].blocked)
	end

	local function vmatch(j)
		return (j ~= unit.index) and units_[j] and j >= 0 and j < matrixCapacity_ and (not units_[j].isLocked) and (colorIndex == units_[j].colorIndex) and (not units_[j].blocked)
	end

	if not unit then
		return false
	end

	--horizontal
	if hmatch(i - 1) then
		-- print("hmatched:", i - 1)
		if hmatch(i - 2) then
			-- print("hmatched:", i - 2)
			return true
		end
		if hmatch(i + 1) then
			-- print("hmatched:", i - 2)
			return true
		end
	end
	if hmatch(i + 1) and hmatch(i + 2) then
		-- print("matched:", i + 1, i + 2)
		return true
	end

	--vertical
	if vmatch(i - Constants.MATRIX_COL) then
		-- print("vmatched:", i - Constants.MATRIX_COL)
		if vmatch(i - 2 * Constants.MATRIX_COL) then
			-- print("vmatched:", i - 2 * Constants.MATRIX_COL)
			return true
		end
		if vmatch(i + Constants.MATRIX_COL) then
			-- print("vmatched:",  i + Constants.MATRIX_COL)
			return true
		end
	end
	if vmatch(i + Constants.MATRIX_COL) and vmatch(i + 2 * Constants.MATRIX_COL) then
		-- print("vmatched:",  i + Constants.MATRIX_COL, i + 2 * Constants.MATRIX_COL)
		return true
	end

	return false
end

local function lockUnitCallFunc(sender, unitTable)
	unitTable[1]:lock()
end

local function unlockUnitCallFunc(sender, unitTable)
	unitTable[1]:unlock()
end

local function backupDoneFunc(sender, unitTable) 
	local unit = unitTable[1]
	unit:unlock()
	if unit.colorType == 0 then
		if unit.index < Constants.MATRIX_COL then
			unit:lock()
			unit:disappear()
			unit:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function()
				unit:removeFromParent()
				units_[unit.index] = nil
			end)))
		end
	end
end

local function findSwitchable()
	switchableIndexies_ = {}

	for i=0,matrixCapacity_-1 do
		local unitI = units_[i]

		if unitI ~= nil then
			local indexI = unitI.index
			local lockStateI = unitI.isLocked

			-- 检查indexI和index是否能交换
			local function testSwitch(index)
				-- print("test switch of ", indexI, index)
				if ((index >= 0) and (index < matrixCapacity_-1) and ((index - indexI == Constants.MATRIX_COL) or isSameRow(indexI, index))) then

					local nextUnit = units_[index]

					if (nextUnit ~= nil) and not nextUnit.isLocked and not nextUnit.blocked and (nextUnit.colorType == unitI.colorType) then
						-- 检查是否是可以消除的特殊元素
						-- 让s1为两者的specialType中较大者
						if unitI.specialType == EliminateUnit.SPECIAL_TYPE.SUPER_BOMB then
							table.insert(switchableIndexies_, {indexI, index})
							return
						end

						if nextUnit.specialType == EliminateUnit.SPECIAL_TYPE.SUPER_BOMB then
							table.insert(switchableIndexies_, {index, indexI})
							return
						end

						local s1, s2
						if unitI.specialType > nextUnit.specialType then
							s1 = unitI.specialType
							s2 = nextUnit.specialType
						else
							s1 = nextUnit.specialType
							s2 = unitI.specialType
						end
						if (((s1 == EliminateUnit.SPECIAL_TYPE.X_BOMB)
									or (s1 == EliminateUnit.SPECIAL_TYPE.Y_BOMB))
								and (s2 == s1))
							or ((s1 == EliminateUnit.SPECIAL_TYPE.Y_BOMB) 
								and (s2 == EliminateUnit.SPECIAL_TYPE.X_BOMB))
							or ((s1 == EliminateUnit.SPECIAL_TYPE.X_BOMB)
								and (s2 == EliminateUnit.SPECIAL_TYPE.BOMB))
							or ((s1 == EliminateUnit.SPECIAL_TYPE.Y_BOMB) 
								and (s2 == EliminateUnit.SPECIAL_TYPE.BOMB))
							or ((s1 == EliminateUnit.SPECIAL_TYPE.BOMB) 
								and (s2 == EliminateUnit.SPECIAL_TYPE.BOMB)) then
							table.insert(switchableIndexies_, {indexI, index})
							return
						end

						-- 检查是否通过match消除
						local lockState = nextUnit.isLocked
						unitI:lock()
						nextUnit:lock()
						if checkMatch(unitI, index) then
							table.insert(switchableIndexies_, {indexI, index})
						end
						if checkMatch(nextUnit, indexI) then
							table.insert(switchableIndexies_, {index, indexI})
						end
						unitI.isLocked = lockStateI
						nextUnit.isLocked = lockState
					end
				end
			end

			if not unitI.isLocked and not unitI.blocked then
				testSwitch(indexI + 1)
				testSwitch(indexI + Constants.MATRIX_COL)
			end
		end
	end

	-- print("##############")
	-- for i,v in ipairs(switchableIndexies_) do
	-- 	print(string.format("{%d, %d}", v[1], v[2]))
	-- end
end

local function hint()
	if paused_ or BattleUI.getAutoStatus() == "1" then
		return
	end

	findSwitchable()
	local paire = nil
	if (#switchableIndexies_ == 1) then
		paire = switchableIndexies_[1]
	else
		paire = switchableIndexies_[math.random(#switchableIndexies_)]
	end

	if paire ~= nil then
		if hintAnim_ == nil then
			hintAnim_ = CLayout:create()
			hintAnim_:setContentSize(cc.size(10, 10))
			hintAnim_:setAnchorPoint(cc.p(0, 0))
			local atlas = TextureManager.RES_PATH.SPINE_BATTLE_HINT .. "_unit.atlas"
			local json = TextureManager.RES_PATH.SPINE_BATTLE_HINT .. "_unit.json"
		    
		    local hintUnitSpine1 = sp.SkeletonAnimation:create(json, atlas, 1)
		    hintUnitSpine1:setAnimation(0, "part1", true)
		    hintUnitSpine1:setPosition(cc.p(-Constants.UNIT_SIZE.width/2, 0))
		    hintAnim_:addChild(hintUnitSpine1)
		    
		    local hintUnitSpine2 = sp.SkeletonAnimation:create(json, atlas, 1)
		    hintUnitSpine2:setAnimation(0, "part1", true)
		    hintUnitSpine2:setPosition(cc.p(Constants.UNIT_SIZE.width/2, 0))
		    hintAnim_:addChild(hintUnitSpine2)

		    atlas = TextureManager.RES_PATH.SPINE_BATTLE_HINT .. "_arrow.atlas"
			json = TextureManager.RES_PATH.SPINE_BATTLE_HINT .. "_arrow.json"
		    local hintArrow = sp.SkeletonAnimation:create(json, atlas, 1)
		    hintArrow:setAnimation(0, "part1", true)
		    hintAnim_:addChild(hintArrow)

		    hintAnim_:retain()
		end
	end

	local pos1 = getUnitPosition(paire[1])
	local pos2 = getUnitPosition(paire[2])

	if hintAnim_:getParent() == nil then
		if math.abs(paire[1] - paire[2]) == 1 then
			hintAnim_:setRotation(0)
		else
			hintAnim_:setRotation(90)
		end
		hintAnim_:setPosition(cc.p((pos1.x + pos2.x + Constants.UNIT_SIZE.width)/2, (pos1.y + pos2.y + Constants.UNIT_SIZE.height)/2))
		layout_:addChild(hintAnim_, 2000)
	end

	lastActionTime_ = os.time()
end

function removeHint()
	if hintAnim_ then
		hintAnim_:removeFromParent()
	end
end

local function shuffle()
	-- print("**************** shuffle ***********")
	-- printMatrix()

	freezed_ = true

	hlinks_ = {}
	vlinks_ = {}
	hlinkIndexes_ = {}
	vlinkIndexes_ = {}
	selectedUnit_ = nil

	-- 将所有unit初始化为nil
	for i = 0, matrixCapacity_ - 1 do
		if (units_[i] ~= nil) then
			units_[i]:removeFromParent()
			units_[i] = nil
		end
	end
	print("GuideManager.getMainGuidePhase() =".. GuideManager.getMainGuidePhase())
	-- for test
	----[[
	if GuideManager.getMainGuidePhase() == 3 then

		colorIndexes = {
			5, 5, 4, 4, 1, 5, 2, 1,
			5, 1, 2, 5, 3, 4, 4, 2,
			4, 2, 2, 3, 2, 2, 3, 3,
			1, 4, 4, 2, 4, 1, 5, 4,
			1, 1, 2, 1, 3, 5, 1, 5,
		}
	end
	--]]
	print()
	for i = 0, matrixCapacity_ - 1 do
		local availColors = getAvailableColorsAt(i)
		local colorIdx
		if GuideManager.getMainGuidePhase() == 3 then
			colorIdx = colorIndexes[i + 1]
		else
			colorIdx = availColors[math.random(#availColors)]
		end
		
		local eUnit = EliminateUnit:create(1, colorIdx)
		local pos = getUnitPosition(i)
		-- if i == 23 then
		-- 	eUnit = EliminateUnit:createSpecialUnit(1, colorIdx, EliminateUnit.SPECIAL_TYPE.X_BOMB)
		-- elseif i == 18 then
			-- eUnit = EliminateUnit:createSpecialUnit(1, colorIdx, EliminateUnit.SPECIAL_TYPE.BOMB)
		-- end
		eUnit.index = i
		eUnit:setPosition(cc.p(pos.x, pos.y + Constants.MATRIX_ROW*Constants.UNIT_SIZE.height))
		layout_:addChild(eUnit)
		eUnit:setLocalZOrder(i)
		units_[i] = eUnit

		eUnit:runAction(cc.Sequence:create(cc.MoveTo:create(0.5, pos), 
										  cc.JumpTo:create(0.2, pos, 15, 1),
										  cc.CallFunc:create(function() 
										  		freezed_ = false
										  	end)))
	end
	-- printMatrix()
	-- print("*****************************")
end

local function initUnits()
	math.randomseed(os.time())
	math.random()
	shuffle()
	findSwitchable()
	
	-- printMatrix()
end

local switchSuperBombOther

-- 消除一个元素
-- local eliminate
local function eliminate(unit)
	if unit == nil or unit.isLocked then
		return
	end
	
	local idx = unit.index
	local row = math.floor(idx/Constants.MATRIX_COL)
	local col = idx % Constants.MATRIX_COL

	if unit.specialType ~= EliminateUnit.SPECIAL_TYPE.SUPER_BOMB then
		unit:explode()
		-- 检查上下左右是否有被冻住的元素
		if not unit.blocked then
			local idx = unit.index
			local row = math.floor(idx/Constants.MATRIX_COL)
			local col = idx % Constants.MATRIX_COL
			local pos = {row, col}
			local posAround = { {col, row+1}, {col-1, row}, {col+1, row}, {col, row-1}}
			for i,p in ipairs(posAround) do
				if p[1] >= 0 and p[1] < Constants.MATRIX_COL and p[2] >= 0 and p[2] < Constants.MATRIX_ROW then
					local idx = p[1] + p[2] * Constants.MATRIX_COL
					if units_[idx] ~= nil
						 and units_[idx].blocked then
						 units_[idx]:explode(0)
					end
				end
			end
		end
	end

	if unit.specialType == EliminateUnit.SPECIAL_TYPE.X_BOMB then 	--横向消除
		MusicManager.eliminate_horizontal()
		local atlas = TextureManager.RES_PATH.SPINE_ANIM_ELIMINATE .. ".atlas"
		local json = TextureManager.RES_PATH.SPINE_ANIM_ELIMINATE .. ".json"
	    local spine = sp.SkeletonAnimation:create(json, atlas, 1)
	    spine:setTimeScale(0.66)
	    spine:setPosition(cc.pAdd(cc.p(unit:getPosition()), cc.p(Constants.UNIT_SIZE.width/2, Constants.UNIT_SIZE.height/2)))
		spine:setAnimation(0, "part1", false)
	    layout_:addChild(spine)
	    layout_:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
	    	layout_:removeChild(spine)
	    end)))

		local row = math.floor(unit.index/Constants.MATRIX_COL)

		local rowStart = row * Constants.MATRIX_COL
		local rowEnd = rowStart + Constants.MATRIX_COL - 1
		for i = rowStart, rowEnd do
			if units_[i] ~= nil
				 and units_[i].specialType ~= EliminateUnit.SPECIAL_TYPE.NONE
				 and not units_[i].isLocked then
				matchCount_ = matchCount_ + 1
			end
			eliminate(units_[i])
		end
	elseif unit.specialType == EliminateUnit.SPECIAL_TYPE.Y_BOMB then 	-- 纵向消除
		MusicManager.eliminate_vertical()
		local atlas = TextureManager.RES_PATH.SPINE_ANIM_ELIMINATE .. ".atlas"
		local json = TextureManager.RES_PATH.SPINE_ANIM_ELIMINATE .. ".json"
	    local spine = sp.SkeletonAnimation:create(json, atlas, 1)
	    spine:setTimeScale(0.66)
	    spine:setPosition(cc.pAdd(cc.p(unit:getPosition()), cc.p(Constants.UNIT_SIZE.width/2, Constants.UNIT_SIZE.height/2)))
		spine:setAnimation(0, "part1", false)
		spine:setRotation(90)
	    layout_:addChild(spine)
	    layout_:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
	    	layout_:removeChild(spine)
	    end)))

		local col = unit.index % Constants.MATRIX_COL

		for i = 0, Constants.MATRIX_ROW - 1 do
			local idx = i * Constants.MATRIX_COL + col
			if units_[idx] ~= nil
				 and units_[idx].specialType ~= EliminateUnit.SPECIAL_TYPE.NONE
				 and not units_[idx].isLocked then
				matchCount_ = matchCount_ + 1
			end
			eliminate(units_[idx])
		end
	elseif unit.specialType == EliminateUnit.SPECIAL_TYPE.BOMB then 	--炸弹
		MusicManager.eliminate_bomb()
		local idx = unit.index
		local row = math.floor(idx/Constants.MATRIX_COL)
		local col = idx % Constants.MATRIX_COL
		local pos = {row, col}
		local posAround = { {col-1, row+1}, {col, row+1}, {col+1, row+1},
							{col-1, row  },               {col+1, row  },
							{col-1, row-1}, {col, row-1}, {col+1, row-1}}
		for i,p in ipairs(posAround) do
			if p[1] >= 0 and p[1] < Constants.MATRIX_COL and p[2] >= 0 and p[2] < Constants.MATRIX_ROW then
				local idx = p[1] + p[2] * Constants.MATRIX_COL
				if units_[idx] ~= nil
					 and units_[idx].specialType ~= EliminateUnit.SPECIAL_TYPE.NONE
					 and not units_[idx].isLocked then
					matchCount_ = matchCount_ + 1
				end
				eliminate(units_[idx])
			end
		end
	elseif unit.specialType == EliminateUnit.SPECIAL_TYPE.SUPER_BOMB then
		MusicManager.eliminate_bomb()
		local idx = math.random(matrixCapacity_) - 1
		while (idx == unit.index or units_[idx] == nil)
			 and units_[idx].specialType == EliminateUnit.SPECIAL_TYPE.NONE do
			idx = math.random(matrixCapacity_) - 1
		end
		unit:lock()
		local check = false
		for i = 0, matrixCapacity_ - 1 do
			local unit = units_[i]
			if unit == nil or unit.isLocked then
				check = true
				break
			end
		end
		if check then
			unit:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(function()
				switchSuperBombOther(unit, units_[idx])
			end)))
		else
			switchSuperBombOther(unit, units_[idx])
		end
	end
end

-- 消除一组连续元素
-- param unitGroup 需要消除的一组unit
-- return 最终消除的unit
local function eliminateGroup(unitGroup)
	MusicManager.eliminate_once()
	-- flagUnit即由于其交换而产生其所在消除组的unit
	local flagUnit = nil
	local row = math.floor(unitGroup[1].index / Constants.MATRIX_COL)
	local column = (unitGroup[1].index - 1) % Constants.MATRIX_COL + 1
	local num = #unitGroup
	for i, unit in ipairs(unitGroup) do
		eliminate(unit)
		if unit.flag then
			flagUnit = unit
		end
		if row >= 0 then
			local rowI = math.floor(unit.index / Constants.MATRIX_COL)
			if rowI ~= row then
				row = -1
			end
		end
		if column >= 0 then
			local columnI = (unit.index - 1) % Constants.MATRIX_COL + 1
			if columnI ~= column then
				column = -1
			end
		end
	end

	-- 如果消除组中没有flagUnit，说明该消除组不是由于交换产生的，而是由于补充产生的，这种情况将中间的一个作为flagUnit
	if flagUnit == nil then
		local flagIndex = math.ceil(num/2)
		unitGroup[flagIndex].flag = true
		flagUnit = unitGroup[flagIndex]
	end
	if num == 4 then
		if row > 0 then
			flagUnit.changeTo = EliminateUnit.SPECIAL_TYPE.Y_BOMB
		else
			flagUnit.changeTo = EliminateUnit.SPECIAL_TYPE.X_BOMB
		end
	elseif num >= 5 then
		if row > 0 or column > 0 then
			flagUnit.changeTo = EliminateUnit.SPECIAL_TYPE.SUPER_BOMB
		else
			flagUnit.changeTo = EliminateUnit.SPECIAL_TYPE.BOMB
		end
	end
	return uinitGroup
end

local function buildHLinks()
	for i = 0, matrixCapacity_ - 1 do
		if hmatch(i, i - 1) then
			hlinkIndexes_[i] = hlinkIndexes_[i - 1]
			table.insert(hlinks_[hlinkIndexes_[i]], i)
			hlinks_[i] = {}
		else
			hlinkIndexes_[i] = i
			hlinks_[i] = {i}
		end
	end
end

local function buildVLinks()
	for i = 0, matrixCapacity_ - 1 do
		if vmatch(i, i - Constants.MATRIX_COL) then
			vlinkIndexes_[i] = vlinkIndexes_[i - Constants.MATRIX_COL]
			table.insert(vlinks_[vlinkIndexes_[i]], i)
			vlinks_[i] = {}
		else
			vlinkIndexes_[i] = i
			vlinks_[i] = {i}
		end
	end
end

local function findMatchedUnits()
	local addHLinkNodes
	local addVLinkNodes
	local idxFlags = {}
	addHLinkNodes = function(idx, ub)
		local hlink = hlinks_[hlinkIndexes_[idx]]
		if #hlink > 2 then
			for i,v in ipairs(hlink) do
				if v ~= idx and idxFlags[v] == nil then
					idxFlags[v] = 1
					-- units_[v]:lock()
					table.insert(ub, units_[v])
					addVLinkNodes(v, ub)
				end
			end
		end
	end
	addVLinkNodes = function(idx, ub)
		local vlink = vlinks_[vlinkIndexes_[idx]]
		if #vlink > 2 then
			for i,v in ipairs(vlink) do
				if v ~= idx and idxFlags[v] == nil then
					-- units_[v]:lock()
					idxFlags[v] = 1
					table.insert(ub, units_[v])
					addHLinkNodes(v, ub)
				end
			end
		end
	end
	buildHLinks()
	buildVLinks()
	for i = 0, matrixCapacity_ - 1 do
		-- print(units_[i].index, units_[i].isLocked)
		local tmpUnits = {}
		if units_[i] and (not units_[i].isLocked) then
			if #hlinks_[hlinkIndexes_[i]] > 2 or #vlinks_[vlinkIndexes_[i]] > 2 then
				-- units_[i]:lock()
				table.insert(tmpUnits, units_[i])
				addHLinkNodes(i, tmpUnits)
				addVLinkNodes(i, tmpUnits)
				local s = ""
				for j,v in ipairs(tmpUnits) do
					s = s .. "  " .. v.index
				end
				-- print("color: " .. units_[i].colorIndex .. ", matched units:", s)
				eliminateGroup(tmpUnits)
				matchCount_ = matchCount_ + 1
			end
		end
	end
end

local function testMatch()
	colorIndexes = {
		3, 4, 3, 2, 2, 3, 4,
		4, 3, 2, 4, 1, 2, 1,
		3, 3, 2, 4, 1, 2, 3, 
		3, 1, 1, 1, 1, 3, 1,
	}
	units_ = {}
	for i,v in ipairs(colorIndexes) do
		local colorIndex = v
		local unit = EliminateUnit:create(1, colorIndex)
		units_[i - 1] = unit
	end
	findMatchedUnits()
end

local function switchSuperBombSuperBomb(superBomb1, superBomb2)
	for i = 0, matrixCapacity_ do
		local v = units_[i]
		if v.index == superBomb1.index or v.index == superBomb2.index then
			v:explode()
		else
			eliminate(v)
		end
	end
end

switchSuperBombOther = function(superBomb, otherUnit)
	local superBombPos = cc.p(superBomb:getPosition())
	local connectDelay = 0
	superBombPos.x = superBombPos.x + Constants.UNIT_SIZE.width/2
	superBombPos.y = superBombPos.y + Constants.UNIT_SIZE.height/2

	local function getAngle(pos1, pos2)
		if pos1.x == pos2.x then
			if (pos1.y > pos2.y) then
				return -90
			else
				return 90
			end
		end
		if pos1.x > pos2.x then
			return math.atan((pos1.y-pos2.y)/(pos1.x-pos2.x)) * 180/3.14159 - 180
		end
		return math.atan((pos1.y-pos2.y)/(pos1.x-pos2.x)) * 180/3.14159
	end

	local function connectToSumperBomb(unitToConnect)
		local v = 800
		local targetPos = cc.p(unitToConnect:getPosition())
		targetPos.x = targetPos.x + Constants.UNIT_SIZE.width/2
		targetPos.y = targetPos.y + Constants.UNIT_SIZE.height/2
		local t = cc.pGetDistance(superBombPos, targetPos)/v
		local atlas = TextureManager.RES_PATH.SPINE_SUPER_BOMB_CONNECT .. ".atlas"
		local json = TextureManager.RES_PATH.SPINE_SUPER_BOMB_CONNECT .. ".json"
	    local spine = sp.SkeletonAnimation:create(json, atlas, 1.25)
	    spine:setPosition(superBombPos)
	    spine:setRotation(180 - getAngle(superBombPos, targetPos))
		spine:setAnimation(0, "part1", true)
		spine:setOpacity(0)
	    layout_:addChild(spine, 1000, 1000)
		spine:runAction(cc.Sequence:create(
			cc.DelayTime:create(connectDelay),
			cc.Spawn:create(cc.FadeIn:create(0.2),cc.MoveTo:create(t, targetPos)),
			cc.CallFunc:create(function()
				layout_:removeChild(spine)
				unitToConnect:lock()
				unitToConnect:select()
			end)))
		connectDelay = connectDelay + 0
		return t + connectDelay + 0.1
	end

	local sameKinds = {}
	local t = 0
	for i=0, matrixCapacity_ - 1 do
		local u = units_[i]
		if not u.isLocked and u.colorIndex == otherUnit.colorIndex then
			if u.specialType == 0 then
				u.specialType = otherUnit.specialType
				if (u.specialType == EliminateUnit.SPECIAL_TYPE.X_BOMB)
					or (u.specialType == EliminateUnit.SPECIAL_TYPE.Y_BOMB) then
					u.specialType = EliminateUnit.SPECIAL_TYPE.X_BOMB + math.random(1)
				end
			end
			table.insert(sameKinds, u)
			local tu = connectToSumperBomb(u)
			if tu > t then
				t = tu
			end
			matchCount_ = matchCount_ + 1
		end
	end
	freezed_ = true
	superBomb:lock()
	superBomb:runAction(cc.Sequence:create(cc.DelayTime:create(t + 0.1), cc.CallFunc:create(function()
			superBomb:explode()
			for i,u in ipairs(sameKinds) do
				u:unlock()
				eliminate(u)
			end
			freezed_ = false
		end)))
end

local function switchXYBomb(u1, u2)
	eliminate(u1)
	eliminate(u2)
end

-- u1 is x_bomb, u2 is bomb
local function switchXBombBomb(u1, u2)
	local upUnitIndex = u1.index + Constants.MATRIX_COL
	local downUnitIndex = u1.index - Constants.MATRIX_COL
	if upUnitIndex < matrixCapacity_ then
		units_[upUnitIndex].specialType = EliminateUnit.SPECIAL_TYPE.X_BOMB
		eliminate(units_[upUnitIndex])
	end
	if downUnitIndex >= 0 then
		units_[downUnitIndex].specialType = EliminateUnit.SPECIAL_TYPE.X_BOMB
		eliminate(units_[downUnitIndex])
	end
	eliminate(u1)
	eliminate(u2)
end

-- u1 is y_bomb, u2 is bomb
local function switchYBombBomb(u1, u2)
	local leftUnitIndex = u1.index - 1
	local rightUnitIndex = u1.index + 1
	if isSameRow(leftUnitIndex, u1.index) then
		units_[leftUnitIndex].specialType = EliminateUnit.SPECIAL_TYPE.Y_BOMB
		eliminate(units_[leftUnitIndex])
	end
	if isSameRow(rightUnitIndex, u1.index) then
		units_[rightUnitIndex].specialType = EliminateUnit.SPECIAL_TYPE.Y_BOMB
		eliminate(units_[rightUnitIndex])
	end
	eliminate(u1)
	eliminate(u2)
end

local function switchBombBomb(u1, u2)
	local function largeRangeExplode(u)
		local idx = u.index
		local row = math.floor(idx/Constants.MATRIX_COL)
		local col = idx % Constants.MATRIX_COL
		for i=-2,2 do
			for j=-2,2 do
				local c = col + i
				local r = row + j
				if c >= 0 and c < Constants.MATRIX_COL and r >= 0 and r < Constants.MATRIX_ROW then
					eliminate(units_[c + r * Constants.MATRIX_COL])
				end
			end
		end
	end
	largeRangeExplode(u1)
	largeRangeExplode(u2)
end

local function specialSwitch(unit1, unit2)
	local u1 = nil
	local u2 = nil
	local actFunc = nil

	-- 如果两者同为X_BOMB或Y_BOMB，前者变成另一种BOMB
	if unit1.specialType == unit2.specialType then
		if unit1.specialType == EliminateUnit.SPECIAL_TYPE.X_BOMB then
			-- unit1.specialType = EliminateUnit.SPECIAL_TYPE.Y_BOMB
		elseif unit1.specialType == EliminateUnit.SPECIAL_TYPE.Y_BOMB then
			-- unit1.specialType = EliminateUnit.SPECIAL_TYPE.X_BOMB
		end
	end

	-- 让u1为两者中specialType较大者
	if unit1.specialType > unit2.specialType then
		u1 = unit1
		u2 = unit2
	else
		u1 = unit2
		u2 = unit1
	end
	MusicManager.eliminate_bomb()
	if u1.specialType == EliminateUnit.SPECIAL_TYPE.SUPER_BOMB then
		if u2.specialType == EliminateUnit.SPECIAL_TYPE.SUPER_BOMB then
			-- 全消元素A	全消元素B	消除全场所有元素
			actFunc = switchSuperBombSuperBomb
			-- todo sure?
			matchCount_ = matchCount_ + 10
			
		else
			-- 元素A	全消元素B	消除全场与A同色的元素
			actFunc = switchSuperBombOther
			matchCount_ = matchCount_ + 2
		end
	elseif (u1.specialType == EliminateUnit.SPECIAL_TYPE.Y_BOMB) and (u2.specialType == EliminateUnit.SPECIAL_TYPE.X_BOMB) then
		-- 竖消元素A	横消元素B	消除A和B（根据规则会自动形成十字消除）	
		actFunc = switchXYBomb
		matchCount_ = matchCount_ + 2
	elseif (u1.specialType == EliminateUnit.SPECIAL_TYPE.Y_BOMB) and (u2.specialType == EliminateUnit.SPECIAL_TYPE.Y_BOMB) then
		-- 竖消元素A	竖消元素B	消除A和B	
		print("－－－－－－－－两竖消")
		actFunc = switchYBombBomb
		matchCount_ = matchCount_ + 2
	elseif (u1.specialType == EliminateUnit.SPECIAL_TYPE.X_BOMB) and (u2.specialType == EliminateUnit.SPECIAL_TYPE.X_BOMB) then
		-- 横消元素A	横消元素B	消除A和B	
		print("－－－－－－－－两横消")
		actFunc = switchXBombBomb
		matchCount_ = matchCount_ + 2
	elseif (u1.specialType == EliminateUnit.SPECIAL_TYPE.X_BOMB) and (u2.specialType == EliminateUnit.SPECIAL_TYPE.BOMB) then
		-- 横消元素A	炸弹元素B	消除以A移动终点为中心的3条x轴所有元素
		actFunc = switchXBombBomb
		matchCount_ = matchCount_ + 3
	elseif (u1.specialType == EliminateUnit.SPECIAL_TYPE.Y_BOMB) and (u2.specialType == EliminateUnit.SPECIAL_TYPE.BOMB) then
		-- 竖消元素A	炸弹元素B	消除以A移动终点为中心的3条y轴所有元素
		actFunc = switchYBombBomb
		matchCount_ = matchCount_ + 3
	elseif (u1.specialType == EliminateUnit.SPECIAL_TYPE.BOMB) and (u2.specialType == EliminateUnit.SPECIAL_TYPE.BOMB) then
		actFunc = switchBombBomb
		matchCount_ = matchCount_ + 3
	end

	if actFunc ~= nil then
		u1:runAction(cc.Sequence:create(cc.DelayTime:create(SWITCH_TIME), cc.CallFunc:create(function() 
			local index1 = u1.index
			local index2 = u2.index
			u1:unlock()
			u2:unlock()
			u1.index = index2
			u2.index = index1
			units_[index1] = u2
			units_[index2] = u1
			
			actFunc(u1, u2)
		end)))
		return true
	end

	return false
end

local function switchUnits(unit1, unit2)
	if unit1.isLocked or unit2.isLocked or freezed_ or paused_ then
		return
	end

	if (unit1.colorType ~= unit2.colorType) or (unit1.blocked or unit2.blocked) then
		return
	end

	removeHint()

	unit1.isLocked = true
	unit2.isLocked = true

	local index1 = unit1.index
	local index2 = unit2.index
	local pos1 = getUnitPosition(index1)
	local pos2 = getUnitPosition(index2)

	unit1:runAction(cc.MoveTo:create(SWITCH_TIME, pos2))
	unit2:runAction(cc.MoveTo:create(SWITCH_TIME, pos1))
	MusicManager.eliminate_move()
	if specialSwitch(unit1, unit2) then
		lastActionTime_ = os.time()
		stepInProgress_ = true

		if selectedUnit_ ~= nil then
			if (selectedUnit_.unselect) then
				selectedUnit_:unselect()
			end
			selectedUnit_ = nil
		end
		return
	end

	local index1 = unit1.index
	local index2 = unit2.index
	local colorIndex1 = unit1.colorIndex
	local colorIndex2 = unit2.colorIndex

	local flag1 = checkMatch(unit1, index2)
	local flag2 = checkMatch(unit2, index1)

	if (colorIndex1 ~= colorIndex2) and (flag1 or flag2) then
		stepInProgress_ = true
		-- print("switch:", index1, index2)
		-- flag=true将unit标记成flagUnit, 表明其所在的消除组是由其移动产生的
		unit1.flag = flag1
		unit2.flag = flag2
		unit1.index = index2
		unit2.index = index1
		units_[index1] = unit2
		units_[index2] = unit1

		unit1:runAction(cc.Sequence:create(cc.DelayTime:create(SWITCH_TIME), cc.CallFunc:create(function() 
				unit1:unlock()
				unit2:unlock()
			end)))

		lastActionTime_ = os.time()
		--printMatrix()
	else
		-- 消除不成功交换回去
		unit1:runAction(cc.Sequence:create(cc.DelayTime:create(SWITCH_TIME), cc.MoveTo:create(SWITCH_TIME, pos1), cc.CallFunc:create(unlockUnitCallFunc, {unit1})))
		unit2:runAction(cc.Sequence:create(cc.DelayTime:create(SWITCH_TIME), cc.MoveTo:create(SWITCH_TIME, pos2), cc.CallFunc:create(unlockUnitCallFunc, {unit2})))
	end

	if selectedUnit_ ~= nil then
		if (selectedUnit_.unselect) then
			selectedUnit_:unselect()
		end
		selectedUnit_ = nil
	end
end

local function getBackUpUnitFor(index)
	--print("************************************")
	--print("find backup for "..index)
	local nextIndex = index + Constants.MATRIX_COL
	while nextIndex < matrixCapacity_ do
		if units_[nextIndex] then
			if units_[nextIndex].isLocked then
				--print(nextIndex .. " is locked, return nil")
				return nil, nextIndex
			elseif units_[nextIndex].blocked then
				local left = index + Constants.MATRIX_COL - 1
				local right = index + Constants.MATRIX_COL + 1
				if isSameRow(left, index + Constants.MATRIX_COL) and units_[left] and not units_[left].isLocked and not units_[left].blocked then
					return units_[left], left
				elseif isSameRow(right, index + Constants.MATRIX_COL) and units_[right] and not units_[right].isLocked and not units_[right].blocked then
					return units_[right], right
				else
					return nil, nil
				end
			else
				--print(nextIndex .. " is available, return " .. nextIndex)
				return units_[nextIndex], nextIndex
			end
		end
		--print(nextIndex .. " is nil, continue")
		nextIndex = nextIndex + Constants.MATRIX_COL
	end
	while backup_units_[nextIndex] do
		--print("backup at " .. nextIndex .. " is occupied")
		nextIndex = nextIndex + Constants.MATRIX_COL
	end
	--print("backup at " .. nextIndex .. " is not occupied, generate new unit at ".. nextIndex)
	local colorIdx
	-- 控制连消
	-- if math.random(10) > 5 then
		colorIdx = colors_[math.random(#colors_)]
	-- else
		-- local availColors = getAvailableColorsAt(index)
		-- colorIdx = availColors[math.random(#availColors)]
	-- end
	local eUnit = EliminateUnit:create(1, colorIdx)
	backup_units_[nextIndex] = eUnit
	--print("********************************")
	return eUnit, nextIndex
end

local function getUnitUnderLocation(location)
	-- if paused_ then
	-- 	return nil
	-- end
	--左右方向如果没有点在方阵上，找离触点最近的一个
	location.x = math.max(0, location.x)
	location.x = math.min(location.x, Constants.UNIT_SIZE.width * Constants.MATRIX_COL - 1)
	location.y = math.max(0, location.y)
	location.y = math.min(location.y, Constants.UNIT_SIZE.height * Constants.MATRIX_ROW - 1)
	local row = math.floor(location.y / Constants.UNIT_SIZE.height)
	local col = math.floor(location.x / Constants.UNIT_SIZE.width)
	local idx = row * Constants.MATRIX_COL + col
	return units_[idx]
end

local function onTouchBegan(touch, event) 
	print("****", BattleUI.getAutoStatus())
	if paused_ or freezed_ or stepInProgress_ or BattleUI.getAutoStatus() == "1" then
		return false
	end
	local location = layout_:convertTouchToNodeSpace(touch)
	if location.y >= 0 and location.y <= Constants.UNIT_SIZE.height * (Constants.MATRIX_ROW) then
		local location = layout_:convertTouchToNodeSpace(touch)
		-- if selectedUnit_ ~= nil then
		-- 	selectedUnit_:unselect()
		-- 	selectedUnit_ = nil
		-- end
		touchStartUnit_ = getUnitUnderLocation(location)
		touchOutPos_ = nil
		if touchStartUnit_ == nil or touchStartUnit_.blocked then
			return false
		end
		-- selectedUnit_:select()
		return true
	end
	return false
end

local function onTouchMoved(touch, event)
	if touchOutPos_ ~= nil then
		return
	end

	local top = Constants.MATRIX_ROW * Constants.UNIT_SIZE.height - 1
	local right = Constants.UNIT_SIZE.width * Constants.MATRIX_COL - 1
	local location = layout_:convertTouchToNodeSpace(touch)
	if location.x < 0 or location.x > right or location.y < 0 or location.y > top then
		location.x = math.min(location.x, right)
		location.x = math.max(location.x, 0)
		location.y = math.min(location.y, top)
		location.y = math.max(location.y, 0)
		touchOutPos_ = location
	end
end

local function onTouchEnded(touch, event)
	local location = touchOutPos_ or layout_:convertTouchToNodeSpace(touch)
	local unit = getUnitUnderLocation(location)
	if unit == nil or touchStartUnit_ == nil then
		return
	end

	local pos1 = getUnitPosition(touchStartUnit_.index)
	local pos2 = getUnitPosition(unit.index)

	local distX = math.abs(pos1.x - pos2.x)
	local distY = math.abs(pos1.y - pos2.y)

	if distY >= Constants.UNIT_SIZE.height or distX >= Constants.UNIT_SIZE.width then
		-- 拖动
		if distY > distX then
			if pos1.y < pos2.y then
				unit = units_[touchStartUnit_.index + Constants.MATRIX_COL]
			else
				unit = units_[touchStartUnit_.index - Constants.MATRIX_COL]
			end
		else
			if pos1.x < pos2.x then
				unit = units_[touchStartUnit_.index + 1]
			else
				unit = units_[touchStartUnit_.index - 1]
			end
		end
		if unit ~= nil then
			switchUnits(touchStartUnit_, unit)

		end
	else
		-- 点击
		if selectedUnit_ ~= nil then
			local indexDist = math.abs(touchStartUnit_.index - selectedUnit_.index)
			local row1 = math.floor(touchStartUnit_.index/Constants.MATRIX_COL)
			local row2 = math.floor(selectedUnit_.index/Constants.MATRIX_COL)
			if (indexDist == Constants.MATRIX_COL) or (indexDist == 1 and row1 == row2) then
				switchUnits(selectedUnit_, unit)
			else
				selectedUnit_:unselect()
				selectedUnit_ = unit
				selectedUnit_:select()
			end
		else
			selectedUnit_ = unit
			selectedUnit_:select()
		end
	end

	touchStartUnit_ = nil
end

local function initTouchEvents()
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN )
	listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_CANCELLED )
    eventDispatcher = layout_:getEventDispatcher() -- 事件派发器  
    -- 绑定触摸事件到层当中  
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layout_)
end

local function initBackground()
	for i=0, Constants.MATRIX_COL - 1 do
		for j=0,Constants.MATRIX_ROW - 1 do
			local tile = TextureManager.createImg(TextureManager.RES_PATH.MATRIX_TILE)
			local pos = cc.p((i + 0.5) * Constants.UNIT_SIZE.width, (j + 0.5) * Constants.UNIT_SIZE.height)
			tile:setPosition(pos)
			layout_:addChild(tile)
		end
	end
end

---------- object functions

function Matrix:create(colors)
	colors_ = colors

	if container_ ~= nil then
		container_:removeFromParent()
	else
		container_ = cc.ClippingNode:create()
		local w = Constants.MATRIX_COL * Constants.UNIT_SIZE.width + 30
		local h = Constants.MATRIX_ROW * Constants.UNIT_SIZE.height + 30
		local stencil = cc.DrawNode:create()
	    local points = {cc.p(0, 0), cc.p(w, 0), cc.p(w, h), cc.p(0, h)}
	    stencil:drawPolygon(points, 4, cc.c4f(1,1,1,1), 4, cc.c4f(1,1,1,1))
	    -- stencil:retain()
	    container_:setStencil(stencil)
	    container_:setContentSize(cc.size(w, h))
		container_:setAnchorPoint(cc.p(0, 0))
		container_:retain()
	end

	if layout_ == nil then
		layout_ = CLayout:create()
		local w = Constants.MATRIX_COL * Constants.UNIT_SIZE.width
		local h = Constants.MATRIX_ROW * Constants.UNIT_SIZE.height
		layout_:setContentSize(cc.size(w, h))
		layout_:setAnchorPoint(cc.p(0, 0))
		layout_:setPosition(cc.p(15, 6))
		container_:addChild(layout_)
		layout_:retain()
	end

	paused_ = false

	initBackground()

	initUnits()
	initTouchEvents()

	lastActionTime_ = os.time()

	--testMatch()
	instance_ = Matrix:new()

	if (tickEntry ~= nil) then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(tickEntry)
	end

	tickEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0, false)

	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	if specialUnitListener ~= nil then
		eventDispatcher:removeEventListener(specialUnitListener)
	end
	specialUnitListener = cc.EventListenerCustom:create("event_generate_special_unit", function(event)
		local stype = event._usedata.stype
		local row = event._usedata.row
		local col = event._usedata.col
		instance_:generateSpecialUnit(stype, row, col)
	end)
    eventDispatcher:addEventListenerWithFixedPriority(specialUnitListener, 1)

    if petUnitActListener_ ~= nil then
		eventDispatcher:removeEventListener(petUnitActListener_)
	end
    petUnitActListener_ = cc.EventListenerCustom:create("event_unit_act", function(event)
    	local stype = event._usedata.stype
    	if stype == nil then
    		return
    	end
    	for i=0,matrixCapacity_ - 1 do
    		if units_[i].stype == stype then
    			local seunit = units_[i]
    			seunit:lock()
    			seunit:disappear()
		    	seunit:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function()
					seunit:removeFromParent()
					units_[seunit.index] = nil
				end)))
    		end
    	end
    end)
    eventDispatcher:addEventListenerWithFixedPriority(petUnitActListener_, 1)

    if blockListener ~= nil then
		eventDispatcher:removeEventListener(blockListener)
	end
	blockListener = cc.EventListenerCustom:create("event_block_unit", function(event)
		local btype = event._usedata.block_type
		instance_:block(btype)
	end)
    eventDispatcher:addEventListenerWithFixedPriority(blockListener, 1)

	return instance_
end

function Matrix:ctor()
	-- print("matrix constructor")
end

function Matrix:getLayout()
	return container_
end

function Matrix:tick()
	if paused_ then
		return
	end

	local ret = {}
	-- 找到连续的元素并消除
	if not freezed_ then
		local matchedUnits = findMatchedUnits()
	end
	-- local num = #matchedUnits
	-- if matchedUnits and num > 0 then
	-- 	for i,group in ipairs(matchedUnits) do
	-- 		group = eliminateGroup(group)
	-- 		table.insert(ret, group)
	-- 	end
	-- end

	-- 移除生命周期完结的unit
	for i = 0, matrixCapacity_ - 1 do
		local unit = units_[i]
		if unit and unit.isFinished then
			unit:removeFromParent()
			units_[i] = nil
		end
	end

	-- 生成补充元素
	backup_units_ = {}
	for i = 0, matrixCapacity_ - 1 do
		if not units_[i] then
			-- idx ==> i
			local unit, idx = getBackUpUnitFor(i)
			if unit then
				backup_units_[idx] = {unit, idx, i}
				units_[idx] = nil
			end
		end
	end

	local maxTime = 0
	-- 补充元素移动到被消除元素的位置
	for k,t in pairs(backup_units_) do
		local unit = t[1]
		local origIndex = t[2]
		local destIndex = t[3]
		unit.index = destIndex
		unit:lock()
		units_[destIndex] = unit
		if not unit:getParent() then
			unit:setPosition(getUnitPosition(origIndex))
			layout_:addChild(unit, destIndex)
			unit:setLocalZOrder(destIndex)
		end
		local origPos = getUnitPosition(origIndex)
		local destPos = getUnitPosition(destIndex)
		local t = (origPos.y - destPos.y)/Constants.PET_SPEED
		if maxTime < t then
			maxTime = t
		end
		unit:runAction(cc.Sequence:create(cc.MoveTo:create(t, destPos), 
										  cc.JumpTo:create(0.2, destPos, 15, 1),
										  cc.CallFunc:create(backupDoneFunc, {unit})))
	end

	if stepInProgress_ then
		local stepFinished = true
		for i = 0, matrixCapacity_ - 1 do
			local unit = units_[i]
			if unit == nil then
				local unit, idx = getBackUpUnitFor(i)
				stepFinished = (unit == nil and idx == nil)
				if stepFinished == false then
					break
				end
			elseif unit.isLocked then
				stepFinished = false
				break
			end
		end
		if stepFinished then
			stepInProgress_ = false
			-- -- 如果发呆时间超过设定则提示
			-- if os.time() - lastActionTime_ > 3 and GuideManager.battle_shuffle == false then
			-- 	hint()
			-- end
			local event = cc.EventCustom:new("event_switch")
			cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)

			if BattleUI.getAutoStatus() == "1" then
				self:autoSwitch()
			end
		end
	end
	-- 如果发呆时间超过设定则提示
	if firstEliminate == true and not stepInProgress_ then
		if os.time() - lastActionTime_ > 3 and GuideManager.battle_shuffle == false then
			hint()
		end
	end
	return ret
end

function Matrix:pauseMatrix()
	paused_ = true
	removeHint()
	-- cc.Director:getInstance():getScheduler():unscheduleScriptEntry(tickEntry)
end

function Matrix:resumeMatrix()
	paused_ = false
	-- tickEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0, false)
end

function Matrix:freeze()
	freezed_ = true
end

function Matrix:unfreeze()
	freezed_ = false
end

function Matrix:cleanup()
	self:pauseMatrix()
	container_:removeAllChildren()
	container_:removeFromParent()
	container_:release()
	container_ = nil

	layout_:release()
	layout_ = nil

	instance_ = nil
	units_ = {}
	colors_ = nil
	selectedUnit_ = nil
	touchStartUnit_ = nil
	touchStartPos_ = nil
	hlinks_ = {}
	vlinks_ = {}
	hlinkIndexes_ = {}
	vlinkIndexes_ = {}
	backup_units_ = nil
	paused_ = false
	freezed_ = false
	lastActionTime_ = 0
	switchableIndexies_ = {}
	stepInProgress_ = false

	if hintAnim_ ~= nil then
		hintAnim_:removeFromParent()
		hintAnim_:release()
		hintAnim_ = nil
	end

	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	if specialUnitListener ~= nil then
		eventDispatcher:removeEventListener(self.specialUnitListener)
	end
	if petUnitActListener_ ~= nil then
		eventDispatcher:removeEventListener(petUnitActListener_)
	end
	if blockListener ~= nil then
		eventDispatcher:removeEventListener(blockListener)
	end
end

function Matrix:clearSpecialUnits()
	for i = 0, matrixCapacity_ - 1 do
		local unit = units_[i]
		if unit and unit.specialType == EliminateUnit.SPECIAL_TYPE.SUPER_BOMB then
			stepInProgress_ = true
			eliminate(unit)
			layout_:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function()
				self:clearSpecialUnits()
			end)))
			return true
		end
	end
	for i = 0, matrixCapacity_ - 1 do
		local unit = units_[i]
		if unit and unit.specialType ~= EliminateUnit.SPECIAL_TYPE.NONE then
			stepInProgress_ = true
			eliminate(unit)
		end
	end
	return stepInProgress_
end

function Matrix:getMatchCount()
	return matchCount_
end

function Matrix:resetMatchCount()
	matchCount_ = 0
end

-- 检查是否需要shuffle，如果需要则进行shuffle操作 
function Matrix:checkShuffle()
	findSwitchable()
	local startShuffle
	startShuffle = function()
		local atlas = TextureManager.RES_PATH.SPINE_BATTLE_SHUFFLE .. ".atlas"
		local json = TextureManager.RES_PATH.SPINE_BATTLE_SHUFFLE .. ".json"
	    local spine = sp.SkeletonAnimation:create(json, atlas, 1)
	    spine:setPosition(cc.p(cc.Director:getInstance():getWinSize().width/2 - 10, Constants.UNIT_SIZE.height * (Constants.MATRIX_COL/2 - 1) - 10))
		container_:addChild(spine)
		spine:setAnimation(0, "part1", false)
		spine:runAction(cc.Sequence:create(cc.DelayTime:create(3.0), cc.CallFunc:create(function()
			shuffle()
			findSwitchable()
			if #switchableIndexies_ == 0 then
				startShuffle()
			end
		end), cc.DelayTime:create(2.0), cc.CallFunc:create(function()
			spine:removeFromParent()
			self:autoSwitch()
		end)))
	end
	if (switchableIndexies_ == nil) or (#switchableIndexies_ == 0)  then
		startShuffle()
	end
end

function Matrix:isStepInProgress()
	return stepInProgress_
end

function Matrix:generateSpecialUnit(stype, row, col)
	local idx = row * Constants.MATRIX_COL + col
	local u = units_[idx]
	if u then
		u:removeFromParent()
	end
	local su = SpecialUnit:create(stype)
	local pos = getUnitPosition(idx)
	su.index = idx
	su:setPosition(pos)
	layout_:addChild(su)
	su:setLocalZOrder(idx)
	units_[idx] = su
end

function Matrix:block(block_type)
	local euec = ConfigManager.getEliminateUnitEffectConfig(block_type)
	local amount = euec.amount
	if type(amount) == "table" then
		amount = math.random(amount[1], amount[2])
	end
	for i=1,amount do
		local idx = math.random(matrixCapacity_ - 1)
		local u = units_[idx]
		if u ~= nil and not u.locked then
			u:block(block_type, rounds)
		end
	end

	removeHint()
end

function Matrix:autoSwitch()
	if BattleUI.getAutoStatus() ~= "1" or stepInProgress_ then
		return
	end

	findSwitchable()

	if not switchableIndexies_ or #switchableIndexies_ == 0 then
		self:checkShuffle()
		return
	end

	local paire = nil
	if (#switchableIndexies_ == 1) then
		paire = switchableIndexies_[1]
	else
		paire = switchableIndexies_[math.random(#switchableIndexies_)]
	end

	switchUnits(units_[paire[1]], units_[paire[2]])
end