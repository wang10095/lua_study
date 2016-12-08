--
-- Author: hapigames
-- Date: 2014-12-03 22:15:10
--
require "view/tagMap/Tag_ui_trial"

RecoveryPopup = class("RecoveryPopup",function()
	return Popup:create()
end)

RecoveryPopup.__index = RecoveryPopup
local __instance = nil

function RecoveryPopup:create()
	local ret = RecoveryPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function RecoveryPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function RecoveryPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_trial.PANEL_RECOVERY_ENERGY then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_close( p_sender )
		Utils.popUIScene(__instance)
end

local function callback_recovery_energy(result)
	Player:getInstance():set("energy",result["energy"])
	Utils.popUIScene(__instance)
end

function RecoveryPopup:onLoadScene( )
	TuiManager:getInstance():parseScene(self,"panel_recovery_energy",PATH_UI_TRIAL)
	
	local btn_close = self:getControl(Tag_ui_trial.PANEL_RECOVERY_ENERGY,Tag_ui_trial.BTN_CLOSE_RECOVERY)
	btn_close:setOnClickScriptHandler(event_close)
	local labTips = self:getControl(Tag_ui_trial.PANEL_RECOVERY_ENERGY,Tag_ui_trial.LAB_RECOVERY_TIPS)
	local recoverEnergy = ConfigManager.getUserCommonConfig('energy_recover_nums')
	labTips:setString("每天12～15点和18～21点均可来恢复体力" .. recoverEnergy .. "点")

	local function event_recovery_energy( p_sender ) 
		local time = os.date("%H")
		if (time >= '12' and time <= '15') or (time >= '18' and time <= '21') then
			NetManager.sendCmd("recoveryenergy",callback_recovery_energy)
		else
			TipManager.showTip("未到时间!")
		end 
	end
	local btn_addenergy = self:getControl(Tag_ui_trial.PANEL_RECOVERY_ENERGY,Tag_ui_trial.BTN_RECOVERY_ENERGY)
	btn_addenergy:setOnClickScriptHandler(event_recovery_energy)

	

	-- TouchEffect.addTouchEffect(self)
end
