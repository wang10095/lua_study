--
-- Author: hapigames
-- Date: 2014-12-09 12:17:19
--
require "view/tagMap/Tag_popup_bag_useitem"

UseItemPopup = class("UseItemPopup",function()
	return Popup:create()
end)

UseItemPopup.__index = UseItemPopup
local __instance = nil
local gvCotent = {}
local exp_potion_index   --  经验药水mid
local currentPet = nil
local itemNum 

function UseItemPopup:create()
	local ret = UseItemPopup.new()
	__instance = ret 
	if ItemManager.currentPet~=nil then
		currentPet = ItemManager.currentPet 
		ItemManager.currentPet = nil
	end
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret  
end

function UseItemPopup:dtor()
	PetAttributeDataProxy:getInstance():set("useExpItem",1)
	if currentPet then
		currentPet:set("isEatExp",0)
	end
end      

function UseItemPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function UseItemPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_bag_useitem.PANEL_POPUP_USEITEM then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function stopSchedule()
	if __instance.schedulerID then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(__instance.schedulerID)
		__instance.schedulerID = nil	
	end	
end

local function getExpAmount(pet)
	local currentLevel = pet:get("level")
	local limitlevel = Player:getInstance():get("level")
	local maxPet = ConfigManager.getUserConfig(limitlevel).max_pet_exp
	local allExp = maxPet - pet:get("exp")
	while currentLevel < limitlevel do
		currentLevel = currentLevel + 1
		allExp = allExp + ConfigManager.getUserConfig(currentLevel).max_pet_exp
	end
	local use_exp = ConfigManager.getItemConfig(5, exp_potion_index).use_param
	local amount = math.ceil(allExp/use_exp)
	return amount
end

local function levelupAnimation(itemLayout)
	MusicManager.upstar()
	local effectLayout = cc.Sprite:create("spine/spine_pet_attribute/pet_upgrade/shengji_0001.png")
	effectLayout:setPosition(cc.p(60,70))
	effectLayout:setScale(2)
	itemLayout:addChild(effectLayout,5)
 	local animation = cc.Animation:create()
 	for i=1,43,2 do
 		local name = string.format("spine/spine_pet_attribute/pet_upgrade/shengji_00%.2d.png",i)
 		animation:addSpriteFrameWithFile(name)
 	end
 	animation:setDelayPerUnit(0.08)
    animation:setRestoreOriginalFrame(false)
    local animate = cc.Animate:create(animation)
    effectLayout:runAction(cc.Sequence:create(animate,cc.CallFunc:create(function() effectLayout:removeFromParent() end),nil))
end

local function ItemCountdown()
	itemNum:setString(itemNum:getString()-1)
	local scaleBig = cc.ScaleTo:create(0.1,1.3)
	local scaleNomal = cc.ScaleTo:create(0.1,1.0)
	local sequence = cc.Sequence:create(scaleBig,scaleNomal)
	itemNum:runAction(sequence)
end

function UseItemPopup:onLoadPetList()
	for i=1,4 do
		local itemNum = self:getControl(Tag_popup_bag_useitem.PANEL_POPUP_USEITEM,Tag_popup_bag_useitem["LAB_CONSUMABLE_NUM" .. i])
		local itemAmount = ItemManager.getItemAmount(Constants.ITEM_TYPE.EXP_POTION,i)
		itemNum:setString(itemAmount)
	end
	
	local list = self:getControl(Tag_popup_bag_useitem.PANEL_POPUP_USEITEM,Tag_popup_bag_useitem.LIST_USEITEM)
	list:removeAllNodes()
	local petCotent = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
	gvCotent = {}
	for i,v in ipairs(petCotent) do
		table.insert(gvCotent, v)
	end
	table.sort(gvCotent, function(a,b)
		if a:get("isEatExp") == b:get("isEatExp") then
			return a:get("level") > b:get("level")
		else
			return a:get("isEatExp") > b:get("isEatExp")
		end
	end )
  	local count = list:getNodeCount()
  	while count < #gvCotent  do
		local pCell = CGridViewCell:new()
		TuiManager:getInstance():parseCell(pCell, "cell_petlist", PATH_POPUP_BAG_USEITEM)
		list:insertNodeAtLast(pCell)
		count = list:getNodeCount()
	end
	list:reloadData()    
	for i=1,#gvCotent do
		local node = list:getNodeAtIndex(i-1)
		local itemLayout = node:getChildByTag(Tag_popup_bag_useitem.LAYOUT_ITEM_USEITEM)
		local petCell = PetCell:create(gvCotent[i])
		Utils.addCellToParent(petCell,itemLayout,true)
		local itemnameLab = node:getChildByTag(Tag_popup_bag_useitem.LAB_ITEMNAME_USEITEM)
		local name = TextManager.getPetName(gvCotent[i]:get("mid"),gvCotent[i]:get("form"))
		itemnameLab:setString(name)
		local petRank = node:getChildByTag(Tag_popup_bag_useitem.LAB_RANK)
		petRank:setString(gvCotent[i]:get("rank") .. "段")

		local maxStar = ConfigManager.getPetCommonConfig('star_limit')
		for k = gvCotent[i]:get("star")+1,maxStar do
			local petStar = node:getChildByTag(Tag_popup_bag_useitem["IMG_STAR" .. k])
			petStar:setVisible(false)
		end

		local img_click_bg = node:getChildByTag(Tag_popup_bag_useitem.IMG_CLICK_BG)
		img_click_bg:setVisible(false)

		local labPetLevel = node:getChildByTag(Tag_popup_bag_useitem.LAB_LEVELS)
		local level = gvCotent[i]:get("level")
		labPetLevel:setString(level)
		local expProg = node:getChildByTag(Tag_popup_bag_useitem.PROG_EXP)	
		local petExp = gvCotent[i]:get("exp")
		local maxExp = ConfigManager.getUserConfig(level).max_pet_exp
		expProg:setValue(100*petExp/maxExp)
		
		local count = 0  --计算吃经验药水的个数
		local countX = 0 --计数
		local inteval = 15 --间隔时间
		local oldPetExp 
		local allProgessTime = 0.5
		local function event_up_level()
			expProg:startProgressFromTo(100*oldPetExp/maxExp,100,(maxExp-oldPetExp)/maxExp*allProgessTime)
			local delay = cc.DelayTime:create((maxExp-oldPetExp)/maxExp*allProgessTime) --延时
			oldPetExp = 0
			level = level+1
			petExp = petExp - maxExp
			maxExp = ConfigManager.getUserConfig(level).max_pet_exp --升级要求经验值
			if level > Player:getInstance():get("level") then
				stopSchedule()
				TipManager.showTip("达到宠物等级上限")
				labPetLevel:setString(Player:getInstance():get("level"))
				return
			end
			
			local callFunc = cc.CallFunc:create(function()
				levelupAnimation(itemLayout)  --升级特效
				labPetLevel:setString(level)
				if petExp >= maxExp then      --宠物升级
					event_up_level()
				else                       
					expProg:startProgressFromTo(0,100*petExp/maxExp,petExp/maxExp*allProgessTime)
				end
			end)
			local sequence = cc.Sequence:create(delay,callFunc,nil)
			self:runAction(sequence)
		end

		local function callback_eat_exp(result)
			img_click_bg:setVisible(false)
			local img_select_bg = self:getControl(Tag_popup_bag_useitem.PANEL_POPUP_USEITEM,Tag_popup_bag_useitem["IMG_SELECT_BG".. exp_potion_index])
			img_select_bg:setVisible(false)
			if result["pet"]["id"] ==  gvCotent[i]:get("id") then
				--材料数量-1
				ItemCountdown()

				ItemManager.updatePet(result["pet"]["id"],result["pet"])
				ItemManager.updateItems({result["item"]})

				oldPetExp = petExp
				local addPetExp = ConfigManager.getItemConfig(Constants.ITEM_TYPE.EXP_POTION, exp_potion_index).use_param --当前经验药水增加的经验值
				petExp = petExp + addPetExp

				if petExp >= maxExp then   --升级
					event_up_level()
				else      --不升级
					expProg:startProgressFromTo(100*oldPetExp/maxExp,100*petExp/maxExp,addPetExp/maxExp*allProgessTime)
				end

				if tonumber(itemNum:getString()) <= 0 then   --停止时间调度
					if __instance.schedulerID then
						cc.Director:getInstance():getScheduler():unscheduleScriptEntry(__instance.schedulerID)
						__instance.schedulerID = nil
					end	
				end
			end
		end

		local function event_schedule()
			local itemRemainNum = tonumber(itemNum:getString())
			if itemRemainNum <=0  then
				stopSchedule()  --经验药水不足 停止时间调度 
				TipManager.showTip("物品数量不足")
				img_click_bg:setVisible(false)
				return
			end
			if count >=getExpAmount(gvCotent[i]) then
				-- print("==物品上限=" .. getExpAmount(gvCotent[i]),count)
				stopSchedule()
				return
			end
			if tonumber(labPetLevel:getString())>=Player:getInstance():get("level")  then
				labPetLevel:setString(Player:getInstance():get("level"))
			end
			countX = countX + 1
			img_click_bg:setVisible(false)
			local img_select_bg = self:getControl(Tag_popup_bag_useitem.PANEL_POPUP_USEITEM,Tag_popup_bag_useitem["IMG_SELECT_BG".. exp_potion_index])
			img_select_bg:setVisible(false)
			if countX >= inteval  then
				if tonumber(itemNum:getString()) <=0  then
					stopSchedule()  --经验药水不足 停止时间调度 
					TipManager.showTip("物品数量不足")
					img_click_bg:setVisible(false)
					return
				end
				img_click_bg:setVisible(true)
				local img_select_bg = self:getControl(Tag_popup_bag_useitem.PANEL_POPUP_USEITEM,Tag_popup_bag_useitem["IMG_SELECT_BG".. exp_potion_index])
				img_select_bg:setVisible(true)
				count = count + 1 --吃经验药水数量+1
				inteval = inteval-1 --减少间隔时间 
				if inteval <= 3 then
					inteval = 3
				end
				countX = 0
				--减少经验药水数量
				ItemCountdown()
    
				oldPetExp = petExp  --保存原有宠物经验
				local addPetExp = ConfigManager.getItemConfig(Constants.ITEM_TYPE.EXP_POTION, exp_potion_index).use_param --当前经验药水增加的经验值
				petExp = petExp + addPetExp

				if petExp >= maxExp then     --升级
					event_up_level()
				else     					 --不升级
					expProg:startProgressFromTo(100*oldPetExp/maxExp,100*petExp/maxExp,addPetExp/maxExp*allProgessTime)
				end
			end
		end

		local xx,yy = nil,nil
		local canEat = true --单击是否可以使用
		local longTouch = false
		local function onTouchBegan(touch, event)
			local amount = ItemManager.getItemAmount(Constants.ITEM_TYPE.EXP_POTION, exp_potion_index)
			local function event_long_touch()
				canEat = false --长时间按  非单击模式
				if gvCotent[i]:get("level")>=Player:getInstance():get("level")  then
					stopSchedule()
					TipManager.showTip("达到宠物等级上限")
					img_click_bg:setVisible(false)
					labPetLevel:setString(Player:getInstance():get("level"))
					return
				end

				longTouch = true
				if amount > 0 then
					count = count+1
					--减少经验药水数量
					ItemCountdown()

					oldPetExp = petExp  --保存原有宠物经验
					local addPetExp = ConfigManager.getItemConfig(Constants.ITEM_TYPE.EXP_POTION, exp_potion_index).use_param --当前经验药水增加的经验值
					petExp = petExp + addPetExp

					if petExp >= maxExp then     --升级
						event_up_level()
					else     					 --不升级
						expProg:startProgressFromTo(100*oldPetExp/maxExp,100*petExp/maxExp,addPetExp/maxExp*allProgessTime)
					end

					stopSchedule() 
					__instance.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(event_schedule, 0, false)
				else
					longTouch = false
					stopSchedule()--数量不足 停止时间调度
					TipManager.showTip("物品数量不足")
					img_click_bg:setVisible(false)
				end
			end
			local selfLocation = list:convertTouchToNodeSpace(touch)
			xx,yy = selfLocation.x,selfLocation.y
			local location  = node:convertTouchToNodeSpace(touch)
			local size = node:getContentSize()
			if yy>0 and yy <530 and size and location.x >0 and location.x <size.width and location.y >0 and location.y <size.height then
				__instance.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(event_long_touch,0.6, false) --开启长按模式
				return true
			else
				return false
			end
		end

		local function onTouchMoved(touch, event)
			local location  = list:convertTouchToNodeSpace(touch)
			local distance = math.floor(location.y - yy)
			if math.abs(distance) > Constants.TOUCH_SCOPE   then
				canEat = false  --不可以吃
				stopSchedule()	--停止吃经验药水	
			end
		end

		local function callback_eat_long_exp(result)
			ItemManager.updatePet(result["pet"]["id"],result["pet"])
			ItemManager.updateItems({result["item"]})
		end

		local function onTouchEnded(touch, event)
			img_click_bg:setVisible(false)
			local img_select_bg = self:getControl(Tag_popup_bag_useitem.PANEL_POPUP_USEITEM,Tag_popup_bag_useitem["IMG_SELECT_BG".. exp_potion_index])
			img_select_bg:setVisible(false)
			stopSchedule()
			if canEat == true and longTouch == false and yy > 0 and yy <530 then  --可以吃经验药水 单击 并且没有滑动 
				img_click_bg:setVisible(true)
				local img_select_bg = self:getControl(Tag_popup_bag_useitem.PANEL_POPUP_USEITEM,Tag_popup_bag_useitem["IMG_SELECT_BG".. exp_potion_index])
				img_select_bg:setVisible(true)

				if (gvCotent[i]:get("level")>=Player:getInstance():get("level"))  then
					TipManager.showTip("达到宠物等级上限")
					img_select_bg:setVisible(false)
					img_click_bg:setVisible(false)
					labPetLevel:setString(Player:getInstance():get("level"))
				else
					local amount = ItemManager.getItemAmount(Constants.ITEM_TYPE.EXP_POTION, exp_potion_index)
					if amount > 0 then
						NetManager.sendCmd("useExppotion",callback_eat_exp,exp_potion_index,1,gvCotent[i]:get("id"))
					else
						TipManager.showTip("物品数量不足")
						img_select_bg:setVisible(false)
						img_click_bg:setVisible(false)
					end
				end
			end

			if longTouch == true and yy>0 and yy <530 then
				NetManager.sendCmd("useExppotion",callback_eat_long_exp,exp_potion_index,count,gvCotent[i]:get("id"))
			end
			count = 0
			countX = 0
			inteval = 15
			longTouch = false
			canEat = true
		end
		
		local listener = cc.EventListenerTouchOneByOne:create()
		listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )   
		listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
		listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )  
		local eventDispatcher = list:getEventDispatcher() -- 时间派发器 
		eventDispatcher:addEventListenerWithSceneGraphPriority(listener, list)
	end
end

local function event_return( p_sender )
	Utils.popUIScene(__instance)
	if PetAttributeDataProxy:getInstance():get("eatExp")==false then
		-- Utils.runUIScene("BagPopup")
	else
		if NormalDataProxy:getInstance().confirmHandler then
			NormalDataProxy:getInstance().confirmHandler()
		end
		NormalDataProxy:getInstance().confirmHandler = nil
	end
	PetAttributeDataProxy:getInstance():set("eatExp",false)
end


local function select_item()
	for  i = 1,4 do
		local img_select = __instance:getControl(Tag_popup_bag_useitem.PANEL_POPUP_USEITEM,Tag_popup_bag_useitem["IMG_SELECT"..i])
		if exp_potion_index == i then
			img_select:setVisible(true)
		else
			img_select:setVisible(false)
		end
	end
end

function UseItemPopup:onLoadScene()
	exp_potion_index = 1
	TuiManager:getInstance():parseScene(self,"panel_popup_useitem",PATH_POPUP_BAG_USEITEM)
	local returnBtn = self:getControl(Tag_popup_bag_useitem.PANEL_POPUP_USEITEM,Tag_popup_bag_useitem.BTN_RETURN)
	returnBtn:setOnClickScriptHandler(event_return)
	

	local img_select = self:getControl(Tag_popup_bag_useitem.PANEL_POPUP_USEITEM,Tag_popup_bag_useitem["IMG_SELECT1"])

	local position_now = img_select:getPositionX()
	for i=1,4  do
		local itemAmount = ItemManager.getItemAmount(Constants.ITEM_TYPE.EXP_POTION,i)
		local layoutExp = self:getControl(Tag_popup_bag_useitem.PANEL_POPUP_USEITEM,Tag_popup_bag_useitem["LAYOUT_CONSUMABLE" .. i])
		local item = ItemManager.createItem(Constants.ITEM_TYPE.EXP_POTION,i)
		local ItemCell = ItemCell:create(Constants.ITEM_TYPE.EXP_POTION,item)
		Utils.addCellToParent(ItemCell,layoutExp,true)
		ItemCell:setTouchBeganNormalHandler(function() 
			exp_potion_index = i
			img_select:setPositionX(position_now+(i-1)*130)
			itemNum = self:getControl(Tag_popup_bag_useitem.PANEL_POPUP_USEITEM,Tag_popup_bag_useitem["LAB_CONSUMABLE_NUM" .. exp_potion_index])
		end)

		local img_select_bg = self:getControl(Tag_popup_bag_useitem.PANEL_POPUP_USEITEM,Tag_popup_bag_useitem["IMG_SELECT_BG"..i])
		img_select_bg:setVisible(false)
		local itemName = TextManager.getItemName(Constants.ITEM_TYPE.EXP_POTION,i)
		local labItemName = self:getControl(Tag_popup_bag_useitem.PANEL_POPUP_USEITEM,Tag_popup_bag_useitem["LAB_ITEM_NAME" .. i])
		labItemName:setString(itemName)
		local lab_exp_num1 = self:getControl(Tag_popup_bag_useitem.PANEL_POPUP_USEITEM,Tag_popup_bag_useitem["LAB_EXP_NUM"..i])
		local itemConfig = ConfigManager.getItemConfig(Constants.ITEM_TYPE.EXP_POTION,i)
		lab_exp_num1:setString(itemConfig.use_param)
	end
	itemNum = self:getControl(Tag_popup_bag_useitem.PANEL_POPUP_USEITEM,Tag_popup_bag_useitem["LAB_CONSUMABLE_NUM" .. 1])
	self:onLoadPetList()
	TouchEffect.addTouchEffect(self)
	local function onNodeEvent(event)
		if "enter" == event then
			self:show()
		end
		if "enterTransitionFinish"  == event then
			if GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.PET_LEVEL) == false and Player.getInstance():get("level") >= 8 then
				-- Utils.dispatchCustomEvent("enter_view",{callback = function ()
					Utils.dispatchCustomEvent("event_pet_level",{view = "UseItemPopup",phase = GuideManager.FUNC_GUIDE_PHASES.PET_LEVEL,scene = self})
				-- end, params = {view = "func", phase = GuideManager.FUNC_GUIDE_PHASES.PET_LEVEL}})
			end
		end
	end
	self:registerScriptHandler(onNodeEvent)
end







