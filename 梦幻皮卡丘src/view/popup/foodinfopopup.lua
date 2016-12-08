require "view/tagMap/Tag_ui_pet_attribute"

FoodInfoPopup = class("FoodInfoPopup",function()
	return Popup:create()
end)

FoodInfoPopup.__index = FoodInfoPopup
local __instance = nil

function FoodInfoPopup:create()
	local ret = FoodInfoPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function FoodInfoPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function FoodInfoPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_pet_attribute.PANEL_FOOD_INFO then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function FoodInfoPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_food_info",PATH_UI_PET_ATTRIBUTE)
	local layoutFoodPopup = self:getControl(Tag_ui_pet_attribute.PANEL_FOOD_INFO, Tag_ui_pet_attribute.LAYOUT_FOOD_POPUP)
	local btnFunction = layoutFoodPopup:getChildByTag(Tag_ui_pet_attribute.BTN_FUNCTION)	-- 装备 合成公式 确定 
	local food, status = ItemManager.currentItem[1], ItemManager.currentItem[2]   
	-- local foodItems = ItemManager.getItemsByType(Constants.ITEM_TYPE.MATERIAL)

	local function loadFoodItems()
 		print("loadFoodItems")
 		local function event_function(p_sender)
			print("装备")
			local status = ItemManager.currentItem[2] --status  判断 
			if status ~= 0 then   --点击确定  statsu = 1
				Utils.popUIScene(self)
			elseif self.state ~= nil then
				local function putonfood()
					ItemManager.eraseItemsByType(Constants.ITEM_TYPE.MATERIAL, food, 1)
					local tmpFood = ItemManager.currentItem[3]
					tmpFood:copyProperty(food)
					local foodcell = ItemManager.currentItem[4]
					local touchHandler = function ()
						ItemManager.currentItem = {food, 1, tmpFood, foodcell}  --status == 1
						Utils.runUIScene("FoodInfoPopup")
					end
					foodcell:setTouchEndedNormalHandler(touchHandler)
					Utils.popUIScene(self)
				end
				NetManager.registerNotifyData("putonfood", putonfood)
				local idx, pid = ItemManager.currentItem[5], ItemManager.currentItem[6]
				print("========"..idx,pid)
    			NetManager.sendCmd("putonfood", pid, food:get("fid"), idx) 
			else   
				-- local x = self:getPosition()
				-- print(Constants.OFFSET.POPUP_OFFSETX)
				-- self:setPositionX(x-Constants.OFFSET.POPUP_OFFSETX)
				Utils.popUIScene(self)
				Utils.runUIScene("SubInfoPopup")  -- 进入合成界面
			end	
		end
		btnFunction:setOnClickScriptHandler(event_function)
		local labNum = layoutFoodPopup:getChildByTag(Tag_ui_pet_attribute.LAB_FOOD_NUM)
		local num = ItemManager.getItemAmount(Constants.ITEM_TYPE.MATERIAL, food:get("fid"))
		

		if status ~= 0 then  
			btnFunction:setText("确定")
			
		else   --status == 0
			if num > 0 then
				btnFunction:setText("装备")
				self.state = 1
			else
				btnFunction:setText("合成公式")
			end
		end
		labNum:setString(num)
    end

	NetManager.registerNotifyData("loaditems", loadFoodItems, Constants.ITEM_TYPE.MATERIAL)
    NetManager.sendCmd("loaditems", Constants.ITEM_TYPE.MATERIAL) 
    
	local layout_food = layoutFoodPopup:getChildByTag(Tag_ui_pet_attribute.LAYOUT_FOOD)
	local cell = ItemCell:create(Constants.ITEM_TYPE.MATERIAL,food)
	Utils.addCellToParent(cell, layout_food, true)
	
	local labName = layoutFoodPopup:getChildByTag(Tag_ui_pet_attribute.LAB_FOOD_NAME)
	local name, color = food:getNameString()
	labName:setColor(color)
	labName:setString(name)

	local lab_attribute  = layoutFoodPopup:getChildByTag(Tag_ui_pet_attribute.LAB_ATTRIBUTE)
	lab_attribute:setString("食物的属性")
	local lab_info = layoutFoodPopup:getChildByTag(Tag_ui_pet_attribute.LAB_INFO)
	lab_info:setString("食物简介")
	-- local bg = layoutFoodPopup:getChildByTag(Tag_ui_pet_attribute.IMG9_FOOD_POPUP)
	-- self:setCloseTouchNode(bg)

	TouchEffect.addTouchEffect(self)
end 

