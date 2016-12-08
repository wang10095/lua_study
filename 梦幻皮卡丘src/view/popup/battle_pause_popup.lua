require "view/tagMap/Tag_popup_battle_pause"

BattlePausePopup = class("BattlePausePopup",function()
	return Popup:create()
end)

BattlePausePopup.__index = BattlePausePopup
local __instance = nil

function BattlePausePopup:create()
	local ret = BattlePausePopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function BattlePausePopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function BattlePausePopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_battle_pause.PANEL_PAUSE_POPUP then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

function BattlePausePopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_pause_popup",PATH_POPUP_BATTLE_PAUSE)

	local btnQuit = self:getControl(Tag_popup_battle_pause.PANEL_PAUSE_POPUP,Tag_popup_battle_pause.BTN_QUIT)
	btnQuit:setOnClickScriptHandler(function()
		Utils.popUIScene(self)
		if StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY3 then
			Utils.replaceScene("PyramidUI")
		elseif StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY2 then
			Utils.replaceScene("RouletteUI")
		elseif StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.PVP1 then
			if Stagedataproxy:getInstance():get("startBattle") then
				NetManager.sendCmd("pvp1battleend",function(result) end,2)
			end
			Utils.replaceScene("SilverChampionshipUI")
		elseif  StageRecord:getInstance():get("dungeonType") == Constants.DUNGEON_TYPE.ACTIVITY1  then
			Utils.replaceScene("BattlePalaceUI")
		else
			if Stagedataproxy:getInstance():get("startBattle") then
				NetManager.sendCmd("battleend", function(result)
					Player:getInstance():set("energy",result["energy"])
				end,0, 0,0,0, 0)
			end
			Utils.replaceScene("PveUI")	
		end
		Stagedataproxy:getInstance():set("startBattle",false)
	end)

	local btnResume = self:getControl(Tag_popup_battle_pause.PANEL_PAUSE_POPUP,Tag_popup_battle_pause.BTN_RESUME)
	btnResume:setOnClickScriptHandler(function()
		Utils.popUIScene(self)
		local event = cc.EventCustom:new("event_resume_battle")
		self:getEventDispatcher():dispatchEvent(event)
	end)

	local btnMusicOff = self:getControl(Tag_popup_battle_pause.PANEL_PAUSE_POPUP,Tag_popup_battle_pause.BTN_SOUND_OFF)
    local btnMusicOn = self:getControl(Tag_popup_battle_pause.PANEL_PAUSE_POPUP,Tag_popup_battle_pause.BTN_SOUND_ON)

    if MusicManager.getMusicStatus() == 1 then
    	btnMusicOn:setVisible(false)
    else
    	btnMusicOff:setVisible(false)
    end

    btnMusicOn:setOnClickScriptHandler(function( )
        MusicManager.setMusicStatus(1)
        MusicManager.setEffectStatus(1)
        -- MusicManager.resumeMusic()
        MusicManager.battlebackground()
     	btnMusicOff:setVisible(true)
        btnMusicOn:setVisible(false)
    end)

    btnMusicOff:setOnClickScriptHandler(function( )
        MusicManager.setMusicStatus(0)
        MusicManager.setEffectStatus(0)
        MusicManager.stopAllMusic()
        btnMusicOff:setVisible(false)
        btnMusicOn:setVisible(true)
    end)
    TouchEffect.addTouchEffect(self)
end