--
-- Author: hapigames
-- Date: 2014-11-25 17:19:00
--
require "view/tagMap/Tag_ui_wild"

WildUI = class("WildUI",function()
	return TuiBase:create()
end)

--先执行骨骼动画 再向后端发送数据
WildUI.__index = WildUI
local __instance = nil
local goldTime,diamondTime,remainTime = nil,nil,nil
local isCost = false
WildUI.buyType = 0  --购买类型  1钻石 2 金币
local frontGold = nil
local frontDiamond = nil
local isCaptureing = false --  是否正在扑捉  （特效进行中）
local lab_now_gold ,lab_now_diamond
local petScrol = nil
local layoutDisplay
local scheduleQiu
local layoutWildBack

function WildUI:create()
	local ret = WildUI.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function WildUI:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function WildUI:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_wild.PANEL_WILD then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end
function WildUI:dtor( )
	self:getEventDispatcher():removeEventListener(__instance.listenerNewPet)
end
local function event_alert(num)
	if num ==1 then --钻石不足
		Utils.useRechargeDiamond()
		isCaptureing = false
	else
		Utils.useGoldhand()
		isCaptureing = false
	end
end

local function callback_buy1(result)   --一个物品

	img_can_get_pet:setVisible(false)
	labCaptureItem:setVisible(true)
	labCaptureItem:setScale(0.01)
	layoutDisplay:setVisible(false)
	layoutPet:removeAllChildren()
	layoutSpine:removeAllChildren()

	local proxy = WildDataProxy:getInstance() 
	local function callback()
		local delay = cc.DelayTime:create(1.5)
		labCaptureItem:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3,1.3),cc.ScaleTo:create(0.2,1)))
		proxy:set("buyNum",1)
		if isCost == true then
			Player:getInstance():set("diamond",result["diamond"])
			Player:getInstance():set("gold",result["gold"])
			lab_now_gold:setString(result["gold"])
			lab_now_diamond:setString(result["diamond"])
			if #result["pets"]~=0 then
			    local pet = Pet:create()
		        pet:set("id", result["pets"][1]["id"])
		        pet:set("mid",result["pets"][1]["mid"])
		        pet:set("form", result["pets"][1]["form"])
		        pet:set("aptitude",result["pets"][1]["aptitude"])
		        pet:set("star",result["pets"][1]["star"])
			    local pCell = PetCell:create(pet)
		        Utils.addCellToParent(pCell,layoutPet)
		        local itemApatitude = result["pets"][1]["aptitude"]
		        pCell:setRotation(180)
		        --点击查看宠物信息
    			local listener = cc.EventListenerTouchOneByOne:create()
				listener:registerScriptHandler(function(touch,event)
					local location = pCell:convertTouchToNodeSpace(touch)
					local size = pCell:getContentSize()
					if size and WildDataProxy:getInstance():get("isPopup")==false and location.x > 0 and location.y >0 and location.x < size.width and  location.y< size.height then
						return true
					end
				end,cc.Handler.EVENT_TOUCH_BEGAN )   
				listener:registerScriptHandler(function()
					AtlasDataProxy:getInstance():set("mid",pet:get("mid"))
					AtlasDataProxy:getInstance():set("form",pet:get("form"))
					Utils.runUIScene("PetInfoPopup")
				end,cc.Handler.EVENT_TOUCH_ENDED )  
				local eventDispatcher = pCell:getEventDispatcher() -- 时间派发器 
				eventDispatcher:addEventListenerWithSceneGraphPriority(listener, pCell)
		        --飞出
		        MusicManager.wild_item()
		    	local atlas = "spine/spine_wild/spine_wild_show.atlas"
				local json  = "spine/spine_wild/spine_wild_show.json"
				local spine = sp.SkeletonAnimation:create(json, atlas)
				spine:setAnimation(0, "part1", false)
				Utils.addCellToParent(spine,pCell.layout_effect_up)

		        local pos = layoutPet:getContentSize()
		        pCell:setPosition(cc.p(pos.width/2,0))
		        local move = cc.MoveTo:create(0.3,cc.p(pos.width/2,pos.height/2+60))
    	        local rotate = cc.RotateBy:create(0.3,180)
		        local spawn = cc.Spawn:create(move,rotate)
		        local callfunc1 = cc.CallFunc:create(function()   spine:setAnimation(0, "part2", false)  end)
		        local delay = cc.DelayTime:create(0.5)
		        local callfunc2 = cc.CallFunc:create(function()
		        		local petName  = TextManager.getPetName(result["pets"][1]["mid"] ,result["pets"][1]["form"])
				        local labPetName = CLabel:createWithTTF(petName,"fonts/FZCuYuan/M03S.ttf",25)
				        labPetName:setColor(Constants.APTITUDE_COLOR[result["pets"][1]["aptitude"]])
				        labPetName:setPosition(cc.p(pCell:getContentSize().width/2,-18))
				        pCell:addChild(labPetName,10)

			        	pCell.layout_effect_up:removeAllChildren()
						local atlas = "spine/spine_wild/spine_wild_border.atlas"
						local json  = "spine/spine_wild/spine_wild_border.json"
						local spine = sp.SkeletonAnimation:create(json, atlas)
						spine:setAnimation(0, "part" ..itemApatitude , true)
						Utils.addCellToParent(spine,pCell.layout_effect_up)

			        	local atlas = "spine/spine_wild/spine_wild_light.atlas"
						local json  = "spine/spine_wild/spine_wild_light.json"
						local spine = sp.SkeletonAnimation:create(json, atlas)
						spine:setAnimation(0, "part" .. itemApatitude, true)
						Utils.addCellToParent(spine,pCell.layout_effect_down)

						WildDataProxy:getInstance():set("newPet_mid",result["pets"][1]["mid"])
						WildDataProxy:getInstance():set("newPet_form",result["pets"][1]["form"])
						--判断是否是第一次获得宠物
						local petsTable = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
						local newPet = true
					    for k,v in ipairs(petsTable) do
					    	if v:get("mid")==result["pets"][1]["mid"]  then
					    		newPet = false
					    	end
					    end
					    if newPet == true then
					    	-- Utils.runUIScene("NewPetPopup")
					    end
	    				ItemManager.addPet(result["pets"][1])
		        	end)
		        pCell:runAction(cc.Sequence:create(spawn,callfunc1,delay,callfunc2,nil))
			end
			if #result["items"]~=0 then
				local item = Item:create(result["items"][1]["item_type"],result["items"][1]["mid"])
		    	local itemCell = ItemCell:create(result["items"][1]["item_type"],item)
		    	Utils.addCellToParent(itemCell,layoutPet)
		    	itemCell:setRotation(180)
		    	--点击显示信息
		    	local listener = cc.EventListenerTouchOneByOne:create()
				listener:registerScriptHandler(function(touch,event)
					local location = itemCell:convertTouchToNodeSpace(touch)
					local size = itemCell:getContentSize()
					if size and WildDataProxy:getInstance():get("isPopup")==false and location.x > 0 and location.y >0 and location.x < size.width and  location.y< size.height then
						return true
					end
				end,cc.Handler.EVENT_TOUCH_BEGAN )   
				listener:registerScriptHandler(function()
					ItemManager.currentItem = item
					Utils.runUIScene("IteminfoPopup")
				end,cc.Handler.EVENT_TOUCH_ENDED )  
				local eventDispatcher = itemCell:getEventDispatcher() -- 时间派发器 
				eventDispatcher:addEventListenerWithSceneGraphPriority(listener, itemCell)

		    	local itemApatitude = ConfigManager.getItemConfig(result["items"][1]["item_type"],result["items"][1]["mid"]).quality
		        --加特效
		        MusicManager.wild_item()
		       	local atlas = "spine/spine_wild/spine_wild_show.atlas"
				local json  = "spine/spine_wild/spine_wild_show.json"
				local spine = sp.SkeletonAnimation:create(json, atlas)
				spine:setAnimation(0, "part1", false)
				Utils.addCellToParent(spine,itemCell.layout_effect_up)

		        local pos = layoutPet:getContentSize()
		        itemCell:setPosition(cc.p(pos.width/2,0))
		        local move = cc.MoveTo:create(0.3,cc.p(pos.width/2,pos.height/2+60))
		        local rotate = cc.RotateBy:create(0.3,180)
		        local spawn = cc.Spawn:create(move,rotate)
	
		        local callfunc1 = cc.CallFunc:create(function()   spine:setAnimation(0, "part2", false)  end)
		        local delay = cc.DelayTime:create(0.5)
		        local callfunc2 = cc.CallFunc:create(function()
		        		local itemName  = TextManager.getItemName(result["items"][1]["item_type"],result["items"][1]["mid"])
				        local labItemName = CLabel:createWithTTF(itemName,"fonts/FZCuYuan/M03S.ttf",25)
				        local itemQuilty = TextManager.getItemQuality(result["items"][1]["item_type"],result["items"][1]["mid"])
				        labItemName:setColor(Constants.APTITUDE_COLOR[itemQuilty])
				        labItemName:setPosition(cc.p(itemCell:getContentSize().width/2,-18))
				        itemCell:addChild(labItemName,10)

			        	itemCell.layout_effect_up:removeAllChildren()
						local atlas = "spine/spine_wild/spine_wild_border.atlas"
						local json  = "spine/spine_wild/spine_wild_border.json"
						local spine = sp.SkeletonAnimation:create(json, atlas)
						spine:setAnimation(0, "part" ..itemApatitude , true)
						Utils.addCellToParent(spine,itemCell.layout_effect_up)

			        	local atlas = "spine/spine_wild/spine_wild_light.atlas"
						local json  = "spine/spine_wild/spine_wild_light.json"
						local spine = sp.SkeletonAnimation:create(json, atlas)
						spine:setAnimation(0, "part" .. itemApatitude, true)
						Utils.addCellToParent(spine,itemCell.layout_effect_down)
		        	end)
		        itemCell:runAction(cc.Sequence:create(spawn,callfunc1,delay,callfunc2,nil))
				ItemManager.addItem(result["items"][1]["item_type"], result["items"][1]["mid"], result["items"][1]["amount"]) --更新物品
			end
		else
			if result["pet"]["id"]~= nil then
			    local pet = Pet:create()
		        pet:set("id", result["pet"]["id"])
		        pet:set("mid",result["pet"]["mid"] )
		        pet:set("form", result["pet"]["form"])
		        pet:set("aptitude",result["pet"]["aptitude"])
		        pet:set("star",result["pet"]["star"])
			    local pCell = PetCell:create(pet)
		        Utils.addCellToParent(pCell,layoutPet)
		        local itemApatitude = result["pet"]["aptitude"]
		        pCell:setRotation(180)
		        --点击查看宠物信息
    			local listener = cc.EventListenerTouchOneByOne:create()
				listener:registerScriptHandler(function(touch,event)
					local location = pCell:convertTouchToNodeSpace(touch)
					local size = pCell:getContentSize()
					if size and WildDataProxy:getInstance():get("isPopup")==false and location.x > 0 and location.y >0 and location.x < size.width and  location.y< size.height then
						return true
					end
				end,cc.Handler.EVENT_TOUCH_BEGAN )   
				listener:registerScriptHandler(function()
					AtlasDataProxy:getInstance():set("mid",pet:get("mid"))
					AtlasDataProxy:getInstance():set("form",pet:get("form"))
					Utils.runUIScene("PetInfoPopup")
				end,cc.Handler.EVENT_TOUCH_ENDED )  
				local eventDispatcher = pCell:getEventDispatcher() -- 时间派发器 
				eventDispatcher:addEventListenerWithSceneGraphPriority(listener, pCell)
		        --飞出
		        MusicManager.wild_item()
		    	local atlas = "spine/spine_wild/spine_wild_show.atlas"
				local json  = "spine/spine_wild/spine_wild_show.json"
				local spine = sp.SkeletonAnimation:create(json, atlas)
				spine:setAnimation(0, "part1", false)
				Utils.addCellToParent(spine,pCell.layout_effect_up)

		        local pos = layoutPet:getContentSize()
		        pCell:setPosition(cc.p(pos.width/2,0))
		        local move = cc.MoveTo:create(0.3,cc.p(pos.width/2,pos.height/2+60))
    	        local rotate = cc.RotateBy:create(0.3,180)
		        local spawn = cc.Spawn:create(move,rotate)
		        local callfunc1 = cc.CallFunc:create(function()   spine:setAnimation(0, "part2", false)  end)
		        local delay = cc.DelayTime:create(0.5)
		        local callfunc2 = cc.CallFunc:create(function()
		        		local petName  = TextManager.getPetName(result["pet"]["mid"] ,result["pet"]["form"])
				        local labPetName = CLabel:createWithTTF(petName,"fonts/FZCuYuan/M03S.ttf",25)
				        labPetName:setColor(Constants.APTITUDE_COLOR[result["pet"]["aptitude"]])
				        labPetName:setPosition(cc.p(pCell:getContentSize().width/2,-18))
				        pCell:addChild(labPetName,10)

			        	pCell.layout_effect_up:removeAllChildren()
						local atlas = "spine/spine_wild/spine_wild_border.atlas"
						local json  = "spine/spine_wild/spine_wild_border.json"
						local spine = sp.SkeletonAnimation:create(json, atlas)
						spine:setAnimation(0, "part" ..itemApatitude , true)
						Utils.addCellToParent(spine,pCell.layout_effect_up)

			        	local atlas = "spine/spine_wild/spine_wild_light.atlas"
						local json  = "spine/spine_wild/spine_wild_light.json"
						local spine = sp.SkeletonAnimation:create(json, atlas)
						spine:setAnimation(0, "part" .. itemApatitude, true)
						Utils.addCellToParent(spine,pCell.layout_effect_down)
						-- WildDataProxy:getInstance():set("newPet_mid",result["pet"]["mid"])
						-- WildDataProxy:getInstance():set("newPet_form",result["pet"]["form"])
						local function confirmHandler()
							if __instance.buyType == 2 and GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.DIAMOND_CAPTURE then
								print("dispatchCustomEvent")
								Utils.dispatchCustomEvent("enter_view",{callback = function( )
									Utils.dispatchCustomEvent("event_enter_view",{view = "WildUI",phase = GuideManager.MAIN_GUIDE_PHASES.DIAMOND_CAPTURE,scene = __instance})
								end, params = {view = "view", scene = 6}})
							elseif GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.FINISH_WILD then
								print("finish_wild guide")
								Utils.dispatchCustomEvent("event_enter_view",{view = "WildUI",phase = GuideManager.MAIN_GUIDE_PHASES.FINISH_WILD,scene = __instance})
								local layoutButtom = __instance:getControl(Tag_ui_wild.PANEL_WILD, Tag_ui_wild.LAYOUT_BUTTOM)
								local btnBack = layoutButtom:getChildByTag(Tag_ui_wild.BTN_BACK)
								btnBack:setEnabled(true)
							else
								return
							end
						end
						WildDataProxy:getInstance():set("newPet_mid",result["pet"]["mid"])
						WildDataProxy:getInstance():set("newPet_form",result["pet"]["form"])

						if GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.START_BATTLE then
							GuideManager.guide_pet = 2
							if __instance.listenerNewPet  then
								__instance:getEventDispatcher():removeEventListener(__instance.listenerNewPet)
								__instance.listenerNewPet = nil
							end
							local listener = cc.EventListenerCustom:create("new_pet_2", confirmHandler)
							__instance.listenerNewPet = listener
						    local dispatcher = cc.Director:getInstance():getEventDispatcher()
						    dispatcher:addEventListenerWithFixedPriority(listener, 1)
						else
							GuideManager.guide_pet = 0
							if NormalDataProxy:getInstance().confirmHandler then
								NormalDataProxy:getInstance().confirmHandler = nil
							end
							NormalDataProxy:getInstance().confirmHandler = confirmHandler
						end
						--判断是否首次获得
						local petsTable = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
						local newPet = true
					    for k,v in ipairs(petsTable) do
					    	if v:get("mid")==result["pet"]["mid"] and v:get("form")== result["pet"]["form"] then
					    		newPet = false
					    		break
					    	end
					    end
					    if newPet == true then
					    	Utils.runUIScene("NewPetPopup")
					    end
	    				ItemManager.addPet(result["pet"])
		        	end)
		        pCell:runAction(cc.Sequence:create(spawn,callfunc1,delay,callfunc2,nil))
		        
			end
			if result["item"]["item_type"]~=nil then
				local item = Item:create(result["item"]["item_type"],result["item"]["mid"])
		    	local itemCell = ItemCell:create(result["item"]["item_type"],item)
		    	Utils.addCellToParent(itemCell,layoutPet)
		        itemCell:setRotation(180)
		        --点击显示信息
		        local listener = cc.EventListenerTouchOneByOne:create()
				listener:registerScriptHandler(function(touch,event)
					local location = itemCell:convertTouchToNodeSpace(touch)
					local size = itemCell:getContentSize()
					if size and WildDataProxy:getInstance():get("isPopup")==false and location.x > 0 and location.y >0 and location.x < size.width and  location.y< size.height then
						return true
					end
				end,cc.Handler.EVENT_TOUCH_BEGAN )   
				listener:registerScriptHandler(function()
					ItemManager.currentItem = item
					Utils.runUIScene("IteminfoPopup")
				end,cc.Handler.EVENT_TOUCH_ENDED )  
				local eventDispatcher = itemCell:getEventDispatcher() -- 时间派发器 
				eventDispatcher:addEventListenerWithSceneGraphPriority(listener, itemCell)

		    	local itemApatitude = ConfigManager.getItemConfig(result["item"]["item_type"],result["item"] ["mid"]).quality
		        --加特效
		        MusicManager.wild_item()
		       	local atlas = "spine/spine_wild/spine_wild_show.atlas"
				local json  = "spine/spine_wild/spine_wild_show.json"
				local spine = sp.SkeletonAnimation:create(json, atlas)
				spine:setAnimation(0, "part1", false)
				Utils.addCellToParent(spine,itemCell.layout_effect_up)

		        local pos = layoutPet:getContentSize()
		        itemCell:setPosition(cc.p(pos.width/2,0))
		        local move = cc.MoveTo:create(0.3,cc.p(pos.width/2,pos.height/2+60))
		        local rotate = cc.RotateBy:create(0.3,180)
		        local spawn = cc.Spawn:create(move,rotate)

		        local callfunc1 = cc.CallFunc:create(function()   spine:setAnimation(0, "part2", false)  end)
		        local delay = cc.DelayTime:create(0.5)
		        local callfunc2 = cc.CallFunc:create(function()
	        		 	local itemName  = TextManager.getItemName(result["item"]["item_type"],result["item"]["mid"])
				        local labItemName = CLabel:createWithTTF(itemName,"fonts/FZCuYuan/M03S.ttf",25)
				        local itemQuilty = TextManager.getItemQuality(result["item"]["item_type"],result["item"]["mid"])
				        labItemName:setColor(Constants.APTITUDE_COLOR[itemQuilty])
				        labItemName:setPosition(cc.p(itemCell:getContentSize().width/2,-18))
				        itemCell:addChild(labItemName,10)

			        	itemCell.layout_effect_up:removeAllChildren()
						local atlas = "spine/spine_wild/spine_wild_border.atlas"
						local json  = "spine/spine_wild/spine_wild_border.json"
						local spine = sp.SkeletonAnimation:create(json, atlas)
						spine:setAnimation(0, "part" ..itemApatitude , true)
						Utils.addCellToParent(spine,itemCell.layout_effect_up)

			        	local atlas = "spine/spine_wild/spine_wild_light.atlas"
						local json  = "spine/spine_wild/spine_wild_light.json"
						local spine = sp.SkeletonAnimation:create(json, atlas)
						spine:setAnimation(0, "part" .. itemApatitude, true)
						Utils.addCellToParent(spine,itemCell.layout_effect_down)
		        	end)
		        itemCell:runAction(cc.Sequence:create(spawn,callfunc1,delay,callfunc2,nil))
				ItemManager.addItem(result["item"]["item_type"], result["item"]["mid"], result["item"]["amount"])
			end
			if __instance.buyType == 1 then
				local freeTime = ConfigManager.getCardCommonConfig('free_diamond_times')
				diamondTime = freeTime*60  --重置时间
				__instance:LayoutSeniorFront()  --全部刷新界面 保证数据同步
				__instance:LayoutSeniorBack()   
				__instance:LayoutWildFront()
				__instance:LayoutWildBack()
			else
				remainTime = remainTime -1 --免费次数 
				local freeTime = ConfigManager.getCardCommonConfig('free_gold_times')
				goldTime = freeTime*60
				__instance:LayoutSeniorFront() --全部刷新界面 保证数据同步
				__instance:LayoutSeniorBack()
				__instance:LayoutWildFront()
				__instance:LayoutWildBack() 
			end
		end
		isCost = false
	end 
	local function runSpine( )
		MusicManager.subMusicVolume(1)
		MusicManager.wild()
		local atlas = TextureManager.RES_PATH.CAPTURE..".atlas"
		local json = TextureManager.RES_PATH.CAPTURE..".json"
		local spine = sp.SkeletonAnimation:create(json, atlas, 1)
		if __instance.buyType  == 2 then
			spine:setAnimation(0, "spine_wild_wildball", false)
		else
			spine:setAnimation(0, "spine_wild_masterball", false)
		end
		local winSize = layoutSpine:getContentSize()
		spine:setPosition(cc.p(winSize.width/2,winSize.height/2))
		layoutSpine:addChild(spine,5)
	end
	__instance:runAction(cc.Sequence:create(cc.CallFunc:create(runSpine),cc.DelayTime:create(4),cc.CallFunc:create(callback),cc.DelayTime:create(1),cc.CallFunc:create(function()
		MusicManager.addMusicVolume(1)
		isCaptureing = false
		local btnBuy1 = layoutWildBack:getChildByTag(Tag_ui_wild.BTN_WILD_BUY1)
		local btnBuy10 = layoutWildBack:getChildByTag(Tag_ui_wild.BTN_WILD_BUY10)
		local btnSBuy1 = layoutSeniorBack:getChildByTag(Tag_ui_wild.BTN_SENIOR_BUY1)
		local btnSBuy10 = layoutSeniorBack:getChildByTag(Tag_ui_wild.BTN_SENIOR_BUY10)
		local layoutButtom = __instance:getControl(Tag_ui_wild.PANEL_WILD, Tag_ui_wild.LAYOUT_BUTTOM)
		local btnBack = layoutButtom:getChildByTag(Tag_ui_wild.BTN_BACK)
		btnBack:setEnabled(true)
		btnBuy1:setEnabled(true)
		btnBuy10:setEnabled(true)
		btnSBuy1:setEnabled(true)
		btnSBuy10:setEnabled(true)
	end)))
end

local function callback_buy10(result)--购买十个物品
	lab_now_gold:setString(result["gold"])
	lab_now_diamond:setString(result["diamond"])
	img_can_get_pet:setVisible(false)
	labCaptureItem:setVisible(true)
	labCaptureItem:setScale(0.01)
	labCaptureItem:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3,1.3),cc.ScaleTo:create(0.2,1)))
	layoutDisplay:setVisible(false)
	layoutPet:removeAllChildren()
	layoutSpine:removeAllChildren()
	
	Player:getInstance():set("diamond",result["diamond"])
	Player:getInstance():set("gold",result["gold"])
	local proxy = WildDataProxy:getInstance() 
	proxy:set("buyNum",10)
	local itemsList = {}
	local array = cc.DelayTime:create(0)
	local callback = function ()
	end
	if #result["pets"]~=0 then
		for i,v in ipairs(result["pets"]) do
			-- ItemManager.addPet(v)
			table.insert(itemsList, v)
		end
	end
	if #result["items"]~=0 then
		for i,v in ipairs(result["items"]) do
			ItemManager.addItem(v["item_type"], v["mid"], v["amount"])
			table.insert(itemsList,v)
		end
	end
	local i = 1
	local width = 120
	local height = 300
	local function event_ten_items()
		if i>10 then
			isCaptureing = false
			local btnBuy1 = layoutWildBack:getChildByTag(Tag_ui_wild.BTN_WILD_BUY1)
			local btnBuy10 = layoutWildBack:getChildByTag(Tag_ui_wild.BTN_WILD_BUY10)
			local btnSBuy1 = layoutSeniorBack:getChildByTag(Tag_ui_wild.BTN_SENIOR_BUY1)
			local btnSBuy10 = layoutSeniorBack:getChildByTag(Tag_ui_wild.BTN_SENIOR_BUY10)
			local layoutButtom = __instance:getControl(Tag_ui_wild.PANEL_WILD, Tag_ui_wild.LAYOUT_BUTTOM)
			local btnBack = layoutButtom:getChildByTag(Tag_ui_wild.BTN_BACK)
			btnBack:setEnabled(true)
			btnBuy1:setEnabled(true)
			btnBuy10:setEnabled(true)
			btnSBuy1:setEnabled(true)
			btnSBuy10:setEnabled(true)
			return  nil
		end
		if i > 5  then
			height = 0
		end
		local pCell = CGridViewCell:new()
		TuiManager:getInstance():parseCell(pCell,"cell_item",PATH_UI_WILD)
		pCell:setAnchorPoint(cc.p(0,0))
		local Pos = layoutPet:getContentSize()
		pCell:setPosition(cc.p(Pos.width/2,0))
		layoutPet:addChild(pCell,3)

		local layoutItems = pCell:getChildByTag(Tag_ui_wild.LAYOUT_ITEMS)
		local layoutItem = layoutItems:getChildByTag(Tag_ui_wild.LAYOUT_ITEM_IMAGE)
		if itemsList[i]["id"]~=nil then
		    local pet = Pet:create()
	        pet:set("id", itemsList[i]["id"])
	        pet:set("mid",itemsList[i]["mid"] )
	        pet:set("form", itemsList[i]["form"])
	        pet:set("aptitude",itemsList[i]["aptitude"])
	        pet:set("star",itemsList[i]["star"])
		    local pCell = PetCell:create(pet)
	        Utils.addCellToParent(pCell,layoutItem)

	        local itemApatitude = itemsList[i]["aptitude"] --宠物资质
	        pCell:setRotation(180)

			local listener = cc.EventListenerTouchOneByOne:create()
			listener:registerScriptHandler(function(touch,event)
				local location = pCell:convertTouchToNodeSpace(touch)
				local size = pCell:getContentSize()
				if size and WildDataProxy:getInstance():get("isPopup")==false and location.x > 0 and location.y >0 and location.x < size.width and  location.y< size.height then
					return true
				end
			end,cc.Handler.EVENT_TOUCH_BEGAN )   
			listener:registerScriptHandler(function()
				AtlasDataProxy:getInstance():set("mid",pet:get("mid"))
				AtlasDataProxy:getInstance():set("form",pet:get("form"))
				Utils.runUIScene("PetInfoPopup")
			end,cc.Handler.EVENT_TOUCH_ENDED )  
			local eventDispatcher = pCell:getEventDispatcher() -- 时间派发器 
			eventDispatcher:addEventListenerWithSceneGraphPriority(listener, pCell)

			layoutItems:setPositionX(layoutItems:getPositionX()-layoutItems:getContentSize().width/2)
			local xx,yy
			if i<=5 then
				xx = -200+(i-1)*width
				yy = height-100
			else
				xx = -200+(i-6)*width
				yy = height+50
			end
			moveTo = cc.MoveTo:create(0.2,cc.p(xx,yy))

			MusicManager.wild_item()
			local atlas = "spine/spine_wild/spine_wild_show.atlas"
			local json  = "spine/spine_wild/spine_wild_show.json"
			local spine = sp.SkeletonAnimation:create(json, atlas)
			spine:setAnimation(0, "part1", false)
			Utils.addCellToParent(spine,pCell.layout_effect_up)

	        local pos = layoutItems:getContentSize()
	        pCell:setPosition(cc.p(pos.width/2,0))
	        local rotate = cc.RotateBy:create(0.3,180)
	        local spawn = cc.Spawn:create(moveTo,rotate)
	        local callfunc1 = cc.CallFunc:create(function()   spine:setAnimation(0, "part2", false)  end)
	        local delay = cc.DelayTime:create(0.5)
	        local callfunc2 = cc.CallFunc:create(function()
		        	pCell.layout_effect_up:removeAllChildren()
    		        local petName  = TextManager.getPetName(itemsList[i]["mid"] ,itemsList[i]["form"])
			        local labPetName = CLabel:createWithTTF(petName,"fonts/FZCuYuan/M03S.ttf",25)
			        labPetName:setColor(Constants.APTITUDE_COLOR[itemsList[i]["aptitude"]])
			        labPetName:setPosition(cc.p(pCell:getContentSize().width/2,-18))
			        pCell:addChild(labPetName,10)

					local atlas = "spine/spine_wild/spine_wild_border.atlas"
					local json  = "spine/spine_wild/spine_wild_border.json"
					local spine = sp.SkeletonAnimation:create(json, atlas)
					spine:setAnimation(0, "part" ..itemApatitude , true)
					Utils.addCellToParent(spine,pCell.layout_effect_up)

		        	local atlas = "spine/spine_wild/spine_wild_light.atlas"
					local json  = "spine/spine_wild/spine_wild_light.json"
					local spine = sp.SkeletonAnimation:create(json, atlas)
					spine:setAnimation(0, "part" .. itemApatitude, true)
					-- Utils.addCellToParent(spine,pCell.layout_effect_down)
					spine:setPosition(cc.p(xx+20,yy+15))
					layoutPet:addChild(spine)

					local function confirmHandler()
						i = i + 1
						event_ten_items()
					end
					WildDataProxy:getInstance():set("newPet_mid",itemsList[i]["mid"])
					WildDataProxy:getInstance():set("newPet_form",itemsList[i]["form"])
					GuideManager.guide_pet = 0
					if NormalDataProxy:getInstance().confirmHandler then
						NormalDataProxy:getInstance().confirmHandler = nil
					end
					NormalDataProxy:getInstance().confirmHandler = confirmHandler

					local petsTable = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
					local newPet = true
				    for k,v in ipairs(petsTable) do
				    	if v:get("mid") == itemsList[i]["mid"] then
				    		newPet = false
				    	end
				    end
				    ItemManager.addPet(itemsList[i]) --加入宠物
				    if newPet == true then
				    	Utils.runUIScene("NewPetPopup")
				    else
				    	i = i + 1
						event_ten_items()
				    end
	        	end)
	        pCell:runAction(cc.Sequence:create(spawn,callfunc1,delay,callfunc2,nil))
		else
			local item = Item:create(itemsList[i]["item_type"],itemsList[i]["mid"])
	    	local itemCell = ItemCell:create(itemsList[i]["item_type"],item)
	    	Utils.addCellToParent(itemCell,layoutItem)
	    	itemCell:setRotation(180)
	    	--点击查看物品信息
			local listener = cc.EventListenerTouchOneByOne:create()
			listener:registerScriptHandler(function(touch,event)
				local location = itemCell:convertTouchToNodeSpace(touch)
				local size = itemCell:getContentSize()
				if size and WildDataProxy:getInstance():get("isPopup")==false and location.x > 0 and location.y >0 and location.x < size.width and  location.y< size.height then
					return true
				end
			end,cc.Handler.EVENT_TOUCH_BEGAN )   
			listener:registerScriptHandler(function()
				ItemManager.currentItem = item
				Utils.runUIScene("IteminfoPopup")
			end,cc.Handler.EVENT_TOUCH_ENDED )  
			local eventDispatcher = itemCell:getEventDispatcher() -- 时间派发器 
			eventDispatcher:addEventListenerWithSceneGraphPriority(listener, itemCell)
	   
	    	local itemApatitude = ConfigManager.getItemConfig(itemsList[i]["item_type"],itemsList[i]["mid"]).quality
			layoutItems:setPositionX(layoutItems:getPositionX()-layoutItems:getContentSize().width/2)
			local xx,yy
			if i<=5 then
				xx = -200+(i-1)*width
				yy = height-100
			else
				xx = -200+(i-6)*width
				yy = height+50
			end
			moveTo = cc.MoveTo:create(0.2,cc.p(xx,yy))

			MusicManager.wild_item()
			local atlas = "spine/spine_wild/spine_wild_show.atlas"
			local json  = "spine/spine_wild/spine_wild_show.json"
			local spine = sp.SkeletonAnimation:create(json, atlas)
			spine:setAnimation(0, "part1", false)
			Utils.addCellToParent(spine,itemCell.layout_effect_up)

	        local pos = layoutPet:getContentSize()
	        itemCell:setPosition(cc.p(pos.width/2,0))
	        local rotate = cc.RotateBy:create(0.3,180)
	        local spawn = cc.Spawn:create(moveTo,rotate)
	        local callfunc1 = cc.CallFunc:create(function()   spine:setAnimation(0, "part2", false)  end)
	        local delay = cc.DelayTime:create(0.5)
	        local callfunc2 = cc.CallFunc:create(function()
        		 	local itemName  = TextManager.getItemName(itemsList[i]["item_type"],itemsList[i]["mid"])
			        local labItemName = CLabel:createWithTTF(itemName,"fonts/FZCuYuan/M03S.ttf",25)
			        local itemQuilty = TextManager.getItemQuality(itemsList[i]["item_type"],itemsList[i]["mid"])
				    labItemName:setColor(Constants.APTITUDE_COLOR[itemQuilty])
			        labItemName:setPosition(cc.p(itemCell:getContentSize().width/2,-18))
			        itemCell:addChild(labItemName,10)

		        	itemCell.layout_effect_up:removeAllChildren()
					local atlas = "spine/spine_wild/spine_wild_border.atlas"
					local json  = "spine/spine_wild/spine_wild_border.json"
					local spine = sp.SkeletonAnimation:create(json, atlas)
					spine:setAnimation(0, "part" ..itemApatitude , true)
					Utils.addCellToParent(spine,itemCell.layout_effect_up)

		        	local atlas = "spine/spine_wild/spine_wild_light.atlas"
					local json  = "spine/spine_wild/spine_wild_light.json"
					local spine = sp.SkeletonAnimation:create(json, atlas)
					spine:setAnimation(0, "part" .. itemApatitude, true)
					-- Utils.addCellToParent(spine,itemCell.layout_effect_down)
					spine:setPosition(cc.p(xx+20,yy+15))
					layoutPet:addChild(spine)
					i = i + 1
					event_ten_items()
					
	        	end)
	        itemCell:runAction(cc.Sequence:create(spawn,callfunc1,delay,callfunc2,nil))
		end
		
	end
	-- local layoutSpine = __instance:getControl(Tag_ui_wild.PANEL_WILD,Tag_ui_wild.LAYOUT_SPINE)
	
	-- Utils.runUIScene("WildItemsPopup")
	local function runSpine( )  --购买十次
		MusicManager.subMusicVolume(1)
		MusicManager.wild()
		local atlas = TextureManager.RES_PATH.CAPTURE..".atlas"
		local json = TextureManager.RES_PATH.CAPTURE..".json"
		local spine = sp.SkeletonAnimation:create(json, atlas, 1)
		if __instance.buyType  == 2 then
			spine:setAnimation(0, "spine_wild_wildball", false)
		else
			spine:setAnimation(0, "spine_wild_masterball", false)
		end
		local winSize = layoutSpine:getContentSize()
		spine:setPosition(cc.p(winSize.width/2,winSize.height/2))
		spine:retain()
		layoutSpine:addChild(spine,5)
	end
	local function initUI()
		MusicManager.addMusicVolume(1)
		isCaptureing = false
		local btnBuy1 = layoutWildBack:getChildByTag(Tag_ui_wild.BTN_WILD_BUY1)
		local btnBuy10 = layoutWildBack:getChildByTag(Tag_ui_wild.BTN_WILD_BUY10)
		local btnSBuy1 = layoutSeniorBack:getChildByTag(Tag_ui_wild.BTN_SENIOR_BUY1)
		local btnSBuy10 = layoutSeniorBack:getChildByTag(Tag_ui_wild.BTN_SENIOR_BUY10)
		local layoutButtom = __instance:getControl(Tag_ui_wild.PANEL_WILD, Tag_ui_wild.LAYOUT_BUTTOM)
		local btnBack = layoutButtom:getChildByTag(Tag_ui_wild.BTN_BACK)
		btnBack:setEnabled(true)
		btnBuy1:setEnabled(true)
		btnBuy10:setEnabled(true)
		btnSBuy1:setEnabled(true)
		btnSBuy10:setEnabled(true)
	end
	__instance:runAction(cc.Sequence:create(cc.CallFunc:create(runSpine),cc.DelayTime:create(4),cc.CallFunc:create(event_ten_items),cc.DelayTime:create(11),cc.CallFunc:create(initUI)))
end

function WildUI:LayoutWildFront()
	local canTouch = true
	local wildFreeNum = layoutWildBack:getChildByTag(Tag_ui_wild.LAB_WILD_FREE_NUM)
	wildFreeNum:retain()
	local lab_gold_time = layoutWildFront:getChildByTag(Tag_ui_wild.LAB_WILD_TIME)
	lab_gold_time:retain()
	if remainTime == 0 then --免费次数用完
	 	lab_gold_time:setColor(cc.c3b(255,255,255))
	 	lab_gold_time:setScale(1)
		lab_gold_time:setString("今日免费次数已无")
	else  --还有免费次数
		if goldTime == 0 then
			lab_gold_time:setColor(cc.c3b(0,255,0))
			lab_gold_time:setVerticalAlignment(1)
			lab_gold_time:setScale(1.5)
			lab_gold_time:setString("免 费")
		else
			local hh,mm,ss = Utils.parseTime(goldTime)
			hh,mm,ss = string.format("%.2d",hh),string.format("%.2d",mm),string.format("%.2d",ss)
			lab_gold_time:setColor(cc.c3b(255,255,255))
			lab_gold_time:setScale(1)
			lab_gold_time:setString(hh..":" ..mm.. ":" ..ss.."后免费")

			local function tick()
				goldTime = goldTime -1
				if goldTime == 0  then
					cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleGold)
					lab_gold_time:setColor(cc.c3b(0,255,0))
					lab_gold_time:setVerticalAlignment(1)
					lab_gold_time:setScale(1.5)
					lab_gold_time:setString("免 费")
					__instance:LayoutWildBack() --刷新背面  同步数据
				else
					local hh,mm,ss = Utils.parseTime(goldTime)
					hh,mm,ss = string.format("%.2d",hh),string.format("%.2d",mm),string.format("%.2d",ss)
					lab_gold_time:setColor(cc.c3b(255,255,255))
					lab_gold_time:setScale(1)
					lab_gold_time:setString(hh..":" ..mm.. ":" ..ss.."后免费")
					wildFreeNum:setString(hh..":" ..mm.. ":" ..ss.."后免费")
				end	
			end
			if  scheduleGold then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleGold)
			end
			scheduleGold = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 1, false)
		end
    end
    layoutWildFront:setOnTouchBeganScriptHandler(function()
    	if isCaptureing == true then
    		return false
    	else
	    	local sequence1 = cc.Sequence:create(cc.OrbitCamera:create(0.3,1,0,0,90,0,0),cc.CallFunc:create(function()
				-- frontGold = false
				self:LayoutWildBack()
				layoutWildFront:setVisible(false)
				layoutWildBack:setVisible(true)
			end),nil)
			layoutWildFront:runAction(sequence1)
			local sequence2 = cc.Sequence:create(cc.DelayTime:create(0.3),cc.OrbitCamera:create(0.3,1,0,-90,90,0,0),nil)
			layoutWildBack:runAction(sequence2)
		end
		return false
    end)
end

function WildUI:LayoutWildBack()
	local wildFreeNum = layoutWildBack:getChildByTag(Tag_ui_wild.LAB_WILD_FREE_NUM)
	local gold1Num = layoutWildBack:getChildByTag(Tag_ui_wild.LAB_GOLD1_NUM)
	local gold10Num =  layoutWildBack:getChildByTag(Tag_ui_wild.LAB_GOLD10_NUM)
	local cardGoldOne = ConfigManager.getCardCommonConfig('gold_singgle_price')
	local cardGoldTen  = ConfigManager.getCardCommonConfig('gold_ten_price')
	local CangoldNum = ConfigManager.getCardCommonConfig('day_free_nums')
	if remainTime == 0 then  --免费次数用完
		wildFreeNum:setString("今日免费次数已无")
		gold1Num:setString(cardGoldOne)
	else  
		if goldTime == 0 then   --免费
			wildFreeNum:setString("免费次数" .. remainTime .. "/" .. CangoldNum)
			gold1Num:setString("免费")
		else
			gold1Num:setString(cardGoldOne)
		end
	end
	
	gold10Num:setString(cardGoldTen)
	
	local btnBuy1 = layoutWildBack:getChildByTag(Tag_ui_wild.BTN_WILD_BUY1)
	btnBuy1:setEnabled(true)
	local function event_gold_buy1() --购买1次
		if isCaptureing == true  then
			return
		end
		
		if goldTime <= 0 then
			isCost = false
			__instance.buyType = 2
			NetManager.sendCmd("freedraw",callback_buy1,2)
			local btnBuy1 = layoutWildBack:getChildByTag(Tag_ui_wild.BTN_WILD_BUY1)
			btnBuy1:setEnabled(false)
			local btnBuy10 = layoutWildBack:getChildByTag(Tag_ui_wild.BTN_WILD_BUY10)
			btnBuy10:setEnabled(false)
			local btnSBuy1 = layoutSeniorBack:getChildByTag(Tag_ui_wild.BTN_SENIOR_BUY1)
			btnSBuy1:setEnabled(false)
			local btnSBuy10 = layoutSeniorBack:getChildByTag(Tag_ui_wild.BTN_SENIOR_BUY10)
			btnSBuy10:setEnabled(false)
			local layoutButtom = __instance:getControl(Tag_ui_wild.PANEL_WILD, Tag_ui_wild.LAYOUT_BUTTOM)
			local btnBack = layoutButtom:getChildByTag(Tag_ui_wild.BTN_BACK)
			btnBack:setEnabled(false)
			isCaptureing = true 
		else
			
			if Player:getInstance():get("gold")<cardGoldOne then
				event_alert(2)
			else
				__instance.buyType = 2
				isCost = true
				NetManager.sendCmd("draw",callback_buy1,2,1)
				local btnBuy1 = layoutWildBack:getChildByTag(Tag_ui_wild.BTN_WILD_BUY1)
				btnBuy1:setEnabled(false)
				local btnBuy10 = layoutWildBack:getChildByTag(Tag_ui_wild.BTN_WILD_BUY10)
				btnBuy10:setEnabled(false)
				local btnSBuy1 = layoutSeniorBack:getChildByTag(Tag_ui_wild.BTN_SENIOR_BUY1)
				btnSBuy1:setEnabled(false)
				local btnSBuy10 = layoutSeniorBack:getChildByTag(Tag_ui_wild.BTN_SENIOR_BUY10)
				btnSBuy10:setEnabled(false)
				local layoutButtom = __instance:getControl(Tag_ui_wild.PANEL_WILD, Tag_ui_wild.LAYOUT_BUTTOM)
				local btnBack = layoutButtom:getChildByTag(Tag_ui_wild.BTN_BACK)
				btnBack:setEnabled(false)
				isCaptureing = true 
			end
		end
	end
	btnBuy1:setOnClickScriptHandler(event_gold_buy1)
	

	local btnBuy10 = layoutWildBack:getChildByTag(Tag_ui_wild.BTN_WILD_BUY10)
	local function event_gold_buy10() --购买十次

		if isCaptureing == true then
			return 
		end
		if Player:getInstance():get("gold")<cardGoldTen then
			event_alert(2)
		else
			isCaptureing = true 
			__instance.buyType = 2
			NetManager.sendCmd("draw",callback_buy10,2,10)
			local btnBuy1 = layoutWildBack:getChildByTag(Tag_ui_wild.BTN_WILD_BUY1)
			btnBuy1:setEnabled(false)
			local btnBuy10 = layoutWildBack:getChildByTag(Tag_ui_wild.BTN_WILD_BUY10)
			btnBuy10:setEnabled(false)
			local btnSBuy1 = layoutSeniorBack:getChildByTag(Tag_ui_wild.BTN_SENIOR_BUY1)
			btnSBuy1:setEnabled(false)
			local btnSBuy10 = layoutSeniorBack:getChildByTag(Tag_ui_wild.BTN_SENIOR_BUY10)
			btnSBuy10:setEnabled(false)
			local layoutButtom = __instance:getControl(Tag_ui_wild.PANEL_WILD, Tag_ui_wild.LAYOUT_BUTTOM)
			local btnBack = layoutButtom:getChildByTag(Tag_ui_wild.BTN_BACK)
			btnBack:setEnabled(false)
		end
	end
	btnBuy10:setOnClickScriptHandler(event_gold_buy10)
	
end

function WildUI:LayoutSeniorFront()
	local canTouch = true
	local seniorFreeNum = layoutSeniorBack:getChildByTag(Tag_ui_wild.LAB_SENIOR_FREE_NUM)
	local lab_diamond_time = layoutSeniorFront:getChildByTag(Tag_ui_wild.LAB_SENIOR_TIME)

	if diamondTime == 0 then
		lab_diamond_time:setColor(cc.c3b(0,255,0))
		lab_diamond_time:setVerticalAlignment(1)
		lab_diamond_time:setScale(1.5)
		lab_diamond_time:setString("免 费")
	else
		local hh,mm,ss = Utils.parseTime(diamondTime)
		hh,mm,ss = string.format("%.2d",hh),string.format("%.2d",mm),string.format("%.2d",ss)
		lab_diamond_time:setColor(cc.c3b(255,255,255))
		lab_diamond_time:setScale(1)
		lab_diamond_time:setString(hh..":" ..mm.. ":" ..ss.."后免费")
		-- seniorFreeNum:setString(hh..":" ..mm.. ":" ..ss.."后免费")
		local function tick()
			diamondTime = diamondTime -1
			if diamondTime == 0  then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleDiamond)
				lab_diamond_time:setColor(cc.c3b(0,255,0))
				lab_diamond_time:setVerticalAlignment(1)
				lab_diamond_time:setScale(1.5)
				lab_diamond_time:setString("免 费")
				seniorFreeNum:setString("本次免费")
				__instance:LayoutSeniorBack()
			else
				local hh,mm,ss = Utils.parseTime(diamondTime)
				hh,mm,ss = string.format("%.2d",hh),string.format("%.2d",mm),string.format("%.2d",ss)
				lab_diamond_time:setColor(cc.c3b(255,255,255))
				lab_diamond_time:setScale(1)
				lab_diamond_time:setString(hh..":" ..mm.. ":" ..ss.."后免费")
				seniorFreeNum:setString(hh..":" ..mm.. ":" ..ss.."后免费")
			end
		end
		if  scheduleDiamond then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleDiamond)
		end
		scheduleDiamond = cc.Director:getInstance():getScheduler():scheduleScriptFunc(tick, 1, false)
	end
	
	layoutSeniorFront:setOnTouchBeganScriptHandler(function( p_sender )
		if isCaptureing == true then
			return false
		else
			local sequence3 = cc.Sequence:create(cc.OrbitCamera:create(0.3,1,0,0,90,0,0),cc.CallFunc:create(function()
				-- frontDiamond = false
				self:LayoutSeniorBack()
				layoutSeniorFront:setVisible(false)
				layoutSeniorBack:setVisible(true)
			end),nil)
			layoutSeniorFront:runAction(sequence3)
			local sequence4 = cc.Sequence:create(cc.DelayTime:create(0.3),cc.OrbitCamera:create(0.3,1,0,-90,90,0,0),nil)
			layoutSeniorBack:runAction(sequence4)
		end
		return false
	end)
end

function WildUI:LayoutSeniorBack()
	local seniorFreeNum = layoutSeniorBack:getChildByTag(Tag_ui_wild.LAB_SENIOR_FREE_NUM)
	local diamond1Num = layoutSeniorBack:getChildByTag(Tag_ui_wild.LAB_DIAMOND1_NUM)
	local diamond10Num =  layoutSeniorBack:getChildByTag(Tag_ui_wild.LAB_DIAMOND10_NUM)

	local cardDiamondOne = ConfigManager.getCardCommonConfig('diamond_singgle_price')
	local cardDiamondTen  = ConfigManager.getCardCommonConfig('diamond_ten_price')
	-- print("====diamondTime======" .. diamondTime)
	if diamondTime == 0 then   --免费
		seniorFreeNum:setString("本次免费")
		diamond1Num:setString("免费")
	else
		diamond1Num:setString(cardDiamondOne)
	end
	diamond10Num:setString(cardDiamondTen)
	
	local btnBuy1 = layoutSeniorBack:getChildByTag(Tag_ui_wild.BTN_SENIOR_BUY1)
	btnBuy1:setEnabled(true)
	-- if __instance.isCaptureing == false then
		local function event_diamond_buy1()
			if 	isCaptureing == true then
				return
			end
			-- isCaptureing = 1
			if diamondTime <= 0 then
				isCost = false
				__instance.buyType = 1
				NetManager.sendCmd("freedraw",callback_buy1,1)
				local btnNBuy1 = layoutWildBack:getChildByTag(Tag_ui_wild.BTN_WILD_BUY1)
				btnNBuy1:setEnabled(false)
				local btnNBuy10 = layoutWildBack:getChildByTag(Tag_ui_wild.BTN_WILD_BUY10)
				btnNBuy10:setEnabled(false)
				local btnBuy1 = layoutSeniorBack:getChildByTag(Tag_ui_wild.BTN_SENIOR_BUY1)
				btnBuy1:setEnabled(false)
				local btnBuy10 = layoutSeniorBack:getChildByTag(Tag_ui_wild.BTN_SENIOR_BUY10)
				btnBuy10:setEnabled(false)
				local layoutButtom = __instance:getControl(Tag_ui_wild.PANEL_WILD, Tag_ui_wild.LAYOUT_BUTTOM)
				local btnBack = layoutButtom:getChildByTag(Tag_ui_wild.BTN_BACK)
				btnBack:setEnabled(false)
				isCaptureing = true 
			else
				if Player:getInstance():get("diamond")<cardDiamondOne then
					event_alert(1)
				else
					isCaptureing = true 
					__instance.buyType = 1
					isCost = true
					NetManager.sendCmd("draw",callback_buy1,1,1)
					local btnNBuy1 = layoutWildBack:getChildByTag(Tag_ui_wild.BTN_WILD_BUY1)
					btnNBuy1:setEnabled(false)
					local btnNBuy10 = layoutWildBack:getChildByTag(Tag_ui_wild.BTN_WILD_BUY10)
					btnNBuy10:setEnabled(false)
					local btnBuy1 = layoutSeniorBack:getChildByTag(Tag_ui_wild.BTN_SENIOR_BUY1)
					btnBuy1:setEnabled(false)
					local btnBuy10 = layoutSeniorBack:getChildByTag(Tag_ui_wild.BTN_SENIOR_BUY10)
					btnBuy10:setEnabled(false)
					local layoutButtom = __instance:getControl(Tag_ui_wild.PANEL_WILD, Tag_ui_wild.LAYOUT_BUTTOM)
					local btnBack = layoutButtom:getChildByTag(Tag_ui_wild.BTN_BACK)
					btnBack:setEnabled(false)
				end	
			end
		end
		btnBuy1:setOnClickScriptHandler(event_diamond_buy1)
	-- end
	local btnBuy10 = layoutSeniorBack:getChildByTag(Tag_ui_wild.BTN_SENIOR_BUY10)
	-- if __instance.isCaptureing == false then
		local function event_diamond_buy10()
			if isCaptureing == true then
				return
			end
			-- isCaptureing = 1
			if Player:getInstance():get("diamond")<cardDiamondTen then
				event_alert(1)
			else
				isCaptureing = true 
				__instance.buyType = 1
				NetManager.sendCmd("draw",callback_buy10,1,10)
				local btnNBuy1 = layoutWildBack:getChildByTag(Tag_ui_wild.BTN_WILD_BUY1)
				btnNBuy1:setEnabled(false)
				local btnNBuy10 = layoutWildBack:getChildByTag(Tag_ui_wild.BTN_WILD_BUY10)
				btnNBuy10:setEnabled(false)
				local btnBuy1 = layoutSeniorBack:getChildByTag(Tag_ui_wild.BTN_SENIOR_BUY1)
				btnBuy1:setEnabled(false)
				local btnBuy10 = layoutSeniorBack:getChildByTag(Tag_ui_wild.BTN_SENIOR_BUY10)
				btnBuy10:setEnabled(false)
				local layoutButtom = __instance:getControl(Tag_ui_wild.PANEL_WILD, Tag_ui_wild.LAYOUT_BUTTOM)
				local btnBack = layoutButtom:getChildByTag(Tag_ui_wild.BTN_BACK)
				btnBack:setEnabled(false)
			end
		end
		btnBuy10:setOnClickScriptHandler(event_diamond_buy10)
	-- end
end

local function event_return()
	if isCaptureing == true then  -- 抽卡状态不能返回
		return
	end
	if NormalDataProxy:getInstance():get("isDaliyPursue") then
		Utils.popScene()
		Utils.runUIScene("DailyPopup")
		return
	end
	Utils.replaceScene("MainUI",__instance)
end

local function event_adapt_pvchapter( p_convertview, idx )
	local pCell = p_convertview
	-- if pCell == nil then
		local index = idx + 1
		pCell = CPageViewCell:new()
		TuiManager:getInstance():parseCell(pCell, "cell_pvpet", PATH_UI_WILD)
		local layoutPet = pCell:getChildByTag(Tag_ui_wild.LAYOUT_PVPET)
		local img = TextureManager.createImg("ui_wild/img_pet%d.png",index)
		Utils.addCellToParent(img,layoutPet)
	-- end
	return pCell
end

function WildUI:onLoadScene()
	WildDataProxy:getInstance().itemsList = {}
	TuiManager:getInstance():parseScene(self,"panel_wild",PATH_UI_WILD)
	local layoutTop = self:getControl(Tag_ui_wild.PANEL_WILD,Tag_ui_wild.LAYOUT_TOP)

	img_can_get_pet = layoutTop:getChildByTag(Tag_ui_wild.IMG_CAN_GET_PET)
	labCaptureItem = layoutTop:getChildByTag(Tag_ui_wild.LAB_CAPTURE_ITEMS)
	labCaptureItem:setVisible(false)
	Utils.floatToTop(layoutTop)

	local layoutButtom = self:getControl(Tag_ui_wild.PANEL_WILD, Tag_ui_wild.LAYOUT_BUTTOM)
	Utils.floatToBottom(layoutButtom)

	local btnBack = layoutButtom:getChildByTag(Tag_ui_wild.BTN_BACK)
	btnBack:setOnClickScriptHandler(event_return)

	lab_now_gold = layoutButtom:getChildByTag(Tag_ui_wild.LAB_NOW_GOLD)
	lab_now_gold:setString(Player:getInstance():get("gold"))
	local function updateGold()
		if lab_now_gold then
			lab_now_gold:setString(Player:getInstance():get("gold"))
		end
	end
    self.listenerGold = cc.EventListenerCustom:create("recharge_update_gold",updateGold)
    local eventDispatcher = __instance:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(self.listenerGold, 1)
	lab_now_diamond = layoutButtom:getChildByTag(Tag_ui_wild.LAB_NOW_DIAMOND)
	lab_now_diamond:setString(Player:getInstance():get("diamond"))
	local function updateWildDiamond()
		if lab_now_diamond then
			lab_now_diamond:setString(Player:getInstance():get("diamond"))
		end
	end
    self.listenerDiamond = cc.EventListenerCustom:create("recharge_update_diamond",updateWildDiamond)
    local eventDispatcher = __instance:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(self.listenerDiamond, 1)


	layoutDisplay = self:getControl(Tag_ui_wild.PANEL_WILD,Tag_ui_wild.LAYOUT_DISPLAY)
	local img_qiu1 = layoutDisplay:getChildByTag(Tag_ui_wild.IMG_QIU1)
	local img_qiu2 = layoutDisplay:getChildByTag(Tag_ui_wild.IMG_QIU2)
	local img_qiu3 = layoutDisplay:getChildByTag(Tag_ui_wild.IMG_QIU3)

	pvPet = layoutDisplay:getChildByTag(Tag_ui_wild.PV_PET)
	pvPet:setDataSourceAdapterScriptHandler(event_adapt_pvchapter)
	pvPet:setCountOfCell(3)
	pvPet:reloadData()
	scheduleQiu = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function() 
		local xx = pvPet:getContentOffset().x
		local conten = layoutDisplay:getContentSize().width
		xx = xx-20
		if xx > - conten then
			img_qiu1:setVisible(true)
			img_qiu2:setVisible(false)
			img_qiu3:setVisible(false)
		elseif xx >-conten*2 and xx <= -conten then
			img_qiu1:setVisible(false)
			img_qiu2:setVisible(true)
			img_qiu3:setVisible(false)
		elseif  xx<-conten*2 then
			img_qiu1:setVisible(false)
			img_qiu2:setVisible(false)
			img_qiu3:setVisible(true)
		end

	end, 0, false)

	layoutPet = self:getControl(Tag_ui_wild.PANEL_WILD, Tag_ui_wild.LAYOUT_PET)
	-- local pet = TextureManager.createImg(TextureManager.RES_PATH.PET_PORTRAIT,1)
	-- Utils.addCellToParent(pet,layoutPet)
	layoutSpine = __instance:getControl(Tag_ui_wild.PANEL_WILD,Tag_ui_wild.LAYOUT_SPINE)

	local layoutFunction = layoutButtom:getChildByTag(Tag_ui_wild.LAYOUT_FUNCTION)
	layoutWildFront = layoutFunction:getChildByTag(Tag_ui_wild.LAYOUT_WILD_FRONT)
	layoutWildBack = layoutFunction:getChildByTag(Tag_ui_wild.LAYOUT_WILD_BACK)
	layoutSeniorFront = layoutFunction:getChildByTag(Tag_ui_wild.LAYOUT_SENIOR_FRONT)
	layoutSeniorBack = layoutFunction:getChildByTag(Tag_ui_wild.LAYOUT_SENIOR_BACK)

	layoutWildFront:setVisible(true)
	layoutWildBack:setVisible(false)
	layoutSeniorFront:setVisible(true)
	layoutSeniorBack:setVisible(false)

	local function timekeeping(result)
		goldTime,diamondTime,remainTime = result["goldtimekeeping"],result["diamondtimekeeping"],result["remaintime"]
		__instance:LayoutWildFront()
		__instance:LayoutSeniorFront()
	end

	local function onNodeEvent(event)
		if "enter" == event then
			frontGold = true
			frontDiamond = true
			NetManager.sendCmd("countdown",timekeeping)
		end
		if event == "enterTransitionFinish" then
			if GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.GOLD_CAPTURE or  GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.DIAMOND_CAPTURE then
				local layoutButtom = self:getControl(Tag_ui_wild.PANEL_WILD, Tag_ui_wild.LAYOUT_BUTTOM)
				local layoutFunction = layoutButtom:getChildByTag(Tag_ui_wild.LAYOUT_FUNCTION)
				local layoutSeniorBack = layoutFunction:getChildByTag(Tag_ui_wild.LAYOUT_SENIOR_BACK)
				if GuideManager.main_guide_phase_ == GuideManager.MAIN_GUIDE_PHASES.GOLD_CAPTURE then

					Utils.dispatchCustomEvent("enter_view",{callback = function( )
						Utils.dispatchCustomEvent("event_enter_view",{view = "WildUI",phase = GuideManager.MAIN_GUIDE_PHASES.GOLD_CAPTURE,scene = self})
					end, params = {view = "view", scene = 5}})
					
					local btnBack = layoutButtom:getChildByTag(Tag_ui_wild.BTN_BACK)
					btnBack:setEnabled(false)
					-- btnBack:runAction(cc.Sequence:create(cc.DelayTime:create(15),cc.CallFunc:create(function( )
					-- 	btnBack:setEnabled(true)
					-- end)))
				else
					Utils.dispatchCustomEvent("event_enter_view",{view = "WildUI",phase = GuideManager.MAIN_GUIDE_PHASES.DIAMOND_CAPTURE,scene = self})
					
					local btnBack = layoutButtom:getChildByTag(Tag_ui_wild.BTN_BACK)
					btnBack:setEnabled(false)
					-- btnBack:runAction(cc.Sequence:create(cc.DelayTime:create(7),cc.CallFunc:create(function( )
					-- 	btnBack:setEnabled(true)
					-- end)))
				end
				
				-- layoutSeniorBack:setEnabled(false)
				-- layoutSeniorBack:runAction(cc.Sequence:create(cc.DelayTime:create(7),cc.CallFunc:create(function( )
				-- 	layoutSeniorBack:setEnabled(true)
				-- end)))

				local btnSeniorBuy10 = layoutSeniorBack:getChildByTag(Tag_ui_wild.BTN_SENIOR_BUY10)
				btnSeniorBuy10:setEnabled(false)
				local btnSeniorBuy1 = layoutSeniorBack:getChildByTag(Tag_ui_wild.BTN_SENIOR_BUY1)
				btnSeniorBuy1:setEnabled(false)
				btnSeniorBuy1:runAction(cc.Sequence:create(cc.DelayTime:create(11),cc.CallFunc:create(function( )
					btnSeniorBuy1:setEnabled(true)
				end)))
				

				local layoutWildBack = layoutFunction:getChildByTag(Tag_ui_wild.LAYOUT_WILD_BACK)
				local btnWildBuy10 = layoutWildBack:getChildByTag(Tag_ui_wild.BTN_WILD_BUY10)
				btnWildBuy10:setEnabled(false)
				local btnWildBuy1 = layoutWildBack:getChildByTag(Tag_ui_wild.BTN_WILD_BUY1)
				btnWildBuy1:setEnabled(false)
				btnWildBuy1:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function( )
					btnWildBuy1:setEnabled(true)
				end)))
			end
		end
		if "exit" == event then
			if scheduleGold then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleGold)
			end
			if scheduleDiamond then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleDiamond)
			end
			if scheduleQiu then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleQiu)
			end
			if self.listenerDiamond then
				self:getEventDispatcher():removeEventListener(self.listenerDiamond)
			end
			if self.listenerGold then
				self:getEventDispatcher():removeEventListener(self.listenerGold)
			end
		end
	end
	self:registerScriptHandler(onNodeEvent)

	TouchEffect.addTouchEffect(self)
end







