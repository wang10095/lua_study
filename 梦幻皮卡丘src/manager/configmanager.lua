module("ConfigManager", package.seeall)

local CONFIG_FILES = {
	PET_TRAIN = "pet_train",
	PET = "pet",
	PET_FORM = "pet_form",
	PET_APTITUDE = "pet_aptitude",
	PET_CHARACTER = "pet_character",
	SKILL = "skill",
	PET_COMMON = "pet_common",
	USER_COMMON = "user_common",
	DAILYATTENDANCE = "dailyattendance",
	QUALITY = "quality",
	USER = "user",
	PET_STAR = "pet_star",
	SKILL_CONSUME  = "pet_skill_consume",
	STAGE_REWARD_NORMAL = "stage_reward_normal",
	STAGE_REWARD_ELITE	= "stage_reward_elite",
	ITEM = "item",
	TRIAL = "trial",
	VIP = "vip",
	ACHIEVEMENT = "achievement",
	ACTIVITY3_COMMON = "activity3_common",
	ACTIVITY3_REWARDS = "activity3_rewards",
	ACTIVITY1_GRID = "activity1_grid",
	ACTIVITY1_COUPON = "activity1_coupon",
	ACTIVITY1_COMMON = "activity1_common",
	ACTIVITY1_SCORE = "activity1_score",
	ACTIVITY1_REWARD = "activity1_reward",
	ACTIVITY1_ERNIE = "activity1_ernie",
	EMAIL = "email",
	DUNGEON_NORMAL = "dungeon_normal",
	DUNGEON_ELITE = "dungeon_elite",
	DUNGEON_ACTIVITY = "dungeon_activity",
	MONSTER = "monster",
	ACTIVITY2_COMMON = "activity2_common",
	ACTIVITY2_STATUS = "activity2_status",
	ACTIVITY2_DIFFICULTY = "activity2_difficulty",
	ACTIVITY1_MONSTER = "activity1_monster",
	DEBUFF = "debuff",
	BUFF = "buff",
	SKILL_EXTRA_EFFECT = "skill_extra_effect",
	SERVICER = "servicer",
	PVP1_COMMON = "pvp1_common",
	PVP1_BOXQUALITY = "pvp1_boxquality",
	PVP1_REWARDBASE = "pvp1_rewardbase",
	PVP1_ROCKREWARD = "pvp1_rockreward",
	EFFECT = "effect",
	SPECIAL_MONSTER = "special_monster",
	PVP1_BOXREWARD = "pvp1_boxreward",
	--七日礼包 配置
	SEVEN_COMMON = "seven_common",
	SEVEN_BUY = "seven_buy",
	SEVEN_ELITE_STAGE = "seven_elite_stage",
	SEVEN_BREED = "seven_breed",
	SEVEN_NORMAL_STAGE = "seven_normal_stage",
	SEVEN_PAYWELFARE = "seven_paywelfare",
	SEVEN_PETLEVEL = "seven_petlevel",
	SEVEN_POWER = "seven_power",
	SEVEN_PVE1 = "seven_pve1",
	SEVEN_PVE2 = "seven_pve2",
	SEVEN_PVE3 = "seven_pve3",
	SEVEN_PVP = "seven_pvp",
	SEVEN_SHOP = "seven_shop",
	SEVEN_SKILL = "seven_skill",
	SEVEN_STAR = "seven_star",
	SEVEN_TRAIN = "seven_train",
	SEVEN_USERLEVEL = "seven_userlevel",
	SEVEN_WELFARE = "seven_welfare",
	SIGN = "sign",
	PAY_SIGN = "pay_sign",
	STORY_NPC = "story_npc",
	STORY_VIEW = "story_view",
	STORY_CHAPTER = "story_chapter",
	STORY_STAGE = "story_stage",
	GUIDE  = "guide",
	GUIDE_PET = "guide_pet",
	PASSIVE_SKILL = "passive_skill",
	STAR_REWARD_NORAML = "star_reward_normal",
	STAR_REWARD_ELITE = "star_reward_elite",
	DAILY_TASK = "dailytask",
	STAGE_NORMAL = "stage_normal",
	SHOP_COMMON = "shop_common",
	SKILL_ELIMINATE_UNIT_EFFECT = "eliminate_unit_effect",
	STAGE_ELITE = "stage_elite",
	STAGE_COMMON = "stage_common",
	PET_GROW_RANDOM = "pet_grow_random",
	CARD_COMMON = "card_common",
	RECHARGE = "recharge",
	GOLDHAND_COMMON = "goldhand_common",
	USER_INIT = "user_init",
	STAGE_MAP = "stage_map",
	DIAMONDCONSUME = "diamondconsume",
	ACTIVITY_STAGE = "activity_stage",
	PET_INHERIT_COST = "pet_inherit_cost",
	STORY_FUNC = "story_func",
	RECHARGE_COMMON = "recharge_common",
	MENUSHOP = "menushop",
	HEAD_UNLOCK = "head_unlock",
	ANNOUNCE_COMMON = "announce_common",
}

local MAIN_KEY =
{
	chapter = function(t)
		return t.chapter.."_"..t.stage
	end,
	--aptitude--
	aptitude = function(t) 
		return t.aptitude 
	end,
	dungeon_stage = function (t)
		return t.chapter .. "_" .. t.stage 
	end,
	stage = function( t )
		return t.chapter .. "_" .. t.stage
	end,
	--user--
	user = function (t)
		return t.level
	end,
	food = function (t)
		return t.fid
	end,
	--quality
	quality = function (t)
		return t.quality
	end,
	--star
	starlevel = function (t)
		return t.starlevel
	end,
	--active_skill
	active_skill = function (t)
		return t.asid
	end,
	--passive_skill
	passive_skill = function (t)
		return t.psid
	end,
	--food merge formula
	food_merge = function (t)
		return t.fmid
	end,
	--fragment
	fragment = function (t)
		return t.fgid
	end,
	--scroll
	scroll = function (t)
		return t.scid
	end,
	--soul
	soul = function (t)
		return t.slid
	end,
	--consumable 
	consumable = function (t)
		return t.cid
	end,
	--trial
	trial = function (t)
		return t.storey
	end,
	trial_treasure = function (t)
		return t.has_treasure
	end,
	--achievement
	achievement = function (t)
		return t.achievement_id .. '_' .. t.sequence_id
	end,

	--texts
	--texts_dungeon--
	dungeon = function (t)
		return t.chapter 
	end,
	recharge = function ( t )
		return t.id
	end,

	vip = function (t)
		return t.vip_level
	end,

	dailytask = function(t )
		return t.task_id
	end,

	dailyattendance = function (t)
		return t.day_id
	end,
	
	skill_consume = function (t)
		return t.level
	end,

	--texts
	texts_pet = function (t)
		return t.model
	end,
	texts_ui = function (t)
		return t.key
	end,
	texts_mail = function(t)
		return t.mail_id 
	end,
	texts_pet_aptitude = function(t)
		return t.id
	end,
	texts_pet_character = function(t)
		return t.id
	end,
	texts_pet_rank = function(t)
		return t.id
	end,
	texts_pet_ability = function(t)
		return t.id
	end,
	texts_skill = function(t)
		return t.id
	end,

	stage = function(t)
		return t.chapter
	end,
}

local configs = {}

--no need to be called by outer space for local function
function getConfigByFile(key)
	local configs = Config.getConfigs(key)
	if (configs == nil) then
		print("no configuration found!")
		return nil
	end
    -- Debug.printTable("testConfigs", testConfigs)
	return configs[key]
end

--get all tuples that match the mainKey
function getTable(fileNameWithoutExtension, mainKeyIndex, ...)
	local arg = {...}
	local main_key = ""
	if #arg >= 1 then
		main_key = arg[1]
	end
	for i=2, #arg do
		main_key = main_key.."_"..arg[i]
	end
	local key_table = getConfigByFile(fileNameWithoutExtension)
	local ret = nil
	for _,v in pairs(key_table) do
		-- Debug.printTable(key, v)
		-- print("main_key:  "..MAIN_KEY[mainKeyIndex](v).." : "..main_key)
		-- print(mainKeyIndex)
		if MAIN_KEY[mainKeyIndex](v) == main_key then
			ret = ret or {}
			table.insert(ret, v)
		end
	end
	return ret
end


--get the only config that match the mainKey
function getConfig(fileNameWithoutExtension, mainKeyIndex, ...)
	local arg = {...}
	local main_key = ""
	if #arg >= 1 then
		main_key = arg[1]
	end
	for i=2, #arg do
		main_key = main_key.."_"..arg[i]
	end
	local key_table = getConfigByFile(fileNameWithoutExtension)
	for _,v in pairs(key_table) do
		-- Debug.printTable(key, v)
		-- print("main_key:  "..MAIN_KEY[mainKeyIndex](v).." : "..main_key)
		-- print(mainKeyIndex)
		if MAIN_KEY[mainKeyIndex](v) == main_key then
			return v
		end
	end
	return nil
end

function initPetTrainConfig()
	local trainConfigs = {}
	local tmpConfigs = getConfigByFile(CONFIG_FILES.PET_TRAIN) 
	for i,v in ipairs(tmpConfigs) do 
		trainConfigs[v.id] = trainConfigs[v.id] or {}
		trainConfigs[v.id][v.rank] = trainConfigs[v.id][v.rank] or {}
		trainConfigs[v.id][v.rank][v.rankPoint] = {
			levelDemand = v.levelDemand,
			materials = {v.material1, v.material2, v.material3},
			attributeAddition = v.attributeAddition
		}
	end
	configs[CONFIG_FILES.PET_TRAIN] = trainConfigs
end

function getPetTrainConfig(trainId, rank, rankPoint)
	local trainConfigs = configs[CONFIG_FILES.PET_TRAIN]
	if (trainConfigs == nil) then
		initPetTrainConfig()
		trainConfigs = configs[CONFIG_FILES.PET_TRAIN]
	end

	if (trainConfigs == nil) then
		return nil
	end
	return trainConfigs[trainId][rank][rankPoint]
end

function getTotalTrainPoint(trainId, rank)
	local trainConfigs = configs[CONFIG_FILES.PET_TRAIN]
	if (trainConfigs == nil) then
		initPetTrainConfig()
		trainConfigs = configs[CONFIG_FILES.PET_TRAIN]
	end

	if (trainConfigs == nil) then
		return nil
	end

	return #trainConfigs[trainId][rank]
end

function getPetConfig(mid) 
	local petConfigs = configs[CONFIG_FILES.PET]
	if (petConfigs == nil) then
		petConfigs = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.PET)
		for i,v in ipairs(tmpConfigs) do
			petConfigs[v.mid] = {
				form = v.form,
				item_type = v.item_type,
				star = v.star,
				pet_rank = v.pet_rank,
				intimacy = v.intimacy,
				level = v.level,
				train_id = v.train_id,
				aptitude = v.aptitude,  
				character = v.character,
				basic_attributes = { --基本信息 
					v.hp, 
					v.common_attack, 
					v.crit,
					v.crit_damage, 
					v.dodge_rate, 
					v.speed
				},
				star_attribute_growths = {  --星级属性提升
					v.star_hp_growth, --生命
					v.star_attack_growth,--攻击
				},
				evolution_stone =  v.evolution_stone,
				skill_energy_part = v.skill_energy_ranges
			}
		end
		configs[CONFIG_FILES.PET] = petConfigs
	end

	if petConfigs == nil then 
		return nil
	end

	return petConfigs[mid]
end

function getPetAttributeFactors()
	petCommonConfigs = configs[CONFIG_FILES.PET_COMMON]
	return {
		getPetCommonConfig('hp_coefficient'), 
		getPetCommonConfig('common_attack_coefficient'), 
		getPetCommonConfig('crit_coefficient'),
		getPetCommonConfig('crit_damage_coefficient'),
		getPetCommonConfig('dodge_rate_coefficient'),
		getPetCommonConfig('speed_coefficient'),
		getPetCommonConfig('passive1_open_rank'),
		getPetCommonConfig('passive2_open_rank'),
		getPetCommonConfig('skill_openlevel')
	}
end

function getPetFormConfig(PetMid,PetForm)
	local petFormConfigs = configs[CONFIG_FILES.PET_FORM]
	if petFormConfigs == nil then
		petFormConfigs = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.PET_FORM)
		for i,v in ipairs(tmpConfigs) do
			petFormConfigs[v.mid] = petFormConfigs[v.mid] or {}
			petFormConfigs[v.mid][v.form] = {
				model = v.model,
				skills = v.skills,
				passive_skills = v.passive_skills
			}
		end
		configs[CONFIG_FILES.PET_FORM] = petFormConfigs
	end
	if petFormConfigs[PetMid]==nil then
		return nil
	end
	if petFormConfigs == nil then
		return nil
	end
	return petFormConfigs[PetMid][PetForm]
end

function getPetAptitudeConfig(id)
	local petAptitudeConfigs = configs[CONFIG_FILES.PET_APTITUDE]
	if petAptitudeConfigs == nil then
		petAptitudeConfigs = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.PET_APTITUDE)
		for i,v in ipairs(tmpConfigs) do
			petAptitudeConfigs[v.id] = {
				num = v.num,
				drop_metrics = v.drop_metrics,
				breed_metrics = v.breed_metrics
			}
			
		end
		configs[CONFIG_FILES.PET_APTITUDE] = petAptitudeConfigs
	end
	if petAptitudeConfigs == nil then
		return nil
	end
	return petAptitudeConfigs[id]
end

function getPetCharacterConfig(id)
	local petCharacterConfigs = configs[CONFIG_FILES.PET_CHARACTER]
	if petCharacterConfigs == nil then
		petCharacterConfigs = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.PET_CHARACTER)
		for i,v in ipairs(tmpConfigs) do
			petCharacterConfigs[v.id] = {
				addition_type = v.addition_type,
				addition_percent = v.addition_percent,
			}
		end
		configs[CONFIG_FILES.PET_CHARACTER] = petCharacterConfigs
	end
	if petCharacterConfigs == nil then
		return nil
	end
	return petCharacterConfigs[id]
end


function getSkillConfig(id)
	local skillConfigs = configs[CONFIG_FILES.SKILL]
	if skillConfigs == nil then
		skillConfigs = 	{}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.SKILL)
		for i,v in ipairs(tmpConfigs) do
			skillConfigs[v.id] = v
		end
		configs[CONFIG_FILES.SKILL] = skillConfigs
	end
	if skillConfigs == nil then 
		return nil
	end
	return skillConfigs[id]
end



function getPetCommonConfig(key)
	local petCommonConfigs = configs[CONFIG_FILES.PET_COMMON]
	if petCommonConfigs == nil then
		petCommonConfigs = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.PET_COMMON)
		for i,v in ipairs(tmpConfigs) do
			petCommonConfigs[v.key] = v.param
		end
		configs[CONFIG_FILES.PET_COMMON] = petCommonConfigs
	end
	if petCommonConfigs == nil then 
		return nil
	end
	return petCommonConfigs[key]
end

function getUserCommonConfig(key)
	local userCommonConfigs = configs[CONFIG_FILES.USER_COMMON]
	if userCommonConfigs == nil then
		userCommonConfigs = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.USER_COMMON)
		for i,v in ipairs(tmpConfigs) do
			userCommonConfigs[v.key] = v.param
		end
		configs[CONFIG_FILES.USER_COMMON] = userCommonConfigs
	end
	if userCommonConfigs == nil then 
		return nil
	end
	return userCommonConfigs[key]
end

function getDailyAttendanceConfig(id)
	local dailyattendanceConfig = configs[CONFIG_FILES.DAILYATTENDANCE]
	if dailyattendanceConfig == nil then
		dailyattendanceConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.DAILYATTENDANCE)
		for i,v in pairs(tmpConfigs) do
			dailyattendanceConfig[v.id] = {
				day_id = v.day_id,
				item = v.item,
				vip_mult = v.vip_mult
			}
		end
		configs[CONFIG_FILES.DAILYATTENDANCE] = dailyattendanceConfig
	end
	if dailyattendanceConfig == nil then 
		return nil
	end
	return dailyattendanceConfig[id]
end

function getQualityConfig(quality)
	local qualityConfig = configs[CONFIG_FILES.QUALITY]
	if qualityConfig == nil then
		qualityConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.QUALITY)
		for i,v in pairs(tmpConfigs) do
			qualityConfig[v.quality] = {
				quality = v.quality,
				source = v.source,
				font_color = v.font_color,
				cost = v.cost
			}
		end
		configs[CONFIG_FILES.QUALITY] = qualityConfig
	end
	if qualityConfig == nil then 
		return nil
	end
	return qualityConfig[quality]
end

function getUserConfig(level)
	local  userConfigs = configs[CONFIG_FILES.USER]
	if userConfigs == nil then
		userConfigs = {}           
		local tmpConfigs = getConfigByFile(CONFIG_FILES.USER)
		for i,v in ipairs(tmpConfigs) do
			userConfigs[v.level] = {
				max_exp = v.max_exp,
				max_pet_exp = v.max_pet_exp,
				energy_gain = v.energy_gain,
				max_energy = v.max_energy,
				max_pet_num = v.max_pet_num
			}
		end
		configs[CONFIG_FILES.USER] = userConfigs
	end
	if userConfigs == nil then 
		return nil
	end
	return  userConfigs[level]
end

function getPetStarConfig(starlevel)
	local petStarConfigs = configs[CONFIG_FILES.PET_STAR]
	if petStarConfigs  == nil then
		petStarConfigs = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.PET_STAR)
		for i,v in ipairs(tmpConfigs) do
			petStarConfigs[v.starlevel] = { 
				material_num = v.material_num,
				gold_num = v.gold_num,
				form = v.form
			}
		end
		configs[CONFIG_FILES.PET_STAR] = petStarConfigs
	end
	if petStarConfigs == nil then
		return nil
	end
	return petStarConfigs[starlevel]
end


function getSkillConsumeConfig(level)
	local skillConsumeConfigs = configs[CONFIG_FILES.SKILL_CONSUME]
	if skillConsumeConfigs  == nil then
		skillConsumeConfigs = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.SKILL_CONSUME)
		for i,v in ipairs(tmpConfigs) do
			skillConsumeConfigs[v.level] = { 
				skill1 = v.skill1,
				skill2 = v.skill2,
				skill3 = v.skill3,
				skill4 = v.skill4
			}
		end
		configs[CONFIG_FILES.SKILL_CONSUME] = skillConsumeConfigs
	end
	if skillConsumeConfigs == nil then
		return nil
	end
	return skillConsumeConfigs[level]
end

function getStageRewardConfig(chapter,stage,item_type,mid)
	local stagerewardConfigs = configs[CONFIG_FILES.STAGE_REWARD_NORMAL]
	if stagerewardConfigs  == nil then
		stagerewardConfigs = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.STAGE_REWARD_NORMAL)
		for i,v in ipairs(tmpConfigs) do
			stagerewardConfigs[v.chapter] = stagerewardConfigs[v.chapter] or {} 
			stagerewardConfigs[v.chapter][v.stage] = stagerewardConfigs[v.chapter][v.stage] or {}
			stagerewardConfigs[v.chapter][v.stage][v.item_type] = stagerewardConfigs[v.chapter][v.stage][v.item_type] or {}
			stagerewardConfigs[v.chapter][v.stage][v.item_type][v.mid] = {
				num_scope =  v.num_scope, --数量区间
				chance = v.chance, --概率
				sweep_status = v.sweep_status, --扫荡标示
				isShow = v.isShow,  --显示
			}
		end
		configs[CONFIG_FILES.STAGE_REWARD_NORMAL] = stagerewardConfigs
	end
	if stagerewardConfigs == nil then
		return nil
	end
	if stagerewardConfigs[chapter][stage][item_type]== nil then
		return nil
	else
		if stagerewardConfigs[chapter][stage][item_type][mid] == nil then
			return nil
		end
	end
	return stagerewardConfigs[chapter][stage][item_type][mid]
end

function getStageEliteRewardConfig(chapter,stage,item_type,mid)
	local eliteRewardConfig = configs[CONFIG_FILES.STAGE_REWARD_ELITE]
	if eliteRewardConfig  == nil then
		eliteRewardConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.STAGE_REWARD_ELITE)
		for i,v in ipairs(tmpConfigs) do
			eliteRewardConfig[v.chapter] = eliteRewardConfig[v.chapter] or {} 
			eliteRewardConfig[v.chapter][v.stage] = eliteRewardConfig[v.chapter][v.stage] or {}
			eliteRewardConfig[v.chapter][v.stage][v.item_type] = eliteRewardConfig[v.chapter][v.stage][v.item_type] or {}
			eliteRewardConfig[v.chapter][v.stage][v.item_type][v.mid] = {
				num_scope =  v.num_scope, --数量区间
				chance = v.chance, --概率
				sweep_status = v.sweep_status, --扫荡标示
				isShow = v.isShow,  --显示
			}
		end
		configs[CONFIG_FILES.STAGE_REWARD_ELITE] = eliteRewardConfig
	end
	if eliteRewardConfig == nil then
		return nil
	end
	if eliteRewardConfig[chapter][stage][item_type]== nil then
		return nil
	else
		if eliteRewardConfig[chapter][stage][item_type][mid] == nil then
			return nil
		end
	end
	return eliteRewardConfig[chapter][stage][item_type][mid]
end

function getItemConfig(item_type,mid)
	local itemConfig = configs[CONFIG_FILES.ITEM]
	if itemConfig == nil then
		itemConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.ITEM)
		for i,v in ipairs(tmpConfigs) do
			itemConfig[v.item_type] = itemConfig[v.item_type] or {}
			itemConfig[v.item_type][v.mid] = {
				quality = v.quality,
				sell_price = v.sell_price,
				drop_type = v.drop_type,
				drop_stage = v.drop_stage,
				use_param = v.use_param
			}
		end
		configs[CONFIG_FILES.ITEM] = itemConfig
	end
	if itemConfig == nil then
		return nil
	end
	return itemConfig[item_type][mid]
end

function getTrialConfig(storey)
	local trialConfig = configs[CONFIG_FILES.TRIAL]
	if trialConfig == nil then
		trialConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.TRIAL)
		for i,v in ipairs(tmpConfigs) do
			trialConfig[v.storey] = {
				sid = v.sid,
				exp_bonus = v.exp_bonus,
				gold_bonus = v.gold_bonus,
				has_treasure = v.has_treasure,
				type1 = v.type1,
				id1 = v.id1,
				amount1 = v.amount1,
				type2 = v.type2,
				id2 = v.id2,
				amount2 = v.amount2,
				type3 = v.type3,
				id3 = v.id3,
				amount3 = v.amount3,
				type3 = v.type3,
				id3 = v.id3,
				amount3 = v.amount3
			}
		end
		configs[CONFIG_FILES.TRIAL] = trialConfig
	end
	if trialConfig == nil then
		return nil
	end
	return trialConfig[storey]
end

function getVipConfig(vip_level)
	local vipConfig = configs[CONFIG_FILES.VIP]
	if vipConfig == nil then
		vipConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.VIP)
		for i,v in ipairs(tmpConfigs) do
			vipConfig[v.vip_level] = {
				money_num = v.money_num,
				items = v.items,
				privilege = v.privilege,
				elite_reset_num = v.elite_reset_num,
				buy_energy_num = v.buy_energy_num,
				goldhand_num = v.goldhand_num,
				pyramid_num = v.pyramid_num,
				free_sweepcard_num = v.free_sweepcard_num,
				buy_pvp_num = v.buy_pvp_num,
				skillpoint_limit = v.skillpoint_limit
			}
		end
		configs[CONFIG_FILES.VIP] = vipConfig
	end
	if vipConfig == nil then
		return nil
	end
	return vipConfig[vip_level]
end

function getAchievementConfig(aid,sqid)
	local achievementConfig = configs[CONFIG_FILES.ACHIEVEMENT]
	if achievementConfig == nil then
		achievementConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.ACHIEVEMENT)
		for i,v in ipairs(tmpConfigs) do
			achievementConfig[v.aid] = achievementConfig[v.aid] or {}
			achievementConfig[v.aid][v.sqid] = {
				openlevel = v.openlevel,
				complete_condition = v.complete_condition,
				complete_condition_param = v.complete_condition_param,
				exp = v.exp,
				gold = v.gold,
				diamond = v.diamond,
				fame = v.fame,
				badge = v.badge,
				item1 = v.item1,
				item2 = v.item2,
				item3 = v.item3,
				item4 = v.item4,
				a_icon = v.a_icon
			}
		end
		configs[CONFIG_FILES.ACHIEVEMENT] = achievementConfig
	end
	if achievementConfig == nil then
		return nil
	end
	return achievementConfig[aid][sqid]
end

function getActivity3RewardsConfig(stage)
	local rewardsConfig = configs[CONFIG_FILES.ACTIVITY3_REWARDS]
	if rewardsConfig == nil then
		rewardsConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.ACTIVITY3_REWARDS)
		for i,v in ipairs(tmpConfigs) do
			rewardsConfig[v.stage] = {
				badget = v.badget,
				gold = v.gold,
				items = v.items
			}
		end
		configs[CONFIG_FILES.ACTIVITY3_REWARDS] = rewardsConfig
	end
	if rewardsConfig == nil then
		return nil
	end
	return rewardsConfig[stage]
end

function getActivity1GridConfig(grid_id)
	local gridConfig = configs[CONFIG_FILES.ACTIVITY1_GRID]
	if gridConfig == nil then
		gridConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.ACTIVITY1_GRID)
		for i,v in ipairs(tmpConfigs) do
			gridConfig[v.grid_id] = {
				grid_id = v.grid_id,
				Monday = v.Monday,
				Tuesday = v.Tuesday,
				Wednesday = v.Wednesday,
				Thursday = v.Thursday,
				Friday = v.Friday,
				Saturday = v.Saturday,
				Sunday = v.Sunday
			}
		end
		configs[CONFIG_FILES.ACTIVITY1_GRID] = gridConfig
	end
	if gridConfig == nil then
		return nil
	end
	return gridConfig[grid_id]
end

function getActivity1CouponConfig( id )
	local couponConfig = configs[CONFIG_FILES.ACTIVITY1_COUPON]
	if couponConfig == nil then
		couponConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.ACTIVITY1_COUPON)
		for i,v in ipairs(tmpConfigs) do
			couponConfig[v.id] = {
				id = v.id,
				item = v.item,
				diamond_price = v.diamond_price
			}
		end
		configs[CONFIG_FILES.ACTIVITY1_COUPON] = couponConfig
	end
	if couponConfig == nil then
		return nil
	end
	return couponConfig[id]
end
function getActivity1ErnieReward (id)
	local ernieConfig = configs[CONFIG_FILES.ACTIVITY1_ERNIE]
	if ernieConfig == nil then
		ernieConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.ACTIVITY1_ERNIE)
		for i,v in pairs(tmpConfigs) do
			ernieConfig[v.id] ={
				id = v.id,
				item = v.item
			}
		end
		configs[CONFIG_FILES.ACTIVITY1_ERNIE] = ernieConfig
	end 
	if ernieConfig == nil then
		return nil
	end
	return ernieConfig[id]
end

function getActivty1CommonConfig(key)
	local commonConfig = configs[CONFIG_FILES.ACTIVITY1_COMMON]
	if commonConfig == nil then
		commonConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.ACTIVITY1_COMMON)
		for i,v in ipairs(tmpConfigs) do
			commonConfig[v.key] = v.value 
		end
		configs[CONFIG_FILES.ACTIVITY1_COMMON] = commonConfig
	end
	if commonConfig == nil then
		return nil
	end
	return commonConfig[key]
end
function getActivty2CommonConfig(key)
	local commonConfig = configs[CONFIG_FILES.ACTIVITY2_COMMON]
	if commonConfig == nil then
		commonConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.ACTIVITY2_COMMON)
		for i,v in ipairs(tmpConfigs) do
			commonConfig[v.key] = v.value 
		end
		configs[CONFIG_FILES.ACTIVITY2_COMMON] = commonConfig
	end
	if commonConfig == nil then
		return nil
	end
	return commonConfig[key]
end
function getActivty3CommonConfig(key)
	local commonConfig = configs[CONFIG_FILES.ACTIVITY3_COMMON]
	if commonConfig == nil then
		commonConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.ACTIVITY3_COMMON)
		for i,v in ipairs(tmpConfigs) do
			commonConfig[v.key] = v.value 
		end
		configs[CONFIG_FILES.ACTIVITY3_COMMON] = commonConfig
	end
	if commonConfig == nil then
		return nil
	end
	return commonConfig[key]
end
function getActivity2StatusConfig(id)
	local activity2Config = configs[CONFIG_FILES.ACTIVITY2_STATUS]
	if activity2Config == nil then
		activity2Config = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.ACTIVITY2_STATUS)
		for i,v in ipairs(tmpConfigs) do
			activity2Config[v.id] = {
				demandLevel = v.demandLevel,
				enemyModel = v.enemyModel,
				action = v.action,
				dungeons = {
					v.dif1dungeon,
					v.dif2dungeon,
					v.dif3dungeon,
					v.dif4dungeon,
					v.dif5dungeon,
					v.dif6dungeon,
					v.dif7dungeon,
					v.dif8dungeon,
					v.dif9dungeon,
				}
			}
		end
		configs[CONFIG_FILES.ACTIVITY2_STATUS] = activity2Config
	end
	if activity2Config==nil then
		return nil
	end
	return activity2Config[id]
end

function getMonsterConfig(id)
	local monsterConfigs = configs[CONFIG_FILES.MONSTER]
	if monsterConfigs == nil then
		monsterConfigs = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.MONSTER)
		for i,v in ipairs(tmpConfigs) do
			monsterConfigs[v.id] = {
				id = v.id,
				model = v.model,
				level = v.level,
				skills = v.skills,
				passive_skills = v.passive_skills,
				attributes = {
							v.hp, 
							v.common_attack,  
							v.crit, 
							v.crit_damage, 
							v.dodge_rate, 
							v.speed},
				isBoss = v.is_boss
			}
		end
		configs[CONFIG_FILES.MONSTER] = monsterConfigs
	end
	return monsterConfigs[id]
end

function getActivity2DifficultyConfig(id)
	local difficultyConfig = configs[CONFIG_FILES.ACTIVITY2_DIFFICULTY]
	if difficultyConfig == nil then
		difficultyConfig = {}
		local tmpConfigs = getConfigByKey(CONFIG_FILES.ACTIVITY2_DIFFICULTY)
		for i,v in ipairs(tmpConfigs) do
			difficultyConfig[v.id] = {
                demandLevel = v.demandLevel
		    }
		end
		configs[CONFIG_FILES.ACTIVITY2_STATUS] = difficultyConfig
	end
	if difficultyConfig==nil then
		return nil
	end
	return difficultyConfig[id]
end

function getDungeonConfig(dungeonType, chapter, stage)
	local file
	if dungeonType == Constants.DUNGEON_TYPE.NORMAL then
		file = CONFIG_FILES.DUNGEON_NORMAL
	elseif dungeonType == Constants.DUNGEON_TYPE.ELITE then
		file = CONFIG_FILES.DUNGEON_ELITE
	else
		file = CONFIG_FILES.DUNGEON_ACTIVITY
	end

	-- print(file, chapter, stage)

	local dungeonConfigs = configs[file]
	if dungeonConfigs == nil then
		dungeonConfigs = {}
		local tmpConfigs = getConfigByFile(file)
		for i,v in ipairs(tmpConfigs) do
			local cpt = v.chapter or v.activity_id
			dungeonConfigs[cpt] = dungeonConfigs[cpt] or {}
			dungeonConfigs[cpt][v.stage] = {
				chapter = cpt,
				stage = v.stage,	
			}
			local monsters = {v.wave1}
			if type(v.wave2) == "table" then
				table.insert(monsters, v.wave2)
			end
			if type(v.wave3) == "table" then
				table.insert(monsters, v.wave3)
			end
			dungeonConfigs[cpt][v.stage].monsters = monsters
		end
		configs[file] = dungeonConfigs
	end
	return dungeonConfigs[chapter][stage]
end

function getActivity1MonsterConfig()
	local difficultyConfig = configs[CONFIG_FILES.ACTIVITY1_MONSTER]
	if difficultyConfig == nil then
		difficultyConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.ACTIVITY1_MONSTER)
		for i,v in ipairs(tmpConfigs) do
			table.insert(difficultyConfig,{
				level = v.level,
                candy_difficulty1 = v.candy_difficulty1,
                candy_difficulty2 = v.candy_difficulty2,
                candy_difficulty3 = v.candy_difficulty3,
                regal_difficulty1 = v.regal_difficulty1,
                regal_difficulty2 = v.regal_difficulty2,
                regal_difficulty3 = v.regal_difficulty3
		    })
		end
		configs[CONFIG_FILES.ACTIVITY1_MONSTER] = difficultyConfig
	end
	return difficultyConfig
end

function getDebuffConfig(id)
	local debuffConfigs = configs[CONFIG_FILES.DEBUFF]
	if debuffConfigs == nil then
		debuffConfigs = {}
		local tmp = getConfigByFile(CONFIG_FILES.DEBUFF)
		for i,v in ipairs(tmp) do
			debuffConfigs[v.id] = v
		end
		configs[CONFIG_FILES.DEBUFF] = debuffConfigs
	end
	return debuffConfigs[id]
end

function getBuffConfig(id)
	local buffConfigs = configs[CONFIG_FILES.BUFF]
	if buffConfigs == nil then
		buffConfigs = {}
		local tmp = getConfigByFile(CONFIG_FILES.BUFF)
		for i,v in ipairs(tmp) do
			buffConfigs[v.id] = v
		end
		configs[CONFIG_FILES.BUFF] = buffConfigs
	end
	return buffConfigs[id]
end

function getSkillExtraEffectConfig(id)
	local extConfig = configs[CONFIG_FILES.SKILL_EXTRA_EFFECT]
	if extConfig == nil then
		extConfig = {}
		local tmp = getConfigByFile(CONFIG_FILES.SKILL_EXTRA_EFFECT)
		for i,v in ipairs(tmp) do
			extConfig[v.id] = v
		end
		configs[CONFIG_FILES.SKILL_EXTRA_EFFECT] = extConfig
	end
	return extConfig[id]
end

function getServicerConfig(id)
	local servicerConfig = configs[CONFIG_FILES.SERVICER]
	if servicerConfig == nil then
		servicerConfig = {}
		local tmp = getConfigByFile(CONFIG_FILES.SERVICER)
		for i,v in ipairs(tmp) do
			servicerConfig[v.id] = v
		end
		configs[CONFIG_FILES.SERVICER] = servicerConfig
	end
	return servicerConfig[id]
end


function getPvp1CommonConfig(key)
	local pvp1CommonConfig = configs[CONFIG_FILES.PVP1_COMMON]
	if pvp1CommonConfig == nil then
		pvp1CommonConfig = {}
		local tmpConfigS = getConfigByFile(CONFIG_FILES.PVP1_COMMON)
		for i,v in ipairs(tmpConfigS) do
			pvp1CommonConfig[v.key] = v.data
		end
		configs[CONFIG_FILES.PVP1_COMMON] = pvp1CommonConfig
	end
	if pvp1CommonConfig==nil then
		return nil
	end

	return pvp1CommonConfig[key]

	-- return {
	-- 	pvp1CommonConfig("openlevel"),
	-- 	pvp1CommonConfig("daytimes"),
	-- 	pvp1CommonConfig("timekeeping"),
	-- 	pvp1CommonConfig("diamond"),
	-- 	pvp1CommonConfig("winrepution"),
	-- 	pvp1CommonConfig("failrepution"),
	-- 	pvp1CommonConfig("petlevel"),
	-- 	pvp1CommonConfig("lootper")
	-- }
end

function getPvp1ChestQuality( id )
local pvp1chestqualityConfig = configs[CONFIG_FILES.PVP1_BOXQUALITY]
	if pvp1chestqualityConfig == nil then
		pvp1chestqualityConfig = {}
		local tmp = getConfigByFile(CONFIG_FILES.PVP1_BOXQUALITY)
		for i,v in ipairs(tmp) do
			pvp1chestqualityConfig[v.id] = {
				quality = v.quality,
				percent = v.percent,
				need_time = v.need_time,
				weight = v.weight
			}
		end
		configs[CONFIG_FILES.PVP1_BOXQUALITY] = pvp1chestqualityConfig
	end
	return pvp1chestqualityConfig[id]
end

function getPvp1rockReward( rank )
	local pvp1rockrewardConfig = configs[CONFIG_FILES.PVP1_BOXQUALITY]
	if pvp1rockrewardConfig == nil then
		pvp1rockrewardConfig = {}
		local tmp = getConfigByFile(CONFIG_FILES.PVP1_BOXQUALITY)
		for i,v in ipairs(tmp) do
			pvp1rockrewardConfig[v.rank] = {
				diamond = v.diamond,
				prestige = v.prestige
			}
		end
		configs[CONFIG_FILES.PVP1_BOXQUALITY] = pvp1rockrewardConfig
	end
	return pvp1rockrewardConfig[id]
end

function getMailConfig(mailid)
	local mailConfig = configs[CONFIG_FILES.EMAIL]
	if mailConfig == nil then
		mailConfig = {}
		local tmp = getConfigByFile(CONFIG_FILES.EMAIL)
		for i,v in ipairs(tmp) do
			mailConfig[v.mailid] = {
			    mail_type = v.mail_type,
				diamond = v.diamond,
				gold = v.gold,
				prestige = v.prestige,
				dadge = v.dadge,
				item = v.item
			}
		end
		configs[CONFIG_FILES.EMAIL] = mailConfig
	end
	return mailConfig[mailid]
end

function getEffectConfig( pid ,index)
	print(pid,index)
	local effectConfig = configs[CONFIG_FILES.EFFECT]
	if effectConfig == nil then
		effectConfig = {}
		local tmp = getConfigByFile(CONFIG_FILES.EFFECT)
		for i,v in ipairs(tmp) do
			effectConfig[v.pid] = effectConfig[v.pid] or {}
			effectConfig[v.pid][v.index] = {
				pid = v.pid,
			    index = v.index,
				action_id = v.action_id,
				action_pos = v.action_pos,
				action_scale = v.action_scale,
				skill_id = v.skill_id,
				skill_pos = v.skill_pos,
				skill_scale = v.skill_scale,
				target_id = v.target_id,
				target_pos = v.target_pos,
				target_scale = v.target_scale,
				hit_num = v.hit_num
			}
		end
		configs[CONFIG_FILES.EFFECT] = effectConfig
	end
	
	return effectConfig[pid][index]
end

function getSevenCommonConfig(key)
	local sevenCommonConfig = configs[CONFIG_FILES.SEVEN_COMMON]
	if sevenCommonConfig == nil then
		sevenCommonConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.SEVEN_COMMON)
		for i,v in ipairs(tmpConfigs) do
			sevenCommonConfig[v.key] = v.param
		end
		configs[CONFIG_FILES.SEVEN_COMMON] = sevenCommonConfig
	end
	if sevenCommonConfig == nil then
		return nil
	end
	return sevenCommonConfig[key]
end

function getSevenBuyConfig(day_id)
	local sevenBuyConfig = configs[CONFIG_FILES.SEVEN_BUY]
	if sevenBuyConfig == nil then
		sevenBuyConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.SEVEN_BUY)
		for i,v in ipairs(tmpConfigs) do
			sevenBuyConfig[v.day_id] = {
				item = v.item,
				gold = v.gold,
				cost_diamond = v.cost_diamond
			}
		end
		-- configs[CONFIG_FILES.SEVEN_BUY] = sevenBuyConfig
	end
	if sevenBuyConfig == nil then
		return nil
	end
	if day_id == nil then
		return #sevenBuyConfig
	else
		return sevenBuyConfig[day_id]
	end
end

function getSevenEliteStageConfig(id)
	local sevenEliteStageConfig = configs[CONFIG_FILES.SEVEN_ELITE_STAGE]
	if sevenEliteStageConfig == nil then
		sevenEliteStageConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.SEVEN_ELITE_STAGE)
		for i,v in ipairs(tmpConfigs) do
			sevenEliteStageConfig[v.id] = {
				dungeon_id = v.dungeon_id,
				items = v.items,
				diamond = v.diamond,
				gold = v.gold
			}
		end
		-- configs[CONFIG_FILES.SEVEN_ELITE_STAGE] = sevenEliteStageConfig
	end
	if sevenEliteStageConfig == nil then
		return nil
	end
	
	if id == nil then
		return #sevenEliteStageConfig
	else
		return sevenEliteStageConfig[id]
	end
end

function getSevenBreedConfig(id)
	local sevenFusionConfig = configs[CONFIG_FILES.SEVEN_BREED]
	if sevenFusionConfig == nil then
		sevenFusionConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.SEVEN_BREED)
		for i,v in ipairs(tmpConfigs) do
			sevenFusionConfig[v.id] = {
				breed_num = v.breed_num,
				breed_aptitude = v.breed_aptitude,
				items = v.items,
				diamond = v.diamond,
				gold = v.gold
			}
		end
		-- configs[CONFIG_FILES.SEVEN_BREED] = sevenFusionConfig
	end
	if sevenFusionConfig == nil then
		return nil
	end
	if id == nil then
		return #sevenFusionConfig
	else
		return sevenFusionConfig[id]
	end
end
 
function getSevenNormalStageConfig(id)
	-- print("七日礼包的 普通关"..id)
	local sevenNormalStageConfig = configs[CONFIG_FILES.SEVEN_NORMAL_STAGE]
	if sevenNormalStageConfig == nil then
		sevenNormalStageConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.SEVEN_NORMAL_STAGE)
		for i,v in ipairs(tmpConfigs) do
			sevenNormalStageConfig[v.id] = {
				dungeon_id = v.dungeon_id,
				items = v.items,
				diamond = v.diamond,
				gold = v.gold
			}
		end
		-- configs[CONFIG_FILES.SEVEN_NORMAL_STAGE] = sevenNormalStageConfig
	end
	if sevenNormalStageConfig == nil then
		return nil
	end
	if id == nil then
		return #sevenNormalStageConfig
	else
		return sevenNormalStageConfig[id]	
	end
end

function getSevenPaywelfareConfig(day_id)
	local sevenPaywelfareConfig = configs[CONFIG_FILES.SEVEN_PAYWELFARE]
	if sevenPaywelfareConfig == nil then
		sevenPaywelfareConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.SEVEN_PAYWELFARE)
		for i,v in ipairs(tmpConfigs) do
			sevenPaywelfareConfig[v.day_id ] = {
				recharge = v.recharge,
				items = v.items,
				diamond = v.diamond,
				gold = v.gold
			}
		end
		-- configs[CONFIG_FILES.SEVEN_PAYWELFARE] = sevenPaywelfareConfig
	end
	if sevenPaywelfareConfig == nil then
		return nil
	end
	if day_id == nil then
		return #sevenPaywelfareConfig
	else
		return sevenPaywelfareConfig[day_id]	
	end

end

function getSevenPetLevelConfig(id)
	local sevenPetLevelConfig = configs[CONFIG_FILES.SEVEN_PETLEVEL]
	if sevenPetLevelConfig == nil then
		sevenPetLevelConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.SEVEN_PETLEVEL)
		for i,v in ipairs(tmpConfigs) do
			sevenPetLevelConfig[v.id] = {
				pet_num = v.pet_num,
				level = v.level,
				items = v.items,
				diamond = v.diamond,
				gold = v.gold
			}
		end
		-- configs[CONFIG_FILES.SEVEN_PETLEVEL] = sevenPetLevelConfig
	end
	if sevenPetLevelConfig == nil then
		return nil
	end
	if id == nil then
		return #sevenPetLevelConfig
	else
		return sevenPetLevelConfig[id]
	end
end

function getSevenPowerConfig(id)
	local getSevenPowerConfig = configs[CONFIG_FILES.SEVEN_POWER]
	if getSevenPowerConfig == nil then
		getSevenPowerConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.SEVEN_POWER)
		for i,v in ipairs(tmpConfigs) do
			getSevenPowerConfig[v.id] = {
				power = v.power,
				items = v.items,
				diamond = v.diamond,
				gold = v.gold
			}
		end
		-- configs[CONFIG_FILES.SEVEN_POWER] = getSevenPowerConfig
	end
	if getSevenPowerConfig == nil then
		return nil
	end
	if id == nil then
		return #getSevenPowerConfig
	else
		return getSevenPowerConfig[id]
	end
end

function getSevenPve1Config(id)
	local sevenPve1Config = configs[CONFIG_FILES.SEVEN_PVE1]
	if sevenPve1Config == nil then
		sevenPve1Config = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.SEVEN_PVE1)
		for i,v in ipairs(tmpConfigs) do
			sevenPve1Config[v.id] = {
				score = v.score,
				items = v.items,
				diamond = v.diamond,
				gold = v.gold
			}
		end
		-- configs[CONFIG_FILES.SEVEN_PVE1] = sevenPve1Config
	end
	if sevenPve1Config == nil then
		return nil
	end
	if id == nil then
		return #sevenPve1Config
	else
		return sevenPve1Config[id]
	end
end

function getSevenPve2Config(id)
	local sevenPve2Config = configs[CONFIG_FILES.SEVEN_PVE2]
	if sevenPve2Config == nil then
		sevenPve2Config = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.SEVEN_PVE2)
		for i,v in ipairs(tmpConfigs) do
			sevenPve2Config[v.id] = {
				dungeon_type = v.dungeon_type,
				difficulty = v.difficulty,
				items = v.items,
				diamond = v.diamond,
				gold = v.gold
			}
		end
		-- configs[CONFIG_FILES.SEVEN_PVE2] = sevenPve2Config
	end
	if sevenPve2Config == nil then
		return nil
	end
	if id == nil then
		return  #sevenPve2Config
	else
		return sevenPve2Config[id]	
	end
end

function getSevenPve3Config(id)
	local sevenPve3Config = configs[CONFIG_FILES.SEVEN_PVE3]
	if sevenPve3Config == nil then
		sevenPve3Config = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.SEVEN_PVE3)
		for i,v in ipairs(tmpConfigs) do
			sevenPve3Config[v.id] = {
				floor = v.floor,
				items = v.items,
				diamond = v.diamond,
				gold = v.gold
			}
		end
		-- configs[CONFIG_FILES.SEVEN_PVE3] = sevenPve3Config
	end
	if sevenPve3Config == nil then
		return nil
	end
	if id == nil then
		return #sevenPve3Config
	else
		return sevenPve3Config[id]
	end
end

function getSevenPvpConfig(id)
	local sevenPvpConfig = configs[CONFIG_FILES.SEVEN_PVP]
	if sevenPvpConfig == nil then
		sevenPvpConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.SEVEN_PVP)
		for i,v in ipairs(tmpConfigs) do
			sevenPvpConfig[v.id] = {
				ranking = v.ranking,
				measure_chest = v.measure_chest,
				items = v.items,
				diamond = v.diamond,
				gold = v.gold
			}
		end
		-- configs[CONFIG_FILES.SEVEN_PVP] = sevenPvpConfig
	end
	if sevenPvpConfig == nil then
		return nil
	end
	if id == nil then
		return #sevenPvpConfig
	else
		return sevenPvpConfig[id]
	end
end

function getSevenShopConfig(id)
	local sevenShopConfig = configs[CONFIG_FILES.SEVEN_SHOP]
	if sevenShopConfig == nil then
		sevenShopConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.SEVEN_SHOP)
		for i,v in ipairs(tmpConfigs) do
			sevenShopConfig[v.id] = {
				flush_num = v.flush_num,
				items = v.items,
				diamond = v.diamond,
				gold = v.gold
			}
		end
		-- configs[CONFIG_FILES.SEVEN_SHOP] = sevenShopConfig
	end
	if sevenShopConfig == nil then
		return nil
	end
	if id == nil then
		return #sevenShopConfig
	else
		return sevenShopConfig[id]
	end

end

function getSevenSkillConfig(id)
	local sevenSkillConfig = configs[CONFIG_FILES.SEVEN_SKILL]
	if sevenSkillConfig == nil then
		sevenSkillConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.SEVEN_SKILL)
		for i,v in ipairs(tmpConfigs) do
			sevenSkillConfig[v.id] = {
				skill_num = v.skill_num,
				skill_level = v.skill_level,
				items = v.items,
				diamond = v.diamond,
				gold = v.gold
			}
		end
		-- configs[CONFIG_FILES.SEVEN_SKILL] = sevenSkillConfig
	end
	if sevenSkillConfig == nil then
		return nil
	end
	if id == nil then
		return #sevenSkillConfig
	else
		return sevenSkillConfig[id]
	end
end

function getSevenStarConfig(id)
	local sevenStarConfig = configs[CONFIG_FILES.SEVEN_STAR]
	if sevenStarConfig == nil then
		sevenStarConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.SEVEN_STAR)
		for i,v in ipairs(tmpConfigs) do
			sevenStarConfig[v.id] = {
				pet_num = v.pet_num,
				star = v.star,
				items = v.items,
				diamond = v.diamond,
				gold = v.gold
			}
		end
		-- configs[CONFIG_FILES.SEVEN_STAR] = sevenStarConfig
	end
	if sevenStarConfig == nil then
		return nil
	end
	if id == nil then
		return #sevenStarConfig
	else
		return sevenStarConfig[id]
	end
end

function getSevenTrainConfig(id)
	local sevenTrainConfig = configs[CONFIG_FILES.SEVEN_TRAIN]
	if sevenTrainConfig == nil then
		sevenTrainConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.SEVEN_TRAIN)
		for i,v in ipairs(tmpConfigs) do
			sevenTrainConfig[v.id] = {
				num = v.num,
				rank = v.rank,
				items = v.items,
				diamond = v.diamond,
				gold = v.gold
			}
		end
		-- configs[CONFIG_FILES.SEVEN_TRAIN] = sevenTrainConfig
	end
	if sevenTrainConfig == nil then
		return nil
	end
	if id == nil then
		return #sevenTrainConfig
	else
		return sevenTrainConfig[id]
	end
end

function getSevenUserLevel(id)
	local sevenUserConfig = configs[CONFIG_FILES.SEVEN_USERLEVEL]
	if sevenUserConfig == nil then
		sevenUserConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.SEVEN_USERLEVEL)
		for i,v in ipairs(tmpConfigs) do
			sevenUserConfig[v.id] = {
				level = v.level,
				items = v.items,
				diamond = v.diamond,
				gold = v.gold
			}
		end
		-- configs[CONFIG_FILES.SEVEN_USERLEVEL] = sevenUserConfig
	end
	if sevenUserConfig == nil then
		return nil
	end
	if id == nil then
		return #sevenUserConfig
	else
		return sevenUserConfig[id]
	end
end

function getSevenWelfareLevel(day_id)
	local sevenWelfareConfig = configs[CONFIG_FILES.SEVEN_WELFARE]
	if sevenWelfareConfig == nil then
		sevenWelfareConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.SEVEN_WELFARE)
		for i,v in ipairs(tmpConfigs) do
			sevenWelfareConfig[v.day_id] = {
				items = v.items,
				diamond = v.diamond,
				gold = v.gold,
				tag_id1 = v.tag_id1,
				tag_id2 = v.tag_id2
			}
		end
		-- configs[CONFIG_FILES.SEVEN_WELFARE] = sevenWelfareConfig
	end
	if sevenWelfareConfig == nil then
		return nil
	end
	if day_id == nil then
		return #sevenWelfareConfig
	else
		return sevenWelfareConfig[day_id]
	end
end

function getSignConfig(id)
	local signConfig = configs[CONFIG_FILES.SIGN]
	if signConfig == nil then
		signConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.SIGN)
		for i,v in ipairs(tmpConfigs) do
			signConfig[v.id] = {
				diamond = v.diamond,
				gold = v.gold,
				items = v.items,
				vip = v.vip
			}
		end
		configs[CONFIG_FILES.SIGN] = signConfig
	end
	if signConfig == nil then
		return nil
	end
	return signConfig[id]
end

function getPaySignConfig(id)
	local paySignConfig = configs[CONFIG_FILES.PAY_SIGN]
	if paySignConfig == nil then
		paySignConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.PAY_SIGN)
		for i,v in ipairs(tmpConfigs) do
			paySignConfig[v.id] = {
				diamond = v.diamond,
				gold = v.gold,
				items = v.items
			}
		end
		configs[CONFIG_FILES.PAY_SIGN] = paySignConfig
	end
	if paySignConfig == nil then
		return nil
	end
	return paySignConfig[id]
end

function getSpecialMonsterConfig(monster_id)

	local smconfig = configs[CONFIG_FILES.SPECIAL_MONSTER]
	if smconfig == nil then
		smconfig = {}
		local tmpConfig = getConfigByFile(CONFIG_FILES.SPECIAL_MONSTER)
		for i,v in ipairs(tmpConfig) do
			smconfig[v.monster_id] = {
				monster_id = v.monster_id,
				special_monster_type = v.special_monster_type,
				rounds = v.rounds,
				disappear = v.disappear
			}
		end
		configs[CONFIG_FILES.SPECIAL_MONSTER] = smconfig
	end
	if smconfig == nil then
		return nil
	end
	return smconfig[monster_id]
end

function getGuideConfig(guidetype,guide_id)
	local guideConfig = configs[CONFIG_FILES.GUIDE]
	if guideConfig == nil then
		guideConfig = {}
		local tmpConfig = getConfigByFile(CONFIG_FILES.GUIDE)
		for i,v in ipairs(tmpConfig) do
			guideConfig[v.guidetype] = guideConfig[v.guidetype] or {}
			guideConfig[v.guidetype][v.guide_id] = {
				guidetype = v.guidetype,
				guide_id = v.guide_id,
				guide_type = v.guide_type,
				steps = v.steps,
				guide_icon = v.guide_icon,
				tip_npc = v.npc_id,
				tip_npc_pos = v.npc_pos,
				rect_scale = v.trans_rect,
				tip_pos = v.tip_pos,
				mask_type = v.mask_type,
				arrow_type = v.arrow_type,
				arrow_pos = v.arrow_pos
			}
		end
		configs[CONFIG_FILES.GUIDE] = guideConfig
	end
	if guideConfig == nil then
		return nil
	end
	return guideConfig[guidetype][guide_id]
end

function getGuidePetConfig( id )
	local guidepetConfig = configs[CONFIG_FILES.GUIDE_PET]
	if guidepetConfig == nil then
		guidepetConfig = {}
		local tmpConfig = getConfigByFile(CONFIG_FILES.GUIDE_PET)
		for i,v in ipairs(tmpConfig) do
			guidepetConfig[v.id] = {
				id = v.id,
				mid = v.mid,
				aptitude = v.aptitude,
				character = v.character,
				grow_random = v.grow_random
			}
		end
		configs[CONFIG_FILES.GUIDE_PET] = guidepetConfig
	end
	if guidepetConfig == nil then
		return nil
	end
	return guidepetConfig[id]
end

function getNPCStoryConfig(id)
	local npcConfig = configs[CONFIG_FILES.STORY_NPC]
	if npcConfig == nil then
		npcConfig = {}
		local tmpConfig = getConfigByFile(CONFIG_FILES.STORY_NPC)
		for i,v in ipairs(tmpConfig) do
			npcConfig[v.id] = {
				name = v.name,
				model = v.model
			}
		end
		configs[CONFIG_FILES.STORY_NPC] = npcConfig
	end
	if npcConfig == nil then
		return nil
	end
	return npcConfig[id]
end

function getViewStoryConfig(id)
	local viewConfig = configs[CONFIG_FILES.STORY_VIEW]
	if viewConfig == nil then
		viewConfig = {}
		local tmpConfig = getConfigByFile(CONFIG_FILES.STORY_VIEW)
		for i,v in ipairs(tmpConfig) do
			if viewConfig[v.id] then
				table.insert(viewConfig[v.id],{
					level = v.level,
					scene = v.scene,
					style = v.style,
					NPC = v.NPC,
					content = v.content
				})
			else
				viewConfig[v.id] = {}
				table.insert(viewConfig[v.id],{
					level = v.level,
					scene = v.scene,
					style = v.style,
					NPC = v.NPC,
					content = v.content
				})
			end
		end
		configs[CONFIG_FILES.STORY_VIEW] = viewConfig
	end
	if viewConfig == nil then
		return nil
	end
	return viewConfig[id]
end

function getFuncStoryConfig(id)
	local funcConfig = configs[CONFIG_FILES.STORY_FUNC]
	if funcConfig == nil then
		funcConfig = {}
		local tmpConfig = getConfigByFile(CONFIG_FILES.STORY_FUNC)
		for i,v in ipairs(tmpConfig) do
			if funcConfig[v.id] then
				table.insert(funcConfig[v.id],{
					level = v.level,
					scene = v.scene,
					style = v.style,
					NPC = v.NPC,
					content = v.content
				})
			else
				funcConfig[v.id] = {}
				table.insert(funcConfig[v.id],{
					level = v.level,
					scene = v.scene,
					style = v.style,
					NPC = v.NPC,
					content = v.content
				})
			end
		end
		configs[CONFIG_FILES.STORY_FUNC] = funcConfig
	end
	if funcConfig == nil then
		return nil
	end
	return funcConfig[id]
end
function getChapterStoryConfig(chapter)
	local chapterConfig = configs[CONFIG_FILES.STORY_CHAPTER]
	if chapterConfig == nil then
		chapterConfig = {}
		local tmpConfig = getConfigByFile(CONFIG_FILES.STORY_CHAPTER)
		for i,v in ipairs(tmpConfig) do
			if chapterConfig[v.chapter] then
				table.insert(chapterConfig[v.chapter],{
					style = v.style,
					NPC = v.NPC,
					content = v.content
				})
			else
				chapterConfig[v.chapter] = {}
				table.insert(chapterConfig[v.chapter],{
					style = v.style,
					NPC = v.NPC,
					content = v.content
				})
			end
		end
		configs[CONFIG_FILES.STORY_CHAPTER] = chapterConfig
	end
	if chapterConfig == nil then
		return nil
	end
	return chapterConfig[chapter]
end
function getStageStoryConfig(chapter,stage,pos)
	local stageStoryConfig = configs[CONFIG_FILES.STORY_STAGE]
	if stageStoryConfig == nil then
		stageStoryConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.STORY_STAGE)
		for i,v in ipairs(tmpConfigs) do
			stageStoryConfig[v.chapter] = stageStoryConfig[v.chapter] or {}
			stageStoryConfig[v.chapter][v.stage] = stageStoryConfig[v.chapter][v.stage] or {}
			if stageStoryConfig[v.chapter][v.stage][v.pos] then
				table.insert(stageStoryConfig[v.chapter][v.stage][v.pos],{
					style  = v.style,
					NPC = v.NPC,
					content = v.content
				})
			else
				stageStoryConfig[v.chapter][v.stage][v.pos] = {}
				table.insert(stageStoryConfig[v.chapter][v.stage][v.pos],{
					style  = v.style,
					NPC = v.NPC,
					content = v.content
				})
			end
		end
		configs[CONFIG_FILES.STORY_STAGE] = stageStoryConfig
	end
	if stageStoryConfig == nil then
		return nil
	end
	if stageStoryConfig[chapter] == nil then
		return nil
	end
	if stageStoryConfig[chapter][stage]==nil then
		return nil
	end
	return stageStoryConfig[chapter][stage][pos]
end

function getPVP1BoxReward(id)
	local boxConfig = configs[CONFIG_FILES.PVP1_BOXREWARD]
	if boxConfig == nil then
		boxConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.PVP1_BOXREWARD)
		for i,v in ipairs(tmpConfigs) do
			boxConfig[v.id] = {
				types = v.types,
				weight = v.weight
			}
		end
		configs[CONFIG_FILES.PVP1_BOXREWARD] = boxConfig
	end
	if boxConfig == nil then
		return nil
	end
	return boxConfig[id]
end

function getPassiveSkillConfig(id)
	local psConfig = configs[CONFIG_FILES.PASSIVE_SKILL]
	if psConfig == nil then
		psConfig = {}
		local tmpConfig = getConfigByFile(CONFIG_FILES.PASSIVE_SKILL)
		for i,v in ipairs(tmpConfig) do
			psConfig[v.id] = v
		end
		configs[CONFIG_FILES.PASSIVE_SKILL] = psConfig
	end
	if psConfig == nil then
		return nil
	end
	return psConfig[id]
end

function getPveStarReward(dungeonType,chapter)
	local dun = nil
	if dungeonType == Constants.DUNGEON_TYPE.NORMAL then
		dun = CONFIG_FILES.STAR_REWARD_NORAML
	elseif dungeonType == Constants.DUNGEON_TYPE.ELITE then
		dun = CONFIG_FILES.STAR_REWARD_ELITE 
	end
	local  starConfig = configs[dun]
	if starConfig == nil then
		starConfig = {}
		local tmpConfig = getConfigByFile(dun)
		for i,v in ipairs(tmpConfig) do
			starConfig[v.chapter] = {
				star = v.star,
				items = v.items,
				diamond = v.diamond
			}
		end
		configs[dun] = starConfig
	end

	if starConfig == nil then
		return nil
	end
	return starConfig[chapter]
end


function getDailyTaskConfig(task_id)
	local  dailyConfig = configs[CONFIG_FILES.DAILY_TASK]
	if dailyConfig == nil then
		dailyConfig = {}
		local tmpConfig = getConfigByFile(CONFIG_FILES.DAILY_TASK)
		for i,v in ipairs(tmpConfig) do
			dailyConfig[v.task_id] = {
				openlevel = v.openlevel,
				task_times = v.task_times,
				exp = v.exp,
				gold = v.gold,
				diamond = v.diamond,
				item = v.item
			}
		end
		configs[CONFIG_FILES.DAILY_TASK] = dailyConfig
	end

	if dailyConfig == nil then
		return nil
	end
	return dailyConfig[task_id]
end

function getStageNormalConfig(chapter,stage)
	local  stageNormalConfig = configs[CONFIG_FILES.STAGE_NORMAL]
	if stageNormalConfig == nil then
		stageNormalConfig = {}
		local tmpConfig = getConfigByFile(CONFIG_FILES.STAGE_NORMAL)
		for i,v in ipairs(tmpConfig) do
			stageNormalConfig[v.chapter] = stageNormalConfig[v.chapter] or {}
			stageNormalConfig[v.chapter][v.stage] ={
				chapter = v.chapter,
				stage = v.stage,
				entry_level = v.entry_level,
				energy_usage = v.energy_usage,
				time_limit = v.time_limit,
				gold_reward = v.gold_reward,
				player_exp_reward = v.player_exp_reward,
				pet_exp_reward = v.pet_exp_reward,
				boss_stage = v.boss_stage,
				model = v.mid
			}
		end
		configs[CONFIG_FILES.STAGE_NORMAL] = stageNormalConfig
	end

	if stageNormalConfig == nil then
		return nil
	end
	return stageNormalConfig[chapter][stage]
end



function getStageEliteConfig(chapter,stage)
	local  stageEliteConfig = configs[CONFIG_FILES.STAGE_ELITE]
	if stageEliteConfig == nil then
		stageEliteConfig = {}
		local tmpConfig = getConfigByFile(CONFIG_FILES.STAGE_ELITE)
		for i,v in ipairs(tmpConfig) do
			stageEliteConfig[v.chapter] = stageEliteConfig[v.chapter] or {}
			stageEliteConfig[v.chapter][v.stage] ={
				chapter = v.chapter,
				stage = v.stage,
				entry_level = v.entry_level,
				energy_usage = v.energy_usage,
				time_limit = v.time_limit,
				gold_reward = v.gold_reward,
				player_exp_reward = v.player_exp_reward,
				pet_exp_reward = v.pet_exp_reward,
				two_star = v.two_star,
				three_star = v.three_star,
				model = v.model
			}
		end
		configs[CONFIG_FILES.STAGE_ELITE] = stageEliteConfig
	end

	if stageEliteConfig == nil then
		return nil
	end
	return stageEliteConfig[chapter][stage]
end

function getActivityStageConfig(activity,stage)
	print(activity.."  getActivityStageConfig   "..stage)
	local  activityConfig = configs[CONFIG_FILES.ACTIVITY_STAGE]
	if activityConfig == nil then
		activityConfig = {}
		local tmpConfig = getConfigByFile(CONFIG_FILES.ACTIVITY_STAGE)
		for i,v in ipairs(tmpConfig) do
			activityConfig[v.activity] = activityConfig[v.activity] or {}
			activityConfig[v.activity][v.stage] ={
				activity = v.activity,
				stage = v.stage,
				entry_level = v.entry_level,
				energy_usage = v.energy_usage,
				time_limit = v.time_limit,
				gold_reward = v.gold_reward,
				player_exp_reward = v.player_exp_reward,
				pet_exp_reward = v.pet_exp_reward,
				dadge_reward = v.dadge_reward,
				map = v.map
			}
		end
		configs[CONFIG_FILES.ACTIVITY_STAGE] = activityConfig
	end

	if activityConfig == nil then
		return nil
	end
	return activityConfig[activity][stage]
end

function getShopCommonConfig(key)
	local shopCommonConfigs = configs[CONFIG_FILES.SHOP_COMMON]
	if shopCommonConfigs == nil then
		shopCommonConfigs = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.SHOP_COMMON)
		for i,v in ipairs(tmpConfigs) do
			shopCommonConfigs[v.key] = v.value
		end
		configs[CONFIG_FILES.SHOP_COMMON] = shopCommonConfigs
	end
	if shopCommonConfigs == nil then 
		return nil
	end
	return shopCommonConfigs[key]
end


function getEliminateUnitEffectConfig(id)
	local euec = configs[CONFIG_FILES.SKILL_ELIMINATE_UNIT_EFFECT]
	if euec == nil then
		euec = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.SKILL_ELIMINATE_UNIT_EFFECT)
		for i,v in ipairs(tmpConfigs) do
			euec[v.id] = v
		end
		configs[CONFIG_FILES.SKILL_ELIMINATE_UNIT_EFFECT] = euec
	end
	return euec[id]
end

function getStageCommonConfig(key)
	local stageConfig = configs[CONFIG_FILES.STAGE_COMMON]
	if stageConfig == nil then
		stageConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.STAGE_COMMON)
		for i,v in ipairs(tmpConfigs) do
			stageConfig[v.key] = v.param
		end
		configs[CONFIG_FILES.STAGE_COMMON] = stageConfig
	end
	if stageConfig==nil then
		return nil
	end
	return stageConfig[key]
end

function getPetGrowRandom(id)
	local stageConfig = configs[CONFIG_FILES.PET_GROW_RANDOM]
	if stageConfig == nil then
		stageConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.PET_GROW_RANDOM)
		for i,v in ipairs(tmpConfigs) do
			stageConfig[v.id] = {
			addedValueLimit = v.addedValueLimit,
			dropMetrics = v.dropMetrics,
			breedMetrics = v.breedMetrics,
			luckRevise = v.luckRevise,
			luckChange = v.luckChange,
			}
		end
		configs[CONFIG_FILES.PET_GROW_RANDOM] = stageConfig
	end
	if stageConfig==nil then
		return nil
	end
	return stageConfig[id]
end

function getCardCommonConfig(key)
	local stageConfig = configs[CONFIG_FILES.CARD_COMMON]
	if stageConfig == nil then
		stageConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.CARD_COMMON)
		for i,v in ipairs(tmpConfigs) do
			stageConfig[v.key] = v.param
		end
		configs[CONFIG_FILES.CARD_COMMON] = stageConfig
	end
	if stageConfig==nil then
		return nil
	end
	return stageConfig[key]
end
function getUserinitConfig(name)
	local userConfig = configs[CONFIG_FILES.USER_INIT]
	if userConfig == nil then
		userConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.USER_INIT)
		for i,v in ipairs(tmpConfigs) do
			userConfig[v.name] = v.amount
		end
		configs[CONFIG_FILES.USER_INIT] = userConfig
	end
	if userConfig==nil then
		return nil
	end
	return userConfig[name]
end
function getRechargeConfig(id)
	local rechargeConfig = configs[CONFIG_FILES.RECHARGE]
	if rechargeConfig == nil then
		rechargeConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.RECHARGE)
		for i,v in ipairs(tmpConfigs) do
			rechargeConfig[v.id] = {
				month_card = v.month_card,
				title = v.title,
				first_desc = v.first_desc,
				common_desc = v.common_desc,
				diamond_num = v.diamond_num,
				first_append = v.first_append,
				common_append = v.common_append,
				rmb = v.rmb
			}
		end
		configs[CONFIG_FILES.RECHARGE] = rechargeConfig
	end
	if rechargeConfig==nil then
		return nil
	end
	return rechargeConfig[id]
end
function getGoldhandCommonConfig(key)
	local goldHandConfig = configs[CONFIG_FILES.GOLDHAND_COMMON]
	if goldHandConfig == nil then
		goldHandConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.GOLDHAND_COMMON)
		for i,v in ipairs(tmpConfigs) do
			goldHandConfig[v.key] = v.value
		end
		configs[CONFIG_FILES.GOLDHAND_COMMON] = goldHandConfig
	end
	if goldHandConfig==nil then
		return nil
	end
	return goldHandConfig[key]
end

function getChpaterMapName(chapter)
	local mapConfig = configs[CONFIG_FILES.STAGE_MAP]
	if mapConfig == nil then
		mapConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.STAGE_MAP)
		for i,v in ipairs(tmpConfigs) do
			mapConfig[v.chapter] = v.map_name
		end
		configs[CONFIG_FILES.STAGE_MAP] = mapConfig
	end
	if mapConfig==nil then
		return nil
	end
	return mapConfig[chapter]
end

function getGoldHandDiamondCost(num)
	local costConfig = configs[CONFIG_FILES.DIAMONDCONSUME]
	if costConfig == nil then
		costConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.DIAMONDCONSUME)
		for i,v in ipairs(tmpConfigs) do
			costConfig[v.num] = v.cost
		end
		configs[CONFIG_FILES.DIAMONDCONSUME] = costConfig
	end
	if costConfig==nil then
		return nil
	end
	return costConfig[num]
end

function getPetInheritCostConfig(aptitude)
	local costConfig = configs[CONFIG_FILES.PET_INHERIT_COST]
	if costConfig == nil then
		costConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.PET_INHERIT_COST)
		for i,v in ipairs(tmpConfigs) do
			costConfig[v.aptitude] = {
				gold = v.gold,
				diamond = v.diamond
			}
		end
		configs[CONFIG_FILES.PET_INHERIT_COST] = costConfig
	end
	if costConfig==nil then
		return nil
	end
	return costConfig[aptitude]
end


function getActivity1ScoreConfig(id)
	local scoreConfig = configs[CONFIG_FILES.ACTIVITY1_SCORE]
	if scoreConfig == nil then
		scoreConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.ACTIVITY1_SCORE)
		for i,v in ipairs(tmpConfigs) do
			scoreConfig[v.id] = {
				id = v.id,
				reward_level = v.reward_level,
				score = v.score,
			}
		end
		configs[CONFIG_FILES.ACTIVITY1_SCORE] = scoreConfig
	end
	if scoreConfig==nil then
		return nil
	end
	return scoreConfig[id]
end

function getActivity1RewardConfig()
	local rewardConfig = configs[CONFIG_FILES.ACTIVITY1_REWARD]
	if rewardConfig == nil then
		rewardConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.ACTIVITY1_REWARD)
		for i,v in ipairs(tmpConfigs) do
			table.insert(rewardConfig, {
				reward_level = v.reward_level,
				reward_bronze_item = v.reward_bronze_item,
				reward_silver_item = v.reward_silver_item,
				reward_gold_item = v.reward_gold_item,
				reward_bronze_gold = v.reward_bronze_gold,
				reward_silver_gold = v.reward_silver_gold,
				reward_gold_gold = v.reward_gold_gold,
			})
		end
		configs[CONFIG_FILES.ACTIVITY1_REWARD] = rewardConfig
	end
	return rewardConfig
end

function getRechargeCommonConfig(key)
	local rechargeCommonConfig = configs[CONFIG_FILES.RECHARGE_COMMON]
	if rechargeCommonConfig == nil then
		rechargeCommonConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.RECHARGE_COMMON)
		for i,v in ipairs(tmpConfigs) do
			rechargeCommonConfig[v.key] = v.param
		end
		configs[CONFIG_FILES.RECHARGE_COMMON] = rechargeCommonConfig
	end
	if rechargeCommonConfig==nil then
		return nil
	end
	return rechargeCommonConfig[key]
end

function getMenushopConfig(id)
	local menuConfig = configs[CONFIG_FILES.MENUSHOP]
	if menuConfig == nil then
		menuConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.MENUSHOP)
		for i,v in ipairs(tmpConfigs) do
			menuConfig[v.id] = {
				time = v.time,
				moneyType = v.moneyType,
				price = v.price,
				limitNum = v.limitNum
			}
		end
		configs[CONFIG_FILES.MENUSHOP] = menuConfig
	end
	if menuConfig==nil then
		return nil
	end
	return menuConfig[id]
end

function getHeadUnlockCondition(id)
	local headConfig = configs[CONFIG_FILES.HEAD_UNLOCK]
	if headConfig == nil then
		headConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.HEAD_UNLOCK)
		for i,v in ipairs(tmpConfigs) do
			headConfig[v.id] = v.unlockCondition
		end
		configs[CONFIG_FILES.HEAD_UNLOCK] = headConfig
	end
	if headConfig==nil then
		return nil
	end
	return headConfig[id]
end

function getAnnounceCommon(id)
	local headConfig = configs[CONFIG_FILES.ANNOUNCE_COMMON]
	if headConfig == nil then
		headConfig = {}
		local tmpConfigs = getConfigByFile(CONFIG_FILES.ANNOUNCE_COMMON)
		for i,v in ipairs(tmpConfigs) do
			headConfig[v.id] = {
				title = v.title,
				opentime = v.opentime,
				closetime = v.closetime,
				content = v.content
			}
		end
		configs[CONFIG_FILES.ANNOUNCE_COMMON] = headConfig
	end
	if headConfig==nil then
		return nil
	end
	return headConfig[id]
end

function getAnnounceNum()
	local tmpConfigs = getConfigByFile(CONFIG_FILES.ANNOUNCE_COMMON)
	return #tmpConfigs
end




