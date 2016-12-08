BattleEndUI = class("BattleEndUI",function()
    return TuiBase:create()
end)

__instance = nil

local function event_btn_replay(p_sender)
	CSceneManager:getInstance():popUIScene(__instance)
end

local function event_btn_next(p_sender)
	CSceneManager:getInstance():popUIScene(__instance)
	CSceneManager:getInstance():replaceScene(CCSceneExTransitionFade:create(0.3,LoadScene("PveUI")))
end

function BattleEndUI:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	print("get control", ret)
	return ret
end

function BattleEndUI:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_battle.PANEL_BATTLE_END then
		ret = self:getChildByTag(tagPanel)
		print("get panel", tagPanel, ret)
	end
	return ret
end

function BattleEndUI:create()
    local ret = BattleEndUI.new()
    __instance = ret
    ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
    return ret
end

function BattleEndUI:onLoadScene()
	local winSize = cc.Director:getInstance():getWinSize()
	local mask = CLayout:create(winSize)
	mask:setBackgroundColor(cc.c4b(0, 0, 0, 100))
	mask:setAnchorPoint(0, 0)
    local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(function(touch, event)
				print("bettle end popup mask touched")
				return true
			end,
		cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = mask:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, mask)
    self:addChild(mask)

    TuiManager:getInstance():parseScene(self, "panel_battle_end", PATH_UI_BATTLE)

    local team = Player:getInstance():get("team")
    local wonLayout = self:getControl(Tag_ui_battle.PANEL_BATTLE_END, Tag_ui_battle.LAYOUT_BATTLE_WON)
    print("wonLayout", wonLayout, wonLayout:getChildByTag(Tag_ui_battle.LAYOUT_TEAM_PET1), wonLayout:getChildByTag(Tag_ui_battle.LAYOUT_TEAM_PET1):getChildByTag(Tag_ui_battle.LAYOUT_PET_CONTAINER))
	local pc = PetCell:create(team[1])
	pc:setScale(0.9)
	Utils.addCellToParent(pc, wonLayout:getChildByTag(Tag_ui_battle.LAYOUT_TEAM_PET1):getChildByTag(Tag_ui_battle.LAYOUT_PET_CONTAINER))
	pc = PetCell:create(team[2])
	pc:setScale(0.9)
	Utils.addCellToParent(pc, wonLayout:getChildByTag(Tag_ui_battle.LAYOUT_TEAM_PET2):getChildByTag(Tag_ui_battle.LAYOUT_PET_CONTAINER))
	pc = PetCell:create(team[3])
	pc:setScale(0.9)
	Utils.addCellToParent(pc, wonLayout:getChildByTag(Tag_ui_battle.LAYOUT_TEAM_PET3):getChildByTag(Tag_ui_battle.LAYOUT_PET_CONTAINER))
	pc = PetCell:create(team[4])
	pc:setScale(0.9)
	Utils.addCellToParent(pc, wonLayout:getChildByTag(Tag_ui_battle.LAYOUT_TEAM_PET4):getChildByTag(Tag_ui_battle.LAYOUT_PET_CONTAINER))

	local btnReplay = self:getControl(Tag_ui_battle.PANEL_BATTLE_END, Tag_ui_battle.BTN_BATTLE_REPLAY)
	print(btnReplay)
	btnReplay:setOnClickScriptHandler(event_btn_replay)
	local btnNext = self:getControl(Tag_ui_battle.PANEL_BATTLE_END, Tag_ui_battle.BTN_BATTLE_NEXT)
	print(btnNext)
	btnNext:setOnClickScriptHandler(event_btn_next)
end