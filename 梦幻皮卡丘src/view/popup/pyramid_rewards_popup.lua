require "view/tagMap/Tag_popup_pyramid_reward"

PyramidRewardsPopup = class("PyramidRewardsPopup", function()
	return Popup:create()
end)

PyramidRewardsPopup.__index = PyramidRewardsPopup
local __instance = nil
local items = {}
local pets = {}

function PyramidRewardsPopup:create()
	local ret = PyramidRewardsPopup.new()
    __instance = ret
    ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
    return ret
end

function PyramidRewardsPopup:getPanel(tagPanel)
	local ret  = nil
	if tagPanel == Tag_popup_pyramid_reward.PANEL_PYRAMID_REWARDS then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function PyramidRewardsPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

local function event_close()
	local proxy = NormalDataProxy:getInstance()
	if proxy.confirmHandler~=nil then
		proxy.confirmHandler()
        PyramidProxy:getInstance():set("reset_has_reward",1)
	end
	proxy.confirmHandler = nil
	Utils.popUIScene(__instance)
end

local function event_adapt_gvrewards(p_convertview,idx)
	local pCell = p_convertview
	if pCell == nil then
		pCell = CGridViewCell:new()
		TuiManager:getInstance():parseCell(pCell,"cell_reward",PATH_POPUP_PYRAMID_REWARD)
		local layoutReward = pCell:getChildByTag(Tag_popup_pyramid_reward.LAYOUT_REWARD)
		layoutReward:setVisible(false)
		local layoutItem = layoutReward:getChildByTag(Tag_popup_pyramid_reward.LAYOUT_ITEM)
		if idx + 1 > #items then
			local pet = Pet:create()
			pet:set("id",pets[idx + 1 - #items]["id"])
			pet:set("mid",pets[idx + 1 - #items]["mid"])
			pet:set("form",pets[idx + 1 - #items]["form"])
			pet:set("aptitude",pets[idx + 1 - #items]["aptitude"])
			pet:set("star",pets[idx + 1 - #items]["star"])
			pet:set("rank",pets[idx + 1 - #items]["rank"])
			local petCell = PetCell:create(pet)
			Utils.addCellToParent(petCell,layoutItem,true)
			Utils.showpetInfoTips(layoutItem, pets[idx + 1 - #items]["mid"], pets[idx + 1 - #items]["form"])
			local petsTable = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
			local newPet = true
		    for k,v in ipairs(petsTable) do
		    	if v:get("mid")==result["pets"][1]["mid"]  then
		    		newPet = false
		    	end
		    end
		    if newPet == true then
    			WildDataProxy:getInstance():set("newPet_mid",pet:get("mid"))
				WildDataProxy:getInstance():set("newPet_form",pet:get("form"))
		    	Utils.runUIScene("NewPetPopup")
		    	newPet = false
		    end
		else
			local item = ItemManager.createItem(items[idx+1]["item_type"], items[idx+1]["mid"])
			local itemCell = ItemCell:create(items[idx+1]["item_type"],item)
			Utils.addCellToParent(itemCell,layoutItem,true)
			local itemNum = layoutReward:getChildByTag(Tag_popup_pyramid_reward.LAB_ITEM_NUM)
			itemNum:setString(items[idx+1]["amount"])
			local sequence = cc.Sequence:create(cc.DelayTime:create((idx+1)*0.3),cc.CallFunc:create(function() 
				layoutReward:setVisible(true)
			 end),cc.ScaleTo:create(0.15,1.3),cc.ScaleTo:create(0.15,1.0))
			layoutReward:runAction(sequence)
			Utils.showItemInfoTips(layoutItem, item)
		end
	end
	return pCell
end

function PyramidRewardsPopup:onLoadScene()
    TuiManager:getInstance():parseScene(self,"panel_pyramid_rewards",PATH_POPUP_PYRAMID_REWARD)
    local btnClose = self:getControl(Tag_popup_pyramid_reward.PANEL_PYRAMID_REWARDS,Tag_popup_pyramid_reward.BTN_CLOSE_REWARDS)
    btnClose:setOnClickScriptHandler(event_close)

    local labBadget = self:getControl(Tag_popup_pyramid_reward.PANEL_PYRAMID_REWARDS,Tag_popup_pyramid_reward.LAB_REWARDS_BADGET)
    local labGold = self:getControl(Tag_popup_pyramid_reward.PANEL_PYRAMID_REWARDS,Tag_popup_pyramid_reward.LAB_REWARDS_GOLD)
    local gvRewards = self:getControl(Tag_popup_pyramid_reward.PANEL_PYRAMID_REWARDS,Tag_popup_pyramid_reward.GV_REWARDS)
  
	local function callback_rewards(result)
		labBadget:setString(result["badget"])
		labGold:setString(result["gold"])
		items = result["items"]
		pets = result["pets"]
		for i,v in ipairs(result["items"]) do
			ItemManager.addItem(v["item_type"], v["mid"], v["amount"])
		end
		for i,v in ipairs(result["pets"]) do
			ItemManager.addPet(v)
		end
		gvRewards:setDragable(false)
		gvRewards:setCountOfCell(#result["items"] + #result["pets"]) 
		gvRewards:setDataSourceAdapterScriptHandler(event_adapt_gvrewards)
		gvRewards:reloadData()
	end
	NetManager.sendCmd("getactivity3rewards",callback_rewards)
end











