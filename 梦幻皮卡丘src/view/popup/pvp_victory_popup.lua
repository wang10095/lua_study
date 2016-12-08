require "view/tagMap/Tag_popup_pvp_victory"

PvpVictoryPopup = class("PvpVictoryPopup",function()
	return Popup:create()
end)

PvpVictoryPopup.__index = PvpVictoryPopup
local __instance = nil

function PvpVictoryPopup:create()
	local ret = PvpVictoryPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function PvpVictoryPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function PvpVictoryPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_pvp_victory.PANEL_PVP_VICTORY then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function  event_close()
	Utils.popUIScene(__instance)
	Utils.replaceScene("SilverChampionshipUI")
end

function PvpVictoryPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_pvp_victory",PATH_POPUP_PVP_VICTORY)
	local layoutWinSpine = self:getControl(Tag_popup_pvp_victory.PANEL_PVP_VICTORY,Tag_popup_pvp_victory.LAYOUT_WIN)
	local function runSpine()
		Spine.addSpine(layoutWinSpine,"battle","win","part1",false)
	end
	layoutWinSpine:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(runSpine)))
	
	local layout_victory = self:getControl(Tag_popup_pvp_victory.PANEL_PVP_VICTORY,Tag_popup_pvp_victory.LAYOUT_VICTORY)
	layout_victory:setScale(0.5)
	layout_victory:setVisible(false)
	local function loadbg()
		layout_victory:setVisible(true)
		layout_victory:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3,1.2),cc.ScaleTo:create(0.1,1)))
	end
	layout_victory:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(loadbg)))

	local btnSure = layout_victory:getChildByTag(Tag_popup_pvp_victory.BTN_SURE)
	btnSure:setOnClickScriptHandler(event_close)

	local result = SilverChampionShipproxy:getInstance().pvpBattleEnd
	local lab_rank_num = layout_victory:getChildByTag(Tag_popup_pvp_victory.LAB_RANK_NUM)
	local lab_fame_num = layout_victory:getChildByTag(Tag_popup_pvp_victory.LAB_FAME_NUM)
	local lab_diamond_num =  layout_victory:getChildByTag(Tag_popup_pvp_victory.LAB_DIAMOND_NUM)
	-- local lab_gold_num = layout_victory:getChildByTag(Tag_popup_pvp_victory.LAB_GOLD_NUM)

	lab_rank_num:setString(result["rank"] .. '名')
	lab_fame_num:setString('+' .. result["fame"])
	lab_diamond_num:setString('+' .. result["chest"]["amount"]) 
	-- lab_gold_num:setString('+' .. 123)

	local layout_reward1 = layout_victory:getChildByTag(Tag_popup_pvp_victory.LAYOUT_REWARD1)
	local layout_reward2 = layout_victory:getChildByTag(Tag_popup_pvp_victory.LAYOUT_REWARD2)
	local layout_reward3 = layout_victory:getChildByTag(Tag_popup_pvp_victory.LAYOUT_REWARD3)
	local img_fame = TextureManager.createImg("item/img_fame.png")
	Utils.addCellToParent(img_fame,layout_reward1,true)

	--钻石 金币 声望 经验药水
	local img_reward = nil
	if result["chest"]["rid"] == 1 then
		img_reward = TextureManager.createImg("item/img_diamond.png")
	elseif result["chest"]["rid"] == 2 then
		img_reward = TextureManager.createImg("item/img_gold.png")
	elseif result["chest"]["rid"] == 3 then
		img_reward = TextureManager.createImg("item/img_fame.png")
	elseif result["chest"]["rid"] == 4 then
		img_reward = TextureManager.createImg("item/item_5_1.png")
	end
	Utils.addCellToParent(img_reward,layout_reward2,true)
	if result["chest"]["rid"] == 4 then
		local item = ItemManager.createItem(5,1)
		local itemCell = ItemCell:create(5,item)
		Utils.showItemInfoTips(layout_reward2, item)
	end

	local img_border1 = TextureManager.createImg(string.format(TextureManager.RES_PATH.BORDER,4))
	local img_border2 = TextureManager.createImg(string.format(TextureManager.RES_PATH.BORDER,4))
	Utils.addCellToParent(img_border1,img_fame,true)
	Utils.addCellToParent(img_border2,img_reward,true)
	

	local player = Player:getInstance()
	player:set("fame",player:get("fame")+result["fame"])
	if result["chest"]["rid"]==1 then
		player:set("diamond",player:get("diamond")+result["chest"]["amount"])
	elseif result["chest"]["rid"]==2 then
		player:set("gold",player:get("gold")+result["chest"]["amount"])
	elseif result["chest"]["rid"]==3 then
		player:set("fame",player:get("fame")+result["chest"]["amount"])
	elseif result["chest"]["rid"]==4 then
		local oldNum = ItemManager.getItemAmount(Constants.ITEM_TYPE.EXP_POTION,1)
		ItemManager.updateItem(Constants.ITEM_TYPE.EXP_POTION,1,result["chest"]["amount"]+oldNum)
	end
end







