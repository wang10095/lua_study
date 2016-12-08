require "view/tagMap/Tag_ui_trial"

TrialTreasurePopup = class("TrialTreasurePopup",function()
	return Popup:create()
end)

TrialTreasurePopup.__index = TrialTreasurePopup
local __instance = nil

function TrialTreasurePopup:create()
	local ret = TrialTreasurePopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function TrialTreasurePopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function TrialTreasurePopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_trial.PANEL_TREASURE then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function TrialTreasurePopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_treasure",PATH_UI_TRIAL)
	local listView = self:getControl(Tag_ui_trial.PANEL_TREASURE, Tag_ui_trial.LIST_TREASURE)
	local treasureList = TrialDataProxy:getInstance().treasureList
	local count = listView:getNodeCount()
	while count > #treasureList do
		listView:removeLastNode()
		count = listView:getNodeCount()
	end
	listView:reloadData()
	for k,v in pairs(treasureList) do
		local node = listView:getNodeAtIndex(k-1)
		local labName = node:getChildByTag(Tag_ui_trial.LAB_TREASURE_NAME)
		labName:setString(v.name)
		for i = 1, 4 do
			local item_type, id, amount = v["type"..i],v["id"..i],v["amount"..i]
			local cellName = node:getChildByTag(Tag_ui_trial["LAB_TREASURE_NAME"..i])
			local trialName = TextManger.getTrialName(i)
			print(trialName)
			print(item_type)
			if item_type ~= -1 then
				local avatar = node:getChildByTag(Tag_ui_trial["LAYOUT_TREASURE_AVATAR"..i])
				local item = ItemManager.createItem(item_type, id, amount)
				local cell = ItemCell:create(item_type, item)
				Utils.addCellToParent(cell, avatar, true)
				cellName:setString(trialName)
				cellName:setVisible(true)
			else
				cellName:setVisible(false)
			end
		end
	end
	--set touch border
	-- local bg = self:getControl(Tag_ui_trial.PANEL_TREASURE, Tag_ui_trial.IMG9_TREASURE)
	-- self:setCloseTouchNode(bg)
	TouchEffect.addTouchEffect(self)
end 

