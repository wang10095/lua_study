
require "view/tagMap/Tag_ui_explore"

DisplayRewardsPopup = class("DisplayRewardsPopup",function()
	return Popup:create()
end)

DisplayRewardsPopup.__index = DisplayRewardsPopup
local __instance = nil
function DisplayRewardsPopup:create()
	local ret = DisplayRewardsPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function DisplayRewardsPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function DisplayRewardsPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_explore.PANEL_DISPLAY_REWARDS then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_close()
	Utils.popUIScene(__instance)
end

function DisplayRewardsPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_display_rewards",PATH_UI_EXPLORE)
	local btnClose = self:getControl(Tag_ui_explore.PANEL_DISPLAY_REWARDS, Tag_ui_explore.BTN_CLOSE_DISPLAY)
	btnClose:setOnClickScriptHandler(event_close)
	local list = self:getControl(Tag_ui_explore.PANEL_DISPLAY_REWARDS, Tag_ui_explore.LIST_DISPLAY)
	list:removeAllNodes()
	local count = list:getNodeCount()
	while count < 100 do
		local pCell = CGridViewCell:new()
		TuiManager:getInstance():parseCell(pCell,"cell_display",PATH_UI_EXPLORE)
		list:insertNodeAtLast(pCell)
		count = list:getNodeCount()
	end
	list:reloadData()

	for i=1,100 do
		local rewardsConfig = ConfigManager.getActivity3RewardsConfig(i)
		local node = list:getNodeAtIndex(i-1)
		local labStageNum = node:getChildByTag(Tag_ui_explore.LAB_DISPLAY_STAGE_NUM)
		labStageNum:setString("第" .. i .. "层")
		local labBadget = node:getChildByTag(Tag_ui_explore.LAB_DISPLAY_BADGET)
		labBadget:setString(rewardsConfig.badget)
		local labGold = node:getChildByTag(Tag_ui_explore.LAB_DISPLAY_GOLD)
		labGold:setString(rewardsConfig.gold)

		for i,v in ipairs(rewardsConfig.items) do
			local layoutItem = node:getChildByTag(Tag_ui_explore["LAYOUT_DISPLAY_ITEM" .. i])
			local item = ItemManager.createItem(v[1], v[2])
			local cell = ItemCell:create(v[1],item)
			Utils.addCellToParent(cell,layoutItem,true)
		end
	end
end







