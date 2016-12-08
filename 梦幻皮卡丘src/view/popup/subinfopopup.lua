require "view/tagMap/Tag_ui_pet_attribute"

SubInfoPopup = class("SubInfoPopup",function()
	return Popup:create()
end)

SubInfoPopup.__index = SubInfoPopup
local __instance = nil

function SubInfoPopup:create()
	local ret = SubInfoPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function SubInfoPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function SubInfoPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_pet_attribute.PANEL_SUB_INFO then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local layoutSource, tblStack, tblHeight, btnFunction, layoutStack
local layoutFormula = {}
local layoutType = {
	LAYOUT_FORMULA1 = 1,
	LAYOUT_FORMULA2 = 2,
	LAYOUT_FORMULA3 = 3,
	LAYOUT_FORMULA4 = 4,
	LAYOUT_SOURCE = 5
}

local btnState = 
{
	back = 1,
	merge_food = 2,
	merge_scroll = 3
}

function SubInfoPopup:selectVisible(idx)	
	for i = 1, 4 do
		layoutFormula[i]:setVisible(layoutType["LAYOUT_FORMULA"..i] == idx)
	end
	layoutSource:setVisible(layoutType.LAYOUT_SOURCE == idx)
end

function SubInfoPopup:updateLayout(idx)
	local itemCell, item_type = self.itemStack[idx][1], self.itemStack[idx][2]
	self.id = itemCell:get(Constants.ITEM_TYPE_ID[item_type])
	local btnStateValue = {
		[Constants.ITEM_TYPE.MATERIAL] = "merge_food",
		[Constants.ITEM_TYPE.TREASURE_CHEST] = "merge_scroll",
		[Constants.ITEM_TYPE.EXP_POTION] = "back"
	}
	tolua.cast(btnFunction, "ccw.CWidget"):setUserTag(btnState[btnStateValue[item_type]])
	local fmid, fgid, fragment_num 
	if item_type == Constants.ITEM_TYPE.MATERIAL then
		local foodTuple = ConfigManager.getConfig("food","food", itemCell:get("fid"))
		fmid, fgid, fragment_num = foodTuple.fmid, foodTuple.fgid, foodTuple.fragment_num
	elseif item_type == Constants.ITEM_TYPE.TREASURE_CHEST then
		local scrollTuple = ConfigManager.getConfig("scroll","scroll", itemCell:get("scid"))
		fmid = -1
		fgid, fragment_num = scrollTuple.fgid, scrollTuple.fragment_num
	elseif item_type == Constants.ITEM_TYPE.EXP_POTION then
		fmid, fgid = -1, -1
	else
		return
	end

	if fmid == -1 then
		if fgid == -1 then
			self:selectVisible(layoutType.LAYOUT_SOURCE)
			tolua.cast(btnFunction, "ccw.CWidget"):setUserTag(btnState.back)
			btnFunction:setText("返回")
		else
			local materialNum = 1
			self:selectVisible(materialNum)
			local parent = layoutFormula[materialNum]:getChildByTag(Tag_ui_pet_attribute["LAYOUT_FORMULA"..materialNum.."_PARENT"])
			local itemCell = ItemCell:create(item_type,itemCell)
			Utils.addCellToParent(itemCell, parent, true)
			table.insert(self.displayCell, itemCell)

			local child = layoutFormula[materialNum]:getChildByTag(Tag_ui_pet_attribute["LAYOUT_FORMULA"..materialNum.."_CHILD0"])
			local item = ItemManager.createItem(Constants.ITEM_TYPE.EXP_POTION,fgid)
			local cell = ItemCell:create(Constants.ITEM_TYPE.EXP_POTION, item)
			Utils.addCellToParent(cell, child, true)
			table.insert(self.displayCell, cell)
			local amount = ItemManager.getItemAmount(Constants.ITEM_TYPE.EXP_POTION, fgid)
			local labNum = layoutFormula[materialNum]:getChildByTag(Tag_ui_pet_attribute["LAB_FORMULA"..materialNum.."_NUM0"])
			labNum:setString(amount.."/"..fragment_num)
			if amount < fragment_num then
				self.valid = false
			end
			local labCost = layoutFormula[materialNum]:getChildByTag(Tag_ui_pet_attribute["LAB_FORMULA"..materialNum.."_COST_NUM"])
			local tupleCost = ConfigManager.getConfig("quality", "quality", itemCell:getQuality())
			local cost = tupleCost.cost
			labCost:setString(cost)
			local touchCellHandler = function ()
				-- print("itemStackBefore: "..#self.itemStack)
				local t = {}
				t[1] = item
				t[2] = Constants.ITEM_TYPE.EXP_POTION
				table.insert(self.itemStack,t)
				self:updateStack(#self.itemStack)
				-- print("itemStackNum: "..#self.itemStack)
			end
			cell:setTouchEndedNormalHandler(touchCellHandler)

			btnFunction:setText("合成")
		end
	else
		local materialNum = 0
		local formulaTuple = ConfigManager.getConfig("food_merge", "food_merge", fmid)
		for i = 1, 4 do
			if formulaTuple["type"..i] ~= -1 then
				materialNum = materialNum + 1
			end
		end
		self:selectVisible(materialNum)
		-- print("materialNum "..materialNum)
		local parent = layoutFormula[materialNum]:getChildByTag(Tag_ui_pet_attribute["LAYOUT_FORMULA"..materialNum.."_PARENT"])
		local itemCell = ItemCell:create(item_type,itemCell)
		Utils.addCellToParent(itemCell, parent, true)
		table.insert(self.displayCell, itemCell)
		for i = 1, materialNum do
			local child = layoutFormula[materialNum]:getChildByTag(Tag_ui_pet_attribute["LAYOUT_FORMULA"..materialNum.."_CHILD"..(i-1)])
			local item = ItemManager.createItem(formulaTuple["type"..i],formulaTuple["mid"..i])
			local cell = ItemCell:create(formulaTuple["type"..i], item)
			Utils.addCellToParent(cell, child, true)
			table.insert(self.displayCell, cell)
			local amount = ItemManager.getItemAmount(formulaTuple["type"..i], formulaTuple["mid"..i])
			local labNum = layoutFormula[materialNum]:getChildByTag(Tag_ui_pet_attribute["LAB_FORMULA"..materialNum.."_NUM"..(i-1)])
			labNum:setString(amount.."/1")
			if amount < 1 then
				self.valid = false
			end
			local labCost = layoutFormula[materialNum]:getChildByTag(Tag_ui_pet_attribute["LAB_FORMULA"..materialNum.."_COST_NUM"])
			local tupleCost = ConfigManager.getConfig("quality", "quality", itemCell:getQuality())
			local cost = tupleCost.cost
			labCost:setString(cost)
			local touchCellHandler = function ()
				-- print("itemStackBefore: "..#self.itemStack)
				local t = {}
				t[1] = item
				t[2] = formulaTuple["type"..i]
				table.insert(self.itemStack,t)
				self:updateStack(#self.itemStack)
				-- print("itemStackNum: "..#self.itemStack)
			end
			cell:setTouchEndedNormalHandler(touchCellHandler)
		end
		btnFunction:setText("合成")
	end
end

function SubInfoPopup:updateStack(num)
	print("updateStack: "..num)
	self.valid = true
	for _,v in pairs(self.cell) do
		v:removeFromParent()
	end
	self.cell = {}
	for i = 1, num do
		local itemCell, item_type = self.itemStack[i][1], self.itemStack[i][2]
		local pCell = ItemCell:create(item_type,itemCell)
		local touchHandler = function ()
			local cell = pCell
			return function()
				for j = #self.itemStack, 1, -1 do
					print(j.." "..(i))
					if j > i then
						table.remove(self.itemStack, j)
					end
				end
				self:updateStack(#self.itemStack)
			end
		end
		pCell:setTouchEndedClosureHandler(touchHandler)
		local parent = layoutStack:getChildByTag(Tag_ui_pet_attribute["LAYOUT_STACK"..(i-1)])
		Utils.addCellToParent(pCell, parent, true)
		self.cell[i] = pCell
	end
	for _,v in pairs(self.displayCell) do
		v:removeFromParent()
	end
	self.displayCell = {}
	self:updateLayout(num)
end

function SubInfoPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_sub_info",PATH_UI_PET_ATTRIBUTE)
	local function event_function(p_sender)
		local tag = tolua.cast(p_sender, "ccw.CWidget"):getUserTag()
		if tag == btnState.back then  -- fanhu
			Utils.popAllUIScene()
		elseif tag == btnState.merge_food then
			print("merge food "..self.id)
			if self.valid == true then
				NetManager.sendCmd("mergefood", self.id) 
				-- local function mergefood()
				-- 	Utils.runUIScene("SubInfoPopup")
				-- end 
				-- NetManager.registerResponseHandler("mergefood", mergefood)
				-- -- Utils.runUIScene("SubInfoPopup")
				Utils.popAllUIScene()
			else
				lab_need:setVisible(true)
				local sequence = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() lab_need:setVisible(false) end),nil)
				lab_need:runAction(sequence)


				print("no enough materials")
			end
		else
			print("merge scroll "..self.id)
			if self.valid == true then
				NetManager.sendCmd("mergescroll", self.id) 
				Utils.popAllUIScene()
			else
				print("no enough materials")
				local sequence = cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function() lab_need:setVisible(false) end),nil)
				lab_need:runAction(sequence)
				
			end
		end
	end
	local food, status = ItemManager.currentItem[1], ItemManager.currentItem[2]
	btnFunction = self:getControl(Tag_ui_pet_attribute.PANEL_SUB_INFO, Tag_ui_pet_attribute.BTN_INFO_FUNCTION)
	tolua.cast(btnFunction, "ccw.CWidget"):setUserTag(btnState.back)
	btnFunction:setOnClickScriptHandler(event_function)

	for i = 1, 4 do
		local formula = self:getControl(Tag_ui_pet_attribute.PANEL_SUB_INFO, Tag_ui_pet_attribute["LAYOUT_FORMULA"..i])
		layoutFormula[i] = formula
	end
	layoutSource = self:getControl(Tag_ui_pet_attribute.PANEL_SUB_INFO, Tag_ui_pet_attribute.LAYOUT_SOURCE)
	layoutStack = self:getControl(Tag_ui_pet_attribute.PANEL_SUB_INFO,Tag_ui_pet_attribute.LAYOUT_STACK)
	local food = ItemManager.currentItem[1]
	local labName = self:getControl(Tag_ui_pet_attribute.PANEL_SUB_INFO, Tag_ui_pet_attribute.LAB_SUB_INFO_NAME)
	local name, color = food:getNameString()
	labName:setColor(color)
	labName:setString(name)
	
	self.itemStack = {}
	self.cell = {}
	self.displayCell = {}
	self.valid = true
	self.itemStack[1] = {food, Constants.ITEM_TYPE.MATERIAL}
	self:updateStack(1)

	lab_need = self:getControl(Tag_ui_pet_attribute.PANEL_SUB_INFO, Tag_ui_pet_attribute.LAB_NEED)
	lab_need:setVisible(false)

	-- local bg = self:getControl(Tag_ui_pet_attribute.PANEL_SUB_INFO, Tag_ui_pet_attribute.IMG9_SUB_INFO)
	-- self:setCloseTouchNode(bg)
	TouchEffect.addTouchEffect(self)
end 
