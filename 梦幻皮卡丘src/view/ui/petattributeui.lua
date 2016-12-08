
require "view/tagMap/Tag_ui_pet_attribute"

PetAttributeUI = class("PetAttributeUI",function()
	return TuiBase:create()
end)

PetAttributeUI.__index = PetAttributeUI
local __instance = nil
local btnBase,btnSkill,btnAttribute
local layoutBase,layoutSkill,layoutAttribute
local currentPet, portrait
local has_skill_effect = 0  --0初次进入 -1 普通状态 
local has_train_effect = false
local btn_tag 
local layout_buttom,layout_function
local canChange = true
local btnTrain
local petFormTable = {}--形态数
local labSkillPoints,lab_countdown,btnBuyskill,labIntimacy --剩余技能点数  技能点倒计时  购买技能点按钮 
local schedulerCD
local skillNum = -1

function PetAttributeUI:create()
	local ret = PetAttributeUI.new()
	__instance = ret
	if (ItemManager.currentPet ~= nil) then
		currentPet = ItemManager.currentPet
		ItemManager.currentPet = nil
	end
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function PetAttributeUI:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function PetAttributeUI:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_pet_attribute.PANEL_PET_ATTRIBUTE then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_back(p_sender)
	Utils.replaceScene("PetListUI", __instance)
end


local function event_spine(p_sender)	--	执行骨骼动画 
	if (spine ~= nil) then
		spine:setAnimation(1,"attack", false)
	end
end

local function event_function(p_sender)	
	local tag = p_sender:getTag()
	if tag == btn_tag then --如果是同一个区域就不刷新
		return
	end
	btn_tag = tag
	local value = {
		Tag_ui_pet_attribute.TGV_BASE,
		Tag_ui_pet_attribute.TGV_SKILL,
		Tag_ui_pet_attribute.TGV_ATTRIBUTE,
		Tag_ui_pet_attribute.TGV_UPSTAR
	}
	
	if tag == value[1] then
		layoutBase:setVisible(value[1] == tag)
		__instance:showBasicInfo()
	elseif tag == value[2] then
		local petCommonConfig = ConfigManager.getPetCommonConfig('skill_openlevel')
		if Player:getInstance():get("level") >= petCommonConfig then
			layoutSkill:setVisible(value[2] == tag)
			__instance:showSkillInfo()
		else
			local msg = "该功能"..petCommonConfig.."级后开启"
			TipManager.showTip(msg)
		end
	elseif tag == value[3] then
		layoutUpstar:setVisible(value[4] == tag)
		__instance:showAttributeInfo()
	else
		layoutAttribute:setVisible(value[3] == tag)
		__instance:upstar()
	end
end

local function event_get_exp(pSender)
	currentPet:set("isEatExp",1)
	ItemManager.currentPet = currentPet
	PetAttributeDataProxy:getInstance():set("eatExp",true)
	local function confirmHandler()
		__instance:showBasicInfo()
		__instance:updatePowerNum()
	end
	NormalDataProxy:getInstance().confirmHandler = confirmHandler
	Utils.runUIScene("UseItemPopup")
end

local function event_callback_petUpgrade(result)
	ItemManager.updatePet(currentPet:get("id"), { star = result["star"], form = result["form"] }  )
	Player:getInstance():set("gold", result["gold"])
	ItemManager.updateItems({result["item"]})

	if #petFormTable == 2 and result["star"]==petFormTable[2]  then
		canChange = false
	elseif (#petFormTable >=3  and result["star"]==petFormTable[2]) or (#petFormTable >=3 and result["star"]==petFormTable[3]) then
		canChange = false
	end
	__instance:showPetPortrait()
	__instance:upstar()
	ItemManager.currentPet = currentPet
	--------升星特效
	MusicManager.upstar() --升星特效
	local effectLayoutUp = cc.Sprite:create("spine/spine_pet_attribute/pet_upstar/pet_upstar_up/shengxing_0002.png")
	effectLayoutUp:setPosition(cc.p(0,0))
	effectLayoutUp:setScale(2.0)
	local layout_effect_up = layout_buttom:getChildByTag(Tag_ui_pet_attribute.LAYOUT_EFFECT_UP)
	layout_effect_up:addChild(effectLayoutUp,5)
	
 	local animation_up = cc.Animation:create()
 	for i=2,66,2 do
 		local name = string.format("spine/spine_pet_attribute/pet_upstar/pet_upstar_up/shengxing_00%.2d.png",i)
 		animation_up:addSpriteFrameWithFile(name)
 	end
 	animation_up:setDelayPerUnit(0.1)
    animation_up:setRestoreOriginalFrame(false)
    local animate_up = cc.Animate:create(animation_up)
 	effectLayoutUp:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),animate_up,cc.CallFunc:create(function() 
		effectLayoutUp:removeFromParent()
    end)))

    local effectLayoutDown = cc.Sprite:create("spine/spine_pet_attribute/pet_upstar/pet_upstar_down/shengxing_0002.png")
    effectLayoutDown:setPosition(cc.p(0,0))
    effectLayoutDown:setScale(2)
    local layout_effect_down = layout_buttom:getChildByTag(Tag_ui_pet_attribute.LAYOUT_EFFECT_DOWN)
    layout_effect_down:addChild(effectLayoutDown,5)
    local animation_down = cc.Animation:create()
 	for i=2,64,2 do
 		local name = string.format("spine/spine_pet_attribute/pet_upstar/pet_upstar_down/shengxing_00%.2d.png",i)
 		animation_down:addSpriteFrameWithFile(name)
 	end
 	animation_down:setDelayPerUnit(0.1)
    animation_down:setRestoreOriginalFrame(false)
    local animate_down = cc.Animate:create(animation_down)
    effectLayoutDown:runAction(cc.Sequence:create(animate_down,cc.CallFunc:create(function() 
		effectLayoutDown:removeFromParent()
		--判断形态是否发生改变
		local needChangeForm = false
		if #petFormTable == 2 and result["star"]==petFormTable[2]  then
			needChangeForm = true
		elseif (#petFormTable >=3  and result["star"]==petFormTable[2]) or (#petFormTable >=3 and result["star"]==petFormTable[3]) then
			needChangeForm = true
		end
		if needChangeForm == true then
			local layoutTop = __instance:getControl(Tag_ui_pet_attribute.PANEL_PET_ATTRIBUTE, Tag_ui_pet_attribute.LAYOUT_TOP)
			local layout_bottom = layout_buttom:getChildByTag(Tag_ui_pet_attribute.LAYOUT_BOTTOM) --底部
			local layout_function = layout_buttom:getChildByTag(Tag_ui_pet_attribute.LAYOUT_FUNCTION)
			layoutTop:setVisible(false)
			layout_bottom:setVisible(false)
			layout_function:setVisible(false)

			local layout_evolve = __instance:getControl(Tag_ui_pet_attribute.PANEL_PET_ATTRIBUTE,Tag_ui_pet_attribute.LAYOUT_EVOLVE)
			layout_evolve:setVisible(true)
			local lab_evole_tip = layout_evolve:getChildByTag(Tag_ui_pet_attribute.LAB_EVOLVE_TIP)

			local petNameOld = TextManager.getPetName(currentPet:get("mid"),currentPet:get("form")-1)
			local petNameNow = TextManager.getPetName(currentPet:get("mid"),currentPet:get("form"))

			local name_str = petNameOld .. "形态发生了变化"
			for i=1,#name_str do  --字一个个出现
				local sequence = cc.Sequence:create(cc.DelayTime:create(i*0.05),cc.CallFunc:create(function() 
					lab_evole_tip:setString(string.sub(name_str,1,i))
				end))
				lab_evole_tip:runAction(sequence)
			end

			local name_str2 = petNameOld .. "进化为" .. petNameNow
			for i=1,#name_str2 do  --字一个个出现
				local sequence = cc.Sequence:create(cc.DelayTime:create(3.5+i*0.05),cc.CallFunc:create(function() 
					lab_evole_tip:setString(string.sub(name_str2,1,i))             
				end))
				lab_evole_tip:runAction(sequence)
			end

			local atlas = string.format("spine/spine_pet_attribute/spine_pet_attribute_evolution.atlas")
		 	local json = string.format("spine/spine_pet_attribute/spine_pet_attribute_evolution.json")
			local spine = sp.SkeletonAnimation:create(json, atlas, 1)
			spine:setAnimation(0, "part1", false) 

			layout_effect_up:addChild(spine)
			local delay1 = cc.DelayTime:create(1.0)
			local scaleLittle = cc.ScaleTo:create(0.8,0.2)--缩小
			local petFormConfig = ConfigManager.getPetFormConfig(currentPet:get("mid"), currentPet:get("form"))
			local portrait_new_str = string.format(TextureManager.RES_PATH.PET_PORTRAIT, petFormConfig.model) 
			local callFunc = cc.CallFunc:create(function()
				portrait:setTexture(portrait_new_str)  
				portrait:setScale(0.2)  
				end)--改变形态
			local delay2 = cc.DelayTime:create(1.0)
			local scaleBig = cc.ScaleTo:create(0.8,1.0)
			local delay3 = cc.DelayTime:create(2.5)
			local callFunc2 = cc.CallFunc:create(function() 
				Utils.runUIScene("UpStarPopup")
				layout_evolve:setVisible(false)
				layoutTop:setVisible(true)
				layout_bottom:setVisible(true)
				layout_function:setVisible(true)
			end)
			local sequence = cc.Sequence:create(delay1,scaleLittle,callFunc,delay2,scaleBig,delay3,callFunc2,nil)
			portrait:runAction(sequence)
		else
		    Utils.runUIScene("UpStarPopup")		
		end
    end)))
	PromtManager.checkOnePromt("UPSTAR",currentPet:get("id")) --检查红点
end

local function event_upgrade(p_sender)  --进化 升星
	local petConfig = ConfigManager.getPetConfig(currentPet:get("mid"))    
	local evolutionStoneNum = ItemManager.getItemAmount(Constants.ITEM_TYPE.EVOLUTION_STONE,petConfig.evolution_stone)
	local petStarConfig = ConfigManager.getPetStarConfig(currentPet:get("star"))
	local maxStar = ConfigManager.getPetCommonConfig('star_limit')
	local formLimit = ConfigManager.getPetCommonConfig('form_limit')
	if evolutionStoneNum >= petStarConfig.material_num then
		if currentPet:get("star") <= maxStar then  
			local proxy = NormalDataProxy:getInstance()
			proxy:set("title",'进化')
			local cost_gold = petStarConfig.gold_num
			proxy:set("content",'消耗进化石   X'.. petStarConfig.material_num ..'\n消耗金币      X' .. cost_gold )
			local petGrowAttributes = {}
			for i=1,2 do   --生命  攻击   
				petGrowAttributes[i] = currentPet:GetgrowAttribute(i)
			end
			local petFormConfig = ConfigManager.getPetFormConfig(currentPet:get("mid"), currentPet:get("form"))
			petGrowAttributes[3] = petFormConfig.model  --model
			PetAttributeDataProxy:getInstance():set("growAttributes",petGrowAttributes)

			local function confirmHandler()  
				if tonumber(Player:getInstance():get("gold")) <= tonumber(cost_gold) then --金币不足
					Utils.useGoldhand()
				else
					NetManager.sendCmd("petstarup", event_callback_petUpgrade,currentPet:get("id"))
				end
			end
			proxy.confirmHandler = confirmHandler
			Utils.runUIScene("NormalPopup")
		elseif currentPet:get("star")  ==  formLimit then
			-- print("更改形态")
		else
			TipManager.showTip("已达星级上限")
		end
	else
		TipManager.showTip("进化石不足")
	end
end

local function event_pet_train(result)
	if GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.PETATTRIBUTE) and StoryProxy:getInstance():get("isShow")== 1 then
		__instance:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function( )
			Utils.dispatchCustomEvent("enter_view",{callback = nil, params = {view = "func", phase = 2}})
			StoryProxy:getInstance():set("isShow",0) 
		end)))
	end
	MusicManager.upstar()
	ItemManager.updatePet(currentPet:get("id"),{rankPoint = result["rankPoint"]})
	ItemManager.updateItems(result["items"])
	has_train_effect = true
	__instance:showBasicInfo()--刷新信息
	__instance:updatePowerNum()
	local layoutPortrait2 = layout_buttom:getChildByTag(Tag_ui_pet_attribute.LAYOUT_PORTRAIT)
	local point = {}
	point.x,point.y = 150,-150
	local petConfig = ConfigManager.getPetConfig(currentPet:get("mid"))    
	local oldAttributes = ConfigManager.getPetTrainConfig(petConfig.train_id,currentPet:get("rank"), currentPet:get("rankPoint")-1).attributeAddition
	local nowAttributes = ConfigManager.getPetTrainConfig(petConfig.train_id,currentPet:get("rank"), currentPet:get("rankPoint")).attributeAddition
	local enhanceAttributes = {}
	
	for i,v in ipairs(oldAttributes) do
		enhanceAttributes[i] = nowAttributes[i]-v
	end

	local stringTip = ""
	local k = {
		"生命+",
		"攻击+",
	}
	for i,v in ipairs(enhanceAttributes) do
		stringTip = stringTip .. k[i] ..  v .. " "
	end

	local sequence = cc.Sequence:create(cc.DelayTime:create(1.0),cc.CallFunc:create(function() 
		TipManager.showTip(stringTip)
	 end))
	__instance:runAction(sequence)
	btnTrain:setEnabled(true)
	PromtManager.checkOnePromt("TRAIN",currentPet:get("id")) --检查红点
end

local function event_pet_breakthrough(result)
	ItemManager.updateItems(result["items"])
	local skill3Unlock = ConfigManager.getPetCommonConfig('passive1_open_rank')
	local skill4Unlock = ConfigManager.getPetCommonConfig('passive2_open_rank')
	if result["rank"] == skill3Unlock then
		local skill_levels = currentPet:get("skillLevels")
		skill_levels[3] = 1
		ItemManager.updatePet(currentPet:get("id"),{rankPoint = 0 , rank = result["rank"], skillLevels = skill_levels})
	elseif result["rank"] == skill4Unlock then
		local skill_levels = currentPet:get("skillLevels")
		skill_levels[4] = 1
		ItemManager.updatePet(currentPet:get("id"),{rankPoint = 0 , rank = result["rank"], skillLevels = skill_levels}) 
	else
		ItemManager.updatePet(currentPet:get("id"),{rankPoint = 0 , rank = result["rank"] }) 
	end
	__instance:showBasicInfo()
	__instance:updatePowerNum()
	ItemManager.currentPet = currentPet
	Utils.runUIScene("PetRankPromotePopup")
	btnTrain:setEnabled(true)
	PromtManager.checkOnePromt("TRAIN",currentPet:get("id")) --检查红点
end

local canTrain    --判断是否可以训练
local function event_train(p_sender)
	local petConfig = ConfigManager.getPetConfig(currentPet:get("mid"))    
	local totalRankPoint = ConfigManager.getTotalTrainPoint(petConfig.train_id, currentPet:get("rank"))
	local rankLimit = ConfigManager.getPetCommonConfig('rank_limit')
	local levelLimit = ConfigManager.getPetTrainConfig(petConfig.train_id, currentPet:get("rank"),currentPet:get("rankPoint")).levelDemand
	if currentPet:get("level")<levelLimit then
		TipManager.showTip("等级不足")
		return
	end
	if canTrain == true and currentPet:get("rank") < rankLimit then
		btnTrain:setEnabled(false)
		if  currentPet:get("rankPoint") < totalRankPoint  then
			NetManager.sendCmd("train",event_pet_train,currentPet:get("id")) 
		else
			local petConfig = ConfigManager.getPetConfig(currentPet:get("mid"))
			local petTrainConfig = ConfigManager.getPetTrainConfig(petConfig.train_id,currentPet:get("rank"), currentPet:get("rankPoint"))
			PetAttributeDataProxy:getInstance():set("rankAttributes", petTrainConfig.attributeAddition)
			NetManager.sendCmd("breakthrough", event_pet_breakthrough,currentPet:get("id")) 
		end
	else             
		if canTrain == false then
			TipManager.showTip("材料不足")
		else
			TipManager.showTip("已经达到最高段位")
		end		
	end
end

local function event_buyskillpoint(p_sender)
	local limitVip = ConfigManager.getRechargeCommonConfig('vip_level_buy_skill_point')
	if Player:getInstance():get("vip")<limitVip then
		TipManager.showTip("VIP等级达到" .. limitVip .. "后开放")
		return
	end
	local buyskillPoints = ConfigManager.getUserCommonConfig('skill_point_limit')  --购买技能点
	local buyPointsDiamond = ConfigManager.getUserCommonConfig('skill_point_buy') --技能购买价格 
	local normalProxy = NormalDataProxy:getInstance()  
	local proxy = PetAttributeDataProxy:getInstance()

	local buyedCount = proxy:get("buyedCount")
	local cost_diamond 
	if buyedCount >= #buyPointsDiamond then
		cost_diamond = buyPointsDiamond[#buyPointsDiamond]
	else
		cost_diamond = buyPointsDiamond[buyedCount+1]
	end

	normalProxy:set("title",'购买技能点')
	normalProxy:set("content",'花费' .. cost_diamond .. '钻石购买' .. buyskillPoints ..'技能点？\n今天已经购买了' .. buyedCount ..'次')
	local function confirmHandler()
		if Player:getInstance():get("diamond")<cost_diamond then
			Utils.useRechargeDiamond()
		else
			local function event_callback_buyskillpoints(result)
				Player:getInstance():set("diamond",result["diamond"])
				proxy:set("buyedCount",result["buyedCount"])
				__instance:showSkillInfo()
			end
			NetManager.sendCmd("buyskillpoint",event_callback_buyskillpoints)
		end
	end
	normalProxy.confirmHandler = confirmHandler
	Utils.runUIScene("NormalPopup")
end

function PetAttributeUI:updateUpgradeStatus() --进化信息
    local progSoul = layoutUpstar:getChildByTag(Tag_ui_pet_attribute.PROG_SOUL)
	local petStarConfig = ConfigManager.getPetStarConfig(currentPet:get("star"))
	local petConfig = ConfigManager.getPetConfig(currentPet:get("mid"))        
	local evolutionStoneNum = ItemManager.getItemAmount(Constants.ITEM_TYPE.EVOLUTION_STONE,petConfig.evolution_stone)
	progSoul:setValue(math.floor(100*evolutionStoneNum/petStarConfig.material_num))
	local labEvolutionNum = layoutUpstar:getChildByTag(Tag_ui_pet_attribute.LAB_EVOLUTION_STONE_NUM)
	labEvolutionNum:setString(evolutionStoneNum .. "/" .. petStarConfig.material_num)
	local maxStar = ConfigManager.getPetCommonConfig('star_limit')
	if currentPet:get("star") >= maxStar then
		labEvolutionNum:setString("已进化至最高形态")
	end
	local btn_upgrade = layoutUpstar:getChildByTag(Tag_ui_pet_attribute.BTN_UPGRADE) 
	btn_upgrade:setScale(1.3)
	local maxStar = ConfigManager.getPetCommonConfig('star_limit')
	local formLimit = ConfigManager.getPetCommonConfig('form_limit')
	btn_upgrade:setOnClickScriptHandler(event_upgrade)--进化 升星
end

function PetAttributeUI:updateTrainStatus()--训练信息
	local labRank = layoutBase:getChildByTag(Tag_ui_pet_attribute.LAB_RANK)
	local numTable = {'一','二','三','四','五','六','七','八','九'}
	labRank:setString(numTable[currentPet:get("rank")] .. "段")
	local petConfig = ConfigManager.getPetConfig(currentPet:get("mid"))
	local petTrainConfig = ConfigManager.getPetTrainConfig(petConfig.train_id, currentPet:get("rank"),currentPet:get("rankPoint"))
	local totalRankPoint = ConfigManager.getTotalTrainPoint(petConfig.train_id, currentPet:get("rank"))

	local lab_train_points = layoutBase:getChildByTag(Tag_ui_pet_attribute.LAB_TRAIN_POINTS)
	lab_train_points:setString(currentPet:get("rankPoint") * 100 .. "/" .. totalRankPoint*100)
	local pet_level_demond = layoutBase:getChildByTag(Tag_ui_pet_attribute.LAB_LEVEL_DEMAND_NUM)
	pet_level_demond:setString(petTrainConfig.levelDemand)
	if currentPet:get("level")<petTrainConfig.levelDemand then
		pet_level_demond:setColor(cc.c3b(255,0,0))
	else
		pet_level_demond:setColor(cc.c3b(255,255,255))
	end

	canTrain = true --判断是否可以训练
	--循环遍历 显示材料
	local layoutTrainMaterial = layoutBase:getChildByTag(Tag_ui_pet_attribute.LAYOUT_TRAIN_MATERIAL)
	local labMaxRank = layoutBase:getChildByTag(Tag_ui_pet_attribute.LAB_MAX_RANK)
	local maxRank = ConfigManager.getPetCommonConfig('rank_limit')
	layoutTrainMaterial:setVisible(currentPet:get("rank") < maxRank)
	labMaxRank:setVisible(currentPet:get("rank") >= maxRank)
	for i,v in pairs(petTrainConfig.materials) do
		local layout_material = layoutTrainMaterial:getChildByTag(Tag_ui_pet_attribute["LAYOUT_FOOD" .. i])
		layout_material:removeAllChildren()
		local materialType = petTrainConfig.materials[i][1]
		local item = ItemManager.createItem(petTrainConfig.materials[i][1],petTrainConfig.materials[i][2])
		local cell = ItemCell:create(petTrainConfig.materials[i][1], item)
		Utils.addCellToParent(cell, layout_material, true)
		cell:setTouchEndedNormalHandler(function() 
			ItemManager.currentPet = currentPet
			if currentPet:get("rank")>=maxRank then
				ItemManager.currentItem = {item,0}
			else
				ItemManager.currentItem = {item,petTrainConfig.materials[i][3]}
			end
			local function updateItem()  --更新信息
				__instance:showBasicInfo()
			end
			NormalDataProxy:getInstance().updateItem = updateItem
			Utils.runUIScene("ItemDropPopup")
			end)
		local material_num = layoutTrainMaterial:getChildByTag(Tag_ui_pet_attribute["LAB_FOOD" .. i ..  "_NUM"])
		local itemAmount = ItemManager.getItemAmount(petTrainConfig.materials[i][1],petTrainConfig.materials[i][2])
		material_num:setString(itemAmount .. "/" .. petTrainConfig.materials[i][3])
		if itemAmount<petTrainConfig.materials[i][3] then
			material_num:setColor(cc.c3b(255,0,0))
		else
			material_num:setColor(cc.c3b(255,255,255))
		end
		if itemAmount < petTrainConfig.materials[i][3] then
			canTrain = false  --只要一种材料不满足就不可以训练
		end
		--训练特效
		if has_train_effect == true  then
			local effectLayout = cc.Sprite:create("spine/spine_pet_attribute/pet_train/xunlian_0001.png")
			effectLayout:setPosition(cc.p(45,46))
			effectLayout:setScale(2)
			layout_material:addChild(effectLayout,5)
		 	local animation = cc.Animation:create()
		 	for i=1,39,1 do
		 		local name = string.format("spine/spine_pet_attribute/pet_train/xunlian_00%.2d.png",i)
		 		animation:addSpriteFrameWithFile(name)
		 	end
		 	animation:setDelayPerUnit(0.05)
		    animation:setRestoreOriginalFrame(false)
		    local animate = cc.Animate:create(animation)
		    effectLayout:runAction(cc.Sequence:create(animate,cc.CallFunc:create(function() 
		    	has_train_effect = false
		    	effectLayout:removeFromParent() 
		    end),nil))
		end
	end

	local labTrain = layoutBase:getChildByTag(Tag_ui_pet_attribute.LAB_TRAIN) --  训练    突破
	if currentPet:get("rankPoint") < totalRankPoint  then
		labTrain:setString("训练")
	else
		labTrain:setString("突破")
	end
end

function PetAttributeUI:updatePowerNum()
	local layout_num = layout_function:getChildByTag(Tag_ui_pet_attribute.LAYOUT_NUM)
	layout_num:removeAllChildren()
	local powerNum = tostring(ItemManager.getPetPower(currentPet))
	for i=1,#powerNum do
		local num = string.sub(powerNum,i,i)
		local img = TextureManager.createImg("ui_pet_attribute/%d.png",num)
		img:setPositionX(i*36)
		layout_num:addChild(img,5)
	end
end

function PetAttributeUI:showPetPortrait() --宠物的肖像 星级等信息
	local layoutTop = self:getControl(Tag_ui_pet_attribute.PANEL_PET_ATTRIBUTE, Tag_ui_pet_attribute.LAYOUT_TOP)
	layoutTop:setPositionY(cc.Director:getInstance():getVisibleSize().height/2)
	local petFormConfig = ConfigManager.getPetFormConfig(currentPet:get("mid"), currentPet:get("form"))
	local maxStar = ConfigManager.getPetCommonConfig('star_limit')
	for i = 1, maxStar do
		local imgStar = layoutTop:getChildByTag(Tag_ui_pet_attribute["IMG_BIGSTAR"..i])
		if i > currentPet:get("star") then
			imgStar:setVisible(false)
		else
			imgStar:setVisible(true)
		end
	end
	self:updatePowerNum()
	if canChange==true then
		local layoutPortrait = layout_buttom:getChildByTag(Tag_ui_pet_attribute.LAYOUT_PORTRAIT)
		layoutPortrait:removeAllChildren()
		portrait = TextureManager.createImg(TextureManager.RES_PATH.PET_PORTRAIT, petFormConfig.model)
		Utils.addCellToParent(portrait, layoutPortrait)
	end

	local layout_petinfo_up = layout_buttom:getChildByTag(Tag_ui_pet_attribute.LAYOUT_PETINFO_UP)
	local layout_petinfo_down = layout_buttom:getChildByTag(Tag_ui_pet_attribute.LAYOUT_PETINFO_DOWN)
	layout_petinfo_up:removeAllChildren()
	layout_petinfo_down:removeAllChildren()
	local atlas = "spine/spine_pet_attribute/spine_petinfo_up.atlas"
    local json = "spine/spine_pet_attribute/spine_petinfo_up.json"
    local spine = sp.SkeletonAnimation:create(json, atlas, 1)
    spine:setAnimation(0, "part" .. currentPet:get("aptitude"), true)
    spine:setScale(2)
    Utils.addCellToParent(spine,layout_petinfo_up)
    local atlas = "spine/spine_pet_attribute/spine_petinfo_down.atlas"
    local json = "spine/spine_pet_attribute/spine_petinfo_down.json"
    local spine = sp.SkeletonAnimation:create(json, atlas, 1)
 	spine:setScale(2)
    spine:setAnimation(0, "part" .. currentPet:get("aptitude"), true)
    Utils.addCellToParent(spine,layout_petinfo_down)

	local labName = layoutTop:getChildByTag(Tag_ui_pet_attribute.LAB_PET_NAME)
	labName:setColor(Constants.APTITUDE_COLOR[currentPet:get("aptitude")])
	labName:setString(TextManager.getPetName(currentPet:get("mid"),currentPet:get("form")))
	canChange = true --可以更改形象
end

function PetAttributeUI:showBasicInfo()
	local prog_pet_exp = layoutBase:getChildByTag(Tag_ui_pet_attribute.PROG_PETEXP)
	local userConfig = ConfigManager.getUserConfig(currentPet:get("level"))
	prog_pet_exp:setValue(math.floor(100*currentPet:get("exp")/userConfig.max_pet_exp))

	local btn_get_exp = layoutBase:getChildByTag(Tag_ui_pet_attribute.BTN_UP_PET_LEVEL)
	btn_get_exp:setOnClickScriptHandler(event_get_exp)

	local lab_xingge = layoutBase:getChildByTag(Tag_ui_pet_attribute.LAB_XINGGE)
	lab_xingge:setColor(Constants.APTITUDE_COLOR[currentPet:get("aptitude")])
	local lab_life_grow = layoutBase:getChildByTag(Tag_ui_pet_attribute.LAB_LIFE_GROW)
	lab_life_grow:setColor(Constants.APTITUDE_COLOR[currentPet:get("aptitude")])
	local lab_attack_grow = layoutBase:getChildByTag(Tag_ui_pet_attribute.LAB_ATTACK_GROW)
	lab_attack_grow:setColor(Constants.APTITUDE_COLOR[currentPet:get("aptitude")])
	
	local petAptitudeName = TextManager.getPetAptitudeName(currentPet:get("aptitude")) 
	local petCharacterName = TextManager.getPetCharacterName(currentPet:get("character"))
	local petCharacterConfig = ConfigManager.getPetCharacterConfig(currentPet:get("character"))
	local characterAdd = '('
	for i = 1,#petCharacterConfig.addition_type  do
		local petAbilityName = TextManager.getPetAbilityName(petCharacterConfig.addition_type[i])
		characterAdd = characterAdd ..   petAbilityName .. "+" .. petCharacterConfig.addition_percent[i] .. "% "
	end
	characterAdd = characterAdd .. ")"

	local labels = {
		{tag = Tag_ui_pet_attribute.LAB_LEVEL_NUM, text = currentPet:get("level")},
		{tag = Tag_ui_pet_attribute.LAB_EXP_NUM, text = currentPet:get("exp")..'/'..userConfig.max_pet_exp},
		{tag = Tag_ui_pet_attribute.LAB_LIFE_GROW_NUM, text = Utils.roundingOff(currentPet:GetgrowAttribute(1))},
		{tag = Tag_ui_pet_attribute.LAB_ATTACK_GROW_NUM, text = Utils.roundingOff(currentPet:GetgrowAttribute(2))},
		{tag = Tag_ui_pet_attribute.LAB_CHARACTER_ADDITION, text = characterAdd },
		{tag = Tag_ui_pet_attribute.LAB_CHARACTER, text = petCharacterName}
	}
	for i,v in ipairs(labels) do
		local label = layoutBase:getChildByTag(v.tag)
		label:setString(v.text)
		if i > 2  then
			label:setColor(Constants.APTITUDE_COLOR[currentPet:get("aptitude")])
		end
	end

	local layoutPetBg = layoutBase:getChildByTag(Tag_ui_pet_attribute.IMG_PETSHOW_BG)
	layoutPetBg:removeAllChildren()
	local petFormConfig = ConfigManager.getPetFormConfig(currentPet:get("mid"), currentPet:get("form"))
	local atlas = string.format(TextureManager.RES_PATH.SPINE_PET, petFormConfig.model) .. ".atlas"
    local json = string.format(TextureManager.RES_PATH.SPINE_PET, petFormConfig.model) .. ".json"
    local spine = sp.SkeletonAnimation:create(json, atlas, 1)
    spine:setAnimation(0, "breath", true)
    Utils.addCellToParent(spine,layoutPetBg)
    local size = layoutPetBg:getContentSize()
 	spine:setPosition(Arp(cc.p(size.width/2+5, size.height/2+2)))
		
 	local img9BG1 = layoutBase:getChildByTag(Tag_ui_pet_attribute.IMG9_CHACTER_BG)
 	local img9BG2 = layoutBase:getChildByTag(Tag_ui_pet_attribute.IMG9_GROW_BG)
 	local img9BG3 = layoutBase:getChildByTag(Tag_ui_pet_attribute.IMG9_POPUP_BG1_BASE)
 	img9BG1:setOpacity(190)
 	img9BG2:setOpacity(190)
 	img9BG3:setOpacity(190)

	self:updateTrainStatus()--宠物训练
	layoutBase:setVisible(true)
	layoutSkill:setVisible(false)
	layoutUpstar:setVisible(false)
	layoutAttribute:setVisible(false)
end

local function countdownCD(time)
	local skillPointsLimit = ConfigManager.getVipConfig(Player:getInstance():get("vip")).skillpoint_limit
	local pointRecoverTime = ConfigManager.getUserCommonConfig('skill_point_time_step')--技能回复时间
	local player = Player:getInstance()
	if schedulerCD then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerCD)
		schedulerCD = nil
	end
	btnBuyskill:setVisible(player:get("skillPoints")<=0)
	if time<=0 then
		lab_countdown:setVisible(false)
	else
		lab_countdown:setVisible(true)
		schedulerCD = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
			time = time - 1
			local h2,m2,s2 = Utils.parseTime(time) 
			m2,s2 = string.format("%.2d",m2),string.format("%.2d",s2)
			lab_countdown:setString("[" .. m2 .. ":" .. s2 .. "]")
			if time == 0 then
				player:set("skillPoints",player:get("skillPoints")+1)
				labSkillPoints:setString(player:get("skillPoints"))
				btnBuyskill:setVisible(player:get("skillPoints")<=0)
				if Player:getInstance():get("skillPoints") >= skillPointsLimit then --技能点已满  
					if schedulerCD then
						cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerCD)
						schedulerCD = nil
					end
					lab_countdown:setVisible(false)
				else
					time = pointRecoverTime	  --重置时间
				end
			end
		end, 1, false)
	end
end

local function playSkillAnimation(skill_border)
	local effectLayout = cc.Sprite:create("spine/spine_pet_attribute/pet_skill_upgrade/jinengshengji_0001.png")
	Utils.addCellToParent(effectLayout,skill_border,true)
	effectLayout:setScale(1.9)
	effectLayout:setPosition(cc.p(tonumber(effectLayout:getPositionX()-1),tonumber(effectLayout:getPositionY())+2))
 	local animation = cc.Animation:create()
 	for i=1,30 do
 		local name = string.format("spine/spine_pet_attribute/pet_skill_upgrade/jinengshengji_00%.2d.png",i)
 		animation:addSpriteFrameWithFile(name)
 	end
 	animation:setDelayPerUnit(0.05)
    animation:setRestoreOriginalFrame(false)
    local animate = cc.Animate:create(animation)
    effectLayout:runAction(cc.Sequence:create(animate,cc.CallFunc:create(function()
        effectLayout:removeFromParent() 
        skill_border:removeAllChildren()
    end),nil))
end

function PetAttributeUI:upSkill() --升级技能
	local skill3_difference = ConfigManager.getPetCommonConfig('skill3_level_difference')
	local skill4_difference = ConfigManager.getPetCommonConfig('skill4_level_difference')
	local level_limit = {
		currentPet:get("level"),
		currentPet:get("level"),
		currentPet:get("level") - skill3_difference,
		currentPet:get("level") - skill4_difference
	}
	local skillLevels = currentPet:get("skillLevels")	
	local petFormConfig = ConfigManager.getPetFormConfig(currentPet:get("mid"),currentPet:get("form"))
	for i = 1, 4 do  	--宠物的4大技能
		local skillUnit = layoutSkill:getChildByTag(Tag_ui_pet_attribute["LAYOUT_SKILL_UNIT".. i])
		local cell = CLayout:create()
		TuiManager:getInstance():parseCell(cell, "cell_skill_unit", PATH_UI_PET_ATTRIBUTE)
		Utils.addCellToParent(cell, skillUnit)
    	local layoutSkillInfo = cell:getChildByTag(Tag_ui_pet_attribute.LAYOUT_SKILL)--技能图片 
		local img_skill_gray = cell:getChildByTag(Tag_ui_pet_attribute.IMG9_SKILL_GRAY)
		local img_lock = cell:getChildByTag(Tag_ui_pet_attribute.IMG_LOCK)
		local skill_border = cell:getChildByTag(Tag_ui_pet_attribute.IMG_BORDER_5)
		local labActive_name = cell:getChildByTag(Tag_ui_pet_attribute.LAB_SKILL_NAME) --技能名称
		local labActive_level = cell:getChildByTag(Tag_ui_pet_attribute.LAB_SKILL_LEVEL_NUM)   --技能等级
		local labelSkillUpCost = cell:getChildByTag(Tag_ui_pet_attribute.LAB_SKILLUP_COST) --升级消耗的金币
		local btnSkillup = cell:getChildByTag(Tag_ui_pet_attribute.BTN_PLUS) --升级技能
		local imgGold = cell:getChildByTag(Tag_ui_pet_attribute.IMG_GOLD)
		local labSkillLevel = cell:getChildByTag(Tag_ui_pet_attribute.LAB_LEVEL)

		if skillNum == i then
			playSkillAnimation(skill_border)
			skillNum = 0
		end

		local isPassiveSkill = false--是否是被动技能
		local skillType = petFormConfig.skills[i]	--技能类型
		if skillType == nil then --被动技能
			skillType = petFormConfig.passive_skills[i - #petFormConfig.skills]
			isPassiveSkill = true
		end

		local skillImage = ((isPassiveSkill and TextureManager.createImg(TextureManager.RES_PATH.PASSIVE_SKILL_IMAGE,skillType)) or TextureManager.createImg(TextureManager.RES_PATH.SKILL_IMG,skillType))
		Utils.addCellToParent(skillImage, layoutSkillInfo,true)--将真实的图片加入到要显示的位置
		layoutSkillInfo:setOnTouchBeganScriptHandler(function()
			PetAttributeDataProxy:getInstance():set("skillType",skillType)
			PetAttributeDataProxy:getInstance():set("isPassiveSkill",isPassiveSkill)
			PetAttributeDataProxy:getInstance():set("skillLevel",skillLevels[i])
    		Utils.runUIScene("SkillInfoPopup")
    		local isPassiveSkill = false
			return false
		end)
		labActive_name:setString((isPassiveSkill and TextManager.getPassiveSkillName(skillType) or TextManager.getPetSkillName(skillType)))

		if i<= #skillLevels then
			img_skill_gray:setVisible(false)
			img_lock:setVisible(false)
			local function updateSkillInfo()
				labActive_level:setString(skillLevels[i])
				local skillUpGradeCost = ConfigManager.getSkillConsumeConfig(skillLevels[i])
				labelSkillUpCost:setString(skillUpGradeCost["skill" .. i])
		    	btnSkillup:setOnClickScriptHandler(function()
		    		if GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.PET_SKILL) and StoryProxy:getInstance():get("isShow") == 1 then
		    			__instance:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function( )
		    				Utils.dispatchCustomEvent("enter_view",{callback = nil, params = {view = "func", phase = 3}})
		    				StoryProxy:getInstance():set("isShow",0) 
		    			end)))
		    		end
		    	
		    		local points = Player:getInstance():get("skillPoints")
					if points <= 0 then
						TipManager.showTip("技能点不足")
					elseif Player:getInstance():get("gold") < skillUpGradeCost["skill" .. i] then --金币不足
						Utils.useGoldhand()
					else 
						btnSkillup:setEnabled(false)
				  		local function event_callback_skill_up(result)
				  			skillNum = i
						    Player:getInstance():set("skillPoints",result["remainingPoints"])
				  			Player:getInstance():set("gold",result["gold"])
				  			ItemManager.updatePet(currentPet:get("id"),{skillLevels = result["skillLevels"] ,intimacy = result["intimacy"]})
				  			labIntimacy:setString(currentPet:get("intimacy"))
				  			labSkillPoints:setString(result["remainingPoints"])
				  			countdownCD(result["remainingTime"])
				  			__instance:updatePowerNum()
				  			skillLevels = currentPet:get("skillLevels")	
				  			updateSkillInfo()
				  			PromtManager.checkOnePromt("UP_SKILL_LEVEL",currentPet:get("id")) --检查红点
				  		end
						NetManager.sendCmd("petskillup", event_callback_skill_up,currentPet:get("id"), i-1)	--发送数据
					end
		    	end)
				btnSkillup:setEnabled(skillLevels[i] < level_limit[i])
			end
			updateSkillInfo()
	    else
			img_skill_gray:setOpacity(255*0.5)
			img_skill_gray:setVisible(true)
			img_lock:setVisible(true)
			local rankLimit = 1
			if i == 3 then
				rankLimit = ConfigManager.getPetCommonConfig('passive1_open_rank')
			elseif i == 4 then
				rankLimit = ConfigManager.getPetCommonConfig('passive2_open_rank')
			end
			labSkillLevel:setString("达到".. rankLimit .. "段时解锁")
			labActive_level:setVisible(false)
			btnSkillup:setVisible(false)
			imgGold:setVisible(false)
	 		labelSkillUpCost:setVisible(false)
		end
	end
end

local function event_skill_recover(result)
	if schedulerCD then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerCD)
		schedulerCD = nil
	end
	Player:getInstance():set("skillPoints",result["remainingPoints"]) --设置技能点数
	PetAttributeDataProxy:getInstance():set("buyedCount", result["buyedCount"])--设置已经购买次数
	PromtManager.checkOnePromt("UP_SKILL_LEVEL",currentPet:get("id")) --检查红点
	labSkillPoints:setString(result["remainingPoints"]) --显示技能点数
	btnBuyskill:setVisible(result["remainingPoints"]<=0)
	countdownCD(result["remainingTime"])
end

function PetAttributeUI:showSkillInfo()
	local img9_skill_bg1 = layoutSkill:getChildByTag(Tag_ui_pet_attribute.IMG9_SKILL_BG1)
	img9_skill_bg1:setOpacity(190)
	labIntimacy = layoutSkill:getChildByTag(Tag_ui_pet_attribute.LAB_INTIMACY_NUM)--亲密度
	labIntimacy:setString(currentPet:get("intimacy"))

	labSkillPoints = layoutSkill:getChildByTag(Tag_ui_pet_attribute.LAB_REMAINING_POINTS)--剩余技能点数 
	lab_countdown = layoutSkill:getChildByTag(Tag_ui_pet_attribute.LAB_COUNTDOWN)--倒计时
	btnBuyskill = layoutSkill:getChildByTag(Tag_ui_pet_attribute.BTN_BUY_SKILL_POINTS)
	if skillNum == -1  then --初次加载 
		skillNum = 0
		NetManager.sendCmd("loadskillpoints",event_skill_recover) --购买按钮 倒计时 在这个回调方法中	
	end
	self:upSkill()
	layoutBase:setVisible(false)
	layoutSkill:setVisible(true)
	layoutAttribute:setVisible(false)
	layoutUpstar:setVisible(false)
end

function PetAttributeUI:upstar()
	self:updateUpgradeStatus()--宠物进化
	local layout_model = layoutUpstar:getChildByTag(Tag_ui_pet_attribute.LAYOUT_PET_MODEL)
	local img9_upstar_bg = layoutUpstar:getChildByTag(Tag_ui_pet_attribute.IMG9_UPSTAR_BG)
	img9_upstar_bg:setOpacity(190)
	for i=1,#petFormTable do
		local layout_pet_model = layout_model:getChildByTag(Tag_ui_pet_attribute["LAYOUT_STAR_FORM" .. i])
		local cell = CLayout:create()
		TuiManager:getInstance():parseCell(cell, "cell_star_form", PATH_UI_PET_ATTRIBUTE)
		Utils.addCellToParent(cell, layout_pet_model)
		for i=petFormTable[i]+1,5 do
			local star = cell:getChildByTag(Tag_ui_pet_attribute["IMG_MODEL_PET_STAR" .. i])
			star:setVisible(false)
		end
		local layout_pet = cell:getChildByTag(Tag_ui_pet_attribute.LAYOUT_MODEL_PET)
		local petFormConfig = ConfigManager.getPetFormConfig(currentPet:get("mid"),i)
		local pet_portrait = TextureManager.createImg("pet_list/%d.png",petFormConfig.model)
		Utils.addCellToParent(pet_portrait,layout_pet)
	end

	local star_limit = ConfigManager.getPetCommonConfig('star_limit')
	local petStarConfig = ConfigManager.getPetStarConfig(currentPet:get("star"))
	local btn_get_soul = layoutUpstar:getChildByTag(Tag_ui_pet_attribute.BTN_GET_SOUL)
	local evolution_stone = ConfigManager.getPetConfig(currentPet:get("mid")).evolution_stone
	local item = ItemManager.createItem(Constants.ITEM_TYPE.EVOLUTION_STONE, evolution_stone)
	btn_get_soul:setOnClickScriptHandler(function()	
		ItemManager.currentPet = currentPet
		if currentPet:get("star")>=star_limit then
			ItemManager.currentItem = {item,0}
		else
			ItemManager.currentItem = {item,petStarConfig.material_num}
		end
		local function updateItem()  --更新信息
			__instance:upstar()
		end
		NormalDataProxy:getInstance().updateItem = updateItem
		Utils.runUIScene("ItemDropPopup")
	end)
	local btn_upgrade = layoutUpstar:getChildByTag(Tag_ui_pet_attribute.BTN_UPGRADE) 
	btn_upgrade:setOnClickScriptHandler(event_upgrade)--进化 升星
	if currentPet:get("star")>=star_limit then
		btn_upgrade:setEnabled(false)
	end
	layoutBase:setVisible(false)
	layoutSkill:setVisible(false)
	layoutUpstar:setVisible(true)
	layoutAttribute:setVisible(false)
end

function PetAttributeUI:showAttributeInfo()
	local textPetDesc = TextManager.getPetDesc(currentPet:get("mid"), currentPet:get("form"))
	local petCharacterConfig = ConfigManager.getPetCharacterConfig(currentPet:get("character"))
	local petCharacterName = TextManager.getPetCharacterName(currentPet:get("character"))
	local characterAdd = '('
	for i = 1,#petCharacterConfig.addition_type  do
		local petAbilityName = TextManager.getPetAbilityName(petCharacterConfig.addition_type[i])
		characterAdd = characterAdd ..   petAbilityName .. "+" .. petCharacterConfig.addition_percent[i] .. "% "
	end
	characterAdd = characterAdd .. ")"
	local petAptitudeName = TextManager.getPetAptitudeName(currentPet:get("aptitude")) 
	local apit = currentPet:getAptitudeNum()
	local maxApit = Utils.getPetMaxAptitude(currentPet:get("aptitude"))
	if apit >= maxApit  then
		maxApit = '满'
	end
	local labels = {
		{tag = Tag_ui_pet_attribute.LAB_DETAIL_INFO, text = textPetDesc},
		{tag = Tag_ui_pet_attribute.LAB_PET_CHARACTER, text = petCharacterName},
		{tag = Tag_ui_pet_attribute.LAB_PET_CHARACTER_ADDITION, text = characterAdd},
		{tag = Tag_ui_pet_attribute.LAB_PET_APTITUDE, text = petAptitudeName},
		{tag = Tag_ui_pet_attribute.LAB_PET_APTITUDE_NUM, text = Utils.roundingOff(apit)},
		{tag = Tag_ui_pet_attribute.LAB_PET_APTITUDE_MAX, text = '(' .. maxApit  .. ')'}
	}
	for i,v in ipairs(labels) do
		local label = layoutAttribute:getChildByTag(v.tag) 
		label:setString(v.text)
		if i == 4 then
			label:setColor(Constants.APTITUDE_COLOR[currentPet:get("aptitude")])
		end
	end
	local numLabels = {
		{tag = Tag_ui_pet_attribute.LAB_PET_LEVEL_NUM, text = currentPet:get("level")},
		{tag = Tag_ui_pet_attribute.LAB_PET_LIFE_GROW_NUM, text = currentPet:GetgrowAttribute(1)},
		{tag = Tag_ui_pet_attribute.LAB_PET_ATTACK_GROW_NUM, text = currentPet:GetgrowAttribute(2)},
		{tag = Tag_ui_pet_attribute.LAB_HP_NUM, text = ItemManager.getPetAttribute(currentPet, Constants.PET_ATTRIBUTE.HP)}, 
		{tag = Tag_ui_pet_attribute.LAB_ATTACK_NUM, text = ItemManager.getPetAttribute(currentPet, Constants.PET_ATTRIBUTE.COMMON_ATTACK)},
		{tag = Tag_ui_pet_attribute.LAB_SPEED_NUM, text = ItemManager.getPetAttribute(currentPet, Constants.PET_ATTRIBUTE.SPEED)},
		{tag = Tag_ui_pet_attribute.LAB_CRIT_NUM, text = ItemManager.getPetAttribute(currentPet, Constants.PET_ATTRIBUTE.CRIT)},
		{tag = Tag_ui_pet_attribute.LAB_CRIT_RATE_NUM, text = ItemManager.getPetAttribute(currentPet, Constants.PET_ATTRIBUTE.CRIT_RATE)},
		{tag = Tag_ui_pet_attribute.LAB_CRIT_ATTACK_NUM, text = ItemManager.getPetAttribute(currentPet, Constants.PET_ATTRIBUTE.CRIT_DAMAGE)},
		{tag = Tag_ui_pet_attribute.LAB_DODGE_NUM, text = ItemManager.getPetAttribute(currentPet, Constants.PET_ATTRIBUTE.DODGE)},
		{tag = Tag_ui_pet_attribute.LAB_DODGE_RATE_NUM, text = ItemManager.getPetAttribute(currentPet, Constants.PET_ATTRIBUTE.DODGE_RATE)}
	} 
	local lab_pet_life_grow = layoutAttribute:getChildByTag(Tag_ui_pet_attribute.LAB_PET_LIFE_GROW)
	local lab_pet_attack_grow =  layoutAttribute:getChildByTag(Tag_ui_pet_attribute.LAB_PET_ATTACK_GROW)
	lab_pet_life_grow:setColor(Constants.APTITUDE_COLOR[currentPet:get("aptitude")])
	lab_pet_attack_grow:setColor(Constants.APTITUDE_COLOR[currentPet:get("aptitude")])
	for k, v in ipairs(numLabels) do
		local label = layoutAttribute:getChildByTag(v.tag) 
		label:setString(Utils.roundingOff(tonumber(v.text)))
		if k==#numLabels or k == 8 or k == 9 then   
			label:setString(tonumber(tostring(numLabels[k].text))*100 .. '%')
		end
		if k== 2 or k==3 then
			label:setColor(Constants.APTITUDE_COLOR[currentPet:get("aptitude")])
		end
	end
	local img9_bg2_attribute = layoutAttribute:getChildByTag(Tag_ui_pet_attribute.IMG9_PET_INFO_BG2)
	local img9_bg3_attribute = layoutAttribute:getChildByTag(Tag_ui_pet_attribute.IMG9_PET_INFO_BG3)
	local img9_bg4_attribute = layoutAttribute:getChildByTag(Tag_ui_pet_attribute.IMG9_PET_INFO_BG4)
	img9_bg2_attribute:setOpacity(190)
	img9_bg3_attribute:setOpacity(190)
	img9_bg4_attribute:setOpacity(190)
	layoutBase:setVisible(false)
	layoutSkill:setVisible(false)
	layoutUpstar:setVisible(false)
	layoutAttribute:setVisible(true)
end

function PetAttributeUI:EventFunction()
	btnTrain = layoutBase:getChildByTag(Tag_ui_pet_attribute.BTN_TRAIN) --  训练    突破
	local rankLimit = ConfigManager.getPetCommonConfig('rank_limit')
	btnTrain:setEnabled(currentPet:get("rank")<rankLimit)
	btnTrain:setScale(1.3)
	btnTrain:setOnClickScriptHandler(event_train)
	local btnBuyskill = layoutSkill:getChildByTag(Tag_ui_pet_attribute.BTN_BUY_SKILL_POINTS)
	btnBuyskill:setOnClickScriptHandler(event_buyskillpoint)
end

function PetAttributeUI:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_pet_attribute",PATH_UI_PET_ATTRIBUTE)
	layout_buttom = self:getControl(Tag_ui_pet_attribute.PANEL_PET_ATTRIBUTE, Tag_ui_pet_attribute.LAYOUT_BUTTOM) 
	Utils.floatToBottom(layout_buttom)
	local layout_bottom = layout_buttom:getChildByTag(Tag_ui_pet_attribute.LAYOUT_BOTTOM) --底部按钮区
	local backBtn = layout_bottom:getChildByTag(Tag_ui_pet_attribute.BTN_BACK)
	backBtn:setOnClickScriptHandler(event_back)
	btnBase = layout_bottom:getChildByTag(Tag_ui_pet_attribute.TGV_BASE)
	PromtManager.addRedSpot(btnBase,4,"TRAIN",currentPet:get("id")) --添加红点监听	
	btnSkill = layout_bottom:getChildByTag(Tag_ui_pet_attribute.TGV_SKILL)
	PromtManager.addRedSpot(btnSkill,4,"UP_SKILL_LEVEL",currentPet:get("id")) --添加红点监听	
	btnAttribute = layout_bottom:getChildByTag(Tag_ui_pet_attribute.TGV_ATTRIBUTE)
	btnUpstar = layout_bottom:getChildByTag(Tag_ui_pet_attribute.TGV_UPSTAR)
	PromtManager.addRedSpot(btnUpstar,4,"UPSTAR",currentPet:get("id")) --添加红点监听	
	btnBase:setChecked(true)
	btn_tag = Tag_ui_pet_attribute.TGV_BASE
	btnBase:setOnClickScriptHandler(event_function)
	btnSkill:setOnClickScriptHandler(event_function)
	btnAttribute:setOnClickScriptHandler(event_function)
	btnUpstar:setOnClickScriptHandler(event_function)

	layout_function = layout_buttom:getChildByTag(Tag_ui_pet_attribute.LAYOUT_FUNCTION)
	layoutBase = layout_function:getChildByTag(Tag_ui_pet_attribute.LAYOUT_BASE)
	layoutSkill = layout_function:getChildByTag(Tag_ui_pet_attribute.LAYOUT_SKILLUP)
	layoutAttribute = layout_function:getChildByTag(Tag_ui_pet_attribute.LAYOUT_ATTRIBUTE)
	layoutUpstar = layout_function:getChildByTag(Tag_ui_pet_attribute.LAYOUT_UPSTAR)
	self:EventFunction()
	self:showPetPortrait()
	self:showBasicInfo()

	local layout_evolve = self:getControl(Tag_ui_pet_attribute.PANEL_PET_ATTRIBUTE,Tag_ui_pet_attribute.LAYOUT_EVOLVE)
	layout_evolve:setVisible(false)
	petFormTable = {1}
	local petstarlimit = ConfigManager.getPetCommonConfig('star_limit')
	local oldform = 1
	local count = 2
	for i=1,petstarlimit  do
		local petform = ConfigManager.getPetStarConfig(i).form
		if petform>oldform then
			petFormTable[count]=i
			count = count + 1
			oldform = petform
		end
	end
	local function onNodeEvent(event)
		if "enterTransitionFinish"  == event then
			if GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.PETLIST) and GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.PETATTRIBUTE) == false then
				Utils.dispatchCustomEvent("event_train",{view = "PetAttributeUI",phase = GuideManager.FUNC_GUIDE_PHASES.PETATTRIBUTE,scene = self})
				StoryProxy:getInstance():set("isShow",1)
			end
			local pet = currentPet
			local upstarNum = ConfigManager.getPetStarConfig(pet:get("star")).material_num
			local UpstarMid = ConfigManager.getPetConfig(pet:get("mid")).evolution_stone
			local num = ItemManager.getItemAmount(Constants.ITEM_TYPE.EVOLUTION_STONE,UpstarMid)
			if num >= upstarNum then
				Utils.dispatchCustomEvent("event_upstar",{view = "PetAttributeUI",phase = GuideManager.FUNC_GUIDE_PHASES.PET_UPSTAR,scene = self})
			end
			if GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.PET_SKILL) == false and Player.getInstance():get("level") >= ConfigManager.getPetCommonConfig('skill_openlevel') then
				Utils.dispatchCustomEvent("event_upskill",{view = "PetAttributeUI",phase = GuideManager.FUNC_GUIDE_PHASES.PET_SKILL,scene = self})
				StoryProxy:getInstance():set("isShow",1)
			end
			if GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.PET_LEVEL) == false and Player.getInstance():get("level") >= 8 then
				Utils.dispatchCustomEvent("event_pet_level",{view = "PetAttributeUI",phase = GuideManager.FUNC_GUIDE_EXTRA.PET_SKILL,scene = self})
			end
		elseif "exit" == event then
			if schedulerCD then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerCD)
				schedulerCD = nil
			end
		end
	end
	self:registerScriptHandler(onNodeEvent)
	TouchEffect.addTouchEffect(self)
end 

