TransScene = class("TransScene",function()
    return TuiBase:create()
end)

TransScene.spine = nil
TransScene.checkEntry = nil
TransScene.isReady = false
TransScene.target = nil

function TransScene:create()
	local ret = TransScene.new()
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
    -- ret:setOnExitSceneScriptHandler(function() ret:onExitScene() end)
    return ret
end

function TransScene:checkStatus()
	if self.isReady then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.checkEntry)
    	self.checkEntry = nil
    	CSceneManager:getInstance():replaceScene(CCSceneExTransitionFade:create(0.1, LoadScene(self.target)))
    end
end

-- function TransScene:onExitScene()
-- 	self.spine:removeFromParent()
-- 	self.spine:release()
-- end

function TransScene:onLoadScene()
	if self.spine == nil then
		local model = math.random(50)
		local atlas = string.format(TextureManager.RES_PATH.SPINE_PET, model) .. ".atlas"
	    local json = string.format(TextureManager.RES_PATH.SPINE_PET, model) .. ".json"
	    local spine = sp.SkeletonAnimation:create(json, atlas, 1)

	    spine:setPosition(cc.p(320, 400))
	    self:addChild(spine)
	    spine:setAnimation(0, "walk", true)

	    self.spine = spine
	    self.spine:retain()
	end

    self.isReady = false
	self.checkEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function() self:checkStatus() end, 0.1, false)

	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.21), cc.CallFunc:create(function()
		self.isReady = true
	end)))
end