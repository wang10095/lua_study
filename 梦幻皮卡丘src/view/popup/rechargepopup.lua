--
-- Author: hapigames
-- Date: 2014-12-10 20:02:04
--
require "view/tagMap/Tag_popup_topup"

RechargePopup = class("RechargePopup",function()
	return Popup:create()
end)

RechargePopup.__index = RechargePopup
local __instance = nil
local status  = 0
local btn_rightarrow,btn_leftarrow
local gvRecharge

function RechargePopup:create()
	local ret = RechargePopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function RechargePopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function RechargePopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_topup.PANEL_POPUP_TOPUP then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_close()
	if NormalDataProxy:getInstance():get("isDaliyPursue") then
		Utils.popUIScene(__instance)
		Utils.runUIScene("DailyPopup")
		return
	end
	if NormalDataProxy:getInstance().confirmHandler then
		NormalDataProxy:getInstance().confirmHandler()
	end
	NormalDataProxy:getInstance().confirmHandler  = nil
	Utils.popUIScene(__instance)
end

function RechargePopup:onLoadScene()
	status  = 0
	local  rechargeTable = {}
	TuiManager:getInstance():parseScene(self,"panel_popup_topup",PATH_POPUP_TOPUP)
	local btnClose = self:getControl(Tag_popup_topup.PANEL_POPUP_TOPUP,Tag_popup_topup.BTN_CLOSE)
	btnClose:setOnClickScriptHandler(event_close)	

	local img_vip_title = self:getControl(Tag_popup_topup.PANEL_POPUP_TOPUP,Tag_popup_topup.IMG_VIP_TITLE)
	local img_recharge_title = self:getControl(Tag_popup_topup.PANEL_POPUP_TOPUP,Tag_popup_topup.IMG_RECHARGE_TITLE)
	local layout_vip = self:getControl(Tag_popup_topup.PANEL_POPUP_TOPUP,Tag_popup_topup.LAYOUT_VIPLEVEL)
	btn_privilege = self:getControl(Tag_popup_topup.PANEL_POPUP_TOPUP,Tag_popup_topup.BTN_PRIVILEGE) --充值 特权
	labTitle = self:getControl(Tag_popup_topup.PANEL_POPUP_TOPUP,Tag_popup_topup.LAB_TITLE)
	gvRecharge = self:getControl(Tag_popup_topup.PANEL_POPUP_TOPUP,Tag_popup_topup.GV_RECHARGE)
	gpv_privilege = self:getControl(Tag_popup_topup.PANEL_POPUP_TOPUP,Tag_popup_topup.PV_RECHARGE)
	btn_rightarrow = self:getControl(Tag_popup_topup.PANEL_POPUP_TOPUP,Tag_popup_topup.BTN_RIGHTARROW)
 	btn_leftarrow = self:getControl(Tag_popup_topup.PANEL_POPUP_TOPUP,Tag_popup_topup.BTN_LEFTARROW)
	local prog_exp_progress = self:getControl(Tag_popup_topup.PANEL_POPUP_TOPUP,Tag_popup_topup.PROG_EXP_PROGRESS)
	local lab_progress = self:getControl(Tag_popup_topup.PANEL_POPUP_TOPUP,Tag_popup_topup.LAB_PROGRESS)
	local lab_vip_tips = self:getControl(Tag_popup_topup.PANEL_POPUP_TOPUP,Tag_popup_topup.LAB_VIP_TIPS)

	local function event_loadrechargestatus(check)
		NetManager.sendCmd("loadrechargestatus",function(result)
			if check == true then
				PromtManager.checkAll()
			end
			rechargeTable = {}
			rechargeTable = result
			if Player:getInstance():get("vip")==15 then
				prog_exp_progress:setValue(100)
				lab_progress:setString("VIP满级")
				lab_vip_tips:setString("")
			else
				local hadReacharge = result["recharge_num"] 
				local nextVipLevelDiamond = ConfigManager.getVipConfig(Player:getInstance():get("vip")+1).money_num
				prog_exp_progress:setValue(100*hadReacharge/nextVipLevelDiamond)
				lab_progress:setString(hadReacharge .. '/' .. nextVipLevelDiamond)

				local nextVipMoney = ConfigManager.getVipConfig(Player:getInstance():get("vip")+1).money_num
				local needMoney = nextVipMoney-hadReacharge
				lab_vip_tips:setString("再充值" .. needMoney .. "￥即可成为VIP" .. Player:getInstance():get("vip")+1)
			end
			local function event_adapt_gvactive(p_convertview, idx)
				local pCell = p_convertview
				-- if pCell == nil then
					pCell = CGridViewCell:new()
					TuiManager:getInstance():parseCell(pCell, "cell_recharge", PATH_POPUP_TOPUP)
					local layoutRecharge = pCell:getChildByTag(Tag_popup_topup.LAYOUT_RECHARGE)
					local rechargeConfig = ConfigManager.getRechargeConfig(idx+1)
				
					local img_first_recharge = layoutRecharge:getChildByTag(Tag_popup_topup.IMG_FIRST_RECHARGE)
					local img_charge = layoutRecharge:getChildByTag(Tag_popup_topup.IMG_CHARGE)
					local lab_reward_diamond = layoutRecharge:getChildByTag(Tag_popup_topup.LAB_REWARD_DIAMOND)
					local lab_recharge_diamond = layoutRecharge:getChildByTag(Tag_popup_topup.LAB_RECHARGE_DIAMOND)
					local lab_money = layoutRecharge:getChildByTag(Tag_popup_topup.LAB_MONEY)
					local lab_currency = layoutRecharge:getChildByTag(Tag_popup_topup.LAB_CURRENCY)

					if idx+1==1 then
						img_first_recharge:setVisible(false)
						lab_recharge_diamond:setString(rechargeConfig.title)
						lab_reward_diamond:setString("每天领取" .. rechargeConfig.diamond_num ..  "钻石")
					else
						lab_recharge_diamond:setString(rechargeConfig.diamond_num .. "钻石")
						lab_reward_diamond:setString(rechargeConfig.first_desc)
					end
					
					lab_money:setString(rechargeConfig.rmb)
					if idx+1 <4  then
						img_charge:setSpriteFrame("popup_recharge/img_charge_" .. idx+1 ..".png")
					elseif idx+1==4 or idx+1 == 5 then
						img_charge:setSpriteFrame("popup_recharge/img_charge_" .. 4 ..".png")
					else
						img_charge:setSpriteFrame("popup_recharge/img_charge_" .. 5 ..".png")
					end

					for i,v in ipairs(rechargeTable["buyTimes"]) do
						if idx+1 == v["id"] and v["times"]>=1 then
							img_first_recharge:setVisible(false)
							if rechargeConfig.common_append >0 then
								lab_reward_diamond:setString("赠送" .. rechargeConfig.common_append .. "钻石")
							elseif v["id"]==1 then
								lab_reward_diamond:setString("每天领取" .. rechargeConfig.diamond_num ..  "钻石")
							else
								lab_reward_diamond:setString("")
							end
						end
					end
					local noMove  = true
					local xx,yy = nil
					local listener = cc.EventListenerTouchOneByOne:create()
					listener:setSwallowTouches(false)
					listener:registerScriptHandler(function(touch,event)
						local selfLocation = gvRecharge:convertTouchToNodeSpace(touch)
						xx,yy = selfLocation.x,selfLocation.y
						local size = layoutRecharge:getContentSize()
						local location  = layoutRecharge:convertTouchToNodeSpace(touch)
						if  status == 0 and size  and location.x >0 and location.x < size.width and location.y > 0 and location.y < size.height and  PetAttributeDataProxy:getInstance():get("isPopup")==false then
							layoutRecharge:setScale(0.95)
							return true
						end
					 end,cc.Handler.EVENT_TOUCH_BEGAN)   
					listener:registerScriptHandler(function(touch,event)
						local location = gvRecharge:convertTouchToNodeSpace(touch)
						local distanceX,distanceY = math.floor(location.x-xx),math.floor(location.y-yy)
						if not (math.abs(distanceX) < 30 and math.abs(distanceY) < 30) then
							noMove = false
							layoutRecharge:setScale(1.0)
						end
					end,cc.Handler.EVENT_TOUCH_MOVED )
					listener:registerScriptHandler(function()
						if noMove == true then
							-- TDGAVirtualCurrency:onChargeRequest("order00wwwasdf090","recharge ".. rechargeConfig.diamond_num .." diamond",rechargeConfig.rmb,"CNY",rechargeConfig.diamond_num,"AlipPay")
							NetManager.sendCmd("recharge",function(result)
								-- TDGAVirtualCurrency:onChargeSuccess("order00wwwasdf090")
								Player:getInstance():set("diamond",result["diamond"])
								Player:getInstance():set("vip",result["vip"])
								layout_vip:removeAllChildren()
								local imgVip = TextureManager.createImg("popup_recharge/" .. Player:getInstance():get("vip") ..".png")
								Utils.addCellToParent(imgVip,layout_vip)
							
								if NormalDataProxy:getInstance().updateUser  then
									NormalDataProxy:getInstance().updateUser()
								end
								if NormalDataProxy:getInstance():get("isWeekGift") and idx + 1 < 5 then
									print("充值成功，返回领取奖励")
									Utils.dispatchCustomEvent("week_gift_recharge",nil)
									Utils.popUIScene(self)
									return
								end
								local eventDispatcher = self:getEventDispatcher()
								local event = cc.EventCustom:new("recharge_update_diamond")
								eventDispatcher:dispatchEvent(event)
								local function showRecharge()
									TipManager.showTip("充值成功 当前钻石" .. result["diamond"])
								end
								if Shopdataproxy:getInstance():get("isRecharge") then
									Utils.popUIScene(self,showRecharge)
									return
								end
								event_loadrechargestatus(true)
								TipManager.showTip("充值成功 当前钻石" .. result["diamond"])
							end,idx+1)
						end
						layoutRecharge:setScale(1.0)
						noMove = true
					 end,cc.Handler.EVENT_TOUCH_ENDED)  
					local eventDispatcher = layoutRecharge:getEventDispatcher() -- 时间派发器 
					eventDispatcher:addEventListenerWithSceneGraphPriority(listener,layoutRecharge)
				-- end
				return pCell
			end
			gvRecharge:setCountOfCell(7) 
			gvRecharge:setDataSourceAdapterScriptHandler(event_adapt_gvactive)
			gvRecharge:reloadData()
		end)
	end
	event_loadrechargestatus(false)
------------------------------
	local function updateGV(p_convertview,idx)
		local pCell = p_convertview
		-- if pCell == nil then
			pCell = CGridViewCell:new()
			TuiManager:getInstance():parseCell(pCell, "cell_privilege", PATH_POPUP_TOPUP)
			local items = ConfigManager.getVipConfig(idx+1).items
			for i=1,#items do
				local layout_pet = pCell:getChildByTag(Tag_popup_topup["LAYOUT_PRIVILEGE_".. i])
				local lab_num = pCell:getChildByTag(Tag_popup_topup["LAB_PRIVILEGE_NUM" .. i])
				if items[i][1]==1 then
					local pet = Pet:create()
					pet:set("id",1)
					pet:set("mid",items[i][2])
					pet:set("star",1)
					local petCell = PetCell:create(pet)
					Utils.addCellToParent(petCell,layout_pet,true)
					Utils.showPetInfoTips(layout_pet, pet:get("mid"), pet:get("form"))
					lab_num:setString("")
				else
					local item = ItemManager.createItem(items[i][1], items[i][2])
					local itemCell = ItemCell:create(items[i][1],item)
					Utils.addCellToParent(itemCell, layout_pet,true)
					Utils.showItemInfoTips(layout_pet, item)
					lab_num:setString(items[i][3])
				end
			end

			for i=#items+1,3 do
				local lab_num = pCell:getChildByTag(Tag_popup_topup["LAB_PRIVILEGE_NUM" .. i])
				lab_num:setString("")
			end
			local img9_recharge_bg4 = pCell:getChildByTag(Tag_popup_topup.IMG9_RECHARGE_BG4)
			img9_recharge_bg4:setOpacity(255*0.75)
			local lab_vip_title = pCell:getChildByTag(Tag_popup_topup.LAB_VIP_TITLE)
			lab_vip_title:setString('VIP' .. idx+1 .. '  等级特权')
			local lab_privilege_tips = pCell:getChildByTag(Tag_popup_topup.LAB_PRIVILEGE_TIPS)
			local vipDiamond = ConfigManager.getVipConfig(idx+1).money_num
			local msp = '需要累计充值' .. vipDiamond ..'￥\n'
			if idx+1 > 1  then
				msp = msp .. '包含VIP' .. idx .. '所有特权'
			end
			lab_privilege_tips:setString(msp)
			lab_privilege_tips:setVerticalAlignment(1)

			local lab_everyday = pCell:getChildByTag(Tag_popup_topup.LAB_EVERYDAY)
			local vipdesc = TextManager.getVipDesc(idx+1)
			local desc = ''
			for i,v in ipairs(vipdesc) do
				print(i,v)
				desc = desc .. v .. '\n'
			end
			lab_everyday:setString(desc)
		-- end
		return pCell
	end

	gpv_privilege:setCountOfCell(15)
	gpv_privilege:setDataSourceAdapterScriptHandler(updateGV)
	gpv_privilege:reloadData()
	gpv_privilege:setVisible(false)
	scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function() 
	     local xx = gpv_privilege:getContentOffset().x
	     if xx > 0-5 and status == 1 then
	     	if xx>0 then
	     		gpv_privilege:setContentOffset(cc.p(0,0))
	     	end
	     	btn_rightarrow:setVisible(true)
			btn_leftarrow:setVisible(false)
	     elseif xx < -14 * 548 +5 and status == 1 then
	     	if xx < -14 * 548 then
	     		gpv_privilege:setContentOffset(cc.p(-14*548,0))
	     	end
	     	btn_rightarrow:setVisible(false)
			btn_leftarrow:setVisible(true)
	     elseif status == 1 then
			btn_rightarrow:setVisible(true)
			btn_leftarrow:setVisible(true)
	     end
	end, 0, false)

	img_vip_title:setVisible(false)
	local function event_privilege(p_sender)
		if status == 0 then
			gpv_privilege:setVisible(true)
			gvRecharge:setVisible(false)
			labTitle:setString("充值")
			btn_rightarrow:setVisible(true)
			btn_leftarrow:setVisible(true)
			img_vip_title:setVisible(true)
			img_recharge_title:setVisible(false)
			status = 1
		else
			gpv_privilege:setVisible(false)
			gvRecharge:setVisible(true)
			btn_rightarrow:setVisible(false)
			btn_leftarrow:setVisible(false)
			labTitle:setString("VIP特权")
			img_vip_title:setVisible(false)
			img_recharge_title:setVisible(true)
			status = 0
		end
	end

	btn_privilege:setOnClickScriptHandler(event_privilege)
	labTitle:setString("VIP特权")
	local function event_right_arrow()
		local conX = gpv_privilege:getContentOffset().x
		gpv_privilege:setContentOffsetInDuration(cc.p(conX-548,0),0.3)	
	end
	local function event_left_arrow()
		local conX = gpv_privilege:getContentOffset().x
		gpv_privilege:setContentOffsetInDuration(cc.p(conX+548,0),0.3)	
	end

 	btn_rightarrow:setOnClickScriptHandler(event_right_arrow)
 	btn_leftarrow:setOnClickScriptHandler(event_left_arrow)
 	btn_rightarrow:setVisible(false)
	btn_leftarrow:setVisible(false)
		
	local imgVip = TextureManager.createImg("popup_recharge/" .. Player:getInstance():get("vip") ..".png")
	Utils.addCellToParent(imgVip,layout_vip)
	
	TouchEffect.addTouchEffect(self)
	local function onNodeEvent(event)
		if "enter" == event then
			self:show()
			-- NormalDataProxy:getInstance():set("isPopup",true)
		end
		if "exit" == event then
			if scheduleID then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID)
			end
			-- NormalDataProxy:getInstance():set("isPopup",false)
		end
	end
	self:registerScriptHandler(onNodeEvent)
end





