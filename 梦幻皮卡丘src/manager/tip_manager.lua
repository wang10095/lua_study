module("TipManager", package.seeall)


local TIP_INTERVAL = 1.0
local TIP_ZORDER = 1000

local tip_queue = {}
local running = false
local tipSchedule = nil
local scene = nil
local initialized = false

local function init()
	CSceneManager:getInstance():registerSceneClassScriptFunc("CommonTipScene", function()
		return CSceneExtension:create()
	end)
end

local onTipSceneLoaded

local function loadScene(msg)
	scene = LoadScene("CommonTipScene")
	scene:retain()
	scene:setOnLoadSceneScriptHandler(function()
		onTipSceneLoaded(msg)
	end)
	return scene
end

local function updateTip()
	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(tipSchedule)
    showTip()
end

showTip = function(message)
	MusicManager.right_tip()
	if not initialized then
		init()
	end

	if message then
		table.insert(tip_queue, message)
	end

	if running == true then
		return
	end

	local msg = tip_queue[1]
	if msg == nil then
		return
	end
	table.remove(tip_queue, 1)

	running = true
	local scene = loadScene(msg)
    CSceneManager:getInstance():runUIScene(scene, nil, false)
    
    tipSchedule = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateTip, 1.80, false)
end

onTipSceneLoaded = function(msg)
	local winSize = cc.Director:getInstance():getWinSize()
	local atlas = string.format(TextureManager.RES_PATH.SPINE_MAIN_TIP, sid) .. ".atlas"
    local json = string.format(TextureManager.RES_PATH.SPINE_MAIN_TIP, sid) .. ".json"
    local spine = sp.SkeletonAnimation:create(json, atlas, 1)
    spine:retain()
    spine:setPosition(cc.p(winSize.width/2, winSize.height/2))
	scene:addChild(spine, TIP_ZORDER)
	spine:setAnimation(0, "part1", false)

	local label = CLabel:createWithTTF(msg, "fonts/FZCuYuan/M03S.ttf", 30)
	label:retain()
	label:setTextColor(cc.c4b(255, 255, 255, 255))
	label:setPosition(cc.p(winSize.width/2, winSize.height/2))
	scene:addChild(label, TIP_ZORDER)

	function callback()
    	running = false
    	spine:removeFromParent()
    	spine:release()
    	label:removeFromParent()
    	label:release()
    	CSceneManager:getInstance():popUIScene(scene)
    	scene:release()
    	scene = nil
    end

    label:setOpacity(0)
    label:runAction(cc.Sequence:create(
    	cc.DelayTime:create(0.1), 
    	cc.FadeIn:create(0.05),
   	 	cc.DelayTime:create(1),
   	 	cc.Spawn:create(cc.MoveBy:create(0.3, cc.p(0, 150)), cc.FadeOut:create(0.2)),
   	 	cc.DelayTime:create(0.2),
   	 	cc.CallFunc:create(callback)))
end