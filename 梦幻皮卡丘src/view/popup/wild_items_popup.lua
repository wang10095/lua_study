
require "view/tagMap/Tag_ui_wild"

WildItemsPopup = class("WildItemsPopup",function()
	return Popup:create()
end)

WildItemsPopup.__index = WildItemsPopup
local __instance = nil

function WildItemsPopup:create()
	local ret = WildItemsPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function WildItemsPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function WildItemsPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_wild.PANEL_BUY_ITEMS then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_close()
	WildDataProxy:getInstance().itemsList = {}
	Utils.popUIScene(__instance)
end

local function event_GetNewPet(node,item)
	local delay = cc.DelayTime:create(0.3)
	local callFunc = cc.CallFunc:create(function() 
		ItemManager.currentPet = item
		Utils.runUIScene("PetIntroducePopup")
	 end)
	local sequence = cc.Sequence:create(delay,callFunc,nil)
	node:runAction(sequence)
end

function WildItemsPopup:onLoadScene()
	print("WildItemsPopup")
	local proxy = WildDataProxy:getInstance()
	local itemsList = proxy.itemsList 
	TuiManager:getInstance():parseScene(self,"panel_buy_items",PATH_UI_WILD)
	local btnClose = self:getControl(Tag_ui_wild.PANEL_BUY_ITEMS, Tag_ui_wild.BTN_CLOSE_BUY)
	btnClose:setOnClickScriptHandler(event_close)
	labRoleTalk = self:getControl(Tag_ui_wild.PANEL_BUY_ITEMS, Tag_ui_wild.LAB_ROLE_TALK)
	labRoleTalk:setString("恭喜您获得以下物品")
	local layoutTenItems = self:getControl(Tag_ui_wild.PANEL_BUY_ITEMS, Tag_ui_wild.LAYOUT_BUY_TEN_ITEMS)
	if proxy:get("buyNum")==1 then
		local pCell = CGridViewCell:new()
		TuiManager:getInstance():parseCell(pCell,"cell_item",PATH_UI_WILD)
		pCell:setAnchorPoint(cc.p(0.5,0.5))
		local size = layoutTenItems:getContentSize()
		pCell:setPosition(cc.p(size.width/2,size.height/2))
		layoutTenItems:addChild(pCell,1)
		local layoutItems = pCell:getChildByTag(Tag_ui_wild.LAYOUT_ITEMS)
		local layoutItem = layoutItems:getChildByTag(Tag_ui_wild.LAYOUT_ITEM_IMAGE)
		if itemsList["id"] ~=nil then --宠物
			AtlasDataProxy:getInstance():set("mid",itemsList["mid"])
			AtlasDataProxy:getInstance():set("form",itemsList["form"])
			-- ItemManager.currentPet = itemsList
			Utils.runUIScene("PetInfoPopup") 
			-- labRoleTalk:setString("新获得神奇宝贝")
			-- local petFormConfig = ConfigManager.getPetFormConfig(itemsList["mid"], itemsList["form"])
			-- local pet = TextureManager.createImg(TextureManager.RES_PATH.PET_AVATAR,petFormConfig.model)
			-- Utils.addCellToParent(pet,layoutItem,true)
			-- layoutItems:setOnTouchBeganScriptHandler(function()
			-- 	AtlasDataProxy:getInstance():set("mid",itemsList["mid"])
			-- 	AtlasDataProxy:getInstance():set("form",itemsList["form"])
			-- 	-- ItemManager.currentPet = itemsList
			-- 	Utils.runUIScene("PetInfoPopup") 
			-- 	return false
			-- end) 
			-- layoutItems:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function() 
			-- 	Utils.runUIScene("NewPetPopup")
			-- end),nil))
		else
			local item = TextureManager.createImg(TextureManager.RES_PATH.ITEM_IMAGE,itemsList["item_type"],itemsList["mid"])
			Utils.addCellToParent(item,layoutItem,true)
		end
	else
		local i = 1
		local width = 110
		local height = 150
		local function event_ten_items()
			if i>10 then
				return  nil
			end
			if i > 5  then
				height = 0
			end
			local pCell = CGridViewCell:new()
			TuiManager:getInstance():parseCell(pCell,"cell_item",PATH_UI_WILD)
			pCell:setAnchorPoint(cc.p(0,0))
			if i<=5 then
				pCell:setPosition(cc.p((i-1)*width,height))
			else
				pCell:setPosition(cc.p((i-6)*width,height))
			end
			layoutTenItems:addChild(pCell,1)

			local layoutItems = pCell:getChildByTag(Tag_ui_wild.LAYOUT_ITEMS)
			local layoutItem = layoutItems:getChildByTag(Tag_ui_wild.LAYOUT_ITEM_IMAGE)
			if itemsList[i]["id"]~=nil then
				local petFormConfig = ConfigManager.getPetFormConfig(itemsList[i]["mid"], itemsList[i]["form"])
				local pet = TextureManager.createImg(TextureManager.RES_PATH.PET_AVATAR,petFormConfig.model)
				Utils.addCellToParent(pet,layoutItem,true)
				layoutItems:setOnTouchBeganScriptHandler(function()
					ItemManager.currentPet = itemsList
					Utils.runUIScene("PetIntroducePopup") 
					return false
				end) 
				layoutItems:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function() 
					local function confirmHandler()
						i = i + 1
						event_ten_items()
					end
					NormalDataProxy:getInstance().confirmHandler = confirmHandler
					Utils.runUIScene("NewPetPopup")
				end),nil))
			else
				local item = TextureManager.createImg(TextureManager.RES_PATH.ITEM_IMAGE,itemsList[i]["item_type"],itemsList[i]["mid"])
				Utils.addCellToParent(item,layoutItem,true)
				local scale1 = cc.ScaleTo:create(0.15,1.3)
				local scale2 = cc.ScaleTo:create(0.15,1.0)
				local callFunc = cc.CallFunc:create(function()
					i = i + 1
					event_ten_items()
				end)
				local sequence = cc.Sequence:create(scale1,scale2,callFunc,nil)
				layoutItems:runAction(sequence)
			end
		end
		event_ten_items()
	end

	local function onNodeEvent(event)
		if "enter" == event then
			self:show()
			proxy:set("isPopup",true)
		end
		if "exit" == event then
			proxy:set("isPopup",false)
			proxy:set("buyNum",0)
		end
	end
	self:registerScriptHandler(onNodeEvent)
end