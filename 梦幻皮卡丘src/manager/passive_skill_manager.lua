module("PassiveSkillManager", package.seeall)

local petPassiveSkills = {}
local demonPassiveSkills = {}

function addPassiveSkill(caster)
	local passiveSkills
	print("create passive skill", caster.isPet)
	if caster.monsterId ~= nil then
		local monsterConfig = ConfigManager.getMonsterConfig(caster.monsterId)
		passiveSkills = monsterConfig.passive_skills
	else
		local formConfig = ConfigManager.getPetFormConfig(caster.pet:get("mid"), caster.pet:get("form"))
		passiveSkills = formConfig.passive_skills
	end
	if passiveSkills == nil then
		return
	end
	for i,v in ipairs(passiveSkills) do
		local ps = PassiveSkill:create(v, caster)
		if ps ~= nil and caster.isPet then
			table.insert(petPassiveSkills, ps)
		else
			table.insert(demonPassiveSkills, ps)
		end
	end
end

function removePassiveSkill(caster)
	print(">>>>>>>>>>>>>>>>>>>>>>>> removePassiveSkill", #petPassiveSkills, #demonPassiveSkills)
	local psArr = caster.isPet and petPassiveSkills or demonPassiveSkills
	local l = #psArr
	for i = 0, l - 1 do
		local idx = l - i
		if psArr[idx].caster == caster then
			table.remove(psArr, idx)
		end
	end
	print(">>>>>>>>>>>>>>>>>>>>>>>> removePassiveSkill", #petPassiveSkills, #demonPassiveSkills)
end

function getPassiveSkills(petUnit)
	return petUnit.isPet and petPassiveSkills or demonPassiveSkills
end