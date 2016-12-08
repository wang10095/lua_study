Popup = class("Popup",function()
	return TuiBase:create()
end)

Popup.HY_POPUP_FLAG = 1

Popup.__index = Popup

Popup.panelTag = 1

local __instance = nil

local DESIGN_SIZE = cc.size(640, 960)

function Popup:create()
	local ret = Popup.new()
	if ret:init() then
		__instance = ret
		return ret
	end
	return nil
end

function Popup:show()
	local winSize = cc.Director:getInstance():getWinSize()

	self.panel = self:getChildren()[1]
	-- self.panelTag = panel:getTag()
	self.panel:retain()
	-- panel:removeFromParent()

	local mask = CLayout:create()
	mask:setBackgroundColor(cc.c4b(0, 0, 0, 127))
	mask:setContentSize(winSize)
	mask:setPosition(cc.p(DESIGN_SIZE.width/2, DESIGN_SIZE.height/2))
	self:addChild(mask, -1)
	-- self:addChild(panel, self.panelTag)
	-- self.panel:setTag(2)
	self.panel:setScale(0.1)
	self.panel:runAction(cc.Sequence:create(
		cc.ScaleTo:create(0.2, 1.1), 
		cc.ScaleTo:create(0.06, 0.9), 
		cc.ScaleTo:create(0.06, 1.0),
		cc.CallFunc:create(function()
			if self.transFinished then
				self:transFinished()
			end
		end)
	))
end

function Popup:init()
	function onNodeEvent(event)
		if event == "enter" then
			self:show()
		end
	end

	self:registerScriptHandler(onNodeEvent)
	return true
end

function Popup:close(closeCallback)
	-- local panel = self:getChildByTag(self.panelTag)
	self.panel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 0.01),cc.CallFunc:create(function()
		CSceneManager:getInstance():popUIScene(self)
		self.panel:release()
		ResourceManager.removeResourceOfView(self:getClassName())
		if closeCallback then
			closeCallback()
		end
	end)))
end

