--
-- Author: hapigames
-- Date: 2014-11-27 12:09:30
--
require "view/tagMap/Tag_popup_mail"

MailPopup = class("MailPopup",function()
	return Popup:create()
end)

MailPopup.__index = MailPopup
local __instance = nil
local currentFood = nil
function MailPopup:create()
	local ret = MailPopup.new()
	__instance = ret
	if (ItemManager.currentItem ~= nil) then
		currentFood = ItemManager.currentItem
		ItemManager.currentItem = nil
	end
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function MailPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function MailPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_mail.PANEL_POPUP_MAIL then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function MailPopup:onLoadScene() 
	TuiManager:getInstance():parseScene(self,"panel_popup_mail",PATH_POPUP_MAIL)
	local function event_popself( p_sender )
		Utils.popUIScene(self)
	end
	local btn_close = self:getControl(Tag_popup_mail.PANEL_POPUP_MAIL,Tag_popup_mail.BTN_CLOSE)
	btn_close:setOnClickScriptHandler(event_popself)
	
	local maillist = Maildataproxy:getInstance().mailList
	
	local mail_content = {}
	local mail_item = {}
	for k,v in pairs(maillist) do
		local id,mailid,types,time,statue,items,param= v["id"],v["mailid"],v["mail_type"],v["time"],0,v["rewards"],v["param"]
		table.insert(mail_content, {id,mailid,types,time,statue,items,param})
	end
	local list = self:getControl(Tag_popup_mail.PANEL_POPUP_MAIL,Tag_popup_mail.LIST_MAIL)
	-- list:retain()
	list:removeAllNodes()
	local count = list:getNodeCount()
  	while count < #mail_content  do
		local pCell = CGridViewCell:new()
		TuiManager:getInstance():parseCell(pCell, "cell_mail", PATH_POPUP_MAIL)
		list:insertNodeAtLast(pCell)
		count = list:getNodeCount()
	end
	list:reloadData()    

	for k,v in pairs(mail_content) do
		local id,mailid,types,time,statue,items,param= v[1],v[2],v[3],v[4],v[5],v[6],v[7]
		local node = list:getNodeAtIndex(k-1)
		local layout_mail = node:getChildByTag(Tag_popup_mail.LAYOUT_MAIL_CELL)
		local layout_item = layout_mail:getChildByTag(Tag_popup_mail.LAYOUT_ITEM_IMG)
		local img = TextureManager.createImg("pet/".. k ..".png")
		Utils.addCellToParent(img, layout_item)
		
		-- local btnContent = layout_mail:getChildByTag(Tag_popup_mail.BTN_CONTENT)
		local lab_title = layout_mail:getChildByTag(Tag_popup_mail.LAB_MAIL_TITLE)
		local lab_date  = layout_mail:getChildByTag(Tag_popup_mail.LAB_MAIL_DATE)

		local mailTitle = TextManager.getMailDesc(mailid)
		lab_title:setString(mailTitle.name)
		lab_date:setString(time)
		-- local imgMailRead = layout_mail:getChildByTag(Tag_popup_mail.IMG_MAIL_READ)
		-- local img_mail_unread = node:getChildByTag(Tag_popup_mail.IMG_CONTENT_BG)
		-- imgMailRead:setVisible(statue == 1 or false)
		-- btnContent:setVisible(statue == 0 or false)
		local function event_mailcontent()
			local mail = Maildataproxy:getInstance()
			mail:set("mail_index",mailid)
			mail:set("id",id)
			mail:set("mailid",mailid)
			mail:set("mail_type",types)
			mail:set("item",items)
			mail:set("param",param)
			local function event_changemailstate()
				if types == 1 then  
					list:removeNode(node)
					list:reloadData()
					if list:getNodeCount() <=0 then --当没有邮件取消小红点提示
						PromtManager.NewsTable.MAIL.status = false
						PromtManager.checkOnePromt("MAIL")
					end
				end
				statue = 1
			end
			local proxy = NormalDataProxy:getInstance()
			proxy.confirmHandler = event_changemailstate
			
			Utils.runUIScene("MailcontentPopup")
		end
		-- btnContent:setOnClickScriptHandler(event_mailcontent)

		local noMove  = true
		local xx,yy = nil
		local function onTouchBegan(p_sender, touch)
			local selfLocation = list:convertTouchToNodeSpace(touch)
			local location  = layout_mail:convertTouchToNodeSpace(touch)
			local size = layout_mail:getContentSize()
			xx,yy = selfLocation.x,selfLocation.y
			local rect = cc.rect(0,0,size.width,size.height)
			if cc.rectContainsPoint(rect, location) then
				noMove = true
			end
			layout_mail:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,0.95),cc.ScaleTo:create(0.05,1)))
			return Constants.TOUCH_RET.TRANSIENT
		end
		local function onTouchMoved( p_sender,touch )

			local location = layout_mail:convertTouchToNodeSpace(touch)
			local distanceX, distanceY = math.floor(location.x-xx),math.floor(location.y-yy)
			if math.abs(distanceX) > 30 and math.abs(distanceY)>30 then
				noMove = false
			end
			-- layout_mail:setScale(1)
			return Constants.TOUCH_RET.TRANSIENT
		end
		local function onTouchEnded(p_sender, touch, duration)
			layout_mail:setScale(1)
			if noMove == true  then
				event_mailcontent()
				
			end
			-- layout_mail:setScale(1)
			noMove = true
			return Constants.TOUCH_RET.TRANSIENT
		end
		layout_mail:setOnTouchBeganScriptHandler(onTouchBegan)
		layout_mail:setOnTouchMovedScriptHandler(onTouchMoved)
		layout_mail:setOnTouchEndedScriptHandler(onTouchEnded)

	end
	local function onNodeEvent(event)
		if "enter" == event then
			self:show()
			NormalDataProxy:getInstance():set("isPopup",true)
		end
		if "exit" == event then
			NormalDataProxy:getInstance():set("isPopup",false)
		end
	end
	self:registerScriptHandler(onNodeEvent)
	TouchEffect.addTouchEffect(self)
end