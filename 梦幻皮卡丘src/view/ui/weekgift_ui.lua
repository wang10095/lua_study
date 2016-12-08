require "view/tagMap/Tag_ui_weekgift"

WeekGiftUI = class("WeekGiftUI",function()
	return TuiBase:create()
end)

WeekGiftUI.__index = WeekGiftUI
local __instance = nil
local circleMenu = nil
local list,layout_half_price --list表 半价抢购 
local today = 0  --今日是第几天
local labCommon2,labCommon3 --标签页2和3
WeekGiftUI.tag1Table = {}
WeekGiftUI.tag2Table = {}
WeekGiftUI.tag3Table = {}
WeekGiftUI.tag4Table = {}--各个标签对应的数据
local tgv = 1
local layoutTop
local layoutTgv,layout_seven_day
local current4Tgv = nil
local current7Tgv = nil
local currentDay = 0

local Tag_1 = 0
local Tag_2 = 0

function WeekGiftUI:create()
	local ret = WeekGiftUI.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function WeekGiftUI:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function WeekGiftUI:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_weekgift.PANEL_WEEKGIFT then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_close()
	Utils.replaceScene("MainUI",__instance)
end

local function SelectConfig(tagID,id)
	print(tagID,id)
	local k = {
		ConfigManager.getSevenNormalStageConfig,	
		ConfigManager.getSevenEliteStageConfig,
		ConfigManager.getSevenTrainConfig,
		ConfigManager.getSevenPvpConfig,
		ConfigManager.getSevenBreedConfig,
		ConfigManager.getSevenSkillConfig,
		ConfigManager.getSevenPetLevelConfig,
		ConfigManager.getSevenStarConfig,
		ConfigManager.getSevenPve1Config,
		ConfigManager.getSevenPve2Config,
		ConfigManager.getSevenPve3Config,
		ConfigManager.getSevenShopConfig,
		ConfigManager.getSevenPowerConfig,
		ConfigManager.getSevenUserLevel,
		ConfigManager.getSevenWelfareLevel,
		ConfigManager.getSevenBuyConfig,
		ConfigManager.getSevenPaywelfareConfig,
	}
	local sevenConfig = k[tagID](id)
	return sevenConfig
end

local function SelectSevenIDNum(tagID) --每一个标签的任务个数
	local k = {
		ConfigManager.getSevenNormalStageConfig,	
		ConfigManager.getSevenEliteStageConfig,
		ConfigManager.getSevenTrainConfig,
		ConfigManager.getSevenPvpConfig,
		ConfigManager.getSevenBreedConfig,
		ConfigManager.getSevenSkillConfig,
		ConfigManager.getSevenPetLevelConfig,
		ConfigManager.getSevenStarConfig,
		ConfigManager.getSevenPve1Config,
		ConfigManager.getSevenPve2Config,
		ConfigManager.getSevenPve3Config,
		ConfigManager.getSevenShopConfig,
		ConfigManager.getSevenPowerConfig,
		ConfigManager.getSevenUserLevel,
		ConfigManager.getSevenWelfareLevel,
		ConfigManager.getSevenBuyConfig,
		ConfigManager.getSevenPaywelfareConfig
	}
	local sevenConfigNum = k[tagID]()
	return sevenConfigNum
end

local function callback_loadday(result)
	today = result["day_id"]
	print("第 ".. result["day_id"] .."天")
	print("当前是第".. currentDay .."天")
	for i=1,7 do
		local imgToday = layout_seven_day:getChildByTag(Tag_ui_weekgift["IMG_TODAY"..i])
		local spot = imgToday:getChildByTag(800+i)
		local spotShow = false
		for k,v in ipairs(result["finish_days"]) do
			if v == i then
				spotShow = true
			end
		end
		if spotShow then
			spot:setVisible(true)
		else 
			spot:setVisible(false)
		end
	end
	local sevenWelfareConfig = ConfigManager.getSevenWelfareLevel(result["day_id"]) --七日配置
	print(sevenWelfareConfig.tag_id1 .."  and  ".. sevenWelfareConfig.tag_id2 )

	local layout_seven_day = layoutTop:getChildByTag(Tag_ui_weekgift.LAYOUT_SEVEN_DAY)
	for i=1,today do
		local btn_day = layout_seven_day:getChildByTag(Tag_ui_weekgift["TGV_DAY" .. i])
		if result["day_id"] == i then
			btn_day:setChecked(true)
		else
			btn_day:setChecked(false)
		end
	end
	Tag_1 = sevenWelfareConfig.tag_id1 
	Tag_2 = sevenWelfareConfig.tag_id2 
	local tag2 = sevenWelfareConfig.tag_id1  --标签页2
	local tag3 = sevenWelfareConfig.tag_id2  --标签页3
	local labTag2 = TextManager.getSevenTagName(tag2) --标签页2的名称
	local labTag3 = TextManager.getSevenTagName(tag3) --标签页3的名称
	print(labTag2 .."  and  ".. labTag3 )
	labCommon2:setString(labTag2)
	labCommon3:setString(labTag3)
	__instance.tag1Table = {}
	__instance.tag2Table = {}
	__instance.tag3Table = {}
	__instance.tag4Table = {}
	for i,v in pairs(result["task"]) do --对任务进行分类
		if v["tagID"]==15 and v["id"]==result["day_id"] then
			print(" ------------------ ")
			__instance.tag1Table[1] = {15, v["id"], v["status"]}
		end
		
		if v["tagID"]==17 and v["id"]==result["day_id"] then
			__instance.tag1Table[2] = {17, v["id"], v["status"]}
		end
		
		if v["tagID"]==16 and v["id"]==result["day_id"] then
			table.insert(__instance.tag4Table,v)
		end

		if v["tagID"]== tag2  then
			__instance.tag2Table[v.id]={v.tagID, v.id, v.status}
		end

		if v["tagID"] == tag3  then
			__instance.tag3Table[v.id]={v.tagID, v.id, v.status}
		end
	end

	if __instance.tag1Table[1] == nil then
		local sevenConfig = SelectConfig(15,today)
		__instance.tag1Table[1] = {tagID = 15,id = today,status = 0}
	end
	if __instance.tag1Table[2] == nil then
		local sevenConfig = SelectConfig(17,today)
		__instance.tag1Table[2] = {tagID = 17,id = today,status = 0}
	end
	for i,v in pairs(__instance.tag1Table) do
		if v[1] == nil or v[2] == nil or v[3] == nil then
			v[1] =  (i == 1 and 15) or 17
			v[2] =  today
			v[3] =  0
		end
	end
	for i = 1,SelectSevenIDNum(tag2) do
		if __instance.tag2Table[i] == nil then
			-- table.insert(__instance.tag2Table, {tagID = tag2,id = i,status = 0})
			__instance.tag2Table[i] = {tagID = tag2,id = i,status = 0}
		end
	end

	for i,v in ipairs(__instance.tag2Table) do
		if v[1] == nil or v[2] == nil or v[3] == nil then
			v[1] = tag2
			v[2] = i
			v[3] = 0
		end
	end

	for i = 1,SelectSevenIDNum(tag3) do
		if __instance.tag3Table[i]== nil then
			__instance.tag3Table[i] = {tagID = tag3,id = i,status = 0}
			-- table.insert(__instance.tag3Table, {tagID = tag3,id = i,status = 0})
		end
	end
	for i,v in ipairs(__instance.tag3Table) do
		if v[1] == nil or v[2] == nil or v[3] == nil then
			v[1] = tag3
			v[2] = i
			v[3] = 0
		end
	end
	
	if __instance.tag4Table[1] == nil then
		local sevenConfig = SelectConfig(16,today)
		__instance.tag4Table[1] = {tagID = 16,id = today,status = 0}
	end
	
	local layoutTgvButton1 = layoutTgv:getChildByTag(Tag_ui_weekgift["LAYOUT_TGV" .. 1])
	local layoutTgvButton2 = layoutTgv:getChildByTag(Tag_ui_weekgift["LAYOUT_TGV" .. 2])
	local layoutTgvButton3 = layoutTgv:getChildByTag(Tag_ui_weekgift["LAYOUT_TGV" .. 3])
	local layoutTgvButton4 = layoutTgv:getChildByTag(Tag_ui_weekgift["LAYOUT_TGV" .. 4])
	local spot1 = layoutTgvButton1:getChildByTag(901)
	local spot2 = layoutTgvButton2:getChildByTag(902)
	local spot3 = layoutTgvButton3:getChildByTag(903)
	local spot4 = layoutTgvButton4:getChildByTag(904)

	local tgv1promt = false
	for k,n in ipairs(__instance.tag1Table) do
		if n["status"]==1 then
			tgv1promt = true
			break
		end
	end
	if tgv1promt then
		spot1:setVisible(true)
	else
		spot1:setVisible(false)
	end

	local tgv2promt = false
	for k,n in ipairs(__instance.tag2Table) do
		-- print("==status==" .. n["status"])
		if n[3]==1 then
			tgv2promt = true
			break
		end
	end
	if tgv2promt then
		spot2:setVisible(true)
	else
		spot2:setVisible(false)
	end

	local tgv3promt = false
	for k,n in ipairs(__instance.tag3Table) do
		if n[3]==1 then
			tgv3promt = true
			break
		end
	end
	if tgv3promt then
		spot3:setVisible(true)
	else
		spot3:setVisible(false)
	end

	local tgv4promt = false
	for k,n in ipairs(__instance.tag4Table) do
		if n["status"]==1 then
			tgv4promt = true
			break
		end
	end
	if tgv4promt then
		spot4:setVisible(true)
	else
		spot4:setVisible(false)
	end

	if tgv == 1 then  -- 每日福利
		__instance:DailyBouns()
	elseif tgv == 2 then -- 剧情副本
		__instance:PlotElite()
	elseif tgv == 3 then --竞技场
		__instance:SkillUP()
	elseif tgv == 4 then --半价抢购
		__instance:HalfPrice()
	end
end   

function WeekGiftUI:DailyBouns() --每日福利	
	list:setVisible(true)
	layout_half_price:setVisible(false)
	list:removeAllNodes()
	local count = list:getNodeCount()
  	while count < #__instance.tag1Table  do
		local pCell = CGridViewCell:new()
		TuiManager:getInstance():parseCell(pCell, "cell_seven", PATH_UI_WEEKGIFT)
		list:insertNodeAtLast(pCell)
		count = list:getNodeCount()
	end
	for i,v in ipairs(__instance.tag1Table) do
		print("每日福利 ".. i,v[1],v[2],v[3])
	end
	for i=1,#__instance.tag1Table  do
		local node = list:getNodeAtIndex(i-1)
		local sevenConfig = SelectConfig(__instance.tag1Table[i][1],__instance.tag1Table[i][2])
		local items = sevenConfig.items --每日奖励的物品
		local diamond = sevenConfig.diamond --钻石
		local gold = sevenConfig.gold --金币
	
		local count = 0
		if diamond ~= -1 then
			count = count + 1
		end
		if gold ~= -1 then
			count = count + 1
		end
		for j=1,#items+count do
			local layoutItem = node:getChildByTag(Tag_ui_weekgift["LAYOUT_ITEM_"..j])
			local labItemNum = node:getChildByTag(Tag_ui_weekgift["LAB_ITEM_NUM" .. j])
			local labText = node:getChildByTag(Tag_ui_weekgift.LAB_DAY_NUM)
			
			local img = nil
			if diamond ~= -1 and gold ~= -1 then
				if j == 1 then
					img = TextureManager.createImg("item/img_diamond.png")
					labItemNum:setString(diamond)
					Utils.addCellToParent(img,layoutItem,true)
					imgBorder = TextureManager.createImg("cell_item/img_border_4.png")
					Utils.addCellToParent(imgBorder,img,true)
				elseif j == 2 then
					img = TextureManager.createImg("item/img_gold.png")
					labItemNum:setString(gold)
					Utils.addCellToParent(img,layoutItem,true)
					imgBorder = TextureManager.createImg("cell_item/img_border_4.png")
					Utils.addCellToParent(imgBorder,img,true)
				else
					local item = ItemManager.createItem(items[j-2][1],items[j-2][2])
					img = ItemCell:create(items[j-2][1],item)
					labItemNum:setString(items[j-2][3])
					Utils.addCellToParent(img,layoutItem,true)
					Utils.showItemInfoTips(layoutItem, item)
				end
			elseif diamond ~= -1 and gold == -1 then
				if j == 1 then
					img = TextureManager.createImg("item/img_diamond.png")
					labItemNum:setString(diamond)
					Utils.addCellToParent(img,layoutItem,true)
					imgBorder = TextureManager.createImg("cell_item/img_border_4.png")
					Utils.addCellToParent(imgBorder,img,true)
				else
					local item = ItemManager.createItem(items[j-1][1],items[j-1][2])
					img = ItemCell:create(items[j-1][1],item)
					labItemNum:setString(items[j-1][3])
					Utils.addCellToParent(img,layoutItem,true)
					Utils.showItemInfoTips(layoutItem, item)
				end
			elseif diamond == -1 and gold ~= -1 then
				if j == 1 then
					img = TextureManager.createImg("item/img_gold.png")
					labItemNum:setString(gold)
					Utils.addCellToParent(img,layoutItem,true)
					imgBorder = TextureManager.createImg("cell_item/img_border_4.png")
					Utils.addCellToParent(imgBorder,img,true)
				else
					local item = ItemManager.createItem(items[j-1][1],items[j-1][2])
					img = ItemCell:create(items[j-1][1],item)
					labItemNum:setString(items[j-1][3])
					Utils.addCellToParent(img,layoutItem,true)
					Utils.showItemInfoTips(layoutItem, item)
				end
			elseif diamond == -1 and gold == -1 then
				local item = ItemManager.createItem(items[j][1],items[j][2])
				img = ItemCell:create(items[j][1],item)
				labItemNum:setString(items[j][3])
				Utils.addCellToParent(img,layoutItem,true)
				Utils.showItemInfoTips(layoutItem, item)
			end
		end

		if today>=7 and i == 1 then
			local petMid = ConfigManager.getSevenCommonConfig('pet')
			local petAptitude = ConfigManager.getSevenCommonConfig('petsaptitude')
			local pet = Pet:create()
	        pet:set("id", 1)
	        pet:set("mid", petMid)
	        pet:set("form", 1)
	        pet:set("aptitude", petAptitude)
	        local pCELL = PetCell:create(pet)
			local layoutItem = node:getChildByTag(Tag_ui_weekgift["LAYOUT_ITEM_".. #items+count+1])
			Utils.addCellToParent(pCELL,layoutItem,true)
			Utils.showPetInfoTips(layoutItem, pet:get("mid"), pet:get("form"))
		end

		for j=#items+1+count,3  do
			local labItemNum = node:getChildByTag(Tag_ui_weekgift["LAB_ITEM_NUM" .. j])
			labItemNum:setVisible(false)
		end
		local labDayNum = node:getChildByTag(Tag_ui_weekgift.LAB_DAY_NUM)
		if __instance.tag1Table[i][1] == 15 then
			labDayNum:setString("今日签到奖励")
		elseif __instance.tag1Table[i][1] == 17 then
			labDayNum:setString("累计充值" .. sevenConfig.recharge .. "钻石可获得奖励")
		end
		local lab_btn_title = node:getChildByTag(Tag_ui_weekgift.LAB_BTN_TITLE)
		local imgUncomplete = node:getChildByTag(Tag_ui_weekgift.IMG_UNCOMPLETE)
		local btn_can_get = node:getChildByTag(Tag_ui_weekgift.BTN_CAN_GET)
		local imgGot = node:getChildByTag(Tag_ui_weekgift.IMG_GOT)
		btn_can_get:setScale(1.4)
		imgUncomplete:setVisible(false)
		imgGot:setVisible(false)
		if __instance.tag1Table[i][3] == 0 then
			imgUncomplete:setVisible((__instance.tag1Table[i][1] ~= 17 and true) or false)
			lab_btn_title:setVisible((__instance.tag1Table[i][1] == 17 and true) or false)
			lab_btn_title:setString((__instance.tag1Table[i][1] == 17 and "充值") or "")
			btn_can_get:setVisible((__instance.tag1Table[i][1] == 17 and true) or false)
			if __instance.tag1Table[i][1] == 17 and __instance.tag1Table[i][3] == 0 then
				btn_can_get:setOnClickScriptHandler(function( p_sender )
					NormalDataProxy:getInstance():set("isWeekGift",true)
					Utils.runUIScene("RechargePopup")
					Utils.addCustomEventListener("week_gift_recharge",function( )
						-- NetManager.sendCmd("getweekgift",function(result)
						-- 	print("奖励可领取") 
						-- 	imgUncomplete:setVisible(true)
						-- 	lab_btn_title:setVisible(false)
						-- 	btn_can_get:setVisible(false)
						-- end,__instance.tag1Table[i]["tagID"],__instance.tag1Table[i]["id"])
						-- lab_btn_title:setVisible(true)
						-- lab_btn_title:setString("可领取")
						-- __instance.tag1Table[i][3] = 1
						
						-- __instance:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc(function( )
							NetManager.sendCmd("loadweekgift",callback_loadday,today)
							NormalDataProxy:getInstance():set("isWeekGift",false)
						-- end)))
					end)
				end)
			end
		elseif __instance.tag1Table[i][3] == 1 then --可领取
			lab_btn_title:setString("可领取")
			btn_can_get:setVisible(true)
			btn_can_get:setOnClickScriptHandler(function()
				NetManager.sendCmd("getweekgift",function(result) 
					Player:getInstance():set("diamond",result["diamond"])
					Player:getInstance():set("gold",result["gold"])
					if #result["items"]~=0 then
						for k,v in ipairs(result["items"]) do
							ItemManager.addItem(v["item_type"], v["mid"], v["amount"])
						end
					end
					if #result["pets"]~=0 then
						for k,v in ipairs(result["pets"]) do
				            ItemManager.addPet(v)
				        end
					end
					lab_btn_title:setVisible(false)
					imgGot:setVisible(true)
					btn_can_get:setVisible(false)
					TipManager.showTip("领取成功")
					NetManager.sendCmd("loadweekgift",callback_loadday,today)
				end,__instance.tag1Table[i]["tagID"],__instance.tag1Table[i]["id"])
			end)
		elseif __instance.tag1Table[i][3] == 2 then --已领取
			imgGot:setVisible(true)
			lab_btn_title:setVisible(false)
			btn_can_get:setVisible(false)
		end
	end

	list:reloadData()  
end

function WeekGiftUI:PlotElite()--剧情副本
	list:setVisible(true)
	layout_half_price:setVisible(false)
	list:removeAllNodes()
	local count = list:getNodeCount()
  	while count < #__instance.tag2Table   do
		local pCell = CGridViewCell:new()
		TuiManager:getInstance():parseCell(pCell, "cell_seven", PATH_UI_WEEKGIFT)
		list:insertNodeAtLast(pCell)
		count = list:getNodeCount()
	end

	print(" amount tag2Table "..#__instance.tag2Table)
	for i,v in ipairs(__instance.tag2Table) do
		print(i,v[1],v[2],v[3])
	end
	for i=1,#__instance.tag2Table  do
		local node = list:getNodeAtIndex(i-1)
		print("标签页 = "..__instance.tag2Table[i][1]..", id ="..__instance.tag2Table[i][2])
		local sevenConfig = SelectConfig(__instance.tag2Table[i][1],__instance.tag2Table[i][2])
		local items 
		local diamond
		local gold
		local stageId
		if sevenConfig then
			items= sevenConfig.items --每日奖励的物品
			diamond = sevenConfig.diamond --钻石
			gold = sevenConfig.gold --金币
		 	stageId = sevenConfig.dungeon_id
		end
		
		local count = 0
		if diamond ~= -1 then
			count = count + 1
		end
		if gold ~= -1 then
			count = count + 1
		end
	
		for j=1,#items + count do
			local layoutItem = node:getChildByTag(Tag_ui_weekgift["LAYOUT_ITEM_"..j])
			local labItemNum = node:getChildByTag(Tag_ui_weekgift["LAB_ITEM_NUM" .. j])
			local img = nil
			if diamond ~= -1 and gold ~= -1 then
				if j == 1 then
					img = TextureManager.createImg("item/img_diamond.png")
					labItemNum:setString(diamond)
					Utils.addCellToParent(img,layoutItem,true)
					imgBorder = TextureManager.createImg("cell_item/img_border_4.png")
					Utils.addCellToParent(imgBorder,img,true)
				elseif j == 2 then
					img = TextureManager.createImg("item/img_gold.png")
					labItemNum:setString(gold)
					Utils.addCellToParent(img,layoutItem,true)
					imgBorder = TextureManager.createImg("cell_item/img_border_4.png")
					Utils.addCellToParent(imgBorder,img,true)
				else
					local item = ItemManager.createItem(items[j-2][1],items[j-2][2])
					img = ItemCell:create(items[j-2][1],item)
					labItemNum:setString(items[j-2][3])
					Utils.addCellToParent(img,layoutItem,true)
					Utils.showItemInfoTips(layoutItem, item)
				end
			elseif diamond ~= -1 and gold == -1 then
				if j == 1 then
					img = TextureManager.createImg("item/img_diamond.png")
					labItemNum:setString(diamond)
					Utils.addCellToParent(img,layoutItem,true)
					imgBorder = TextureManager.createImg("cell_item/img_border_4.png")
					Utils.addCellToParent(imgBorder,img,true)
				else
					local item = ItemManager.createItem(items[j-1][1],items[j-1][2])
					img = ItemCell:create(items[j-1][1],item)
					labItemNum:setString(items[j-1][3])
					Utils.addCellToParent(img,layoutItem,true)
					Utils.showItemInfoTips(layoutItem, item)
				end
			elseif diamond == -1 and gold ~= -1 then
				if j == 1 then
					img = TextureManager.createImg("item/img_gold.png")
					labItemNum:setString(gold)
					Utils.addCellToParent(img,layoutItem,true)
					img:setScale(1.001)
					imgBorder = TextureManager.createImg("cell_item/img_border_4.png")
					Utils.addCellToParent(imgBorder,img,true)
				else
					local item = ItemManager.createItem(items[j-1][1],items[j-1][2])
					img = ItemCell:create(items[j-1][1],item)
					labItemNum:setString(items[j-1][3])
					Utils.addCellToParent(img,layoutItem,true)
					Utils.showItemInfoTips(layoutItem, item)
				end
			elseif diamond == -1 and gold == -1 then
				local item = ItemManager.createItem(items[j][1],items[j][2])
				img = ItemCell:create(items[j][1],item)
				labItemNum:setString(items[j][3])
				Utils.addCellToParent(img,layoutItem,true)
				Utils.showItemInfoTips(layoutItem, item)
			end
		end
		for j=#items+1+count,3  do
			local labItemNum = node:getChildByTag(Tag_ui_weekgift["LAB_ITEM_NUM" .. j])
			labItemNum:setVisible(false)
		end
		local labDayNum = node:getChildByTag(Tag_ui_weekgift.LAB_DAY_NUM)

		local textsConfig = TextManager.getSevenTagTexts(__instance.tag2Table[i][1])

		
		if __instance.tag2Table[i][1]== 1 then
			labDayNum:setString(string.format(textsConfig,sevenConfig.dungeon_id))
		elseif __instance.tag2Table[i][1]== 4 then
			if sevenConfig.ranking ~= -1 then
				labDayNum:setString(string.format(textsConfig[1],sevenConfig.ranking))
			else
				labDayNum:setString(string.format(textsConfig[2],sevenConfig.measure_chest))
			end
		elseif __instance.tag2Table[i][1] == 7 then
			labDayNum:setString(string.format(textsConfig,sevenConfig.pet_num,sevenConfig.level))
		elseif __instance.tag2Table[i][1] == 2 then
			labDayNum:setString(string.format(textsConfig,sevenConfig.dungeon_id))
		elseif __instance.tag2Table[i][1]== 3 then
			labDayNum:setString(string.format(textsConfig,sevenConfig.num,sevenConfig.rank))
		elseif __instance.tag2Table[i][1]== 5 then
			if sevenConfig.breed_num ~= -1 then
				labDayNum:setString(string.format(textsConfig[1],sevenConfig.breed_num))
			else
				labDayNum:setString(string.format(textsConfig[2],sevenConfig.breed_aptitude))
			end
		elseif __instance.tag2Table[i][1]== 8 then
			labDayNum:setString(string.format(textsConfig,sevenConfig.pet_num,sevenConfig.star))
		end

		local lab_btn_title = node:getChildByTag(Tag_ui_weekgift.LAB_BTN_TITLE)
		local btn_can_get = node:getChildByTag(Tag_ui_weekgift.BTN_CAN_GET)
		local imgUncomplete = node:getChildByTag(Tag_ui_weekgift.IMG_UNCOMPLETE)
		local imgGot = node:getChildByTag(Tag_ui_weekgift.IMG_GOT)
		imgGot:setVisible(false)
		imgUncomplete:setVisible(false)
		btn_can_get:setScale(1.4)
		print(__instance.tag2Table[i][1],__instance.tag2Table[i][2],__instance.tag2Table[i][3])
		if __instance.tag2Table[i][3] == 0 then
			btn_can_get:setVisible(false)
			lab_btn_title:setVisible(false)
			imgUncomplete:setVisible(true)
		elseif __instance.tag2Table[i][3] == 1 then
			lab_btn_title:setString("可领取")
			btn_can_get:setVisible(true)
			btn_can_get:setOnClickScriptHandler(function()
				NetManager.sendCmd("getweekgift",function(result) 
					Player:getInstance():set("diamond",result["diamond"])
					Player:getInstance():set("gold",result["gold"])
					if #result["items"]~=0 then
						for k,v in ipairs(result["items"]) do
							ItemManager.addItem(v["item_type"], v["mid"], v["amount"])
						end
					end
					if #result["pets"]~=0 then
						for k,v in ipairs(result["pets"]) do
				            ItemManager.addPet(v)
				        end
					end
					TipManager.showTip("领取成功")
					btn_can_get:setVisible(false)
					imgGot:setVisible(true)
					NetManager.sendCmd("loadweekgift",callback_loadday,today)
				end,__instance.tag2Table[i][1],__instance.tag2Table[i][2])
			end)
		elseif __instance.tag2Table[i][3] == 2 then
			imgGot:setVisible(true)
			btn_can_get:setVisible(false)
			lab_btn_title:setVisible(false)
		end
	end
	list:reloadData()  
end

function WeekGiftUI:SkillUP() --tag3
	list:setVisible(true)
	layout_half_price:setVisible(false)
	list:removeAllNodes()
	local count = list:getNodeCount()
  	while count < #__instance.tag3Table   do
		local pCell = CGridViewCell:new()
		TuiManager:getInstance():parseCell(pCell, "cell_seven", PATH_UI_WEEKGIFT)
		list:insertNodeAtLast(pCell)
		count = list:getNodeCount()
	end
	print(" amount tag3Table "..#__instance.tag3Table)
	for i,v in ipairs(__instance.tag3Table) do
		print(i,v[1],v[2],v[3])
	end
	for i=1,#__instance.tag3Table  do
		local node = list:getNodeAtIndex(i-1)
		print("标签页 = "..__instance.tag3Table[i][1]..", id ="..__instance.tag3Table[i][2]..", status ="..__instance.tag3Table[i][3])
		local sevenConfig = SelectConfig(__instance.tag3Table[i][1],__instance.tag3Table[i][2])
		local items 
		local diamond
		local gold
		local stageId
		if sevenConfig then
			items= sevenConfig.items --每日奖励的物品
			diamond = sevenConfig.diamond --钻石
			gold = sevenConfig.gold --金币
		 	stageId = sevenConfig.dungeon_id
		end
		
		local count = 0
		if diamond ~= -1 then
			count = count + 1
		end
		if gold ~= -1 then
			count = count + 1
		end
	
		for j=1,#items + count do
			local layoutItem = node:getChildByTag(Tag_ui_weekgift["LAYOUT_ITEM_"..j])
			local labItemNum = node:getChildByTag(Tag_ui_weekgift["LAB_ITEM_NUM" .. j])
			local img = nil
			if diamond ~= -1 and gold ~= -1 then
				if j == 1 then
					img = TextureManager.createImg("item/img_diamond.png")
					labItemNum:setString(diamond)
					Utils.addCellToParent(img,layoutItem,true)
					imgBorder = TextureManager.createImg("cell_item/img_border_4.png")
					Utils.addCellToParent(imgBorder,img,true)
				elseif j == 2 then
					img = TextureManager.createImg("item/img_gold.png")
					labItemNum:setString(gold)
					Utils.addCellToParent(img,layoutItem,true)
					imgBorder = TextureManager.createImg("cell_item/img_border_4.png")
					Utils.addCellToParent(imgBorder,img,true)
				else
					local item = ItemManager.createItem(items[j-2][1],items[j-2][2])
					img = ItemCell:create(items[j-2][1],item)
					labItemNum:setString(items[j-2][3])
					Utils.addCellToParent(img,layoutItem,true)
					Utils.showItemInfoTips(layoutItem, item)
				end
			elseif diamond ~= -1 and gold == -1 then
				if j == 1 then
					img = TextureManager.createImg("item/img_diamond.png")
					labItemNum:setString(diamond)
					Utils.addCellToParent(img,layoutItem,true)
					imgBorder = TextureManager.createImg("cell_item/img_border_4.png")
					Utils.addCellToParent(imgBorder,img,true)
				else
					local item = ItemManager.createItem(items[j-1][1],items[j-1][2])
					img = ItemCell:create(items[j-1][1],item)
					labItemNum:setString(items[j-1][3])
					Utils.addCellToParent(img,layoutItem,true)
					Utils.showItemInfoTips(layoutItem, item)
				end
			elseif diamond == -1 and gold ~= -1 then
				if j == 1 then
					img = TextureManager.createImg("item/img_gold.png")
					labItemNum:setString(gold)
					Utils.addCellToParent(img,layoutItem,true)
					img:setScale(1.001)
					imgBorder = TextureManager.createImg("cell_item/img_border_4.png")
					Utils.addCellToParent(imgBorder,img,true)
				else
					local item = ItemManager.createItem(items[j-1][1],items[j-1][2])
					img = ItemCell:create(items[j-1][1],item)
					labItemNum:setString(items[j-1][3])
					Utils.addCellToParent(img,layoutItem,true)
					Utils.showItemInfoTips(layoutItem, item)
				end
			elseif diamond == -1 and gold == -1 then
				local item = ItemManager.createItem(items[j][1],items[j][2])
				img = ItemCell:create(items[j][1],item)
				labItemNum:setString(items[j][3])
				Utils.addCellToParent(img,layoutItem,true)
				Utils.showItemInfoTips(layoutItem, item)
			end
		end
		for j=#items+1+count,3  do
			local labItemNum = node:getChildByTag(Tag_ui_weekgift["LAB_ITEM_NUM" .. j])
			labItemNum:setVisible(false)
		end
		local labDayNum = node:getChildByTag(Tag_ui_weekgift.LAB_DAY_NUM)

		local textsConfig = TextManager.getSevenTagTexts(__instance.tag3Table[i][1])
		
		if __instance.tag3Table[i][1]== 6 then
			labDayNum:setString(string.format(textsConfig,sevenConfig.skill_num,sevenConfig.skill_level))
		elseif __instance.tag3Table[i][1]==9 then
			labDayNum:setString(string.format(textsConfig[i],sevenConfig.score))
		elseif __instance.tag3Table[i][1]== 10 then
			labDayNum:setString(string.format(textsConfig,i --[[sevenConfig.dungeon_type]]))
		elseif __instance.tag3Table[i][1]==11 then
			labDayNum:setString(string.format(textsConfig,sevenConfig.floor))
		elseif __instance.tag3Table[i][1]==12 then
			labDayNum:setString(string.format(textsConfig,sevenConfig.flush_num))
		elseif __instance.tag3Table[i][1]== 14 then
			labDayNum:setString(string.format(textsConfig,sevenConfig.level))
		elseif  __instance.tag3Table[i][1]== 13 then
			labDayNum:setString(string.format(textsConfig,sevenConfig.power))
		end

		print(__instance.tag3Table[i][1],__instance.tag3Table[i][2],__instance.tag3Table[i][3])
		local lab_btn_title = node:getChildByTag(Tag_ui_weekgift.LAB_BTN_TITLE)
		local btn_can_get = node:getChildByTag(Tag_ui_weekgift.BTN_CAN_GET)
		local imgUncomplete = node:getChildByTag(Tag_ui_weekgift.IMG_UNCOMPLETE)
		local imgGot = node:getChildByTag(Tag_ui_weekgift.IMG_GOT)
		imgGot:setVisible(false)
		imgUncomplete:setVisible(false)
		btn_can_get:setScale(1.4)
		if __instance.tag3Table[i][3] == 0 then
			btn_can_get:setVisible(false)
			lab_btn_title:setVisible(false)
			imgUncomplete:setVisible(true)
		elseif __instance.tag3Table[i][3] == 1 then
			lab_btn_title:setString("可领取")
			btn_can_get:setVisible(true)
			btn_can_get:setOnClickScriptHandler(function()
				NetManager.sendCmd("getweekgift",function(result) 
					Player:getInstance():set("diamond",result["diamond"])
					Player:getInstance():set("gold",result["gold"])
					if #result["items"]~=0 then
						for k,v in ipairs(result["items"]) do
							ItemManager.addItem(v["item_type"], v["mid"], v["amount"])
						end
					end
					if #result["pets"]~=0 then
						for k,v in ipairs(result["pets"]) do
				            ItemManager.addPet(v)
				        end
					end
					TipManager.showTip("领取成功")
					btn_can_get:setVisible(false)
					imgGot:setVisible(true)
					NetManager.sendCmd("loadweekgift",callback_loadday,today)
				end,__instance.tag3Table[i][1],__instance.tag3Table[i][2])
			end)
		elseif __instance.tag3Table[i][3] == 2 then
			imgGot:setVisible(true)
			btn_can_get:setVisible(false)
			lab_btn_title:setVisible(false)
			-- node:setVisible(false)
		end
	end
	list:reloadData()  
end

function WeekGiftUI:HalfPrice() -- 半价抢购
	list:setVisible(false)
	layout_half_price:setVisible(true)
	local layoutHalfPrice = layoutTop:getChildByTag(Tag_ui_weekgift.LAYOUT_HALF_PRICE)
	local layout_item = layoutHalfPrice:getChildByTag(Tag_ui_weekgift.LAYOUT_HALFPRICE_ITEM)
	layout_item:removeAllChildren()
	
	local labItemName = layoutHalfPrice:getChildByTag(Tag_ui_weekgift.LAB_ITEM_NAME)
	local labItemNum = layoutHalfPrice:getChildByTag(Tag_ui_weekgift.LAB_ITEM_NUM)
	local labNowPriceNum = layoutHalfPrice:getChildByTag(Tag_ui_weekgift.LAB_NOW_PRICE_NUM)
	local labOldPriceNum = layoutHalfPrice:getChildByTag(Tag_ui_weekgift.LAB_OLD_PRICE_NUM)
	local sevenConfig = SelectConfig(__instance.tag4Table[1]["tagID"],__instance.tag4Table[1]["id"])
	local item = sevenConfig.item
	local cost_diamond = sevenConfig.cost_diamond
	local gold = sevenConfig.gold
	local imgSellout = layoutHalfPrice:getChildByTag(Tag_ui_weekgift.IMG_SELLOUT)
	imgSellout:setVisible(false)
	local img 
	if item ~= -1 and gold == -1 then
		local itemSell = ItemManager.createItem(item[1],item[2])
		img = ItemCell:create(item[1],itemSell)
		labItemNum:setString("x" .. item[3])
		Utils.addCellToParent(img,layout_item)
		local itemname  = TextManager.getItemName(item[1],item[2])
		labItemName:setString(itemname)
		Utils.showItemInfoTips(layout_item, itemSell)
	else
		img = TextureManager.createImg("item/img_gold.png")
		local border = TextureManager.createImg("cell_item/img_border_5.png")
		labItemNum:setString("x" .. gold)
		labItemName:setString("金币")
		Utils.addCellToParent(img,layout_item)
		Utils.addCellToParent(border,img)
	end
	labNowPriceNum:setString(cost_diamond)
	labOldPriceNum:setString(cost_diamond*2)

	local lab_buy = layoutHalfPrice:getChildByTag(Tag_ui_weekgift.LAB_BUY_HALFPRICE)
	local btn_buy = layoutHalfPrice:getChildByTag(Tag_ui_weekgift.BTN_BUY_HALF)

	if __instance.tag4Table[1]["status"] == 2 or __instance.tag4Table[1]["id"] ~= currentDay then
		imgSellout:setVisible(true)
		lab_buy:setString("已购买")
		btn_buy:setEnabled(false)
	elseif __instance.tag4Table[1]["status"] == 0 and __instance.tag4Table[1]["id"] == currentDay then
		imgSellout:setVisible(false)
		lab_buy:setString("购买")
		btn_buy:setEnabled(true)
	else
		btn_buy:setEnabled(true)
		btn_buy:setOnClickScriptHandler(function() 
			NetManager.sendCmd("buyhalfpriceitem",function(result)
				ItemManager.addItem(item[1],item[2],item[3])
				Player:getInstance():set("diamond",result["diamond"]) 
				TipManager.showTip("购买成功")
				lab_buy:setString("已购买")
				imgSellout:setVisible(true)
				btn_buy:setEnabled(false)
				NetManager.sendCmd("loadweekgift",callback_loadday,today)
			end)
		end)
	end
end

local function event_tgv_commom(p_sender)
	local tag = p_sender:getTag()
	if current4Tgv == tag then
		return
	end
	current4Tgv = tag
	local k = {
		Tag_ui_weekgift.TGV_COMMON1,
		Tag_ui_weekgift.TGV_COMMON2,
		Tag_ui_weekgift.TGV_COMMON3,
		Tag_ui_weekgift.TGV_COMMON4
	}
	local layoutTgvButton1 = layoutTgv:getChildByTag(Tag_ui_weekgift["LAYOUT_TGV" .. 1])
	local layoutTgvButton2 = layoutTgv:getChildByTag(Tag_ui_weekgift["LAYOUT_TGV" .. 2])
	local layoutTgvButton3 = layoutTgv:getChildByTag(Tag_ui_weekgift["LAYOUT_TGV" .. 3])
	local layoutTgvButton4 = layoutTgv:getChildByTag(Tag_ui_weekgift["LAYOUT_TGV" .. 4])

	local TgvButton1 = layoutTgvButton1:getChildByTag(Tag_ui_weekgift["TGV_COMMON" .. 1])
	local TgvButton2 = layoutTgvButton2:getChildByTag(Tag_ui_weekgift["TGV_COMMON" .. 2])
	local TgvButton3 = layoutTgvButton3:getChildByTag(Tag_ui_weekgift["TGV_COMMON" .. 3])
	local TgvButton4 = layoutTgvButton4:getChildByTag(Tag_ui_weekgift["TGV_COMMON" .. 4])

	if k[1] == tag then
		TgvButton1:setChecked(true)
		TgvButton2:setChecked(false)
		TgvButton3:setChecked(false)
		TgvButton4:setChecked(false)
		tgv = 1
		__instance:DailyBouns()
	elseif k[2]==tag then
		TgvButton1:setChecked(false)
		TgvButton2:setChecked(true)
		TgvButton3:setChecked(false)
		TgvButton4:setChecked(false)
		tgv = 2
		__instance:PlotElite()
	elseif k[3]==tag then
		TgvButton1:setChecked(false)
		TgvButton2:setChecked(false)
		TgvButton3:setChecked(true)
		TgvButton4:setChecked(false)
		tgv = 3
		__instance:SkillUP()
	elseif k[4]==tag then
		TgvButton1:setChecked(false)
		TgvButton2:setChecked(false)
		TgvButton3:setChecked(false)
		TgvButton4:setChecked(true)
		tgv = 4
		__instance:HalfPrice()
	end
end

local function event_load_week_gift(result)
	print(" 初始化七日 ")
	today = result["day_id"] --当前是第几天 
	if today>7 then
		today = 7
	end
	local sevenWelfareConfig = ConfigManager.getSevenWelfareLevel(today) --七日配置
	local tag2 = sevenWelfareConfig.tag_id1  --标签页2
	local tag3 = sevenWelfareConfig.tag_id2  --标签页3
	local labTag2 = TextManager.getSevenTagName(tag2) --标签页2的名称
	local labTag3 = TextManager.getSevenTagName(tag3) --标签页3的名称
	labCommon2:setString(labTag2)
	labCommon3:setString(labTag3)

	for i,v in pairs(result["task"]) do --对任务进行分类
		if v["tagID"]==15 then
			print("  签到  ")
			if v["tagID"]~=nil and v["id"]== today  and v["status"]~= nil then
				__instance.tag1Table[1] = {v["tagID"],v["id"],v["status"]}
			else
				__instance.tag1Table[1] = {15,today,0}
			end
		end

		if v["tagID"]==17 then	
			print("  充值  ")
			if v["tagID"]~=nil and v["id"]== today  and v["status"]~= nil then
				__instance.tag1Table[2] = {v["tagID"],v["id"],v["status"]}
			else
				__instance.tag1Table[2] = {17,today,0}
			end
		end

		if v["tagID"]==16 and v["id"]== today then
			table.insert(__instance.tag4Table,v)
		end

		if v["tagID"] == tag2 then
			__instance.tag2Table[v["id"]] = {v["tagID"],v["id"],v["status"]}
		end

		if v["tagID"] == tag3 then
			__instance.tag3Table[v["id"]] = {v["tagID"],v["id"],v["status"]}
		end
		--------------小红点判断
		local layoutTgvButton1 = layoutTgv:getChildByTag(Tag_ui_weekgift["LAYOUT_TGV" .. 1])
		local layoutTgvButton2 = layoutTgv:getChildByTag(Tag_ui_weekgift["LAYOUT_TGV" .. 2])
		local layoutTgvButton3 = layoutTgv:getChildByTag(Tag_ui_weekgift["LAYOUT_TGV" .. 3])
		local layoutTgvButton4 = layoutTgv:getChildByTag(Tag_ui_weekgift["LAYOUT_TGV" .. 4])
		for k,n in pairs(__instance.tag1Table) do
			if n["status"]==1 then
				local spot = layoutTgvButton1:getChildByTag(901)
				spot:setVisible(true)
				break
			end
		end
		for k,n in ipairs(__instance.tag2Table) do
			-- print("===status==" .. n["status"])
			if n[3]==1 then
				local spot = layoutTgvButton2:getChildByTag(902)
				spot:setVisible(true)
				break
			end
		end
		for k,n in ipairs(__instance.tag3Table) do
			if n[3]==1 then
				local spot = layoutTgvButton3:getChildByTag(903)
				spot:setVisible(true)
				break
			end
		end
		for k,n in ipairs(__instance.tag4Table) do
			if n["status"]==1 then
				local spot = layoutTgvButton4:getChildByTag(904)
				spot:setVisible(true)
				break
			end
		end
	end

	---------对后端数据进行填充

	-----每日福利
	-- if __instance.tag1Table[1] == nil then
	-- 	local sevenConfig = SelectConfig(15,today)
	-- 	__instance.tag1Table[1] = {tagID = 15,id = today,status = 0}
	-- end

	-- if __instance.tag1Table[2] == nil then
	-- 	local sevenConfig = SelectConfig(17,today)
	-- 	__instance.tag1Table[2] = {tagID = 17,id = today,status = 0}
	-- end

	-- 第二个标签页
	for i = 1,SelectSevenIDNum(tag2) do
		if __instance.tag2Table[i] == nil then
			__instance.tag2Table[i] = {tagID = tag2,id = i,status = 0}
		end
	end

	for i,v in ipairs(__instance.tag2Table) do
		if v[1]== nil or nil==v[2] or nil == v[3] then
			v[1] =tag3
			v[2] = i
			v[3] = 0
		end
	end

	--第三个标签页
	for i = 1,SelectSevenIDNum(tag3) do
		if __instance.tag3Table[i]== nil then
			__instance.tag3Table[i] = {tagID = tag3,id = i,status = 0}
		end
	end

	for i,v in ipairs(__instance.tag3Table) do
		if v[1]== nil or nil==v[2] or nil == v[3] then
			v[1] =tag3
			v[2] = i
			v[3] = 0
		end
	end

	--运营中心
	if __instance.tag4Table[1] == nil then
		local sevenConfig = SelectConfig(16,today)
		__instance.tag4Table[1] = {tagID = 16,id = today,status = 0}
	end
	
	__instance:DailyBouns()--每日福利
end

local function event_MenuDay_click(p_sender)  --切换天
	local tag = p_sender:getTag()
	if current7Tgv == tag then
		return
	end
	current7Tgv = tag
	local k = {
		Tag_ui_weekgift.TGV_DAY1,
		Tag_ui_weekgift.TGV_DAY2,
		Tag_ui_weekgift.TGV_DAY3,
		Tag_ui_weekgift.TGV_DAY4,
		Tag_ui_weekgift.TGV_DAY5,
		Tag_ui_weekgift.TGV_DAY6,
		Tag_ui_weekgift.TGV_DAY7
	}	
	local day = currentDay
	if today >7 then
		day = 7
	end
	local isOpen = false
	local layout_seven_day = layoutTop:getChildByTag(Tag_ui_weekgift.LAYOUT_SEVEN_DAY)
	for i=1,7 do
		local btn_day = layout_seven_day:getChildByTag(Tag_ui_weekgift["TGV_DAY" .. i])
		if i > day then
			local btn_curday = layout_seven_day:getChildByTag(Tag_ui_weekgift["TGV_DAY" .. today])
			btn_curday:setChecked(true)
			btn_day:setChecked(false)
		end
	end
	
	for i=1,day do  --i 代表天数
		if k[i]==tag then
			NetManager.sendCmd("loadweekgift",callback_loadday,i)--初始化加载当日领取
			isOpen = true
			break
		end
	end
	
	if isOpen == false then
		MusicManager.error_tip()
		TipManager.showTip("未到时间")
	end
end 

function WeekGiftUI:onLoadScene()
	tgv = 1
	today = 0
	__instance.tag1Table,__instance.tag2Table,__instance.tag3Table,__instance.tag4Table = {},{},{},{}
	TuiManager:getInstance():parseScene(self,"panel_weekgift",PATH_UI_WEEKGIFT)
	local layoutBottom = self:getControl(Tag_ui_weekgift.PANEL_WEEKGIFT,Tag_ui_weekgift.LAYOUT_BOTTOM)
	Utils.floatToBottom(layoutBottom)

	layoutTop = self:getControl(Tag_ui_weekgift.PANEL_WEEKGIFT,Tag_ui_weekgift.LAYOUT_TOP)
	Utils.floatToTop(layoutTop)
	local btnCancel = layoutBottom:getChildByTag(Tag_ui_weekgift.BTN_RETURN)
	btnCancel:setOnClickScriptHandler(event_close)

	layout_half_price = layoutTop:getChildByTag(Tag_ui_weekgift.LAYOUT_HALF_PRICE)
	layout_half_price:setVisible(false)

 	layout_seven_day = layoutTop:getChildByTag(Tag_ui_weekgift.LAYOUT_SEVEN_DAY)
 	local result = Dailyattendancedataproxy.attendanceList
 	currentDay = result["day_id"]
 	today =  result["day_id"]
 	for i=1,7 do
 		local btn_day = layout_seven_day:getChildByTag(Tag_ui_weekgift["TGV_DAY" .. i])
 		local imgToday = layout_seven_day:getChildByTag(Tag_ui_weekgift["IMG_TODAY"..i])
 		imgToday:setOpacity(0)
 		btn_day:setOnClickScriptHandler(event_MenuDay_click)
 		if i == result["day_id"] then
			btn_day:setChecked(true)
			imgToday:setOpacity(255)
			current7Tgv = btn_day:getTag()
		elseif i > result["day_id"] then
			btn_day:setChecked(false)
		end
		if result["day_id"]>7 and i == 7 then
			btn_day:setChecked(true)
			current7Tgv = btn_day:getTag()
		end
		local daySpot = false
		for j=1,#result["finish_days"] do
			if result["finish_days"][j]==i then
				daySpot = true
				break
			end
		end
		if i == 7 then
			PromtManager.addRedWeekGigtSpot(imgToday,3,daySpot,800+i)
		else
			PromtManager.addRedWeekGigtSpot(imgToday,2,daySpot,800+i)
		end
 	end

	layoutTgv = layoutTop:getChildByTag(Tag_ui_weekgift.LAYOUT_TGV)
	list = layoutTop:getChildByTag(Tag_ui_weekgift.LIST_CONTENT)

	for i=1,4 do
		local layoutTgvButton = layoutTgv:getChildByTag(Tag_ui_weekgift["LAYOUT_TGV" .. i])
		local tgvCommon = layoutTgvButton:getChildByTag(Tag_ui_weekgift["TGV_COMMON" .. i])
		tgvCommon:setOnClickScriptHandler(event_tgv_commom)
		if i == 1 then
			tgvCommon:setChecked(true)
			current4Tgv = tgvCommon:getTag()
		end
		if i == 2 then
			labCommon2 = layoutTgvButton:getChildByTag(Tag_ui_weekgift["LAB_COMMON" .. i])
		end
		if i == 3  then
			labCommon3 = layoutTgvButton:getChildByTag(Tag_ui_weekgift["LAB_COMMON" .. i])
		end
		PromtManager.addRedWeekGigtSpot(layoutTgvButton,1,false,900+i)
	end
	event_load_week_gift(Dailyattendancedataproxy.attendanceList)
	TouchEffect.addTouchEffect(self)
end	



