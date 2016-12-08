module("ItemManager", package.seeall)
local Items = Items or {}
local missingItems = missingItems or {}
local currentItem = nil
local oldItem = nil
local currentPet = nil
local oldPet = nil

local loadMissingItems = 
{
	[Constants.ITEM_TYPE.PET] = function ()
		-- print("loadMissingItems")
		local pidMissing = {}
		local its = getItemsByType(Constants.ITEM_TYPE.PET)
		for i = 1, 8 do
			pidMissing[i] = i
			for k,v in pairs(its) do
				if v:get("mid") == i then
					pidMissing[i] = nil
					break
				end
			end
		end
		local ret = ret or {}
		for k,_ in pairs(pidMissing) do
			local pet = Pet:create()
			pet:set("mid",k)
			pet:set("star",1)
			local aptitude = 1
			pet:set("aptitude",aptitude)
			table.insert(ret, pet)
		end
		local sortFunc = function (x, y)
			return x:get("aptitude") > y:get("aptitude")
		end
		table.sort(ret, sortFunc)
		missingItems[Constants.ITEM_TYPE.PET] = ret
		return ret
	end
}

-- format: {type, id, amount}
function parseItem(t)
	return createItem(t[1], t[2], t[3])
end

-- 加载道具，加载成功后派发相应消息
function loadItems(item_type)
	local function loadItemsHandler(result)
		updateItems(result["items"])
		local event = cc.EventCustom:new("event_load_items")
		cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
	end
	if item_type == Constants.ITEM_TYPE.PET then
		NetManager.sendCmd("loadpets", loadItemsHandler) 
	else
		NetManager.sendCmd("loaditems", loadItemsHandler, item_type) 
	end
end

function getPetById(id)
	local pets = getItemsByType(Constants.ITEM_TYPE.PET) or {}
	for i,pet in ipairs(pets) do
		if pet:get("id") == id then
			return pet
		end
	end
	return nil
end

-- 有则更新，无则添加
function updatePets(newPets)
	local newPetsTable = PetAttributeDataProxy:getInstance().newPetsTable
	local pets = getItemsByType(Constants.ITEM_TYPE.PET) or {}
	for i,p in ipairs(newPets) do
		local pet = getPetById(p["id"])
		if pet == nil then
			pet = Pet:create()
			table.insert(pets, pet)
			table.insert(newPetsTable,pet:get("id"))
		end
		pet:update(p)
	end
	-- print("添加成功")
	Items[Constants.ITEM_TYPE.PET] = pets
end

function addPet(newPet)
	local newPetsTable = PetAttributeDataProxy:getInstance().newPetsTable
	local pets = getItemsByType(Constants.ITEM_TYPE.PET) or {}
	local pet = getPetById(newPet["id"])
	if pet then
		print("pet with id: " .. pet:get("id") .. " already exists")
		return
	else
		pet = Pet:create()
		pet:update(newPet)
		table.insert(pets, pet)
		table.insert(newPetsTable,pet:get("id"))
	end
	-- print("引导抽卡 宠物添加成功")
	Items[Constants.ITEM_TYPE.PET] = pets
end

function removePetById(id)
	local pets = getItemsByType(Constants.ITEM_TYPE.PET) or {}
	for i = #pets,1,-1 do
		if pets[i]:get("id") == id then
			table.remove(pets, i)
		end
	end
	Items[Constants.ITEM_TYPE.PET] = pets
end

function updatePet(id, petProps)
	local pet = getPetById(id)
	if pet ~= nil then
		pet:update(petProps)
	end
end

function createItem(item_type, mid, amount) --创建物品
	local ret = Item:create(item_type, mid);
	if amount ~= nil then
		ret:set("amount", amount)
	end
	Items[item_type] = Items[item_type] or {}
	table.insert(Items[item_type], ret)
	return ret
end

function getItemsByType(item_type) 
	local ret = Items[item_type]
	if ret ~= nil and item_type == 1 then
		for i = #ret,1,-1 do
			if ret[i]:get("id")==nil then
				table.remove(ret, i)
			end
		end
	end
	return ret
end

function getItem(item_type, mid)
	local items = getItemsByType(item_type) or {}
	for i,item in ipairs(items) do
		if item:get("mid") == mid then
			return item
		end
	end
	return nil
end

function updateItem(item_type, mid, amount)
	local item = getItem(item_type, mid)
	if item == nil then
		item = createItem(item_type, mid, amount)
	else
		item:set("amount",amount)
	end
	local event = cc.EventCustom:new("event_update_item")
	event._usedata = item
	cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function updateItems(items)
	for i,item in ipairs(items) do     
		updateItem(item["item_type"], item["mid"], item["amount"])
	end
	PromtManager.checkOnePromt("UP_SKILL_LEVEL")
	PromtManager.checkOnePromt("TRAIN")
	PromtManager.checkOnePromt("UPSTAR")
end

-- 增加道具，此处amount为增加量
function addItem(item_type, mid, amount)
	updateItem(item_type, mid, getItemAmount(item_type, mid) + amount)
end

function getItemAmount(item_type, mid) -- 得到物品数量
	local item = getItem(item_type, mid)
	if item == nil then
		return 0
	end
	return item:get("amount")
end

function getMisingItemsByType(item_type)--没有获得的材料或宠物
	local ret = missingItems[item_type]
	if (ret == nil) then
		ret = loadMissingItems[item_type]()
		-- print("Misspet")
	end
	return ret
end

function resetItems()
	Items = {}
end

function getPetAttribute(pet, attribId) 
	print("ItemManager.getPetAttribute", attribId)
	local pu = PetUnit:create(pet)
	local ret = 0
	if attribId == Constants.PET_ATTRIBUTE.CRIT_RATE then
		ret = pu:getFinalCritRate(nil)
	elseif attribId == Constants.PET_ATTRIBUTE.DODGE_RATE then
		ret = 1 - pu:getHitRate(nil)
	elseif attribId == Constants.PET_ATTRIBUTE.CRIT_DAMAGE then
		ret = pet:getBasicAttribute(Constants.PET_ATTRIBUTE.CRIT_DAMAGE) + ConfigManager.getPetCommonConfig("basic_crit_damage") * 0.01
	else
		print("**", attribId, "**")
		ret = pu:getPetAttribute(attribId)
	end
	pu:cleanup()
	return ret
end

function getPetPower(pet)
    -- todo: use the right formula
    local skillSum = 0
    for i,v in ipairs(pet:get("skillLevels")) do
        skillSum = skillSum+v
    end
    local HP = ItemManager.getPetAttribute(pet,Constants.PET_ATTRIBUTE.HP)
    local DODGE_RATE =  ItemManager.getPetAttribute(pet,Constants.PET_ATTRIBUTE.DODGE_RATE)
    local COMMON_ATTACK = ItemManager.getPetAttribute(pet,Constants.PET_ATTRIBUTE.COMMON_ATTACK)
    local CRIT = ItemManager.getPetAttribute(pet,Constants.PET_ATTRIBUTE.CRIT)
    local CRIT_DAMAGE = ItemManager.getPetAttribute(pet,Constants.PET_ATTRIBUTE.CRIT_DAMAGE)
    local power = math.floor(HP/(1-DODGE_RATE)*COMMON_ATTACK*(1+CRIT*(0+CRIT_DAMAGE)/100)/1000+skillSum*10)
    ----------------------------128	1	58	0	0	31
    return power
end