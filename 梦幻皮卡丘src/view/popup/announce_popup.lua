require "view/tagMap/Tag_popup_announce"

AnnouncePopup = class("AnnouncePopup",function()
	return Popup:create()
end)

AnnouncePopup.__index = AnnouncePopup
local __instance = nil
local expandList = nil
local scheduleID = nil

function AnnouncePopup:create()
	local ret = AnnouncePopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function AnnouncePopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function AnnouncePopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_announce.PANEL_ANNOUNCE then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function AnnouncePopup:onGetachievementawards()
	__instance.expandList:removeExpandableNodeAtIndex(0)
	__instance.expandList:reloadData()
end

local function event_close( p_sender )
	Utils.popUIScene(__instance)
end 

function AnnouncePopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_announce",PATH_POPUP_ANNOUNCE)
	local btnClose = self:getControl(Tag_popup_announce.PANEL_ANNOUNCE, Tag_popup_announce.BTN_CLOSE_ANNOUNCE)
	btnClose:setOnClickScriptHandler(event_close)
	expandList = self:getControl(Tag_popup_announce.PANEL_ANNOUNCE,Tag_popup_announce.EXPLIST_ACHIEVEMENT)
	local announceNum = ConfigManager.getAnnounceNum()
	local function updateExpandList(expandList)
		for i=1, announceNum do
			local announceConfig = ConfigManager.getAnnounceCommon(i)
			local lab_num = expandList:getExpandableNodeAtIndex(i-1):getChildByTag(Tag_popup_announce.LAB_NUM)
			lab_num:setString(i)
			local labTitle = expandList:getExpandableNodeAtIndex(i-1):getChildByTag(Tag_popup_announce.LAB_TITLE)
			labTitle:setString(announceConfig.title)

			local lab_title_bg = expandList:getExpandableNodeAtIndex(i-1):getChildByTag(Tag_popup_announce.IMG_CONTENT_BG)
			
			local node = expandList:getExpandableNodeAtIndex(i-1):getItemNodeAtIndex(0)

			local lab_announce_content = node:getChildByTag(Tag_popup_announce.LAB_ANNOUNCE_CONTENT)
			lab_announce_content:setDimensions(lab_announce_content:getContentSize().width, 0)
			lab_announce_content:setString(announceConfig.content)
			-- print("=height===" .. lab_announce_content:getContentSize().height)
			node:setContentSize(cc.size(node:getContentSize().width,lab_announce_content:getContentSize().height+50))
			lab_announce_content:setAnchorPoint(cc.p(0.5,1))
			lab_announce_content:setPositionY(node:getContentSize().height-10)

			local img9_display_bg = node:getChildByTag(Tag_popup_announce.IMG9_DISPLAY_BG)
			img9_display_bg:setContentSize(cc.size(node:getContentSize().width-30,node:getContentSize().height))
			img9_display_bg:setAnchorPoint(cc.p(0.5,1))
			img9_display_bg:setPositionY(node:getContentSize().height+10)
			-- print("==dddd==")
		end

		if scheduleID then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID)
		end
		scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
			for i=1,announceNum do
				local img_arrow = expandList:getExpandableNodeAtIndex(i-1):getChildByTag(Tag_popup_announce.IMG_ARROW)
				if expandList:getExpandableNodeAtIndex(i-1):isExpanded() then
					img_arrow:setScaleY(-1)
				else
					img_arrow:setScaleY(1)
				end
			end
		end, 0, false)
	end 
	while(expandList:getExpandableNodeCount() > announceNum) do
		expandList:removeExpandableNodeAtIndex(expandList:getExpandableNodeCount() -1)
	end
	expandList:reloadData()
	updateExpandList(expandList)

    local function onNodeEvent(event)
    	if "enter"==event then
    		self:show()
    	end
		if "exit" == event then
			if scheduleID then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID)
			end
		end
	end
	self:registerScriptHandler(onNodeEvent)
end 

