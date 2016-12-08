NetProxy = class("NetProxy")

local __instance = nil

function NetProxy:getInstance()
	if __instance == nil then
		__instance = NetProxy.new()
	end
	return __instance
end

local proxies = {
	--接口名称
	register 	= {"uid", "auth_code"},
	login 		= {"uid", "auth_code"},
	loadall 	= {"user{'uid', 'nickname','role','sex','vip', 'level', 'gold', 'diamond', 'exp', 'energy', 'normalChapterId', 'normalStageId', 'eliteChapterId', 'eliteStageId','fame','badge','main_guide','func_guide','view_story','chapter_story', 'resetEliteNum'}",
			   		"@pets{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}",
			   		"@items{'item_type', 'mid', 'amount'}","goldhandTimes","buyedEnergyCount"},
	loaduser 	= {"user{'uid', 'nickname', 'role','sex','vip', 'level', 'gold', 'diamond', 'exp', 'energy', 'normalChapterId', 'normalStageId', 'eliteChapterId', 'eliteStageId','fame','badge','main_guide','func_guide','view_story','chapter_story', 'resetEliteNum'}"},
	loaditems 	= {"item_type", "@items{'item_type', 'mid', 'amount'}"},
	loadpets 	= {"@pets{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}"},
	petstarup   = {"id","star","form","gold","item{'item_type','mid','amount'}"},
	train  = {"id","rankPoint","@items{'item_type','mid','amount'}"},
	breakthrough = {"id","rank","@items{'item_type','mid','amount'}"},
	loadskillpoints = {"remainingPoints","remainingTime","buyedCount"},
	buyskillpoint = {"diamond","buyedCount"},
	petskillup = {"id","skillLevels","gold","remainingPoints","remainingTime","intimacy"},
	loaddailytask = {"@task{'task_id','task_state','num'}"},
	petbreed = {"consumed_pet_ids{'id1','id2','id3','id4'}","pet{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}","lucknum"},
	petspecialbreed = {"old_pet_id","new_pet_id","aptitude","attributeGrowths","addAttributeValue"},
	petinherit = {"old_pet_id","diamond","gold","pet{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}"},
	goldhand = {"goldhandTimes","gold","diamond","@list{'getgoldnum','critmultiple'}"},
	secondensure = {"goldhandtimes","usediamondnum"},
	
	loadachievement = {"@achievement{'aid','sqid','status'}"},

	getachievementawards = {"level","exp","gold","diamond","fame","badge","@items{'item_type','mid','amount'}","@pets{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}"},
	
	loadmail = {"@mail{'id','mailid','time','mail_type','rewards','param'}"},
	getmail = {"id"},

	useExppotion = {"pet{'id','exp','level'}","item{'item_type','mid','amount'}"},
	useEnergyPotion  = {"energy","item{'item_type','mid','amount'}"},
	sellitem = {"item_type","mid","amount","gold"},
	loadbuylist = {"@list{'goods_id','item_type','mid','amount','diamond_type','diamond','isbuy'}","refreshTimes"},
	buyitem = {"moneytype","moneynum","item{'item_type','mid','amount'}","pet{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}"},
	refurbish = {"refreshtimes","@list{'goods_id','item_type','mid','amount','diamond_type','diamond','isbuy'}"},
	
	draw = {"@pets{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}","@items{'item_type','mid','amount'}","diamond","gold"},
	countdown = {"goldtimekeeping","diamondtimekeeping","remaintime"},
	freedraw = {"pet{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}","item{'item_type','mid','amount'}"},
	loadstagestar = {"stage_type","chapter","@stageinfo{'stage_id','starnum','remaintime'}","chest_reward","remainResetNum"},
	loadtrial = {"current_storey","remainResetTime","historyMaxStorey","remainSweepTime"},
	resettrial = {"current_storey","remainResetTime","diamond"},
	getstarreward = {"chapter","stage_type","diamond","@items{'item_type','mid','amount'}","pets{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}"},
	recoveryenergy = {"energy"},
	sweepstage = {"stage_type","chapter","stage","left_sweepcard_num","left_times","level","exp","diamond","gold","energy","items","@pets{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}"},
	sweeprewardpet = {"diamond","flag","ball_type","ball_num","pid"},
	capturepet = {"diamond","flag","ball_type","ball_num"},
	resettrial = {"current_storey","remainResetTime","diamond"},
	battlestart = {"battleId", "@rewards{'itemType', 'mid', 'amount'}", "@pets{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}"},
	battleend = {"energy", "gold", "diamond", "energyRecoverTime", "normalChapterId", "normalStageId", "eliteChapterId", "eliteStageId", "level", "exp", "remainTimes", "@pet_exps{'id', 'level', 'exp'}","@pets{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}"},
	buyenergy = {"energy","buyedEnergyCount"},
	loadenergy = {"energy","remainTime"}, -- ?
	loadatlas = {"@pet{'mid','form'}"},   -- ?
	
-- activity1	
	loadactivity1status = {"token","grid","dicecount","score","remaintimes","rewardtimes","diceevent","remainTime"},
	throwdice = {"grid","dicecount","remaintimes","rewardtimes","token","sand","event_id","score","gold","diamond","@items{'item_type','mid','amount'}","ernie_id","pets{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}","event_id2","score2"},
	loadactivity1questions = {"token","question{'id1','id2','id3'}"},
	answeractivity1question = {"score","token"},
	activity1battlestart = {"token","score","@rewards{'itemType', 'mid', 'amount'}","@pets{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}"},
	activity1battleend = {"score","token", "gold", "energy", "exp", "level", "@pet_exps{'id', 'level', 'exp'}","@pets{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}"},

	activity1ernieshop = {"shopinfo{'id1','id2','id3'}","token"},
	buyactivity1ernieitem = {"gold","diamond","token","@items{'item_type','mid','amount'}"},
	getactivity1rewards = {"gold","item{'item_type','mid','amount'}"},
--end
--activity3
	loadactivity3status = {"stage","reset_times","has_reward","reset_has_reward"},
	activity3battlestart = {"floor", "status"},
	activity3battleend = {"badget","gold","item{'item_type','mid','amount'}"},
	getactivity3rewards = {"badget","gold","@items{'item_type','mid','amount'}","@pets{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}"},
	getactivity3reward = {"badget","gold","@items{'item_type','mid','amount'}","@pets{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}"},
	getactivity3reset  = {"reset_times","stage"},
	loadactivity3pethp = {"@hpInfo{'id', 'hp'}"},
	saveactivity3pethp = {},
	loadactivity3rank = {"rank_self","tier","@rank{'ranking','level','role','name','tiernum'}"},
--end
--activity2 
	loadactivity2status = {"remainTimes","exploreResult{'id','max_level'}"},
	activity2explore = {"remainTimes","exploreResult{'id','max_level'}"},
	activity2battlestart = {"@rewards{'itemType', 'mid', 'amount'}", "@pets{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}"},
	activity2battleend = {"gold", "energy", "level", "exp", "@pet_exps{'id', 'level', 'exp'}", "@pets{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}"},
--end
--pvp1
	loadpvp1status = {"remainNum","cd","rank","win_num","chest{'rid','qid','amount','remaintimes'}","@tips{'t_type','name1','name2','tips'}","buytimes","rootPvpTimes"},
	loadenemy = {"@enemy{'uid','rank','level','name','chest'}"},
	loadenemyteam = {"@pets{'location','id','mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}"},
	savepvp1team = {},
	pvp1battlestart = {"left_times"},
	pvp1battleend = {"rank","fame","chest{'rid','amount'}"},
	getchestreward = {"reward{'rid','amount'}","chest{'rid','qid','amount','remaintimes'}"},
	refreshpvp1cd = {"diamond","rootpvp1times"},
	loadpvp1rank = {"rank_self","@rank{'ranking','level','name','role'}"},
	loadpvp1ranktips = {"rank","@pet{'mid',form}"},
	buypvp1times = {"buytimes","diamond"},
--end
	loadunlockedrole = {"role"},
	changerole = {},
	randomname = {"name"},
	changename = {"diamond"},
	recharge = {"diamond","vip"},
	loadrechargestatus = {"recharge_num","@buyTimes{'id','times'}"}, 
	loaddailyattendance = {"num","status","vip_status"},--加载每日状态
	getattendancereward = {"diamond","gold","@items{'item_type','mid','amount'}","vip_status","@pets{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}"},--领取每日签到奖励
	-- loaddailyattendancereward = {"diamond","gold","@items{'item_type','mid',amount}","vip_statue"},
	grandattendance = {"num","status","rechargenum"},--豪华签到
	getgrandreward = {"diamond","gold","@items{'item_type','mid','amount'}","@pets{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}"},--领取豪华签到奖励
--七日礼包
	loadweekgift = {"day_id","@task{'tagID','id','status'}","finish_days"}, --加载七日礼包
	getweekgift = {"diamond","gold","@items{'item_type','mid','amount'}","@pets{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}"}, --领取七日礼包
	buyhalfpriceitem = {"diamond"},--购买半价商品
	loadseventhpet = {"mid","@pets{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}"},--加载第七天宠物
	choosepet = {"id"},--选择宠物
--end
	loadguidestatus = {"@param{'id','status'}"},
	saveguidestatus = {},
	saveguidepet = {"id"},
	guidepetreward = {"@pets{'id', 'mid', 'form', 'exp', 'level', 'star', 'aptitude', 'intimacy', 'skillLevels', 'rank', 'rankPoint', 'character', 'attributeGrowths'}"},

	savestorystatus = {}, --保存剧情状态
	loaddailytaskreward = {"exp","diamond","gold","level","energy"},
	loadrecoverenergy = {"status"},
	loadannounce = {"status","@announce{'title','content'}"},
	resetstage  = {"stage_type","chapter","stage","times","diamond","left_reset_times"},
	loadbreedlucknum = {"lucknum"},
}

local responseData = {}

local function stringToTable(str)
	local func = loadstring("return " .. str)
	return func()
end

local tbToStr
tbToStr = function(t)
	local str = ""
	if type(t) == "table" then
		str = "{"
		if #t > 0 then
			for i,v in ipairs(t) do
				str = str .. tbToStr(v) .. ", "
			end
		else
			for k,v in pairs(t) do
				str = str .. k .. "=" .. tbToStr(v) .. ", "
			end
		end
		str = str .. "}"
	else
		str = "" .. t
	end
	return str
end

-- 一个函数需要调用自己时，需要提前声明
local parseProperty

parseProperty = function(propName, prop)
	local atPos = string.find(propName, "@") or 0
	local bracePos = string.find(propName, "{") or 0
	local subPropNames = nil
	local subProps = nil
	local hostPopName = string.sub(propName, atPos + 1, bracePos - 1)
	local hostProp = prop

	-- propName = *{*}
	if bracePos ~= 0 and type(prop) == "table" then
		hostProp = {}
		subPropNames = stringToTable(string.sub(propName, bracePos, -1))

		for i,subProp in ipairs(prop) do

			-- propName = @*{*}
			-- prop = {{}, {}, ..}
			if atPos > 0 and type(subProp) == "table" then
				local tmp = {}
				for j,v in ipairs(subProp) do
					if subPropNames == nil then
						print(j, v)
						return
					end
					if subPropNames[j] == nil then
						print(j, v)
						print(tbToStr(subPropNames))
						print(tbToStr(prop))
					end
					tmp[subPropNames[j]] = v
				end
				table.insert(hostProp, tmp)
			else
				local subPropName, subProp = parseProperty(subPropNames[i], subProp)
				hostProp[subPropName] = subProp
			end
		end
	end
	return hostPopName, hostProp
end

function NetProxy:parseResponse(response)
	local responseFunc = loadstring("return " .. response)
	if responseFunc == nil then
		return nil
	end

	local ret = responseFunc()
	if ret == nil then
		return nil
	end

	local results = {}
	for cmd, resTable in pairs(ret) do
		local result = {}
		result["cmd"] = cmd
		result["succ"] = resTable[1]

		if proxies[result["cmd"]] ~= nil then
			-- if result["succ"] ~= 0 then
			-- 	return result
			-- end

			result["content"] = {}

			for i, propName in ipairs(proxies[result["cmd"]]) do
				local propName, prop = parseProperty(propName, resTable[i + 1])
				result["content"][propName] = prop
			end
			table.insert(results, result)
		end
	end
	return results
end

-- local ret = NetProxy:parseResponse("{battleend={0,130,20,0,1,1,0,0,2,10,0,{{225,2,10},{224,2,10},{223,2,10},{226,2,10},{222,2,10},},}}")
-- print(tbToStr(ret))
