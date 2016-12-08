--
-- Author: hapigames
-- Date: 2014-12-13 10:36:37
--

require "view/tagMap/Tag_ui_rank"

RankContentPopup = class("RankContentPopup", function()
	return Popup:create()
end)

RankContentPopup.__index = RankContentPopup
local  __instance  = nil
local items = nil
function RankContentPopup:create()
	local ret = RankContentPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function () ret:onLoadScene() end)
	return ret
end

function RankContentPopup:getControl(tagPanel, tagControl)
	local ret = nil
	ret  = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function RankContentPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_ui_rank.PANEL_POPUP_RANKCONTENT then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_close()
	Utils.popUIScene(__instance)
end

function RankContentPopup:onLoadScene()
	-- local function eventCustomListener1(event)
	local count = RankDataProxy:getInstance():get("count")
	local arenarank = RankDataProxy:getInstance().arenarank
	local playerinfo = RankDataProxy:getInstance().playerinfo
	local petteam = RankDataProxy:getInstance().petteam

	TuiManager:getInstance():parseScene(self,"panel_popup_rankcontent",PATH_UI_RANK)
	local btn_close = self:getControl(Tag_ui_rank.PANEL_POPUP_RANKCONTENT, Tag_ui_rank.BTN_INFO_CLOSE)
	btn_close:setOnClickScriptHandler(event_close)

	local layout_player = self:getControl(Tag_ui_rank.PANEL_POPUP_RANKCONTENT,Tag_ui_rank.LAYOUT_PLAYER_1)
	local img_player = TextureManager.createImg(TextureManager.RES_PATH.PLAYER_HEAD, count)  --玩家头像
	Utils.addCellToParent(img_player,layout_player)

	local lab_player_name = self:getControl(Tag_ui_rank.PANEL_POPUP_RANKCONTENT,Tag_ui_rank.LAB_PLAYER_NAME)
	lab_player_name:setString("战魂王者")
	local lab_rank_num = self:getControl(Tag_ui_rank.PANEL_POPUP_RANKCONTENT, Tag_ui_rank.LAB_RANK_NUM)
	lab_rank_num:setString("2")
	local lab_win_num = self:getControl(Tag_ui_rank.PANEL_POPUP_RANKCONTENT, Tag_ui_rank.LAB_WIN_NUM)
	lab_win_num:setString("5")
	local lab_power_num = self:getControl(Tag_ui_rank.PANEL_POPUP_RANKCONTENT,Tag_ui_rank.LAB_TOTALPOWER_NUM)
	lab_power_num:setString("4300")

	for i=1,4 do  --宠物阵型
		local layout_pet = self:getControl(Tag_ui_rank.PANEL_POPUP_RANKCONTENT,Tag_ui_rank["LAYOUT_PET"..i])
		local img_pet = TextureManager.createImg(TextureManager.RES_PATH.PET_AVATAR, i)
		Utils.addCellToParent(img_pet,layout_pet)
	end

	-- NetManager.registerResponseHandler("arenarankcontent",eventCustomListener1)
	-- NetManager.cmdHandler.arenarankcontent()
	-- NetManager.sendCmd("loadrank",RankDataProxy:getInstance():get("uid"))

	TouchEffect.addTouchEffect(self)
end

