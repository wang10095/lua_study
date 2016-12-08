module("TextManager", package.seeall)

local CONFIG_FILES = {
	TEXTS_MATERIAL = "texts_material",
	TEXTS_TREASURE_CHEST = "texts_treasure_chest",
	TEXTS_TRAIN_MATERIAL = "texts_train_material",
	TEXTS_EVOLUTION_STONE = "texts_evolution_stone",
	TEXTS_EXP_POTION = "texts_exp_potion",
	TEXTS_ENERGY_POTION = "texts_energy_potion",
	TEXTS_PET = "texts_pet",
	TEXTS_PET_APTITUDE = "texts_pet_aptitude",
	TEXTS_PET_CHARACTER = "texts_pet_character",
	TEXTS_SKILL = "texts_skill",		
	TEXTS_PET_ABILITY = "texts_pet_ability",
	TEXTS_CHAPTER = "texts_chapter",
	TEXTS_STAGE = "texts_stage",
	TEXTS_DAILYTASK = "texts_dailytask",
	TEXTS_MAIL = "texts_mail",
	TEXTS_TRIAL = "texts_trial",
	TEXTS_ACHIEVEMENT = "texts_achievement",
	TEXTS_ACTIVITY1_QUESTION = "texts_activity1_question",
	TEXTS_ACTIVITY1_ERNIE = "texts_activity1_ernie",
	TEXTS_ACTIVITY2_STATUS = "texts_activity2_status",
	TEXTS_SERVICER = "texts_servicer",
	TEXTS_PVP1REWARD = "texts_pvp1reward",
	TEXTS_RECHARGE = "recharge",
	TEXTS_SEVEN_WELFARE = "texts_seven_welfare",
	TEXTS_ITEM = "texts_item",
	TEXTS_GUIDE = "texts_guide",
	TEXTS_ACHIEVEMENT_TITLE = "texts_achievement_title",
	TEXTS_PASSIVE_SKILL = "texts_passive_skill",
	TEXTS_SEVEN = "texts_seven",
	TEXTS_NPC = "texts_npc",
	TEXTS_VIP = "texts_vip",
	TEXTS_LEVELUP = "texts_levelup",
	TEXTS_ACTIVITY2_DIFFICULTY = "texts_activity2_difficulty",
}
	
local texts = {}

--in order to unify the coding style the key of this manager should start with 'ui_'
function getText(key)
	local text = ConfigManager.getConfig('texts_ui','texts_ui',key)
	local ret = key
	if text ~= nil then
		ret = text.value
	end
	return ret
end

local function initPetTexts()
	local petTexts = ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_PET)
	for i,v in ipairs(petTexts) do
		petTexts[v["mid"]] = petTexts[v["mid"]] or {}
		petTexts[v["mid"]][v["form"]] = v
	end
	texts[CONFIG_FILES.TEXTS_PET] = petTexts
end

function getPetName(mid, form)
	local petTexts = texts[CONFIG_FILES.TEXTS_PET]
	if petTexts == nil then
		initPetTexts()
		petTexts = texts[CONFIG_FILES.TEXTS_PET]
	end
	if petTexts[mid] == nil or petTexts[mid][form] == nil then
		return nil
	end
	return petTexts[mid][form]["name"]
end

function getPetDesc(mid, form)
	local petTexts = texts[CONFIG_FILES.TEXTS_PET]
	if petTexts == nil then
		initPetTexts()
		petTexts = texts[CONFIG_FILES.TEXTS_PET]
	end
	if petTexts[mid] == nil or petTexts[mid][form] == nil then
		return nil
	end
	return petTexts[mid][form]["desc"]
end

function getPetSkillName(skillId)
	if skillId == nil or skillId == 0 then
		return ""
	end
	local  petSkillConfigs = texts[CONFIG_FILES.TEXTS_SKILL]
	if petSkillConfigs == nil then
		petSkillConfigs = {}
		local tmpConfigs = ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_SKILL)
		for i,v in ipairs(tmpConfigs) do
			petSkillConfigs[v.id] = v
		end
	end
	if petSkillConfigs == nil then 
		return nil
	end
	texts[CONFIG_FILES.TEXTS_SKILL] = petSkillConfigs
	if petSkillConfigs and petSkillConfigs[skillId] then
		return  petSkillConfigs[skillId]["name"]
	else
		return "skillname_" .. skillId
	end 
end

function getPetSkillDesc(skillId)
	local  petSkillConfigs = texts[CONFIG_FILES.TEXTS_SKILL]
	if petSkillConfigs == nil then
		petSkillConfigs = {}
		local tmpConfigs = ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_SKILL)
		for i,v in ipairs(tmpConfigs) do
			petSkillConfigs[v.id] = v
		end
	end
	if petSkillConfigs == nil then 
		return nil
	end
	texts[CONFIG_FILES.TEXTS_SKILL] = petSkillConfigs
	return  petSkillConfigs[skillId]["desc"]
end

function getPetSkillNumDesc(skillId)
	local  petSkillConfigs = texts[CONFIG_FILES.TEXTS_SKILL]
	if petSkillConfigs == nil then
		petSkillConfigs = {}
		local tmpConfigs = ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_SKILL)
		for i,v in ipairs(tmpConfigs) do
			petSkillConfigs[v.id] = v
		end
	end
	if petSkillConfigs == nil then 
		return nil
	end
	texts[CONFIG_FILES.TEXTS_SKILL] = petSkillConfigs
	return  petSkillConfigs[skillId]["numDesc"]
end

function getPetAptitudeName(id)
	local  petAptitudeConfigs = texts[CONFIG_FILES.TEXTS_PET_APTITUDE]
	if petAptitudeConfigs == nil then
		petAptitudeConfigs = {}
		local tmpConfigs = ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_PET_APTITUDE)
		for i,v in ipairs(tmpConfigs) do
			petAptitudeConfigs[v.id]  = v
		end
	end
	if petAptitudeConfigs == nil then 
		return nil
	end
	texts[CONFIG_FILES.TEXTS_PET_APTITUDE] = petAptitudeConfigs 
	return  petAptitudeConfigs[id]["name"]
end


function getPetCharacterName(id)
	local  petCharacterConfigs = texts[CONFIG_FILES.TEXTS_PET_CHARACTER]
	if petCharacterConfigs == nil then
		petCharacterConfigs = {}
		local tmpConfigs = ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_PET_CHARACTER)
		for i,v in ipairs(tmpConfigs) do
			petCharacterConfigs[v.id] = v
		end
	end
	if petCharacterConfigs == nil then 
		return nil
	end
	texts[CONFIG_FILES.TEXTS_PET_CHARACTER] = petCharacterConfigs
	return  petCharacterConfigs[id]["name"]
end

function getPetAbilityName(id)
	local  petAbilityNameConfigs = texts[CONFIG_FILES.TEXTS_PET_ABILITY]
	if petAbilityNameConfigs == nil then
		petAbilityNameConfigs = {}
		local tmpConfigs = ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_PET_ABILITY)
		for i,v in ipairs(tmpConfigs) do
			petAbilityNameConfigs[v.id] = v
		end
	end
	if petAbilityNameConfigs == nil then 
		return nil
	end
	texts[CONFIG_FILES.TEXTS_PET_ABILITY] = petAbilityNameConfigs
	return  petAbilityNameConfigs[id]["name"]
end

function getChapterName(chapter)
	local pveChapterConfig = texts[CONFIG_FILES.TEXTS_CHAPTER]
	if pveChapterConfig == nil then
		pveChapterConfig = {}
		local tmpConfigs = ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_CHAPTER)
		for i,v in pairs(tmpConfigs) do
			pveChapterConfig[v.chapter] = {
				chapter = v.chapter,
				chapter_name =v.chapter_name
			}
		end
		texts[CONFIG_FILES.TEXTS_CHAPTER] = pveChapterConfig
	end 
	if pveChapterConfig == nil then
		return nil
	end
	return pveChapterConfig[chapter]
end

function getStageText(chapter,stage)
	local StageConfig = texts[CONFIG_FILES.TEXTS_STAGE]
	if StageConfig == nil then
		StageConfig = {}
		local tmpConfigs =ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_STAGE)
		for i,v in pairs(tmpConfigs) do
			StageConfig[v.chapter] = StageConfig[v.chapter] or {}
			StageConfig[v.chapter][v.stage] = {
				chapter = v.chapter,
				chapter_name =v.chapter_name,
				stage = v.stage,
				name = v.name,
				info = v.info
			}
		end
		texts[CONFIG_FILES.TEXTS_STAGE] = StageConfig
	end 
	if StageConfig == nil then
		return nil
	end
	return StageConfig[chapter][stage]
end


function getChapterDesc(stage_type, chapter)
end

function getStageDesc(stage_type, chapter, stage)
end

function getDailyTaskDesc (task_id)
	local dailytaskConfig = texts[CONFIG_FILES.TEXTS_DAILYTASK]
	if dailytaskConfig == nil then
		dailytaskConfig = {}
		local tmpConfigs =ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_DAILYTASK)
		for i,v in pairs(tmpConfigs) do
			dailytaskConfig[v.task_id] ={
				task_id = v.task_id,
				task_title = v.task_title,
				task_desc =v.task_desc
			}
		end
		texts[CONFIG_FILES.TEXTS_DAILYTASK] = dailytaskConfig
	end 
	if dailytaskConfig == nil then
		return nil
	end
	return dailytaskConfig[task_id]
end

function getAchievementDesc (id)
	local achievementConfig = texts[CONFIG_FILES.TEXTS_ACHIEVEMENT]
	if achievementConfig == nil then
		achievementConfig = {}
		local tmpConfigs = ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_ACHIEVEMENT)
		for i,v in pairs(tmpConfigs) do
			achievementConfig[v.id] = v.desc
		end
		texts[CONFIG_FILES.TEXTS_ACHIEVEMENT] = achievementConfig
	end 
	if achievementConfig == nil then
		return nil
	end
	return achievementConfig[id]
end

function getMailDesc (mailid)
	local mailConfig = texts[CONFIG_FILES.TEXTS_MAIL]
	if mailConfig == nil then
		mailConfig = {}
		local tmpConfigs =ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_MAIL)
		for i,v in pairs(tmpConfigs) do
			mailConfig[v.mailid] ={
				name = v.name,
				text =v.text
			}
		end
		texts[CONFIG_FILES.TEXTS_MAIL] = mailConfig
	end 
	if mailConfig == nil then
		return nil
	end
	return mailConfig[mailid]
end

function getTrialName (storey)
	local trialConfig = texts[CONFIG_FILES.TEXTS_TRIAL]
	if trialConfig == nil then
		trialConfig = {}
		local tmpConfigs =ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_TRIAL)
		for i,v in pairs(tmpConfigs) do
			trialConfig[v.storey] = v
		end
		texts[CONFIG_FILES.TEXTS_TRIAL] = trialConfig
	end 
	if trialConfig == nil then
		return nil
	end
	return trialConfig[storey]["name"]
end

function getActivity1Question (qid)
	local questionConfig = texts[CONFIG_FILES.TEXTS_ACTIVITY1_QUESTION]
	if questionConfig == nil then
		questionConfig = {}
		local tmpConfigs =ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_ACTIVITY1_QUESTION)
		for i,v in pairs(tmpConfigs) do
			questionConfig[v.qid] ={
				question = v.question,
				level_limit = v.level_limit,
				options1 = v.options1,
				options2 = v.options2,
				options3 = v.options3,
				options4 = v.options4,
				correct_option = v.correct_option
			}
		end
		texts[CONFIG_FILES.TEXTS_ACTIVITY1_QUESTION] = questionConfig
	end 
	if questionConfig == nil then
		return nil
	end
	
	return questionConfig[qid]
end

function getActivity1ErnieReward (id)
	local ernieConfig = texts[CONFIG_FILES.TEXTS_ACTIVITY1_ERNIE]
	if ernieConfig == nil then
		ernieConfig = {}
		local tmpConfigs =ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_ACTIVITY1_ERNIE)
		for i,v in pairs(tmpConfigs) do
			ernieConfig[v.id] ={
				id = v.id,
				types = v.types,
				item = v.item
			}
		end
		texts[CONFIG_FILES.TEXTS_ACTIVITY1_ERNIE] = ernieConfig
	end 
	if ernieConfig == nil then
		return nil
	end
	return ernieConfig[id]
end

function getActivity2Status(id)
	local statusConfig = texts[CONFIG_FILES.TEXTS_ACTIVITY2_STATUS]
	if statusConfig == nil then
		statusConfig = {}
		local tmpConfigs = ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_ACTIVITY2_STATUS) 
		for i,v in pairs(tmpConfigs) do
			statusConfig[v.id] = {
              name = v.name,
              desc = v.desc
		    }
		end
		texts[CONFIG_FILES.TEXTS_ACTIVITY2_STATUS] = statusConfig
	end
	if statusConfig == nil then
		return nil
	end
	return statusConfig[id]
end
function getServicerName(id)
	local servicerConfig = texts[CONFIG_FILES.TEXTS_SERVICER]
	if servicerConfig == nil then
		servicerConfig = {}
		local tmpConfigs = ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_SERVICER) 
		for i,v in pairs(tmpConfigs) do
			servicerConfig[v.id] = {
              name = v.name
		    }
		end
		texts[CONFIG_FILES.TEXTS_SERVICER] = servicerConfig
	end
	if servicerConfig == nil then
		return nil
	end
	return servicerConfig[id]
end

function getPvp1RewardType(id)
	local pvp1rewardConfig = texts[CONFIG_FILES.TEXTS_PVP1REWARD]
	if pvp1rewardConfig == nil then
		pvp1rewardConfig = {}
		local tmpConfigs = ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_PVP1REWARD) 
		for i,v in pairs(tmpConfigs) do
			pvp1rewardConfig[v.id] = {
              reward_type = v.reward_type
		    }
		end
		texts[CONFIG_FILES.TEXTS_PVP1REWARD] = pvp1rewardConfig
	end
	if pvp1rewardConfig == nil then
		return nil
	end
	return pvp1rewardConfig[id]
end

function getSevenTagName(id)
	local sevenTagConfig = texts[CONFIG_FILES.TEXTS_SEVEN_WELFARE]
	if sevenTagConfig == nil  then
		sevenTagConfig = {}
		local tmpConfigs = ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_SEVEN_WELFARE)
		for i,v in pairs(tmpConfigs) do
			sevenTagConfig[v.id] = v.name
		end
		texts[CONFIG_FILES.TEXTS_SEVEN_WELFARE] = sevenTagConfig
	end
	if sevenTagConfig == nil then
		return nil
	end
	return sevenTagConfig[id]
end

function getSevenTagTexts(tagid)
	local sevenTagConfig = texts[CONFIG_FILES.TEXTS_SEVEN]
	if sevenTagConfig == nil  then
		sevenTagConfig = {}
		local tmpConfigs = ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_SEVEN)
		for i,v in pairs(tmpConfigs) do
			sevenTagConfig[v.tagid] = v.text
		end
		texts[CONFIG_FILES.TEXTS_SEVEN] = sevenTagConfig
	end
	if sevenTagConfig == nil then
		return nil
	end
	return sevenTagConfig[tagid]
end
function getGuideTexts(types,id,step)
	local guideConfig = texts[CONFIG_FILES.TEXTS_GUIDE]
	if guideConfig == nil  then
		guideConfig = {}
		local tmpConfigs = ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_GUIDE)
		for i,v in pairs(tmpConfigs) do
			guideConfig[v.type][v.id][v.step] = v
			
		end
		texts[CONFIG_FILES.TEXTS_GUIDE] = guideConfig
	end
	if guideConfig == nil then
		return nil
	end
	return guideConfig[types][id][step]
end

local function getItemTextConfig(item_type,mid)
	local itemConfig = texts[CONFIG_FILES.TEXTS_ITEM]
	if itemConfig == nil then
		itemConfig = {}
		local tmpConfigs =ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_ITEM)
		for i,v in pairs(tmpConfigs) do
			itemConfig[v.item_type] = itemConfig[v.item_type] or {}
			itemConfig[v.item_type][v.mid] = {
				name = v.name,
				desc = v.desc
			}
		end
		texts[CONFIG_FILES.TEXTS_ITEM] = itemConfig 
	end 
	if itemConfig == nil then
		return nil
	end
	return itemConfig[item_type][mid]
end

function getItemName(item_type, mid)
	local itemConfig = getItemTextConfig(item_type,mid)
	return itemConfig.name
end

function getItemDesc(item_type, mid)
	local itemConfig = getItemTextConfig(item_type,mid)
	return itemConfig.desc
end

function getItemQuality(item_type,mid)
	local itemConfig = ConfigManager.getItemConfig(item_type,mid)
	return itemConfig.quality
end

function getAchievementTitle(aid,sqid)
	local achievementConfig = texts[CONFIG_FILES.TEXTS_ACHIEVEMENT_TITLE]
	if achievementConfig == nil  then
		achievementConfig = {}
		local tmpConfigs = ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_ACHIEVEMENT_TITLE)
		for i,v in pairs(tmpConfigs) do
			achievementConfig[v.aid] = achievementConfig[v.aid] or {}
			achievementConfig[v.aid][v.sqid] = v.title
		end
		texts[CONFIG_FILES.TEXTS_ACHIEVEMENT_TITLE] = achievementConfig
	end
	if achievementConfig == nil then
		return nil
	end
	return achievementConfig[aid][sqid]
end
	
function initPassiveSkill(id)
	local passiveConfig = texts[CONFIG_FILES.TEXTS_PASSIVE_SKILL]
	if passiveConfig == nil  then
		passiveConfig = {}
		local tmpConfigs = ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_PASSIVE_SKILL)
		for i,v in pairs(tmpConfigs) do
			passiveConfig[v.id] = {
				name = v.name,
				desc = v.desc,
				numDesc = v.numDesc
			}
		end
		texts[CONFIG_FILES.TEXTS_PASSIVE_SKILL] = passiveConfig
	end
	if passiveConfig == nil then
		return nil
	end
	return passiveConfig[id]
end

function getNPCtext(id,talk_type,index)
	local talkText = texts[CONFIG_FILES.TEXTS_NPC]
	if talkText == nil  then
		talkText = {}
		local tmpConfigs = ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_NPC)
		for i,v in pairs(tmpConfigs) do
			talkText[v.id] = talkText[v.id] or {}
			talkText[v.id][v.talk_type] = talkText[v.id][v.talk_type] or {}
			talkText[v.id][v.talk_type][v.index] = v.content
		end
		texts[CONFIG_FILES.TEXTS_NPC] = talkText
	end
	if talkText == nil then
		return nil
	end
	return talkText[id][talk_type][index]
end

function getNPCtextAmount(id,talk_type)
	local talkText = texts[CONFIG_FILES.TEXTS_NPC]
	if talkText == nil  then
		talkText = {}
		local tmpConfigs = ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_NPC)
		for i,v in pairs(tmpConfigs) do
			talkText[v.id] = talkText[v.id] or {}
			talkText[v.id][v.talk_type] = talkText[v.id][v.talk_type] or {}
			talkText[v.id][v.talk_type][v.index] = v.content
		end
		texts[CONFIG_FILES.TEXTS_NPC] = talkText
	end
	if talkText == nil then
		return nil
	end
	return talkText[id][talk_type]
end

function getPassiveSkillName(id)
	local passiveConfig = initPassiveSkill(id)
	return passiveConfig.name
end

function getPassiveSkillDesc(id)
	local passiveConfig = initPassiveSkill(id)
	return passiveConfig.desc
end
function getPassiveSkillNumDesc(id)
	local passiveConfig = initPassiveSkill(id)
	return passiveConfig.numDesc
end

function getVipDesc(vip_level)
	local vipText = texts[CONFIG_FILES.TEXTS_VIP]
	if vipText == nil  then
		vipText = {}
		local tmpConfigs = ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_VIP)
		for i,v in pairs(tmpConfigs) do
			vipText[v.vip_level] = v.desc
		end
		texts[CONFIG_FILES.TEXTS_VIP] = vipText
	end
	if vipText == nil then
		return nil
	end
	return vipText[vip_level]
end

function getLevelUpTexts(level)
	local levelText = texts[CONFIG_FILES.TEXTS_LEVELUP]
	if levelText == nil  then
		levelText = {}
		local tmpConfigs = ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_LEVELUP)
		for i,v in pairs(tmpConfigs) do
			levelText[v.level] = v.texts
		end
		texts[CONFIG_FILES.TEXTS_LEVELUP] = levelText
	end
	if levelText == nil then
		return nil
	end
	return levelText[level]
end

function getActivity2DifficultyName(id)
	local activty2Text = texts[CONFIG_FILES.TEXTS_ACTIVITY2_DIFFICULTY]
	if activty2Text == nil  then
		activty2Text = {}
		local tmpConfigs = ConfigManager.getConfigByFile(CONFIG_FILES.TEXTS_ACTIVITY2_DIFFICULTY)
		for i,v in pairs(tmpConfigs) do
			activty2Text[v.id] = v.name
		end
		texts[CONFIG_FILES.TEXTS_ACTIVITY2_DIFFICULTY] = activty2Text
	end
	if activty2Text == nil then
		return nil
	end
	return activty2Text[id]
end


