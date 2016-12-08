require "view/tagMap/Tag_cell_player"

PlayerCell= class("PlayerCell",function()
	return CLayout:create()
end)

PlayerCell.__index = PlayerCell
local __instance = nil
local scheduleID = nil

function PlayerCell:create()
	local ret = PlayerCell.new()
	__instance = ret
	__instance:init()

    local function onNodeEvent(event)
        local function updatePlayerHandler()
            ret:updateUI()
        end
        local updatePlayerListener = cc.EventListenerCustom:create("event_update_player", updatePlayerHandler)
        if event == "enter" then
            ret:getEventDispatcher():addEventListenerWithFixedPriority(updatePlayerListener, 1)
        elseif event == "exit" then
            ret:getEventDispatcher():removeEventListener(updatePlayerListener)
        end
    end
    return ret
end


function PlayerCell:getControl(tagControl)
	local ret = nil
	ret = self:getChildByTag(tagControl)
	return ret
end

---------------logic----------------------------
local progExp = nil
local progEnergy = nil
local labProgExp = nil
local labProgEnergy = nil
local labGold = nil
local labDiamond = nil
local labLevel = nil
local labVip = nil
local labName = nil
local img_player = nil


local function event_prog_exp(p_sender, n_value)
	-- progExp:setValue(n_value)
	-- print("progExpTest :"..n_value)
end

local function event_prog_energy(p_sender, n_value)
	-- progEnergy:setValue(n_value)
	-- print("progEnergyTest :"..n_value)
end

function PlayerCell:updateUI()
	local player = Player:getInstance()
	local exp, maxExp = player:get("exp"), player:get("maxExp")
	local energy, maxEnergy = player:get("energy"), player:get("maxEnergy")
	local maxEnergy = ConfigManager.getUserConfig(player:get("level")).max_energy
	labEnergy:setString(player:get("energy") .. "/" .. maxEnergy)
	labGold:setString(player:get("gold"))
	labDiamond:setString(player:get("diamond"))
	labLevel:setString(player:get("level"))
	labVip:setString(player:get("vip"))
	labName:setString(player:get("nickname"))
	-- labName:setHspacing(0.1)
	-- print("finished!")
end

local function callback_buy_energy(result)
	Player:getInstance():set("energy",result["energy"])
	Player:getInstance():set("buyedEnergyCount",result["buyedEnergyCount"])
	__instance:updateUI()
end

function PlayerCell:changePlayerNameEvent(event)
	labName:setString(event._usedata)
	-- print("changeName")
end


function PlayerCell:changePlayerIconEvent(event)
	local layoutIcon = layoutPlayerInfo:getChildByTag(Tag_cell_player.LAYOUT_PLAYER_ICON)
	layoutIcon:removeAllChildren()
	local img = TextureManager.createImg(TextureManager.RES_PATH.PLAYER_HEAD,event._usedata)
	Utils.addCellToParent(img,layoutIcon)
end

function PlayerCell:init()
	TuiManager:getInstance():parseCell(self, "cell_player", PATH_CELL_PLAYER)
	layoutPlayerInfo = self:getControl(Tag_cell_player.LAYOUT_PET_INFO)
	-- labGold = self:getControl(Tag_cell_player.LAB_GOLD_NUM)
	-- labDiamond = self:getControl(Tag_cell_player.LAB_DIAMOND_NUM)
	labLevel = layoutPlayerInfo:getChildByTag(Tag_cell_player.LAB_LEVEL_NUM)
	labVip = layoutPlayerInfo:getChildByTag(Tag_cell_player.LAB_VIP_NUM)
	labName = layoutPlayerInfo:getChildByTag(Tag_cell_player.LAB_PLAY_NAME)
	img_player = layoutPlayerInfo:getChildByTag(Tag_cell_player.IMG_PORTRAIT)
	labEnergy = layoutPlayerInfo:getChildByTag(Tag_cell_player.LAB_ENERGY)
	-- buyGold = self:getControl(Tag_cell_player.BTN_GOLD)--购买金币    
	-- buyDiamond = self:getControl(Tag_cell_player.BTN_DIAMOND)--购买钻石
	-- buyEnergy = self:getControl(Tag_cell_player.BTN_ENERGY)  --购买体力
	local layout_addgold = self:getControl(Tag_cell_player.LAYOUT_ADDGOLD)
	local layout_adddiamond = self:getControl(Tag_cell_player.LAYOUT_ADDDIAMOND)
	labGold = layout_addgold:getChildByTag(Tag_cell_player.LAB_GOLD_NUM)
	labDiamond = layout_adddiamond:getChildByTag(Tag_cell_player.LAB_DIAMOND_NUM)

	local layoutIcon = layoutPlayerInfo:getChildByTag(Tag_cell_player.LAYOUT_PLAYER_ICON)
	local img = TextureManager.createImg(TextureManager.RES_PATH.PLAYER_HEAD,Player:getInstance():get("role"))
	Utils.addCellToParent(img,layoutIcon)

	layout_addgold:setOnTouchBeganScriptHandler(function()
		local goldhandCommon = ConfigManager.getGoldhandCommonConfig('openlevel')
		if Player:getInstance():get("level") >= goldhandCommon then
			Utils.runUIScene("GoldhandPopup")
		else
			MusicManager.error_tip()
			local msg = "该功能"..goldhandCommon.."级后开启"
	        TipManager.showTip(msg)
	    end
		return false
	end)
	
	layout_adddiamond:setOnTouchBeganScriptHandler(function()
		Utils.runUIScene("RechargePopup")
		return false
	end)

	layoutPlayerInfo:setOnTouchBeganScriptHandler(function ()
		Utils.runUIScene("RoleIconPopup")
		return false
	end)

	local regsitImg = self:getControl(Tag_cell_player.BTN_REGISTRATION)
	PromtManager.addRedSpot(regsitImg,1,"WEEKGIFT") --添加红点监听

	local function event_regist(p_sender )
		if ConfigManager.getSevenCommonConfig('openlevel') > Player:getInstance():get("level") then
			TipManager.showTip("该功能".. ConfigManager.getSevenCommonConfig('openlevel') .."级后开启")
		else
			local function loaddailyattendance( result )
				Dailyattendancedataproxy.attendanceList = result
				Utils.replaceScene("WeekGiftUI")
			end
			NetManager.sendCmd("loadweekgift",loaddailyattendance,0)
		end
	end
	regsitImg:setOnClickScriptHandler(event_regist)

	local changeNameListener = cc.EventListenerCustom:create("change_player_name", function(event) 
		if self.changePlayerNameEvent then
			self:changePlayerNameEvent(event)
		end
    end)
    self.changeNameListener = changeNameListener
    self:getEventDispatcher():addEventListenerWithFixedPriority(changeNameListener, 1)

    local changeIconListener = cc.EventListenerCustom:create("change_player_icon", function(event) 
    	if self.changePlayerIconEvent then
    		self:changePlayerIconEvent(event)
    	end
    end)
    self.changeIconListener = changeIconListener
    self:getEventDispatcher():addEventListenerWithFixedPriority(changeIconListener, 1)

	local actImg = self:getControl(Tag_cell_player.BTN_ACT)--活动
	PromtManager.addRedSpot(actImg,1,"DAILY_SIGN") --添加红点监听
	PromtManager.addRedSpot(actImg,1,"SUPER_SIGN") --添加红点监听
	PromtManager.addRedSpot(actImg,1,"RECOVER_ENERGY") --添加红点监听

	local function event_trial(p_sender)
		Utils.replaceScene("ActivityUI")
	end
	actImg:setOnClickScriptHandler(event_trial)
	
	local dailyTask = self:getControl(Tag_cell_player.BTN_DAILY) --日常
	PromtManager.addRedSpot(dailyTask,1,"DAILYTASK_FINISH") --添加红点监听
	local  function event_dailytask(p_sender)
		Utils.runUIScene("DailyPopup")  --跳转到日常页面
	end
	dailyTask:setOnClickScriptHandler(event_dailytask)

	local task = self:getControl(Tag_cell_player.BTN_TASK)
	PromtManager.addRedSpot(task,1,"ACHIEVEMENT_FINISH") --添加红点监听
	local function event_task( p_sender)
		local function loadachievement(result)
			AchievementDataProxy.achievementList = result
			Utils.runUIScene("AchievementPopup")
		end
		NetManager.sendCmd("loadachievement",loadachievement)
	end
	task:setOnClickScriptHandler(event_task)

	local snsImg = self:getControl(Tag_cell_player.BTN_CHAT) --日常
	local  function event_sns(p_sender)
		Utils.runUIScene("DailyPopup")  --跳转到日常页面
	end
	dailyTask:setOnClickScriptHandler(event_dailytask)
	self:updateUI()
 	Utils.floatToTop(self)
 	
	local btnWild = self:getControl(Tag_cell_player.BTN_WILD)
	PromtManager.addRedSpot(btnWild,1,"WILD") --添加红点监听
	btnWild:setOnClickScriptHandler(function()  Utils.replaceScene("WildUI")   end)
	local function onNodeEvent(event)
		if "enter" == event then
			NormalDataProxy:getInstance():set("isPlayerCell",true)
			local function updateUser()
				self:updateUI()
			end
			NormalDataProxy:getInstance().updateUser = updateUser

			local player = Player:getInstance()
			local maxEnergy = ConfigManager.getUserConfig(player:get("level")).max_energy
			local energy_recover_time = ConfigManager.getUserCommonConfig('energy_recover_time')
			if player:get("energy")<maxEnergy then
				-- print("==dddd=  energy=")
				scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
					player:set("energy",player:get("energy")+1)
					if NormalDataProxy:getInstance().updateUser then
						NormalDataProxy:getInstance().updateUser()
					end
					
					if player:get("energy")>=maxEnergy then
						cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID)
						scheduleID = nil
					end
				end,energy_recover_time, false)
			end
		end
		if "exit" == event then
			NormalDataProxy:getInstance():set("isPlayerCell",false)
			NormalDataProxy:getInstance().updateUser = nil
			if scheduleID then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID)
				scheduleID = nil
			end
		end
	end
	self:registerScriptHandler(onNodeEvent)
end


