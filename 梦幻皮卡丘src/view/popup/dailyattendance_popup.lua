--
-- Author: hapigames
-- Date: 2014-12-12 17:15:39
--
require "view/tagMap/Tag_popup_dailyattendance"

DailyAttendancePopup = class("DailyAttendancePopup",function()
	return Popup:create()
end)

DailyAttendancePopup.__index = DailyAttendancePopup
local __instance = nil
function DailyAttendancePopup:create()
	local ret = DailyAttendancePopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function DailyAttendancePopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function DailyAttendancePopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_dailyattendance.PANEL_POPUP_DAILYATTENDANCE then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end


function DailyAttendancePopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_dailyattendance",PATH_POPUP_DAILYATTENDANCE)
	local function event_close( p_sender )
		Utils.popUIScene(self)
	end 
	local btn_close = self:getControl(Tag_popup_dailyattendance.PANEL_POPUP_DAILYATTENDANCE,Tag_popup_dailyattendance.BTN_CLOSE)
	btn_close:setOnClickScriptHandler(event_close)
	

	local daily = Dailyattendancedataproxy.attendanceList
	local num = daily["num"]
	local state= daily["today_statue"]
	local attendance_num = self:getControl(Tag_popup_dailyattendance.PANEL_POPUP_DAILYATTENDANCE,Tag_popup_dailyattendance.LAB_REGISTRATION_NUM)
	attendance_num:setString(num)
	local function updateGV(p_convertview,idx)
		local pCell = p_convertview
		if pCell == nil then
			pCell = CGridViewCell:new()
			TuiManager:getInstance():parseCell(pCell, "cell_registration", PATH_POPUP_DAILYATTENDANCE)
			local selectImg = pCell:getChildByTag(Tag_popup_dailyattendance.IMG_SELECT)
			if idx+1 <= num then
				selectImg:setVisible(true)
			else
				selectImg:setVisible(false)
			end
			local function event_receive_reward(p_sender)
				print("receive")
				local function getattendancereward(result)
					Utils.runUIScene("AchievementContentPopup")
					print("getattendancereward")
				end
				NetManager.sendCmd("getattendancereward",getattendancereward)
			end
			local img = pCell:getChildByTag(Tag_popup_dailyattendance.IMG_REGISTRATION_PROP)
			img:setOnClickScriptHandler(event_receive_reward)
		end
		return pCell
	end
	local gv_registration = self:getControl(Tag_popup_dailyattendance.PANEL_POPUP_DAILYATTENDANCE,Tag_popup_dailyattendance.GV_REGISTRATION)
	gv_registration:setDataSourceAdapterScriptHandler(updateGV)
	gv_registration:setCountOfCell(30)
	gv_registration:reloadData()
	TouchEffect.addTouchEffect(self)
end