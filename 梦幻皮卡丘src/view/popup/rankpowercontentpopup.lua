--
-- Author: hapigames
-- Date: 2014-12-13 17:45:22
--
require "view/tagMap/Tag_popup_rank_arena_content"

RankPowerContentPopup = class("RankPowerContentPopup", function()
    return Popup:create()
end)

RankPowerContentPopup.__index = RankPowerContentPopup
local __instance = nil
local items = nil
function RankPowerContentPopup:create()
	local ret = RankPowerContentPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function RankPowerContentPopup:getControl(tagPanel, tagControl)
	local ret = nil
	ret  = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function RankPowerContentPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_rank_arena_content.PANEL_POPUP_POWER_RANKCONTENT then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function RankPowerContentPopup:onLoadScene()
	local count = RankDataProxy:getInstance():get("count")
	local powerrank = RankDataProxy:getInstance().powerrank

	TuiManager:getInstance():parseScene(self,"panel_popup_power_rankcontent",PATH_POPUP_RANK_ARENA_CONTENT)
	local btn_close = self:getControl(Tag_popup_rank_arena_content.PANEL_POPUP_POWER_RANKCONTENT, Tag_popup_rank_arena_content.BTN_POWER_CLOSE)
	btn_close:setOnClickScriptHandler(function()
		Utils.popUIScene(self)
	end)
	local level = 	RankDataProxy:getInstance():get("level")
	local name = 	RankDataProxy:getInstance():get("name")
	local role = 	RankDataProxy:getInstance():get("role")

	local layout_player = self:getControl(Tag_popup_rank_arena_content.PANEL_POPUP_POWER_RANKCONTENT,Tag_popup_rank_arena_content.LAYOUT_PLAYER_2)
	local img_player = TextureManager.createImg(TextureManager.RES_PATH.PLAYER_HEAD, role)  --玩家头像
	Utils.addCellToParent(img_player,layout_player)

	local labName = self:getControl(Tag_popup_rank_arena_content.PANEL_POPUP_POWER_RANKCONTENT,Tag_popup_rank_arena_content.LAB_POWER_PLAYER_NAME1)
	labName:setString(name)

	local lab_association = self:getControl(Tag_popup_rank_arena_content.PANEL_POPUP_POWER_RANKCONTENT, Tag_popup_rank_arena_content.LAB_ASSOCIATION)
	lab_association:setString(RankDataProxy:getInstance():get("association"))

	local lab_level =  self:getControl(Tag_popup_rank_arena_content.PANEL_POPUP_POWER_RANKCONTENT, Tag_popup_rank_arena_content.LAB_LEVEL_2)
	lab_level:setString(level)

	
	
	TouchEffect.addTouchEffect(self)
end