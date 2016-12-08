LoadingMaskPopup = class("LoadingMaskPopup",function()
	return Popup:create()
end)

LoadingMaskPopup.__index = LoadingMaskPopup
local __instance = nil
local _allowNewInstance = nil
local _ref_count = 0
local _start_time = 0
local _should_show_loading = true

function LoadingMaskPopup:create()
	local ret = LoadingMaskPopup.new()
	__instance = ret
	return ret
end

function LoadingMaskPopup:getInstance()
	if __instance == nil then
		local ret = LoadScene("LoadingMaskPopup")
		__instance = ret
		__instance:retain()
		_ref_count = 0
	end
	return __instance
end

function LoadingMaskPopup:begin(shouldShowLoading)
	_start_time = os.clock()*1000
	-- print("loading begin *********************************", _start_time)

	CSceneManager:getInstance():runUIScene(self, nil, true)
	_ref_count = _ref_count + 1
	_should_show_loading = shouldShowLoading
	if shouldShowLoading then
		self:runAction(cc.Sequence:create(cc.DelayTime:create(0.2), cc.CallFunc:create(function()
			local winSize = cc.Director:getInstance():getWinSize()
			local atlas = "spine/spine_loading/spine_loading.atlas"
		    local json = "spine/spine_loading/spine_loading.json"
		    local spine = sp.SkeletonAnimation:create(json, atlas, 1)
		    spine:setPosition(cc.p(320, 480))
		    spine:setAnimation(0, "animation", true)
		    self:addChild(spine)
		end)))
	end
end

function LoadingMaskPopup:show()
end

function LoadingMaskPopup:complete(onComplelte)
	local endTime = os.clock()*1000
	_ref_count = _ref_count - 1
	-- print("loading complete *********************************", endTime, endTime - _start_time, _ref_count)
	if (_ref_count == 0) or (not _should_show_loading) then
	-- print("loading complete *********************************", endTime, endTime - _start_time, _ref_count)
		self:stopAllActions()
		self:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.CallFunc:create(function()
			CSceneManager:getInstance():popUIScene(self)
			__instance:release()
			__instance = nil
			if onComplelte then
				onComplelte()
			end
		end)))
		return
	end
	
	self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
		if _ref_count == 0 then
			CSceneManager:getInstance():popUIScene(self)
			__instance:release()
			__instance = nil
		end
		if onComplelte then
			onComplelte()
		end
	end)))
end