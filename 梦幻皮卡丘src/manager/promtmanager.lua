module("PromtManager", package.seeall)

NewsTable = { --通知列表
	UP_SKILL_LEVEL = {eventName="event_skillup_promt",status=false}, --升级
	TRAIN = {eventName="event_train_promt",status=false}, --训练
	UPSTAR = {eventName="event_upstar_promt",status=false}, --升星
	ACHIEVEMENT_FINISH = {eventName="event_achievement_promt",status=false},--任务
	DAILYTASK_FINISH = {eventName="event_dailytask_promt",status=false},--日常
	DAILY_SIGN = {eventName="event_dailysign_promt",status=false},--每日签到
	SUPER_SIGN = {eventName="event_supersign_promt",status=false},--豪华签到
	RECOVER_ENERGY = {eventName="event_recoverenergy_promt",status=false},--恢复体力
	WEEKGIFT = {eventName="event_weekgift_promt",status=false},--七日礼包
	MAIL = {eventName="event_mail_promt",status=false},--右键
	WILD = {eventName="event_wild_promt",status=false},--野生原野区
}

function init()
	NetManager.registerResponseHandler("newstatus",function(result) 
		
	end,true)
end

function judge_skillup_status() --升级技能
	local skillPoints = Player:getInstance():get("skillPoints")
	local skill_open_level = ConfigManager.getUserCommonConfig('skill_limit')
	if skillPoints>0 and Player:getInstance():get("level") >= skill_open_level then
		local mainSpot = false --是否在神奇宝贝中心标题板显示
		local petContent = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
		local skill3_difference = ConfigManager.getPetCommonConfig('skill3_level_difference')
		local skill4_difference = ConfigManager.getPetCommonConfig('skill4_level_difference')
		for i,v in ipairs(petContent) do
			local canSkillUp = false
			for j = 1,#v:get("skillLevels") do
				local skillUpGradeCost = ConfigManager.getSkillConsumeConfig(v:get("skillLevels")[j])["skill" .. j]
				if j<3 and v:get("skillLevels")[j]<v:get("level") and Player:getInstance():get("gold")>=skillUpGradeCost  then
					canSkillUp = true
				elseif j==3 and v:get("skillLevels")[j]<v:get("level")-skill3_difference and Player:getInstance():get("gold")>=skillUpGradeCost  then
					canSkillUp = true
				elseif j==4 and v:get("skillLevels")[j]<v:get("level")-skill4_difference and Player:getInstance():get("gold")>=skillUpGradeCost  then
					canSkillUp = true
				end
				if canSkillUp == true then
					break
				end
			end
			if canSkillUp == true then
				mainSpot = true
				NewsTable.UP_SKILL_LEVEL.status = true
				local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
				local event = cc.EventCustom:new(NewsTable.UP_SKILL_LEVEL.eventName)
				event._usedata = v:get("id")
				eventDispatcher:dispatchEvent(event)
			end
		end
		if mainSpot == false then
			NewsTable.UP_SKILL_LEVEL.status = false
			local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
			local event = cc.EventCustom:new(NewsTable.UP_SKILL_LEVEL.eventName)
			eventDispatcher:dispatchEvent(event)
		end
	else
		NewsTable.UP_SKILL_LEVEL.status = false
		local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
		local event = cc.EventCustom:new(NewsTable.UP_SKILL_LEVEL.eventName)
		eventDispatcher:dispatchEvent(event)
	end
end

function judge_train_status()--训练
	local mainSpot = false --是否在神奇宝贝中心标题板显示
	local petContent = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
	for i,v in ipairs(petContent) do --遍历所有宠物 找到
		local trainId = ConfigManager.getPetConfig(v:get("mid")).train_id
		local trainConfig = ConfigManager.getPetTrainConfig(trainId,v:get("rank"),v:get("rankPoint"))
		local canTrain = true
		for j = 1,3 do
			local trainItemAmount = ItemManager.getItemAmount(Constants.ITEM_TYPE.TRAIN_MATERIAL,trainConfig.materials[j][2])
			if trainItemAmount<trainConfig.materials[j][3] then
				canTrain = false
				break
			end
		end
		if Player:getInstance():get("level")<trainConfig.levelDemand then
			canTrain = false
		end
		if canTrain == true then
			NewsTable.TRAIN.status = true
			mainSpot = true
			local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
			local event = cc.EventCustom:new(NewsTable.TRAIN.eventName)
			eventDispatcher:dispatchEvent(event)
		end
	end
	if mainSpot == false then
		NewsTable.TRAIN.status = false
		local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
		local event = cc.EventCustom:new(NewsTable.TRAIN.eventName)
		eventDispatcher:dispatchEvent(event)
	end
end

function judge_upstar_status()--升星
	local mainSpot = false --是否在神奇宝贝中心标题板显示
	local petContent = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
	for i,v in ipairs(petContent) do --遍历所有宠物 找到
		local evolution_stone = ConfigManager.getPetConfig(v:get("mid")).evolution_stone
		local ItemAmount = ItemManager.getItemAmount(Constants.ITEM_TYPE.EVOLUTION_STONE,evolution_stone)
		local needAmount =  ConfigManager.getPetStarConfig(v:get("star")).material_num
		local star_limit = ConfigManager.getPetCommonConfig('star_limit')
		if ItemAmount >= needAmount and v:get("star")<star_limit then --可以升星
			NewsTable.UPSTAR.status = true
			mainSpot = true
			local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
			local event = cc.EventCustom:new(NewsTable.UPSTAR.eventName)
			eventDispatcher:dispatchEvent(event)
		end
	end
	if mainSpot == false then
		NewsTable.UPSTAR.status = false
		local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
		local event = cc.EventCustom:new(NewsTable.UPSTAR.eventName)
		eventDispatcher:dispatchEvent(event)
	end
end

function judge_achievement_status() --成就

		local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
		local event = cc.EventCustom:new(NewsTable.ACHIEVEMENT_FINISH.eventName)
		eventDispatcher:dispatchEvent(event)
end
function judge_dailytask_status()--日常

		local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
		local event = cc.EventCustom:new(NewsTable.DAILYTASK_FINISH.eventName)
		eventDispatcher:dispatchEvent(event)
	
end

function judge_dailysign_status()--每日签到

		local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
		local event = cc.EventCustom:new(NewsTable.DAILY_SIGN.eventName)
		eventDispatcher:dispatchEvent(event)

end
function judge_supersign_status()--豪华签到
	
		local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
		local event = cc.EventCustom:new(NewsTable.SUPER_SIGN.eventName)
		eventDispatcher:dispatchEvent(event)

end
function judge_recoverenergy_status()--恢复体力
	
		local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
		local event = cc.EventCustom:new(NewsTable.RECOVER_ENERGY.eventName)
		eventDispatcher:dispatchEvent(event)
	
end
function judge_weekgift_status() --七日礼包

		local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
		local event = cc.EventCustom:new(NewsTable.WEEKGIFT.eventName)
		eventDispatcher:dispatchEvent(event)
	
end
function judge_mail_status()--邮件
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	local event = cc.EventCustom:new(NewsTable.MAIL.eventName)
	eventDispatcher:dispatchEvent(event)
end

function judge_wild_status()--野生原野区
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	local event = cc.EventCustom:new(NewsTable.WILD.eventName)
	eventDispatcher:dispatchEvent(event)
end

NewsCallFuncTable = {
	UP_SKILL_LEVEL = {callFunc = judge_skillup_status}, --升级
	TRAIN = {callFunc = judge_train_status}, --训练
	UPSTAR = {callFunc = judge_upstar_status}, --升星
	ACHIEVEMENT_FINISH = {callFunc = judge_achievement_status},--任务
	DAILYTASK_FINISH = {callFunc = judge_dailytask_status},--日常
	DAILY_SIGN = {callFunc = judge_dailysign_status},--每日签到
	SUPER_SIGN = {callFunc = judge_supersign_status},--豪华签到
	RECOVER_ENERGY = {callFunc = judge_recoverenergy_status},--恢复体力
	WEEKGIFT = {callFunc = judge_weekgift_status},--七日礼包
	MAIL = {callFunc = judge_mail_status},--右键
	WILD = {callFunc = judge_wild_status},--野生原野区	
}

function checkAll()
	-- local proxy = NormalDataProxy:getInstance()
	-- if proxy:get("FirstComeIn")==false then
	-- 	return
	-- end
	-- proxy:set("FirstComeIn",false)
	function checkAllHandler(cmd, result)
		if cmd == "loaddailyattendance" then--每日签到
			if result["status"]==0 then
				NewsTable.DAILY_SIGN.status = true
			else
				NewsTable.DAILY_SIGN.status = false
			end
		elseif cmd == "grandattendance" then--豪华签到
			if result["status"]==0 then
				NewsTable.SUPER_SIGN.status = true
			else
				NewsTable.SUPER_SIGN.status = false
			end
		elseif cmd == "loadrecoverenergy" then--体力恢复
			if result["status"]==0 then
				NewsTable.RECOVER_ENERGY.status = true
			else
				NewsTable.RECOVER_ENERGY.status = false
			end
		elseif cmd == "loadweekgift" then--七日礼包
			if #result["finish_days"]>0 then
				NewsTable.WEEKGIFT.status = true
			else
				NewsTable.WEEKGIFT.status = false
			end
		elseif cmd == "loadachievement" then--成就 {"@achievement{'aid','sqid','status'}"},
			local achievement_finish = false
			AchievementDataProxy:getInstance().achievementList = result
			for k,v in pairs(result["achievement"]) do
				if v["status"]==1 then
					NewsTable.ACHIEVEMENT_FINISH.status = true
					achievement_finish = true
					break
				end
			end
			if achievement_finish == false then
				NewsTable.ACHIEVEMENT_FINISH.status = false
			end
		elseif cmd == "loaddailytask" then--日常  	loaddailytask = {"@task{'task_id','task_state','num'}"},
			local dailytask_finish = false
			for k,v in ipairs(result["task"])do
				local id,status,times = v["task_id"],v["task_state"],v["num"]
				local dailyConfig = ConfigManager.getDailyTaskConfig(id)
				if id == 1 and times>=1 then
					NewsTable.DAILYTASK_FINISH.status = true
					dailytask_finish = true
				elseif id == 15 and  status==2 and Player:getInstance():get("vip")>0 then
					NewsTable.DAILYTASK_FINISH.status = true
					dailytask_finish = true
				elseif times>=dailyConfig.task_times and times>0 then
					NewsTable.DAILYTASK_FINISH.status = true
					dailytask_finish = true
				end
			end
			if dailytask_finish == false then
				NewsTable.DAILYTASK_FINISH.status = false
			end
		elseif cmd == "loadmail" then--邮件
			if #result["mail"] > 0 then --有邮件
				NewsTable.MAIL.status = true
			else
				NewsTable.MAIL.status = false
			end
		elseif cmd == "countdown" then--野生原野区
			if (result["goldtimekeeping"]<=0 and result["remaintime"] >0) or result["diamondtimekeeping"]<=0 then
				NewsTable.WILD.status = true
			else
				NewsTable.WILD.status = false
			end
		elseif cmd == "loadskillpoints" then
			Player:getInstance():set("skillPoints",result["remainingPoints"])
		end
	end

	local cmds = {"loadweekgift","loaddailyattendance","grandattendance","loadrecoverenergy","loadachievement","loaddailytask","loadmail","countdown","loadskillpoints"}
	local checkNext
	checkNext = function()
		if #cmds == 0 then
			for k,v in pairs(NewsCallFuncTable) do
				v.callFunc()
			end
			return
		end
		local cmd = table.remove(cmds)
		if cmd == "loadweekgift" then
			NetManager.sendCmd(cmd, function(result)
				checkAllHandler(cmd, result)
				checkNext()
			end,0)
			NetManager.registerErrorHandler("loadweekgift", function()
				NewsTable.WEEKGIFT.status = false
				checkNext()
			end)
		else
			NetManager.sendCmd(cmd, function(result)
				checkAllHandler(cmd, result)
				checkNext()
			end)
		end
	end
	checkNext()
end

function checkOnePetPromt(key,petId)
	local petContent = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
	local v = nil
	for i,pet in ipairs(petContent) do
		if pet:get("id")==petId then
			v = pet
		end
	end
	if key == "UP_SKILL_LEVEL" then
		local skill3_difference = ConfigManager.getPetCommonConfig('skill3_level_difference')
		local skill4_difference = ConfigManager.getPetCommonConfig('skill4_level_difference')
		local skill_open_level = ConfigManager.getUserCommonConfig('skill_limit')
		if Player:getInstance():get("skillPoints")<=0 or Player:getInstance():get("level")<skill_open_level  then
			return false
		end
		local canSkillUp = false
		for j = 1,#v:get("skillLevels") do
			local skillUpGradeCost = ConfigManager.getSkillConsumeConfig(v:get("skillLevels")[j])["skill" .. j]
			if j<3 and v:get("skillLevels")[j]<v:get("level") and Player:getInstance():get("gold")>=skillUpGradeCost  then
				canSkillUp = true
			elseif j==3 and v:get("skillLevels")[j]<v:get("level")-skill3_difference and Player:getInstance():get("gold")>=skillUpGradeCost  then
				canSkillUp = true
			elseif j==4 and v:get("skillLevels")[j]<v:get("level")-skill4_difference and Player:getInstance():get("gold")>=skillUpGradeCost  then
				canSkillUp = true
			end
			if canSkillUp == true then
				break
			end
		end
		if canSkillUp == true then
			return true
		else
			return false
		end
	elseif key == "TRAIN"  then
		local trainId = ConfigManager.getPetConfig(v:get("mid")).train_id
		local trainConfig = ConfigManager.getPetTrainConfig(trainId,v:get("rank"),v:get("rankPoint"))
		local canTrain = true
		for i = 1,3 do
			local trainItemAmount = ItemManager.getItemAmount(Constants.ITEM_TYPE.TRAIN_MATERIAL,trainConfig.materials[i][2])
			if trainItemAmount<trainConfig.materials[i][3] then
				canTrain = false
			end
		end
		if canTrain == true then
			return true
		else
			return false
		end
	elseif key == "UPSTAR"  then
		local evolution_stone = ConfigManager.getPetConfig(v:get("mid")).evolution_stone
		local ItemAmount = ItemManager.getItemAmount(Constants.ITEM_TYPE.EVOLUTION_STONE,evolution_stone)
		local needAmount = ConfigManager.getPetStarConfig(v:get("star")).material_num
		local star_limit = ConfigManager.getPetCommonConfig('star_limit')
		if ItemAmount >= needAmount and v:get("star")<star_limit then --可以升星
			return true
		else
			return false
		end
	end
end

function checkOnePromt(key,params) 
	if params then --活动  邮件  七日 任务  日常 wild
		if key == "UP_SKILL_LEVEL" or key == "TRAIN" or key == "UPSTAR"  then
			local checkReult = checkOnePetPromt(key, params)
			if checkReult == true then
				NewsTable[key].status = true
			else
				NewsTable[key].status = false
			end

			local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
			local event = cc.EventCustom:new(NewsTable[key].eventName)
			event._usedata = params
			eventDispatcher:dispatchEvent(event)
		end
	else
		NewsCallFuncTable[key].callFunc()
	end
end

function addRedSpot(node,spotType,key,petId) 
	local size = node:getContentSize()
	local posX,posY = 0,0
	if spotType == 1 then --左上角
		posX = 15
		posY = size.height-20
	elseif spotType == 2 then --神奇宝贝中心标题版
		posX = 70
		posY = size.height-40
	elseif spotType == 3 then --左偏下角 
		posX = 25
		posY = 88
	elseif spotType == 4 then --技能 升星按钮
		posX = 35
		posY = size.height-28
	elseif spotType == 5 then --签到
		posX = 36
		posY = size.height-32
	end
	local imgRedSpot = TextureManager.createImg("component_common/img_promt.png")
	imgRedSpot:retain()
	imgRedSpot:setPosition(cc.p(posX,posY))
	node:addChild(imgRedSpot)
	local pet_id = petId
	local function redSpot(event)
		if pet_id then
			if pet_id==event._usedata then
				if NewsTable[key].status == true then
					imgRedSpot:setVisible(true)
				else
					imgRedSpot:setVisible(false)
				end
			end
		else
			if NewsTable[key].status == true then
				imgRedSpot:setVisible(true)
			else
				imgRedSpot:setVisible(false)
			end
		end
	end

	if petId == nil then
		if NewsTable[key].status == true  then
			imgRedSpot:setVisible(true)
		else
			imgRedSpot:setVisible(false)
		end
	else
		local checkReult = checkOnePetPromt(key, petId)
		if checkReult == true then
			imgRedSpot:setVisible(true)
		else
			imgRedSpot:setVisible(false)
		end
	end
	local listener = cc.EventListenerCustom:create(NewsTable[key].eventName,redSpot)
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	eventDispatcher:addEventListenerWithFixedPriority(listener, 1)
end

function  addRedWeekGigtSpot(node,spotType,status,tag)
	local size = node:getContentSize()
	local posX,posY = 0,0
	if spotType == 1 then --左上角
		posX = 10
		posY = size.height-10
	elseif spotType == 2 then --七日板
		posX = -45
		posY = size.height-5
	elseif spotType == 3  then 
		posX = -270
		posY = size.height-5
	end
	local imgRedSpot = TextureManager.createImg("component_common/img_promt.png")
	imgRedSpot:setPosition(cc.p(posX,posY))
	node:addChild(imgRedSpot) 
	imgRedSpot:setTag(tag)
	if status==true then
		imgRedSpot:setVisible(true)
	else
		imgRedSpot:setVisible(false)
	end
end










