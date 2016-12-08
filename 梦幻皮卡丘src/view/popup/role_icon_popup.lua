require "view/tagMap/Tag_popup_role_icon"

RoleIconPopup = class("RoleIconPopup",function()
	return Popup:create()
end)

RoleIconPopup.__index = RoleIconPopup
local __instance = nil
local list  = nil

function RoleIconPopup:create()
	local ret = RoleIconPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function RoleIconPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function RoleIconPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_role_icon.PANEL_POPUP_ROLE_ICON then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function RoleIconPopup:changeIconEvent( event )
	local index = event._usedata
	layoutIcon:removeAllChildren()
	local img = TextureManager.createImg(TextureManager.RES_PATH.PLAYER_HEAD,index)
	Utils.addCellToParent(img,layoutIcon)
	
	local customEvent = cc.EventCustom:new("change_player_icon")
	customEvent._usedata = event._usedata
	cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
end

function RoleIconPopup:changeNameEvent( event )
	labName:setString(event._usedata)
	local customEvent = cc.EventCustom:new("change_player_name")
	customEvent._usedata = event._usedata
	cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
end

function RoleIconPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_role_icon",PATH_POPUP_ROLE_ICON)
	local btnClose = self:getControl(Tag_popup_role_icon.PANEL_POPUP_ROLE_ICON,Tag_popup_role_icon.BTN_CLOSE)
	btnClose:setOnClickScriptHandler(function ()
		Utils.popUIScene(self)
	end)
	
	local lab_vip_num = self:getControl(Tag_popup_role_icon.PANEL_POPUP_ROLE_ICON,Tag_popup_role_icon.LAB_VIP_NUM)
	lab_vip_num:setString(Player:getInstance():get("vip"))
	layoutIcon = self:getControl(Tag_popup_role_icon.PANEL_POPUP_ROLE_ICON,Tag_popup_role_icon.LAYOUT_ICON)
	local img = TextureManager.createImg(TextureManager.RES_PATH.PLAYER_HEAD,Player:getInstance():get("role"))
	Utils.addCellToParent(img,layoutIcon)

	local changeIocnListener = cc.EventListenerCustom:create("event_change_icon", function(event) 
		if self.changeIconEvent then
			 self:changeIconEvent(event)
		end
    end)
    self.changeIocnListener = changeIocnListener
    self:getEventDispatcher():addEventListenerWithFixedPriority(changeIocnListener, 1)

	local name = Player:getInstance():get("nickname")
	labName = self:getControl(Tag_popup_role_icon.PANEL_POPUP_ROLE_ICON,Tag_popup_role_icon.LAB_PLAYER_NAME)
	labName:setString(name)
	local changeNameListener = cc.EventListenerCustom:create("event_change_name", function(event) 
        self:changeNameEvent(event)
    end)
    self.changeNameListener = changeNameListener
    self:getEventDispatcher():addEventListenerWithFixedPriority(changeNameListener, 1)
    --体力进度条
	local progExp = self:getControl(Tag_popup_role_icon.PANEL_POPUP_ROLE_ICON,Tag_popup_role_icon.PROG_EXP)
	local exp = Player:getInstance():get("exp")
	local maxExp = ConfigManager.getUserConfig(Player:getInstance():get("level")).max_exp
	progExp:setValue(100*exp/maxExp)

	local labExp = self:getControl(Tag_popup_role_icon.PANEL_POPUP_ROLE_ICON,Tag_popup_role_icon.LAB_EXP)
	labExp:setString(exp .. "/" .. maxExp)

	local lab_uid = self:getControl(Tag_popup_role_icon.PANEL_POPUP_ROLE_ICON, Tag_popup_role_icon.LAB_ID)
	lab_uid:setString(Player:getInstance():get("uid"))

	local lab_pet_level_limit = self:getControl(Tag_popup_role_icon.PANEL_POPUP_ROLE_ICON, Tag_popup_role_icon.LAB_LEVEL_UP)
	lab_pet_level_limit:setString(Player:getInstance():get("level"))

	local level = Player:getInstance():get("level")
	local labLevel = self:getControl(Tag_popup_role_icon.PANEL_POPUP_ROLE_ICON,Tag_popup_role_icon.LAB_LEVEL)
	labLevel:setString(level)

	local energy = Player:getInstance():get("energy")
	local maxEnergy = ConfigManager.getUserConfig(Player:getInstance():get("level")).max_energy
	local progEnergy = self:getControl(Tag_popup_role_icon.PANEL_POPUP_ROLE_ICON,Tag_popup_role_icon.PROG_ENERGY)
	progEnergy:setValue(100*energy/maxEnergy)
	local labEnergy = self:getControl(Tag_popup_role_icon.PANEL_POPUP_ROLE_ICON,Tag_popup_role_icon.LAB_ENERGY)
	labEnergy:setString(energy .. "/" .. maxEnergy)
	--购买体力
	local btnBuyEnergy = self:getControl(Tag_popup_role_icon.PANEL_POPUP_ROLE_ICON,Tag_popup_role_icon.BTN_BUYENERGY)
	local function updateEnergyProg()
		if labEnergy then
			labEnergy:setString(Player:getInstance():get("energy") .. "/" .. maxEnergy)
		end
		if progEnergy then
			progEnergy:setValue(100 * Player:getInstance():get("energy") / maxEnergy)
		end
	end
	NormalDataProxy:getInstance().updateEnergyProg = updateEnergyProg
	btnBuyEnergy:setOnClickScriptHandler(function ()
		Utils.buyEnergy()
	end)
	--更改名字
	local btnChangeName = self:getControl(Tag_popup_role_icon.PANEL_POPUP_ROLE_ICON,Tag_popup_role_icon.BTN_CHANGENAME)
	btnChangeName:setOnClickScriptHandler(function(  )
		local function randomname( result )
			PlayerProxy:getInstance():set("randomName",result["name"])
			Utils.runUIScene("ChangeNamePopup")
		end
		NetManager.sendCmd("randomname",randomname)
	end)
	--更改头像
	local btnChangeIcon = self:getControl(Tag_popup_role_icon.PANEL_POPUP_ROLE_ICON,Tag_popup_role_icon.BTN_CHANGEICON)
	btnChangeIcon:setOnClickScriptHandler(function(  )
		local function loadunlockedrole( result )
			PlayerProxy:getInstance():set("role_id",result["role"])
			Utils.runUIScene("ChangeIconPopup")
		end
		NetManager.sendCmd("loadunlockedrole",loadunlockedrole)
	end)
	
	local function onNodeEvent(event)
		if "enter" == event then
			self:show()
			NormalDataProxy:getInstance():set("isPopup",true)
			TouchEffect.addTouchEffect(self)
		end
		if "exit" == event then
			NormalDataProxy:getInstance():set("isPopup",false)
		end
	end
	self:registerScriptHandler(onNodeEvent)
end