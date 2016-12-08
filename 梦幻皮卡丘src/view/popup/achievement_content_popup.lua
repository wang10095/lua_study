require "view/tagMap/Tag_popup_achievement_content"

AchievementContentPopup = class("AchievementContentPopup",function()
	return Popup:create()
end)

AchievementContentPopup.__index = AchievementContentPopup
local __instance = nil

function AchievementContentPopup:create()
	local ret = AchievementContentPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function AchievementContentPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function AchievementContentPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_achievement_content.PANEL_ACHIEVEMENT_CONTENT then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end
function AchievementContentPopup:setConfirmNormalHandler(handlerP)
	self.confirmHandler = handlerP
end

function AchievementContentPopup:setCancelNormalHandler(handlerP)
	self.cancelHandler = handlerP
end
function AchievementContentPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_achievement_content",PATH_POPUP_ACHIEVEMENT_CONTENT)
	local list = self:getControl(Tag_popup_achievement_content.PANEL_ACHIEVEMENT_CONTENT, Tag_popup_achievement_content.LIST_ACHIEVEMENT_CONTENT)
	local bg = self:getControl(Tag_popup_achievement_content.PANEL_ACHIEVEMENT_CONTENT, Tag_popup_achievement_content.IMG_ACHIEVEMENT_BG)
	local proxy = AchievementDataProxy:getInstance()
	
	local result = AchievementDataProxy.achievementContent	
	local aid, sqid, status = proxy:get("current_aid"),proxy:get("current_sqid"),proxy:get("current_status")

	local lab_exp_num = self:getControl(Tag_popup_achievement_content.PANEL_ACHIEVEMENT_CONTENT, Tag_popup_achievement_content.LAB_EXP_NUM)
	local lab_gold_num = self:getControl(Tag_popup_achievement_content.PANEL_ACHIEVEMENT_CONTENT, Tag_popup_achievement_content.LAB_GOLD_NUM)
	local lab_diamond_num = self:getControl(Tag_popup_achievement_content.PANEL_ACHIEVEMENT_CONTENT, Tag_popup_achievement_content.LAB_DIAMOND_NUM)
	
	local AchievementConfig = ConfigManager.getAchievementConfig(aid,sqid)
	local rewardTable = {{exp=AchievementConfig.exp},{gold=AchievementConfig.gold},{diamond=AchievementConfig.diamond},{prestige=AchievementConfig.fame},{badge=AchievementConfig.badge}}
	for k=#rewardTable,1,-1 do
		for m,n in pairs(rewardTable[k]) do
			if n == -1 then
				table.remove(rewardTable,k)
			end
		end
	end
	for k = 1,#rewardTable do
		local img_reward = self:getControl(Tag_popup_achievement_content.PANEL_ACHIEVEMENT_CONTENT, Tag_popup_achievement_content["IMG_REWARD"..k])
		local lab_reward = self:getControl(Tag_popup_achievement_content.PANEL_ACHIEVEMENT_CONTENT,Tag_popup_achievement_content["LAB_REWARD_NUM" .. k])
		for m,n in pairs(rewardTable[k]) do
			img_reward:setSpriteFrame("component_common/img_".. m ..".png")
			lab_reward:setString("X" .. n)
			if m == "prestige" or m == "badge" then
				img_reward:setScale(0.5)
			end
		end
	end

	for k=#rewardTable+1,3 do
		local img_reward = self:getControl(Tag_popup_achievement_content.PANEL_ACHIEVEMENT_CONTENT,Tag_popup_achievement_content["IMG_REWARD"..k])
		local lab_reward = self:getControl(Tag_popup_achievement_content.PANEL_ACHIEVEMENT_CONTENT,Tag_popup_achievement_content["LAB_REWARD_NUM"..k])
		img_reward:setVisible(false)
		lab_reward:setVisible(false)
	end

	for i,v in ipairs(result["pets"]) do
		-- print("=获得宠物===")
		local layoutItem = self:getControl(Tag_popup_achievement_content.PANEL_ACHIEVEMENT_CONTENT,Tag_popup_achievement_content["LAYOUT_ITEM_REWARD"..i])
		local lab_item_num = self:getControl(Tag_popup_achievement_content.PANEL_ACHIEVEMENT_CONTENT,Tag_popup_achievement_content["LAB_ITEM_NUM".. i])
		lab_item_num:setString("")
		local pet = Pet:create()
		pet:set("id",v["id"])
		pet:set("mid",v["mid"])
		pet:set("form",v["form"])
		pet:set("star",v["star"])
		pet:set("aptitude",v["aptitude"])
		local pCell = PetCell:create(pet)
		Utils.addCellToParent(pCell, layoutItem, true)
		Utils.showPetInfoTips(layoutItem, pet:get("mid"), pet:get("form"))
		
		if i == 1 then
			--判断是否首次获得
			local petsTable = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
			local newPet = true
		    for k,v in ipairs(petsTable) do
		    	if v:get("mid")==v["mid"]  then
		    		newPet = false
		    	end
		    end
		    if newPet == true then
		    	__instance:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function() 
		    		WildDataProxy:getInstance():set("newPet_mid",v["mid"])
					WildDataProxy:getInstance():set("newPet_form",v["form"])
					Utils.runUIScene("NewPetPopup")
		    	end),nil))
		    end
		end
	end

	for i,v in ipairs(result["items"]) do
		local layoutItem = self:getControl(Tag_popup_achievement_content.PANEL_ACHIEVEMENT_CONTENT,Tag_popup_achievement_content["LAYOUT_ITEM_REWARD".. i+#result["pets"]])
		local lab_item_num = self:getControl(Tag_popup_achievement_content.PANEL_ACHIEVEMENT_CONTENT,Tag_popup_achievement_content["LAB_ITEM_NUM".. i+#result["pets"]])
		local item = ItemManager.createItem(result["items"][i]["item_type"],result["items"][i]["mid"])
		local itemCell = ItemCell:create(result["items"][i]["item_type"], item)
		Utils.addCellToParent(itemCell, layoutItem, true)
		lab_item_num:setString(result["items"][i]["amount"])
		Utils.showItemInfoTips(layoutItem, item)
	end

	for i=#result["pets"]+#result["items"]+1, 4 do
		local lab_item_num = self:getControl(Tag_popup_achievement_content.PANEL_ACHIEVEMENT_CONTENT,Tag_popup_achievement_content["LAB_ITEM_NUM".. i])
		lab_item_num:setVisible(false)
	end


	local proxy = NormalDataProxy:getInstance()                                        
	self.confirmHandler = proxy.confirmHandler
	local function event_ensure()
		local proxy = NormalDataProxy:getInstance()
       	if self.confirmHandler ~= nil then
			self.confirmHandler()
		end
		NormalDataProxy:getInstance().confirmHandler = nil
		local function judge_player_level()
			Player:getInstance():isPlayerLevelUp()
		end
		Utils.popUIScene(self,judge_player_level)
	end
	local btnEnsure = self:getControl(Tag_popup_achievement_content.PANEL_ACHIEVEMENT_CONTENT,Tag_popup_achievement_content.BTN_FUNCTION)
	btnEnsure:setOnClickScriptHandler(event_ensure)
	TouchEffect.addTouchEffect(self)
end 

