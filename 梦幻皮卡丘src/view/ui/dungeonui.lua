require "view/tagMap/Tag_ui_dungeon"

DungeonUI = class("DungeonUI",function()
	return TuiBase:create()
end)

DungeonUI.__index = DungeonUI
local __instance = nil

function DungeonUI:create()
	local ret = DungeonUI.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function DungeonUI:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function DungeonUI:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_dungeon.PANEL_DUNGEON then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local playercell = nil
local functioncell = nil
local chapterBg = nil

local function event_pvp2()
	MusicManager.error_tip()
	local msg = "该功能尚未开启"
    TipManager.showTip(msg)
	return false
end

local function event_returnMain( p_sender )
	Utils.replaceScene("MainUI",__instance)
end

function DungeonUI:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_dungeon",PATH_UI_DUNGEON)
	
	local layoutTop = self:getControl(Tag_ui_dungeon.PANEL_DUNGEON,Tag_ui_dungeon.LAYOUT_TOP)
	Utils.floatToTop(layoutTop)
	local layouBottom = self:getControl(Tag_ui_dungeon.PANEL_DUNGEON,Tag_ui_dungeon.LAYOUT_DUNGON)
	Utils.floatToBottom(layouBottom)
	local btnReturnMain = layouBottom:getChildByTag(Tag_ui_dungeon.BTN_RETURN)
	btnReturnMain:setOnClickScriptHandler(event_returnMain)

	layoutShop = self:getControl(Tag_ui_dungeon.PANEL_DUNGEON,Tag_ui_dungeon.LAYOUT_SHOP)
	local atlas = TextureManager.RES_PATH.SPINE_TOURNAMENT_SHOP .. ".atlas"
    local json = TextureManager.RES_PATH.SPINE_TOURNAMENT_SHOP .. ".json"
    local spine1 = sp.SkeletonAnimation:create(json, atlas, 1)
	local size = layoutShop:getContentSize()
    spine1:setPosition(Arp(cc.p(size.width/2, 0)))
	
	-- layoutShop:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function( )
		spine1:setAnimation(0,"part1",true)
	-- end)))
	layoutShop:addChild(spine1)
	local function event_shop( p_sender )
		local function loadbuylist( result )
			Shopdataproxy.goodsList = result["list"]
			Shopdataproxy:getInstance().refreshList[Constants.SHOP_TYPE.PRESTIGE_SHOP] = result["refreshTimes"]
			Shopdataproxy:getInstance():set("shop_type",Constants.SHOP_TYPE.PRESTIGE_SHOP)
			Utils.replaceScene("ShopUI",__instance)
		end 
		NetManager.sendCmd("loadbuylist",loadbuylist,Constants.SHOP_TYPE.PRESTIGE_SHOP)
		return false
	end
	layoutShop:setOnTouchBeganScriptHandler(event_shop)
	
	layoutPvp1 = self:getControl(Tag_ui_dungeon.PANEL_DUNGEON,Tag_ui_dungeon.LAYOUT_PVP1)
	local atlas = TextureManager.RES_PATH.SPINE_TOURNAMENT_PVP1 .. ".atlas"
    local json = TextureManager.RES_PATH.SPINE_TOURNAMENT_PVP1 .. ".json"
    local spine2 = sp.SkeletonAnimation:create(json, atlas, 1)
	local size = layoutPvp1:getContentSize()
    spine2:setPosition(Arp(cc.p(size.width/2, size.height/2)))
	spine2:setAnimation(0,"part1",true)

	layoutPvp1:addChild(spine2)
	local function event_pvp1()
		local pvpOPenLevel = ConfigManager.getPvp1CommonConfig('openlevel')
		GoldhandDataProxy:getInstance():set("isborrow",0)
		if Player:getInstance():get("level") >= pvpOPenLevel then
			Utils.replaceScene("SilverChampionshipUI",__instance)
		else
			MusicManager.error_tip()
			local msg = "该功能"..pvpOPenLevel.."级后开启"
	        TipManager.showTip(msg)
	    end
		return true
	end
	local layoutTouchpvp1 = self:getControl(Tag_ui_dungeon.PANEL_DUNGEON,Tag_ui_dungeon.LAYOUT_PVPTOUCH)
	layoutTouchpvp1:setOnTouchBeganScriptHandler(event_pvp1)

	layoutPvp2 = self:getControl(Tag_ui_dungeon.PANEL_DUNGEON,Tag_ui_dungeon.LAYOUT_PVP2)
	Spine.addSpine(layoutPvp2,"tournament","pvp2","part1",true)
	local layoutPvp2Touch = self:getControl(Tag_ui_dungeon.PANEL_DUNGEON,Tag_ui_dungeon.LAYOUT_PVP2TOUCH)
	layoutPvp2Touch:setOnTouchBeganScriptHandler(event_pvp2)
	
	StageRecord:getInstance():set("dungeonType",Constants.DUNGEON_TYPE.ACTIVITY)
	TouchEffect.addTouchEffect(self)
	local function onNodeEvent(event)
		if "enterTransitionFinish"  == event then
			local pvp1OPenLevel = ConfigManager.getPvp1CommonConfig('openlevel')
			if Player:getInstance():get("level") == pvp1OPenLevel then
				Utils.dispatchCustomEvent("event_champion",{view = "DungeonUI",phase = GuideManager.FUNC_GUIDE_PHASES.DUNGEON,scene = self})
			end

		elseif "exit" == event then
			
		end
	end
	self:registerScriptHandler(onNodeEvent)
end 

