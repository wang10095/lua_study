require "view/tagMap/Tag_popup_activity1_discount"

ActivityDiscountPopup = class("ActivityDiscountPopup",function()
	return Popup:create()
end)

ActivityDiscountPopup.__index = ActivityDiscountPopup
local __instance = nil
local activity1Type
local score

function ActivityDiscountPopup:create()
	local ret = ActivityDiscountPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function ActivityDiscountPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function ActivityDiscountPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_activity1_discount.PANEL_POPUP_ACTIVITY1_DISCOUNT then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_close(result)
	Activity1StatusProxy:getInstance():set("token",result["token"])
	TipManager.showTip("您什么也没买 当前得分 " .. score)
	local eventDispatcher = __instance:getEventDispatcher()
	local event = cc.EventCustom:new("game_custom_event3")
	eventDispatcher:dispatchEvent(event)
	Utils.popUIScene(__instance)
end

local function event_no_buy()
	NetManager.sendCmd("buyactivity1ernieitem",event_close,activity1Type,Activity1StatusProxy:getInstance():get("token"),0) --不买
end

function ActivityDiscountPopup:onLoadScene()
	score = Activity1StatusProxy:getInstance():get("score")
	TuiManager:getInstance():parseScene(self,"panel_popup_activity1_discount",PATH_POPUP_ACTIVITY1_DISCOUNT)
	local btnClose = self:getControl(Tag_popup_activity1_discount.PANEL_POPUP_ACTIVITY1_DISCOUNT, Tag_popup_activity1_discount.BTN_DISCOUNT_CLOSE)
	btnClose:setOnClickScriptHandler(event_no_buy)

	local id = Activity1StatusProxy:getInstance():get("qid")
	local token = Activity1StatusProxy:getInstance():get("token")
	activity1Type = Activity1StatusProxy:getInstance():get("activity1Type")
	
	for i=1,3 do
		local configGoods = ConfigManager.getActivity1CouponConfig(id["id"..i])
		local layoutGoods = self:getControl(Tag_popup_activity1_discount.PANEL_POPUP_ACTIVITY1_DISCOUNT,Tag_popup_activity1_discount["LAYOUT_DISCOUNT"..i])
		layoutItem = layoutGoods:getChildByTag(Tag_popup_activity1_discount["LAYOUT_ITEM"..i])
		local item = Item:create(configGoods.item[1],configGoods.item[2])
		local itemCell = ItemCell:create(configGoods.item[1],item)
		Utils.addCellToParent(itemCell,layoutItem)
		
		local labItemAmount = layoutGoods:getChildByTag(Tag_popup_activity1_discount["LAB_ITEM"..i.."_AMOUNT"])
		labItemAmount:setString(configGoods.item[3])

		local labItemName = layoutGoods:getChildByTag(Tag_popup_activity1_discount["LAB_ITEM"..i.."_NAME" ])
		local itemName = TextManager.getItemName(configGoods.item[1],configGoods.item[2])
		labItemName:setString(tostring(itemName))
		local function onBuyItem( p_sender )
			local actionBy = cc.ScaleBy:create(0.05, 1.5, 0.8)
			layoutGoods:runAction(cc.Sequence:create(actionBy, actionBy:reverse(),cc.DelayTime:create(0.2)))
			local function buyactivity1ernieitem( result )
				local player = Player:getInstance()
				player:set("gold",result["gold"])
				player:set("diamond",result["diamond"])
				Activity1StatusProxy:getInstance():set("token",result["token"])
				ItemManager.updateItems(result["items"])
				TipManager.showTip(itemName.."购买成功 当前得分 " .. score)
				Utils.popUIScene(self)
				local eventDispatcher = __instance:getEventDispatcher()
				local event = cc.EventCustom:new("game_custom_event3")
				eventDispatcher:dispatchEvent(event)
			end
			NetManager.sendCmd("buyactivity1ernieitem",buyactivity1ernieitem,activity1Type,token,id["id"..i])
			return true
		end
		layoutGoods:setOnTouchBeganScriptHandler(onBuyItem)
	end
	TouchEffect.addTouchEffect(self)
end