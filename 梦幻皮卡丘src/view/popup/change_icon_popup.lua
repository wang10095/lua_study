require "view/tagMap/Tag_popup_change_icon"

ChangeIconPopup = class("ChangeIconPopup",function()
	return Popup:create()
end)

ChangeIconPopup.__index = ChangeIconPopup
local __instance = nil
local role_id = nil

function ChangeIconPopup:create()
	local ret = ChangeIconPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function ChangeIconPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function ChangeIconPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_change_icon.PANEL_POPUP_CHANGE_ICON then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end
function ChangeIconPopup:onLoadScene()
	local currentRole = Player:getInstance():get("role")
	TuiManager:getInstance():parseScene(self,"panel_popup_change_icon",PATH_POPUP_CHANGE_ICON)
	local btnRight = self:getControl(Tag_popup_change_icon.PANEL_POPUP_CHANGE_ICON,Tag_popup_change_icon.BTN_RIGHT)
	local btnLeft = self:getControl(Tag_popup_change_icon.PANEL_POPUP_CHANGE_ICON,Tag_popup_change_icon.BTN_LEFT)
	-- local unlocked_id = PlayerProxy:getInstance():get("role_id")
	local img_using = self:getControl(Tag_popup_change_icon.PANEL_POPUP_CHANGE_ICON,Tag_popup_change_icon.IMG_USING)
	local imgSelect = self:getControl(Tag_popup_change_icon.PANEL_POPUP_CHANGE_ICON,Tag_popup_change_icon.IMG_SELECT)
	img_using:setVisible(true) 
	imgSelect:setVisible(false)
	local function updateIconGv( p_convertview, idx)
		local pCell = p_convertview
			pCell = CGridViewCell:new()
			local player = Player:getInstance()
			TuiManager:getInstance():parseCell(pCell,"cell_icon",PATH_POPUP_CHANGE_ICON)
			local layoutIcon = pCell:getChildByTag(Tag_popup_change_icon.LAYOUT_CELL_ICON)
			local imgLocked = pCell:getChildByTag(Tag_popup_change_icon.IMG_ICON_LOCKED)
			local img9Bg = pCell:getChildByTag(Tag_popup_change_icon.IMG9_GRAY_ICONBG)
			local img_new = pCell:getChildByTag(Tag_popup_change_icon.IMG_NEW)
			img_new:setVisible(false)
			local imgHead
			local index = nil
			if idx+1 <=3 then
				if player:get("sex")==1 then 	--boy
					imgHead = TextureManager.createImg("player/".. idx+1 ..".png")
					index = idx+1
				else 							--girl
					imgHead = TextureManager.createImg("player/".. idx+1+3 ..".png")
					index = idx+1+3
				end
			else
				imgHead = TextureManager.createImg("player/".. idx+1+3 ..".png")
				index = idx+1+3
			end
			Utils.addCellToParent(imgHead,layoutIcon)
			local unlockCondition = ConfigManager.getHeadUnlockCondition(index) 

			local canunlock = false
			if unlockCondition[1]==1 then
				if player:get("level")>=unlockCondition[2] then
					canunlock = true
				end
			elseif unlockCondition[1]==2 then
				local result = AchievementDataProxy:getInstance().achievementList
				for i, v in ipairs(result["achievement"]) do
					local aid,sqid ,status= v['aid'],v['sqid'],v['status']
					if aid == unlockCondition[2] and sqid == unlockCondition[3] and status == 1 then
						canunlock = true
					end
				end
			elseif unlockCondition[1]==3 then
				if player:get("vip")>=unlockCondition[2] then
					canunlock = true
				end
			end

			if index==currentRole then
				role_id = idx+1
				local xx =  -238 + ((idx%3)+1 )*116
				local yy 
				if idx+1 >=1 and idx+1 <=3 then
					yy = 100
				elseif idx+1 >=4 and idx+1 <=6 then
					yy = -44
				elseif idx+1 >=7 and idx+1 <=9 then
					yy = -186
				end
				img_using:setPosition(cc.p(xx,yy))
			end

			if canunlock then
				img9Bg:setVisible(false)
				imgLocked:setVisible(false)
				local function event_change_icon( p_sender )
					img_using:setVisible(false)
					imgSelect:setVisible(true)
					local xx =  -218 + ((idx%3)+1 )*116
					local yy 
					if idx+1 >=1 and idx+1 <=3 then
						yy = 127
					elseif idx+1 >=4 and idx+1 <=6 then
						yy = -20
					elseif idx+1 >=7 and idx+1 <=9 then
						yy = -155
					end
					imgSelect:setPosition(cc.p(xx,yy))
					role_id = index
					return false
				end
				layoutIcon:setOnTouchBeganScriptHandler(event_change_icon)
			else
				layoutIcon:setOnTouchBeganScriptHandler(function()
					local proxy = NormalDataProxy:getInstance()
				    proxy:set("title","解锁条件")
					if unlockCondition[1]==1 then
						proxy:set("content","达到" .. unlockCondition[2] .. "级时解锁")
					elseif unlockCondition[1]==2 then
						local AchievementConfig = ConfigManager.getAchievementConfig(unlockCondition[2],unlockCondition[3])
						local achievementDesc = TextManager.getAchievementDesc(AchievementConfig.complete_condition)
						local desc = tostring(achievementDesc)
						desc = string.gsub(desc,'x',tostring(AchievementConfig.complete_condition_param[1]))
						desc = string.gsub(desc,'y',tostring(AchievementConfig.complete_condition_param[2]))
						proxy:set("content",desc .. "后解锁")
					elseif unlockCondition[1]==3 then
						proxy:set("content","VIP等级达到" .. unlockCondition[2] .."时解锁")
					end
					Utils.runUIScene("NormalPopup")
					return false
				end)
			end
		return pCell
	end
	local gvIcon = self:getControl(Tag_popup_change_icon.PANEL_POPUP_CHANGE_ICON,Tag_popup_change_icon.GV_ICON)
	gvIcon:setDataSourceAdapterScriptHandler(updateIconGv)
	gvIcon:setCountOfCell(9)
	gvIcon:setDragable(true)
	gvIcon:reloadData()
	gvIcon:setDragable(false)

	local btnSure = self:getControl(Tag_popup_change_icon.PANEL_POPUP_CHANGE_ICON,Tag_popup_change_icon.BTN_SURE)
	btnSure:setOnClickScriptHandler(function()
		local function changerole( result )
			Player:getInstance():set("role",role_id)
			local customEvent = cc.EventCustom:new("event_change_icon")
			if customEvent then
				customEvent._usedata = role_id
				cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
			end
		end
		NetManager.sendCmd("changerole",changerole,role_id,Player:getInstance():get("sex"))
		Utils.popUIScene(self)
	end)
	TouchEffect.addTouchEffect(self)
end