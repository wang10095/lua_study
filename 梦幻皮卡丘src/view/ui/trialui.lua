require "view/tagMap/Tag_ui_trial"

TrialUI = class("TrialUI",function()
	return TuiBase:create()
end)

TrialUI.__index = TrialUI
local __instance = nil

function TrialUI:create()
	local ret = TrialUI.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function TrialUI:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function TrialUI:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_trial.PANEL_TRIAL then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_back(p_sender)
	Utils.replaceScene("MainUI", __instance)
end

local btnSweep = nil

--scheduler must be unscheduled when leaving the scene
function TrialUI:dtor()
	if self.schedulerID then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
		self.schedulerID = nil
	end
end

function TrialUI:updateUI()
	local dataproxy = TrialDataProxy:getInstance()
	local currentStorey, remainingResetTimes, historyMaxStorey = dataproxy:get("currentStorey"), dataproxy:get("remainingResetTimes"), dataproxy:get("historyMaxStorey")
	if currentStorey == 0 then
		currentStorey = 1
	end
	local labName = self:getControl(Tag_ui_trial.PANEL_TRIAL,Tag_ui_trial.LAB_NAME)
	local trialTuple = ConfigManager.getTrialConfig(currentStorey)
	local trialName = TextManager.getTrialName(currentStorey)
	labName:setString(currentStorey.." , "..trialName)
	
	local labExp = self:getControl(Tag_ui_trial.PANEL_TRIAL,Tag_ui_trial.LAB_EXP_NUM)
	local labGold = self:getControl(Tag_ui_trial.PANEL_TRIAL,Tag_ui_trial.LAB_GOLD_NUM)
	local labTimes = self:getControl(Tag_ui_trial.PANEL_TRIAL,Tag_ui_trial.LAB_TIMES_NUM)
	labExp:setString(trialTuple.exp_bonus)
	labGold:setString(trialTuple.gold_bonus)
	labTimes:setString(remainingResetTimes)

	local layout_portrait = self:getControl(Tag_ui_trial.PANEL_TRIAL,Tag_ui_trial.LAYOUT_PORTRAIT)
	if self.portrait ~= nil then
		self.portrait:removeFromParent()
	end
	self.portrait = TextureManager.createImg(TextureManager.RES_PATH.PET_PORTRAIT, trialTuple.sid)
	Utils.addCellToParent(self.portrait, layout_portrait)

	local remainingSweepTime = dataproxy:get("remainingSweepTime")
	local labSweepTime = self:getControl(Tag_ui_trial.PANEL_TRIAL,Tag_ui_trial.LAB_SWEEP_TIME)
	local function tick()
		local labSweepTime_ = labSweepTime
		remainingSweepTime = remainingSweepTime - 1
		if remainingSweepTime > 0 then
			local h,m,s = Utils.parseTime(remainingSweepTime)
			m,s = string.format("%.2d",m),string.format("%.2d",s)
			labSweepTime_:setString(h..":"..m..":"..s)
		else
			dataproxy:set("remainingSweepTime", -1)
			local function sweeptrial()
				__instance:updateUI()
			end
			NetManager.registerResponseHandler("sweeptrial", sweeptrial)
			btnSweep:setText("扫荡")
			tolua.cast(btnSweep,"ccw.CWidget"):setUserTag(1)
		end
	end
	if remainingSweepTime ~= -1 then
		labSweepTime:setVisible(true)
		if self.schedulerID then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
			self.schedulerID = nil
		end
		self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 1, false)
	else
		labSweepTime:setVisible(false)
		if self.schedulerID then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerID)
			self.schedulerID = nil
		end
	end
end

function TrialUI:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_trial",PATH_UI_TRIAL)
	local layoutTitle = self:getControl(Tag_ui_trial.PANEL_TRIAL,Tag_ui_trial.LAYOUT_TITLE)
	local backBtn = layoutTitle:getChildByTag(Tag_ui_trial.BTN_BACK)
	backBtn:setOnClickScriptHandler(event_back)

	local btnRank = self:getControl(Tag_ui_trial.PANEL_TRIAL,Tag_ui_trial.BTN_RANK)
	local function event_rank(p_sender)
		Utils.runUIScene("TrialRankPopup")
	end
	btnRank:setOnClickScriptHandler(event_rank)

	local btnTreasure = self:getControl(Tag_ui_trial.PANEL_TRIAL,Tag_ui_trial.BTN_TREASURE)
	local function event_treasure(p_sender)
		TrialDataProxy:getInstance().treasureList = ConfigManager.getTrialConfig(1)
		Utils.runUIScene("TrialTreasurePopup")
	end
	btnTreasure:setOnClickScriptHandler(event_treasure)
	
	local img_title_bg = layoutTitle:getChildByTag(Tag_ui_trial.IMG_TITLE_BG)
	local lab_titlename = layoutTitle:getChildByTag(Tag_ui_trial.LAB_TITLE_NAME)
	Utils.floatToTop(layoutTitle)

	local function event_recovery(p_sender)
		Utils.runUIScene("RecoveryPopup")
	end 
	local btnRecovery = self:getControl(Tag_ui_trial.PANEL_TRIAL,Tag_ui_trial.BTN_RECOVERY)
	btnRecovery:setOnClickScriptHandler(event_recovery)
	
	local function loadtrial(result)
		local dataproxy = TrialDataProxy:getInstance()
		dataproxy:set("currentStorey",result["current_storey"])
		dataproxy:set("remainingResetTimes",result["remainResetTime"])
		dataproxy:set("historyMaxStorey",result["historyMaxStorey"])
		self:updateUI()
		local function event_reset_trial(p_sender)
			local function resettrial(result)
				local dataproxy = TrialDataProxy:getInstance()
				dataproxy:set("currentStorey",result["current_storey"])
				dataproxy:set("remainingResetTimes",result["remainResetTime"])
				self:updateUI()
			end
			NetManager.sendCmd("resettrial", resettrial)
		end
		local btnReset = self:getControl(Tag_ui_trial.PANEL_TRIAL,Tag_ui_trial.BTN_RESET)
		btnReset:setOnClickScriptHandler(event_reset_trial)
		btnSweep = self:getControl(Tag_ui_trial.PANEL_TRIAL,Tag_ui_trial.BTN_SWEEP)
		local function event_sweep_trial(p_sender)
			local tag = tolua.cast(p_sender,"ccw.CWidget"):getUserTag()
			local function sweeptrial()
				self:updateUI()
			end
			NetManager.registerResponseHandler("sweeptrial", sweeptrial)
			if tag == 1 then
				--normal	
				NetManager.cmdHandler.sweeptrial(nil)
			else
				NetManager.cmdHandler.sweeptrial(nil)
			end
		end
		btnSweep:setOnClickScriptHandler(event_sweep_trial)
		local remainingSweepTime = TrialDataProxy:getInstance():get("remainingSweepTime")
		if remainingSweepTime == -1 then
			btnSweep:setText("扫荡")
			tolua.cast(btnSweep,"ccw.CWidget"):setUserTag(1)
		else
			btnSweep:setText("立即扫荡")
			tolua.cast(btnSweep,"ccw.CWidget"):setUserTag(2)
		end
	end

	-- NetManager.sendCmd("loadtrial", loadtrial)
	functioncell = FunctionCell:create()
	self:addChild(functioncell)
end 

