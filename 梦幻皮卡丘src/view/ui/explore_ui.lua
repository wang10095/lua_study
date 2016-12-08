require "view/tagMap/Tag_ui_explore"

ExploreUI = class("ExploreUI",function()
	return TuiBase:create()
end)

ExploreUI.__index = ExploreUI
local __instance = nil

function  ExploreUI:create()
	local ret = ExploreUI.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function ExploreUI:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_explore.PANEL_EXPLORE then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function ExploreUI:getControl(tagPanel, tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

local function onLoadBattlePalace( p_sender )
	local activity1Common = ConfigManager.getActivty1CommonConfig('level_limit')
	local week = os.date("*t")
    local WEEK = {7,1,2,3,4,5,6}
    local today = tonumber(WEEK[tonumber(week.wday)])
    if today%2 ~= 0 then 
        Activity1StatusProxy:getInstance():set("activity1Type", Constants.ACTIVITY1_TYPE.CANDY_AREA)
    else
        Activity1StatusProxy:getInstance():set("activity1Type", Constants.ACTIVITY1_TYPE.REGAL_AREA)
    end 
	if Player:getInstance():get("level") >= activity1Common then
		Spine.spineMix(layoutPve1,"explore","palace","part2","part1",false,true)
		Utils.replaceScene("BattlePalaceUI",__instance)
	else
		MusicManager.error_tip()
		local msg = "该功能"..activity1Common.."级后开启"
        TipManager.showTip(msg)
    end
	return false
end

local function event_roulette()
	local activity2Common = ConfigManager.getActivty2CommonConfig('openlevel')
	if Player:getInstance():get("level") >= activity2Common then
		Spine.spineMix(layoutPve2,"explore","tree","part2","part1",false,true)
		Utils.replaceScene("RouletteUI",__instance)
	else
		MusicManager.error_tip()
		local msg = "该功能"..activity2Common.."级后开启"
        TipManager.showTip(msg)
    end
	return false
end

local function event_pyramid()
	local activity3Common = ConfigManager.getActivty3CommonConfig('level_limit')
	if Player:getInstance():get("level") >= activity3Common then
		Spine.spineMix(layoutPve3,"explore","pyramid","part2","part1",false,true)
		Utils.replaceScene("PyramidUI",__instance)
	else
		MusicManager.error_tip()
		local msg = "该功能"..activity3Common.."级后开启"
        TipManager.showTip(msg)
    end
	return false
end

local function event_shop( p_sender )
	local function loadbuylist( result )
		Spine.spineMix(layoutShop,"explore","shop","part2","part1",false,true)
		Shopdataproxy.goodsList = result["list"]
		Shopdataproxy:getInstance().refreshList[Constants.SHOP_TYPE.BADGE_SHOP] = result["refreshTimes"]
		Shopdataproxy:getInstance():set("shop_type",Constants.SHOP_TYPE.BADGE_SHOP)
		Utils.replaceScene("ShopUI",__instance)
	end 
	NetManager.sendCmd("loadbuylist",loadbuylist,Constants.SHOP_TYPE.BADGE_SHOP)
	return false
end

function ExploreUI:onLoadScene()
    TuiManager:getInstance():parseScene(self,"panel_explore",PATH_UI_EXPLORE)
    local exploreTop = self:getControl(Tag_ui_explore.PANEL_EXPLORE, Tag_ui_explore.LAYOUT_EXPLORE_TOP)
    Utils.floatToTop(exploreTop)

   	layoutShop = self:getControl(Tag_ui_explore.PANEL_EXPLORE,Tag_ui_explore.LAYOUT_SHOP)
   	Spine.addSpine(layoutShop,"explore","shop","part1",true)
    layoutShop:setOnTouchBeganScriptHandler(event_shop) --进入战斗宫殿

    layoutPve1 = self:getControl(Tag_ui_explore.PANEL_EXPLORE,Tag_ui_explore.LAYOUT_ACTIVITY1)
    Spine.addSpine(layoutPve1,"explore","palace","part1",true)
    layoutPve1:setOnTouchBeganScriptHandler(onLoadBattlePalace) --进入战斗宫殿

    layoutPve2 = self:getControl(Tag_ui_explore.PANEL_EXPLORE,Tag_ui_explore.LAYOUT_ACTIVITY2)
    Spine.addSpine(layoutPve2,"explore","tree","part1",true)
    layoutPve2:setOnTouchBeganScriptHandler(event_roulette) 
    
    layoutPve3 = self:getControl(Tag_ui_explore.PANEL_EXPLORE,Tag_ui_explore.LAYOUT_ACTIVITY3)
    Spine.addSpine(layoutPve3,"explore","pyramid","part1",true)
    layoutPve3:setOnTouchBeganScriptHandler(event_pyramid)
    
    local layoutMain = self:getControl(Tag_ui_explore.PANEL_EXPLORE,Tag_ui_explore.LAYOUT_MIAN)
    Spine.addSpine(layoutMain,"explore","main","part1",true)

    local layoutBird = self:getControl(Tag_ui_explore.PANEL_EXPLORE,Tag_ui_explore.LAYOUT_BIRD)
    Spine.addSpine(layoutBird,"explore","main_bird","part1",true)
    -- local btnShop = self:getControl(Tag_ui_explore.PANEL_EXPLORE,Tag_ui_explore.BTN_SHOP)
    -- btnShop:setOnClickScriptHandler(event_shop)
    
 --    local layoutCloud1 = self:getControl(Tag_ui_explore.PANEL_EXPLORE,Tag_ui_explore.LAYOUT_CLOUD1)
	-- local layoutCloud2 = self:getControl(Tag_ui_explore.PANEL_EXPLORE,Tag_ui_explore.LAYOUT_CLOUD2)
	-- local cloud1 = TextureManager.createImg("ui_main/yun1.png")
	-- local cloud2 = TextureManager.createImg("ui_main/yun2.png")
	-- Utils.addCellToParent(cloud1,layoutCloud1)
	-- Utils.addCellToParent(cloud2,layoutCloud2)
	-- local Pos1 = cc.p(layoutCloud1:getPosition())
 --    local Pos2 = cc.p(layoutCloud2:getPosition())
 --    local function CallFucnCallback1 ()
 --    	layoutCloud1:setPosition(cc.p(768,Pos1.y))
 --    end
 --    local function CallFucnCallback2()
 --    	layoutCloud2:setPosition(cc.p(768,Pos2.y))
 --    end
	-- layoutCloud1:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(30, cc.p(-400,Pos1.y)),cc.CallFunc:create(CallFucnCallback1))))
	-- layoutCloud2:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(50, cc.p(-400,Pos2.y)),cc.CallFunc:create(CallFucnCallback2))))

    local layout_exit_explore = self:getControl(Tag_ui_explore.PANEL_EXPLORE, Tag_ui_explore.LAYOUT_EXIT_EXPLORE)  --explore
	Spine.addSpine(layout_exit_explore,"explore","back","part1",true)
	local function event_pvp(touch,p_sender)
		Spine.spineMix(layout_exit_explore,"explore","back","part2","part1",false,true)
		Utils.replaceScene("MainUI",__instance)
		return false
	end
	layout_exit_explore:setOnTouchBeganScriptHandler(event_pvp)
    TouchEffect.addTouchEffect(self)

    local function onNodeEvent(event)
		if "enterTransitionFinish"  == event then
			
			local activity1Common = ConfigManager.getActivty1CommonConfig('level_limit')
			local activity2Common = ConfigManager.getActivty2CommonConfig('openlevel')
			local activity3Common = ConfigManager.getActivty3CommonConfig('level_limit')
			
			if Player:getInstance():get("level") == activity1Common and GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.BATTLE_PALACE) == false then
				Utils.dispatchCustomEvent("enter_view",{callback = function( )
					Utils.dispatchCustomEvent("event_activity",{view = "ExploreUI",phase = GuideManager.FUNC_GUIDE_PHASES.BATTLE_PALACE,scene = self})
				end, params = {view = "func", phase = GuideManager.FUNC_GUIDE_PHASES.BATTLE_PALACE}})
			elseif Player:getInstance():get("level") == activity2Common  and GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.BATTLE_ROULETTE) == false then
				Utils.dispatchCustomEvent("enter_view",{callback = function( )
					Utils.dispatchCustomEvent("event_activity",{view = "ExploreUI",phase = GuideManager.FUNC_GUIDE_PHASES.BATTLE_ROULETTE,scene = self})
				end, params = {view = "func", phase = GuideManager.FUNC_GUIDE_PHASES.BATTLE_ROULETTE}})
			elseif Player:getInstance():get("level") == activity3Common and GuideManager.isFuncGuideFinished(GuideManager.FUNC_GUIDE_PHASES.PYRAMID) == false then
				Utils.dispatchCustomEvent("enter_view",{callback = function()
					Utils.dispatchCustomEvent("event_activity",{view = "ExploreUI",phase = GuideManager.FUNC_GUIDE_PHASES.PYRAMID,scene = self})
				end, params = {view = "func", phase = GuideManager.FUNC_GUIDE_PHASES.PYRAMID}})
			end

		elseif "exit" == event then
		end
	end
	self:registerScriptHandler(onNodeEvent)
end








