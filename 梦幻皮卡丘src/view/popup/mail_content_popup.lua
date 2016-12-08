--
-- Author: hapigames
-- Date: 2014-11-27 15:03:28
--
require "view/tagMap/Tag_popup_mail_read"

MailcontentPopup = class("MailcontentPopup",function()
	return Popup:create()
end)

MailcontentPopup.__index = MailcontentPopup
local __instance = nil
local currentFood = nil
function MailcontentPopup:create()
	local ret = MailcontentPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function MailcontentPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end 

function MailcontentPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_mail_read.PANEL_POPUP_READ then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end
function MailcontentPopup:setConfirmNormalHandler(handlerP)
	self.confirmHandler = handlerP
end

function MailcontentPopup:setCancelNormalHandler(handlerP)
	self.cancelHandler = handlerP
end

function MailcontentPopup:onLoadScene() 
	-- local mid =Maildataproxy:getInstance():get("mail_index")
	-- 
	-- local mailCont = Maildataproxy.mailList

	TuiManager:getInstance():parseScene(self,"panel_popup_read",PATH_POPUP_MAIL_READ)
	local mail = Maildataproxy:getInstance()
	local id = mail:get("id")

	local mailid = mail:get("mailid")
	local mailType = mail:get("mail_type")
	local items = mail:get("item")
	local param = mail:get("param")
	print("id = "..id .."  mailid = "..mailid.." mailType ="..mailType)

	textsMailConfig = TextManager.getMailDesc(mailid)
	local proxy = NormalDataProxy:getInstance()
	self.cancelHandler = proxy.cancelHandler                                           
	self.confirmHandler = proxy.confirmHandler

	local bg = self:getControl(Tag_popup_mail_read.PANEL_POPUP_READ, Tag_popup_mail_read.IMG_MAIL_BG)
	
	local listView = self:getControl(Tag_popup_mail_read.PANEL_POPUP_READ,Tag_popup_mail_read.LIST_READ)
	
	local tipPorxy = TipDataProxy:getInstance()
	if param[1] == nil then
		tipPorxy:set("content",textsMailConfig.text)
	else
		print(param[1])
		print(textsMailConfig.text)
		local text = string.gsub(textsMailConfig.text,"%%s",param[1])
		tipPorxy:set("content",text)
	end
	-- tipPorxy:set("width",bg:getContentSize().width - tipPorxy:get("bg_margin")-150)
	local label = CLabel:createWithTTF(tipPorxy:get("content"),Constants.DEFAULT_FONT ,32,cc.size(470,100),0)
	label:setColor(cc.c3b(61,15,0)) 
	listView:insertNodeAtFront(label)
	listView:reloadData()
	local node =listView:getNodeAtIndex(1)
	local reward = Maildataproxy.mailList
	local mailConfig = ConfigManager.getMailConfig(mailid)
	local labGold = node:getChildByTag(Tag_popup_mail_read.LAB_GOLD)
	local labDiamond = node:getChildByTag(Tag_popup_mail_read.LAB_DIAMOND)
	local pet_ = 0
	local item_ = 0
	for i,v in ipairs(items) do
		if v[1] == 1 then
			labDiamond:setString(v[2])
			labGold:setString(0)
		elseif v[1] == 2 then
			labGold:setString(v[2])
			labDiamond:setString(0)
		elseif v[1] == 3 then
			labDiamond:setString(0)
			labGold:setString(0)
		elseif v[1] == 4 then
			labDiamond:setString(0)
			labGold:setString(0)
		elseif v[1] == 5 then
			item_ = 1
			labDiamond:setString(0)
			labGold:setString(0)
		else
			pet_ = 1 
			labDiamond:setString(0)
			labGold:setString(0)
		end
	end
	if pet_ == 1 then
		labGold:setString(0)
		labDiamond:setString(0)
	end
	local function event_adapt_rewards( p_convertview, idx)
		local pCell = p_convertview
		if pCell == nil then
			pCell = CGridViewCell:new()
			TuiManager:getInstance():parseCell(pCell,"cell_mailitem",PATH_POPUP_MAIL_READ)
			local layoutPet = pCell:getChildByTag(Tag_popup_mail_read.LAYOUT_MAILPET_1)
			if items[idx+1][1] == 6 then
				local pet = Pet:create()
				pet:set("mid",items[idx+1][2])
				pet:set("form",items[idx+1][3])
				pet:set("aptitude",items[idx+1][5])
				local petCell = PetCell:create(pet)
				Utils.addCellToParent(petCell,layoutPet)
				Utils.showPetInfoTips(layoutPet, pet:get("mid"), pet:get("form"))
			elseif items[idx+1][1] == 5 then
				if items[idx+1][2] == 1 then
					local pet = Pet:create()
					pet:set("mid",items[idx+1][3])
					pet:set("form",1)
					pet:set("aptitude",items[idx+1][4])
					local petCell = PetCell:create(pet)
					Utils.addCellToParent(petCell,layoutPet)
					Utils.showPetInfoTips(layoutPet, pet:get("mid"), pet:get("form"))
				else
					local item = Item:create(items[idx+1][2],items[idx+1][3])
					local itemCell = ItemCell:create(items[idx+1][2],item)
					Utils.addCellToParent(itemCell,layoutPet)
					local label = CLabel:createWithTTF(items[idx+1][4],Constants.DEFAULT_FONT ,28,cc.size(70,40),0)
					label:setColor(cc.c3b(136,240,20)) 
					local size = itemCell:getContentSize()
					label:setPosition(cc.p(size.width+10,15))
					itemCell:addChild(label,4)
					Utils.showItemInfoTips(layoutPet, item)
				end
			end
		end
		return pCell
	end
	local gvContent = node:getChildByTag(Tag_popup_mail_read.GV_MAILITEM)
	
	gvContent:setCountOfCell(#items)
	
    gvContent:setDataSourceAdapterScriptHandler(event_adapt_rewards)
    gvContent:reloadData()
    -- end
	listView:reloadData()

	local function event_getmailreward(p_sender )
		-- ItemManager.updateItems(ItemManager.currentItem)
		if mailType == 2 then
			Utils.popUIScene(self)
		else
			local function getmail(result) 
				if item_ == 1 then
					for k,v in pairs(items) do
						if v[1] == 5 and v[2] == 1 then
							ItemManager.addPet({id = result["id"] ,mid = v[3],form = 1,aptitude = 1})
							local petsTable = ItemManager.getItemsByType(Constants.ITEM_TYPE.PET)
							local newPet = true
						    for j,n in ipairs(petsTable) do
						    	if n:get("mid")== v[3]  then
						    		newPet = false
						    	end
						    end
						    if newPet == true then
						    	Utils.runUIScene("NewPetPopup")
						    end
						else
							ItemManager.addItem(v[2],v[3],v[4])
						end
					end
				end
				if pet_ == 1  then
					ItemManager.addPet({mid = items[1][2],form = items[1][3],aptitude = items[1][5]})
				end
				TipManager.showTip("奖励已领取！")
		    end
			NetManager.sendCmd("getmail",getmail,id)
			local proxy = NormalDataProxy:getInstance()
	        if self.confirmHandler ~= nil then
				self.confirmHandler()
			end
			NormalDataProxy:getInstance().confirmHandler = nil
			NormalDataProxy:getInstance().cancelHandler = nil
			-- Maildataproxy:getInstance():set("mail_read",1)
			Utils.popUIScene(self)
		end
	end

	local btn_draw = self:getControl(Tag_popup_mail_read.PANEL_POPUP_READ,Tag_popup_mail_read.BTN_DRAW)
	btn_draw:setOnClickScriptHandler(function()	
		Utils.popUIScene(self)
	end)

	local btnget = self:getControl(Tag_popup_mail_read.PANEL_POPUP_READ,Tag_popup_mail_read.BTN_GETCOMMON)
	btnget:setOnClickScriptHandler(event_getmailreward)
	TouchEffect.addTouchEffect(self)
	
end



