require "view/tagMap/Tag_popup_achievement"

AchievementPopup = class("AchievementPopup",function()
	return Popup:create()
end)

AchievementPopup.__index = AchievementPopup
local __instance = nil
local canGet = 0

function AchievementPopup:create()
	local ret = AchievementPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function AchievementPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function AchievementPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_achievement.PANEL_ACHIEVEMENT then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_close( p_sender )
	Utils.popUIScene(__instance)
end 

function AchievementPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_achievement",PATH_POPUP_ACHIEVEMENT)
	local btnClose = self:getControl(Tag_popup_achievement.PANEL_ACHIEVEMENT, Tag_popup_achievement.BTN_CLOSE_ACHIEVEMENT)
	btnClose:setOnClickScriptHandler(event_close)
	expandList = self:getControl(Tag_popup_achievement.PANEL_ACHIEVEMENT,Tag_popup_achievement.EXPLIST_ACHIEVEMENT)
	
	local function callback_loadachievement(result)
		canGet = 0
		local displayList = {}
		for i, v in pairs(result["achievement"]) do
			local aid,sqid ,status= v['aid'],v['sqid'],v['status']
			table.insert(displayList,{aid,sqid,status})
		end
		table.sort(displayList,function(a,b)
			return a[3]>b[3]
		end)
		local function updateexpandList()
			for i,v in pairs(displayList) do
				local aid,sqid,status= v[1],v[2],v[3]
				-- print("===" .. aid,sqid,status )
				local avaiableBtn = expandList:getExpandableNodeAtIndex(i-1):getChildByTag(Tag_popup_achievement.BTN_GETREWARD)
				avaiableBtn:setNormalSpriteFrameName("component_common/btn_bag_select.png")
				avaiableBtn:setSelectedSpriteFrameName("component_common/btn_bag_normal.png")
				local lab_can_reward = expandList:getExpandableNodeAtIndex(i-1):getChildByTag(Tag_popup_achievement.LAB_CAN_REWARD)
				local img_not_finish = expandList:getExpandableNodeAtIndex(i-1):getChildByTag(Tag_popup_achievement.IMG_NOT_FINISH)
				img_not_finish:setVisible(false)

				local labTitle = expandList:getExpandableNodeAtIndex(i-1):getChildByTag(Tag_popup_achievement.LAB_ACHIEVEMENT_NAME)
				local labDesc = expandList:getExpandableNodeAtIndex(i-1):getChildByTag(Tag_popup_achievement.LAB_ACHIEVEMENT_DESCRIPTION)
				local AchievementConfig = ConfigManager.getAchievementConfig(aid,sqid)
				local AchievementTitle = TextManager.getAchievementTitle(aid,sqid)
				labTitle:setString(AchievementTitle)
				local achievementDesc = TextManager.getAchievementDesc(AchievementConfig.complete_condition)
				local desc = tostring(achievementDesc)
				desc = string.gsub(desc,'x',tostring(AchievementConfig.complete_condition_param[1]))
				desc = string.gsub(desc,'y',tostring(AchievementConfig.complete_condition_param[2]))
				labDesc:setString(desc)
				if status == 0 then
					avaiableBtn:setVisible(false)
					img_not_finish:setVisible(true)
					lab_can_reward:setVisible(false)
				else
					lab_can_reward:setString("领取")
					canGet = canGet + 1
				end	

				local function event_getreward()
					local function getachievementawards(result)
						Player:getInstance():set("level",result["level"])
						Player:getInstance():set("exp",result["exp"])
						Player:getInstance():set("gold",result["gold"])
						Player:getInstance():set("diamond",result["diamond"])
						Player:getInstance():set("fame",result["fame"])
						Player:getInstance():set("badge",result["badge"])
						for k,n in ipairs(result["items"]) do
							ItemManager.addItem(n["item_type"],n["mid"], n["amount"])
						end
						for k,n in ipairs(result["pets"]) do
							ItemManager.addPet(n)
						end

						local proxy = AchievementDataProxy:getInstance()
						proxy:set("current_aid", aid)
						proxy:set("current_sqid", sqid)
						proxy:set("current_status", status)
						AchievementDataProxy.achievementContent = result
						local function confirmHandler()
							NetManager.sendCmd("loadachievement",callback_loadachievement)
						end
						NormalDataProxy:getInstance().confirmHandler = confirmHandler
						Utils.runUIScene("AchievementContentPopup")
					end
					NetManager.sendCmd("getachievementawards", getachievementawards,aid,sqid)	
				end
				avaiableBtn:setOnClickScriptHandler(event_getreward)

				local layoutAvatar = expandList:getExpandableNodeAtIndex(i-1):getChildByTag(Tag_popup_achievement.IMG_ITEM_AVATAR)
				local aimg = TextureManager.createImg("achievement/%d.jpg",AchievementConfig.complete_condition)
				Utils.addCellToParent(aimg, layoutAvatar, true)
				for k=1, 4 do
					local layoutItem = expandList:getExpandableNodeAtIndex(i-1):getItemNodeAtIndex(0):getChildByTag(Tag_popup_achievement["LAYOUT_ITEM"..k])
					local lab_item_num = expandList:getExpandableNodeAtIndex(i-1):getItemNodeAtIndex(0):getChildByTag(Tag_popup_achievement["LAB_ITEM_NUM" .. k])
					lab_item_num:setString("")
					if #AchievementConfig["item" .. k] ~= 0 then
						if AchievementConfig["item" .. k][1]==1 then
							local pet = Pet:create()
							pet:set("id",1)
							pet:set("mid",AchievementConfig["item"..k][2])
							pet:set("form",1)
							pet:set("star",1)
							pet:set("aptitude",AchievementConfig["item"..k][3])
							local petCell = PetCell:create(pet)
							Utils.addCellToParent(petCell, layoutItem, true)
							Utils.showPetInfoTips(layoutItem, pet:get("mid"), pet:get("form"))
						else
							local item = ItemManager.createItem(AchievementConfig["item"..k][1],AchievementConfig["item"..k][2])
							local cell = ItemCell:create(AchievementConfig["item"..k][1], item)
							Utils.addCellToParent(cell, layoutItem, true)
							lab_item_num:setString(AchievementConfig["item"..k][3])
							Utils.showItemInfoTips(layoutItem, item)
						end
					end
				end
				local rewardTable = {{exp=AchievementConfig.exp},{gold=AchievementConfig.gold},{diamond=AchievementConfig.diamond},{prestige=AchievementConfig.fame},{badge=AchievementConfig.badge}}
				for k=#rewardTable,1,-1 do
					for m,n in pairs(rewardTable[k]) do
						if n == -1 then
							table.remove(rewardTable,k)
						end
					end
				end
				for k = 1,#rewardTable do
					local img_reward = expandList:getExpandableNodeAtIndex(i-1):getItemNodeAtIndex(0):getChildByTag(Tag_popup_achievement["IMG_REWARD" .. k])
					local lab_reward = expandList:getExpandableNodeAtIndex(i-1):getItemNodeAtIndex(0):getChildByTag(Tag_popup_achievement["LAB_REWARD_NUM" .. k])
					for m,n in pairs(rewardTable[k]) do
						img_reward:setSpriteFrame("component_common/img_".. m ..".png")
						lab_reward:setString("X" .. n)
						if m == "prestige" or m == "badge" then
							img_reward:setScale(0.5)
						end
					end
				end
				for k=#rewardTable+1,3 do
					local img_reward = expandList:getExpandableNodeAtIndex(i-1):getItemNodeAtIndex(0):getChildByTag(Tag_popup_achievement["IMG_REWARD"..k])
					local lab_reward = expandList:getExpandableNodeAtIndex(i-1):getItemNodeAtIndex(0):getChildByTag(Tag_popup_achievement["LAB_REWARD_NUM"..k])
					img_reward:setVisible(false)
					lab_reward:setVisible(false)
				end
			end
		end 
		if canGet <= 0 then
		 	PromtManager.NewsTable.ACHIEVEMENT_FINISH.status = false
		 	PromtManager.checkOnePromt("ACHIEVEMENT_FINISH")
		end 

		while(expandList:getExpandableNodeCount() > #displayList) do
			expandList:removeLastExpandableNode()
		end
		expandList:reloadData()
		updateexpandList()
	end

	callback_loadachievement(AchievementDataProxy.achievementList)
	local function onNodeEvent(event)
		if "enter" == event then
			self:show()
			NormalDataProxy:getInstance():set("isPopup",true)
		end
		if "exit" == event then
			NormalDataProxy:getInstance():set("isPopup",false)
		end
	end
	self:registerScriptHandler(onNodeEvent)
	TouchEffect.addTouchEffect(self)
end 

