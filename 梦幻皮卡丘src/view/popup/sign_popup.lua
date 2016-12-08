require "view/tagMap/Tag_popup_sign"

SignPopup = class("SignPopup", function()
	return Popup:create()
end)

SignPopup.__index = SignPopup
local __instance = nil
local list = nil
local dayNum,status,vip_status,rechargenum
local tgv = 1

function SignPopup:create()
	local ret = SignPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function SignPopup:getControl(tagPanel, tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function SignPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_sign.PANEL_SIGN then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_close(pSender)
	Utils.popUIScene(__instance)
end

local function event_callback_get_dayily_reward(result) --领取签到奖励
	Player:getInstance():set("diamond",result["diamond"])
	Player:getInstance():set("gold",result["gold"])
	for i,v in ipairs(result["items"]) do
		ItemManager.addItem(v["item_type"], v["mid"], v["amount"])
	end
	for i,v in ipairs(result["pets"]) do
		ItemManager.addPet(v)
	end
	vip_status = result["vip_status"]
	status = 1
	__instance:loadlistView()
	TipManager.showTip("签到成功")
	PromtManager.NewsTable.DAILY_SIGN.status = false
 	PromtManager.checkOnePromt("DAILY_SIGN")
end

local function event_callback_get_recharge_reward(result) --领取豪华签到奖励
	Player:getInstance():set("diamond",result["diamond"])
	Player:getInstance():set("gold",result["gold"])
	for i,v in ipairs(result["items"]) do
		ItemManager.addItem(v["item_type"], v["mid"], v["amount"])
	end
	for i,v in ipairs(result["pets"]) do
		ItemManager.addPet(v)
	end
	status = 2
	__instance:loadlistView()
	TipManager.showTip("领取成功")
	PromtManager.NewsTable.SUPER_SIGN.status = false
 	PromtManager.checkOnePromt("SUPER_SIGN")
end

local function event_callback_load_status(result) --加载每日签到
	dayNum = result["num"]
	status = result["status"]
	vip_status = result["vip_status"]
	__instance:loadlistView()
end

local function event_callback_load_grand(result) --加载豪华签到 
	dayNum = result["num"]
	status = result["status"]
	rechargenum = result["rechargenum"]
	__instance:loadlistView()
end

function SignPopup:loadlistView() --加载签到 与充值
	for i=1,30 do
		local signConfig = ConfigManager.getSignConfig(i) --普通签到
		local paySignConfig = ConfigManager.getPaySignConfig(i) --豪华签到
		local items,diamond,gold
		if tgv == 1 then
			items = signConfig.items
			diamond = signConfig.diamond
			gold = signConfig.gold
		elseif tgv == 2 then
			items = paySignConfig.items
			diamond = paySignConfig.diamond
			gold = paySignConfig.gold
		end
		local vip = signConfig.vip

		local node = list:getNodeAtIndex(i-1)
		local count = #items
		for j=1,#items do
			local layoutItem = node:getChildByTag(Tag_popup_sign["LAYOUT_ITEM"..j])
			if items[j][1] == 1 then
				local pet = Pet:create()
				pet:set("id",1)
				pet:set("mid",items[j][2])
				pet:set("form",1)
				pet:set("star",1)
				pet:set("aptitude",items[j][3])
				local petCell = PetCell:create(pet)
				Utils.addCellToParent(petCell,layoutItem,true)
				local labItemNum = node:getChildByTag(Tag_popup_sign["LAB_ITEM" .. j .. "_NUM"])
				labItemNum:setVisible(false)
				Utils.showPetInfoTips(layoutItem, pet:get("mid"), pet:get("form"))
			else
				local item = ItemManager.createItem(items[j][1],items[j][2])
				local cell = ItemCell:create(items[j][1],item)
				Utils.addCellToParent(cell,layoutItem,true)
				local labItemNum = node:getChildByTag(Tag_popup_sign["LAB_ITEM" .. j .. "_NUM"])
				labItemNum:setString(items[j][3])	
				Utils.showItemInfoTips(layoutItem,item)
			end
		end

		local layout_money = node:getChildByTag(Tag_popup_sign["LAYOUT_ITEM" .. #items+1])
		local lab_money_num = node:getChildByTag(Tag_popup_sign["LAB_ITEM" .. #items+1 .. "_NUM"])
		if gold == -1 and diamond == -1  then
			lab_money_num:setVisible(false)
		elseif gold == -1 and diamond ~= -1 then
			lab_money_num:setString(diamond)
			local img = TextureManager.createImg("item/img_diamond.jpg")
			Utils.addCellToParent(img,layout_money,1)
			count = count + 1
			local imgBorder = TextureManager.createImg("cell_item/img_border_4.png")
			Utils.addCellToParent(imgBorder,layout_money,1)
		elseif gold ~= -1 and diamond == -1 then
			lab_money_num:setString(gold)
			local img = TextureManager.createImg("item/img_gold.jpg")
			Utils.addCellToParent(img,layout_money,1)
			count = count + 1
			local imgBorder = TextureManager.createImg("cell_item/img_border_4.png")
			Utils.addCellToParent(imgBorder,layout_money,1)
		end

		for j=count+1 ,3  do
			local lab_money_num = node:getChildByTag(Tag_popup_sign["LAB_ITEM" .. j .. "_NUM"])
			lab_money_num:setVisible(false)
		end

		local img_vip_bg = node:getChildByTag(Tag_popup_sign.IMG_VIP_BG)
		local lab_vip_tips = node:getChildByTag(Tag_popup_sign.LAB_VIP_TIPS)
		img_vip_bg:setVisible(false)
		lab_vip_tips:setVisible(false)
		if (tgv == 1 or vip == 0) and vip ~= -1  then
			img_vip_bg:setVisible(true)
			lab_vip_tips:setVisible(true)
			lab_vip_tips:setString("VIP" .. vip .. "双倍")
		end

		local img_num1 = node:getChildByTag(Tag_popup_sign.IMG_NUM1)
		local img_num2 = node:getChildByTag(Tag_popup_sign.IMG_NUM2)
		if i <10 then
			img_num2:setVisible(false)
			img_num1:setSpriteFrame("component_ui_weekgift_popup_sign/img_" .. i ..".png")
			img_num1:setPositionX(80)
		else
			img_num1:setSpriteFrame("component_ui_weekgift_popup_sign/img_" .. math.floor(i/10) ..".png")
			img_num2:setSpriteFrame("component_ui_weekgift_popup_sign/img_" .. i%10 ..".png")
		end

		local labBtnTitle = node:getChildByTag(Tag_popup_sign.LAB_BTN_TITLE)
		local imgUncomplete = node:getChildByTag(Tag_popup_sign.IMG_NOT_FINISH)
		local imgGot = node:getChildByTag(Tag_popup_sign.IMG_GOT)
		imgGot:setVisible(false)
		local btnUnComplete = node:getChildByTag(Tag_popup_sign.BTN_UNCOMPLETE) --可以充值
		local btnGet = node:getChildByTag(Tag_popup_sign.BTN_CAN_GET) --可以领取
		btnUnComplete:setVisible(false)
		btnUnComplete:setOnClickScriptHandler(function()
			local proxy = NormalDataProxy:getInstance()
			local function confirmHandler()
				NetManager.sendCmd("grandattendance",event_callback_load_grand)
			end
			proxy.confirmHandler = confirmHandler
			Utils.runUIScene("RechargePopup")
		end)
		btnGet:setVisible(false) 

		if tgv == 1 then
			if i<dayNum then
				imgGot:setVisible(true)
				labBtnTitle:setVisible(false)
				imgUncomplete:setVisible(false)
			end
			if i == dayNum then
				if status == 0 then --可领取
					labBtnTitle:setString("可领取")
					btnUnComplete:setVisible(false)
					btnGet:setVisible(true)	
					imgUncomplete:setVisible(false)
					imgGot:setVisible(false)
				elseif status == 1 then --已领取
					labBtnTitle:setVisible(false)
					btnUnComplete:setVisible(false)
					btnGet:setVisible(false)	
					imgUncomplete:setVisible(false)
					imgGot:setVisible(true)	
				end
			end
			btnGet:setOnClickScriptHandler(function() 
				NetManager.sendCmd("getattendancereward",event_callback_get_dayily_reward)
			end)
		elseif tgv == 2 then
			if i<dayNum then
				imgGot:setVisible(true)
				labBtnTitle:setVisible(false)
				imgUncomplete:setVisible(false)
			end
			if i == dayNum then
				if status == 0 then --可领取
					labBtnTitle:setString("可领取")
					btnUnComplete:setVisible(false)
					btnGet:setVisible(true)	
					imgUncomplete:setVisible(false)
					imgGot:setVisible(false)
				elseif status == 1 then --充值
					labBtnTitle:setVisible(true)
					labBtnTitle:setString("充值")
					btnUnComplete:setVisible(true)
					btnGet:setVisible(false)	
					imgUncomplete:setVisible(false)
					imgGot:setVisible(false)	
				elseif status == 2 then --已领取
					labBtnTitle:setVisible(false)
					btnUnComplete:setVisible(false)
					btnGet:setVisible(false)	
					imgUncomplete:setVisible(false)
					imgGot:setVisible(true)	
				end
			end
			btnGet:setOnClickScriptHandler(function()  --领取奖励
				NetManager.sendCmd("getgrandreward",event_callback_get_recharge_reward)
			end)
		end
	end
	list:reloadData()
end

function SignPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_sign",PATH_POPUP_SIGN)
	local btn_close = self:getControl(Tag_popup_sign.PANEL_SIGN,Tag_popup_sign.BTN_CLOSE_POPUP)
	btn_close:setOnClickScriptHandler(event_close)

	local lab_tips = self:getControl(Tag_popup_sign.PANEL_SIGN,Tag_popup_sign.LAB_POPUP_TIPS)
	list = self:getControl(Tag_popup_sign.PANEL_SIGN,Tag_popup_sign.LIST_REGISTRATION)
	tgv = NormalDataProxy:getInstance():get("signType")
	local img_dailysign_title = self:getControl(Tag_popup_sign.PANEL_SIGN,Tag_popup_sign.IMG_DAILYSIGN_TITLE)
	local img_supersign_title = self:getControl(Tag_popup_sign.PANEL_SIGN,Tag_popup_sign.IMG_SUPERSIGN_TITLE)
	if NormalDataProxy:getInstance():get("signType")==1 then
		lab_tips:setString("每天登陆即可领取奖励")
		NetManager.sendCmd("loaddailyattendance",event_callback_load_status)
		img_supersign_title:setVisible(false)
	else
		lab_tips:setString("每天充值6元以上。即可领取豪华奖励！")
		NetManager.sendCmd("grandattendance",event_callback_load_grand)
		img_dailysign_title:setVisible(false)
	end
	
	TouchEffect.addTouchEffect(self)
end