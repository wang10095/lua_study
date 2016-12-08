Activity2Handler = class("Activity2Handler")

local instance_ = nil

function Activity2Handler:getInstance()
	if instance_ == nil then
		instance_ = Activity2Handler.new()
	end
	return instance_
end

function Activity2Handler:initBattle(battle)
	local id = StageRecord:getInstance():get("activity2Id")
	if id == 1 then
		for k,petUnit in pairs(battle.petUnits) do
            petUnit:addDebuff(1, nil, 0, true)
        end
        for k,demonUnit in pairs(battle.demonUnits) do
        	demonUnit:addDebuff(1, nil, 0, true)
        end
	elseif id == 2 then
	-- battle:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function()
        for k,petUnit in pairs(battle.petUnits) do
            petUnit.maxHP = math.floor(petUnit.maxHP * 0.2)
            petUnit.curHP = math.floor(petUnit.curHP * 0.2)
        end
        for k,demonUnit in pairs(battle.demonUnits) do
        	demonUnit.maxHP = math.floor(demonUnit.maxHP * 0.2)
            demonUnit.curHP = math.floor(demonUnit.curHP * 0.2)
            demonUnit.hpProgress:setMaxValue(demonUnit.maxHP)
            demonUnit.hpProgress:setValue(demonUnit.HP)
        end
    -- end)))
	elseif id == 3 then
		battle.healFactor = 2.0
	end
end

function Activity2Handler:getMatrixMode()
	local id = StageRecord:getInstance():get("activity2Id")
	if id == 4 then
		return 2
	else
		return 1
	end
end

function Activity2Handler:getEffect()
	local id = StageRecord:getInstance():get("activity2Id")
	print("id = "..id)
	local actionConfig = ConfigManager.getActivity2StatusConfig(id)
	 
	local winSize = cc.Director:getInstance():getWinSize()
	if id == 1 then 
		local atlas = TextureManager.RES_PATH.SPINE_ACTIVITY2_HAZE .. ".atlas"
	    local json = TextureManager.RES_PATH.SPINE_ACTIVITY2_HAZE .. ".json"
	    skillNameEffect = sp.SkeletonAnimation:create(json, atlas, 1)
	    skillNameEffect:setAnimation(0,"part1",true)
	    skillNameEffect:retain()
	    skillNameEffect:setPosition(cc.p(winSize.width/2-50, winSize.height/2))
	    return skillNameEffect
    elseif id == 3 then
    	local atlas = TextureManager.RES_PATH.SPINE_ACTIVITY2_RAIN .. ".atlas"
	    local json = TextureManager.RES_PATH.SPINE_ACTIVITY2_RAIN .. ".json"
	    skillNameEffect = sp.SkeletonAnimation:create(json, atlas, 1)
	    skillNameEffect:setAnimation(0,"part1",true)
	    skillNameEffect:retain()
	    skillNameEffect:setPosition(cc.p(winSize.width/2-50, winSize.height/2))
	    return skillNameEffect
    elseif id == 2 then
    	local emitter = cc.ParticleSystemQuad:create(TextureManager.RES_PATH["ACTIVITY2_".. actionConfig.action .."_PLIST"])
        emitter:setPosition(cc.p(winSize.width/2, winSize.height))
	    return emitter
    end
end