
require "view/tagMap/Tag_popup_player_level_up"

PlayerLevelUpPopup = class("PlayerLevelUpPopup",function()
	return Popup:create()
end)

PlayerLevelUpPopup.__index = PlayerLevelUpPopup

PlayerLevelUpPopup.__index = PlayerLevelUpPopup
local __instance = nil
local btnTag = 0

function PlayerLevelUpPopup:create()
	local ret = PlayerLevelUpPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function PlayerLevelUpPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function PlayerLevelUpPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_player_level_up.PANEL_POPUP_PLAYER_LEVEL_UP then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end
function PlayerLevelUpPopup:onLoadScene()

	TuiManager:getInstance():parseScene(self,"panel_popup_player_level_up",PATH_POPUP_PLAYER_LEVEL_UP)

	local newLevel = Player:getInstance():get("level") 
	local oldLevel = StageRecord:getInstance():get("old_level")
	local new_userConfig = ConfigManager.getUserConfig(newLevel)
	local old_userConfig = ConfigManager.getUserConfig(oldLevel)
	Player:getInstance():set("level",newLevel)
	StageRecord:getInstance():set("old_level",newLevel)
	local lablevelFrom = self:getControl(Tag_popup_player_level_up.PANEL_POPUP_PLAYER_LEVEL_UP,Tag_popup_player_level_up.LAB_LEVEL_FROM)
	lablevelFrom:setString(oldLevel)
	local lablevelTo = self:getControl(Tag_popup_player_level_up.PANEL_POPUP_PLAYER_LEVEL_UP,Tag_popup_player_level_up.LAB_LEVEL_TO)
	lablevelTo:setString(newLevel)

	local labenergyFrom = self:getControl(Tag_popup_player_level_up.PANEL_POPUP_PLAYER_LEVEL_UP,Tag_popup_player_level_up.LAB_ENERGY_FROM)
	labenergyFrom:setString(Player:getInstance():get("energy"))
	local labenergyTo = self:getControl(Tag_popup_player_level_up.PANEL_POPUP_PLAYER_LEVEL_UP,Tag_popup_player_level_up.LAB_ENERGY_TO)
	labenergyTo:setString(Player:getInstance():get("energy") + old_userConfig.energy_gain)
	
	local labenergyLimitFrom = self:getControl(Tag_popup_player_level_up.PANEL_POPUP_PLAYER_LEVEL_UP,Tag_popup_player_level_up.LAB_ENERGY_LIMIT_FROM)
	labenergyLimitFrom:setString(old_userConfig.max_energy)
	local labenergyLimitTo = self:getControl(Tag_popup_player_level_up.PANEL_POPUP_PLAYER_LEVEL_UP,Tag_popup_player_level_up.LAB_ENERGY_LIMIT_TO)
	labenergyLimitTo:setString(new_userConfig.max_energy)

	local labPetlevelfrom= self:getControl(Tag_popup_player_level_up.PANEL_POPUP_PLAYER_LEVEL_UP,Tag_popup_player_level_up.LAB_LEVEL_LIMTE)
	labPetlevelfrom:setString(old_userConfig.max_pet_exp)
	local labPetlevelto = self:getControl(Tag_popup_player_level_up.PANEL_POPUP_PLAYER_LEVEL_UP,Tag_popup_player_level_up.LAB_LEVEL_TOLEVEL)
	labPetlevelto:setString(new_userConfig.max_pet_exp)

	local labListFrom = self:getControl(Tag_popup_player_level_up.PANEL_POPUP_PLAYER_LEVEL_UP,Tag_popup_player_level_up.LAB_LEVEL_LIST)
	labListFrom:setString(old_userConfig.max_pet_num)
	local labListTo = self:getControl(Tag_popup_player_level_up.PANEL_POPUP_PLAYER_LEVEL_UP,Tag_popup_player_level_up.LAB_LEVEL_TOLIST)
	labListTo:setString(new_userConfig.max_pet_num)

	local labTexts = self:getControl(Tag_popup_player_level_up.PANEL_POPUP_PLAYER_LEVEL_UP,Tag_popup_player_level_up.LAB_PIKAQIU_TALK)
	local textsConfig = TextManager.getLevelUpTexts(newLevel)
	labTexts:setString(textsConfig)

	local btnClose = self:getControl(Tag_popup_player_level_up.PANEL_POPUP_PLAYER_LEVEL_UP,Tag_popup_player_level_up.BTN_CLOSE_LEVELUP)
	btnClose:setOnClickScriptHandler(function ( )
		Utils.popUIScene(self)
		if StageRecord:getInstance():get("battle_victory") == 1 then
			local customEvent = cc.EventCustom:new("event_battle_end")
		    cc.Director:getInstance():getEventDispatcher():dispatchEvent(customEvent)
		    StageRecord:getInstance():set("battle_victory",0)
		end
	end)

	local labTexts = self:getControl(Tag_popup_player_level_up.PANEL_POPUP_PLAYER_LEVEL_UP,Tag_popup_player_level_up.LAB_PIKAQIU_TALK)
	
	local textsConfig = TextManager.getLevelUpTexts(newLevel)
	labTexts:setString(textsConfig)

	TouchEffect.addTouchEffect(self)
end