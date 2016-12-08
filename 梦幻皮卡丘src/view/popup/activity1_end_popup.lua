require "view/tagMap/Tag_popup_end"

ActivityEndPopup = class("ActivityEndPopup",function()
	return Popup:create()
end)

ActivityEndPopup.__index = ActivityEndPopup
local __instance = nil
local activity1Type

function ActivityEndPopup:create()
	local ret = ActivityEndPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function ActivityEndPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function ActivityEndPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_end.PANEL_END then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_close()
	if NormalDataProxy:getInstance().confirmHandler then
		NormalDataProxy:getInstance().confirmHandler()
	end
	NormalDataProxy:getInstance().confirmHandler = nil
	Utils.popUIScene(__instance)
end

function ActivityEndPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_end",PATH_POPUP_END)

	local activity1Type = Activity1StatusProxy:getInstance():get("activity1Type")
	local btn_activity_end = self:getControl(Tag_popup_end.PANEL_END,Tag_popup_end.BTN_ACTIVITY_END)
	btn_activity_end:setOnClickScriptHandler(event_close)
	local lab_reward_name = self:getControl(Tag_popup_end.PANEL_END,Tag_popup_end.LAB_REWARD_NAME)
	local proxy = Activity1StatusProxy:getInstance()
	local result = proxy.rewardTable  --数据
	local reward
	local rewardConfig = ConfigManager.getActivity1RewardConfig()
	-- print("  99999   "..#rewardConfig )
	for i=1,#rewardConfig do
		print(i,Player:getInstance():get("level"),rewardConfig[i].reward_level)
		if Player:getInstance():get("level") <= rewardConfig[i].reward_level then
			reward = rewardConfig[i]
			print(reward)
			break
		end
	end
		
	local rewarditem 
	local rewardgold
    local level_1 = ConfigManager.getActivity1ScoreConfig(1)
    local level_2 = ConfigManager.getActivity1ScoreConfig(2)
    local level_3 = ConfigManager.getActivity1ScoreConfig(3)
    if proxy:get("score") <= level_1.score then
    	lab_reward_name:setString(level_1.reward_level)
    	rewarditem = reward.reward_bronze_item
    	rewardgold = reward.reward_bronze_gold
    elseif proxy:get("score") <= level_2.score and proxy:get("score") > level_1.score then
    	lab_reward_name:setString(level_2.reward_level)
    	rewarditem = reward.reward_silver_item
    	rewardgold = reward.reward_silver_gold
    else
    	lab_reward_name:setString(level_3.reward_level)
    	rewarditem = reward.reward_gold_item
    	rewardgold = reward.reward_gold_gold
    end

 	Player:getInstance():set("gold",result["gold"])
	local lab_end_score_num = self:getControl(Tag_popup_end.PANEL_END,Tag_popup_end.LAB_END_SCORE_NUM)
	lab_end_score_num:setString(proxy:get("score"))
	
	local lab_end_reward_num = self:getControl(Tag_popup_end.PANEL_END,Tag_popup_end.LAB_END_REWARD_NUM)
	lab_end_reward_num:setString(proxy:get("rewardTimes"))
	-- lab_end_reward_num:setVisible(false)
	
	local layout_reward_item = self:getControl(Tag_popup_end.PANEL_END,Tag_popup_end.LAYOUT_REWARD_ITEM)
	local lab_reward_item_num = self:getControl(Tag_popup_end.PANEL_END,Tag_popup_end.LAB_REWARD_ITEM_NUM)
	
	-- local layout_reward_gold = self:getControl(Tag_popup_end.PANEL_END,Tag_popup_end.LAYOUT_REWARD_GOLD)
	-- local lab_reward_gold_num = self:getControl(Tag_popup_end.PANEL_END,Tag_popup_end.LAB_REWARD_GOLD_NUM)

	if rewarditem and activity1Type ==  Constants.ACTIVITY1_TYPE.CANDY_AREA then
		local item = ItemManager.createItem(rewarditem[1],rewarditem[2])
		local cell = ItemCell:create(rewarditem[1],item)
		Utils.addCellToParent(cell,layout_reward_item,true)

		lab_reward_item_num:setString(rewarditem[3] * proxy:get("rewardTimes") )
		ItemManager.addItem(rewarditem[1],rewarditem[2],rewarditem[3])
	else
		lab_reward_item_num:setString(rewardgold * proxy:get("rewardTimes"))
		local size = layout_reward_item:getContentSize()
		local imgGold = TextureManager.createImg("item/img_gold.jpg")
		imgGold:setPosition(cc.p(size.width/2,size.height/2))
		layout_reward_item:addChild(imgGold,1)

		local imgBorder = TextureManager.createImg("cell_item/img_border_5.png")
		imgBorder:setPosition(cc.p(size.width/2,size.height/2))
		layout_reward_item:addChild(imgBorder,2)
	end

	-- if rewardgold ~= 0 and activity1Type == Constants.ACTIVITY1_TYPE.REGAL_AREA then
	-- 	lab_reward_gold_num:setString(rewardgold)
	-- 	local size = layout_reward_gold:getContentSize()
	-- 	local imgGold = TextureManager.createImg("item/img_gold.jpg")
	-- 	imgGold:setPosition(cc.p(size.width/2,size.height/2))
	-- 	layout_reward_gold:addChild(imgGold,1)

	-- 	local imgBorder = TextureManager.createImg("cell_item/img_border_5.png")
	-- 	imgBorder:setPosition(cc.p(size.width/2,size.height/2))
	-- 	layout_reward_gold:addChild(imgBorder,2)
		
	-- else
	-- 	layout_reward_gold:setVisible(false)
	-- 	lab_reward_gold_num:setVisible(false)
	-- end

	TouchEffect.addTouchEffect(self)
end




