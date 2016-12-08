--
-- Author: hapigames
-- Date: 2014-12-03 22:15:10
--
require "view/tagMap/Tag_popup_setting"

SettingPopup = class("SettingPopup",function()
	return Popup:create()
end)

SettingPopup.__index = SettingPopup
local __instance = nil

function SettingPopup:create()
	local ret = SettingPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function SettingPopup:getControl(tagPanel,tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function SettingPopup:getPanel(tagPanel)
	local ret = nil
	if tagPanel == Tag_popup_setting.PANEL_POPUP_SETTING then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end
local function event_edit_login(strEventName,pSender)
	MusicManager.playBtnClickEffect()
	if strEventName == "return" then
		print(pSender:getText())
	end
end

function SettingPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_setting",PATH_POPUP_SETTING)
	local function event_close( p_sender )
		-- MusicManager.playBtnClickEffect()
		Utils.popUIScene(self)
	end
	local btnClose = self:getControl(Tag_popup_setting.PANEL_POPUP_SETTING,Tag_popup_setting.BTN_CLOSE)
	btnClose:setOnClickScriptHandler(event_close)

	print(" "..MusicManager.getMusicStatus())
	print(" "..MusicManager.getEffectStatus())

	local layoutMusic = self:getControl(Tag_popup_setting.PANEL_POPUP_SETTING,Tag_popup_setting.LAYOUT_MUSIC)
	local layoutEffect = self:getControl(Tag_popup_setting.PANEL_POPUP_SETTING,Tag_popup_setting.LAYOUT_EFFECT)
	local imgMusicOn = layoutMusic:getChildByTag(Tag_popup_setting.IMG_MUSIC_NORMAL)
	local imgMusicOff = layoutMusic:getChildByTag(Tag_popup_setting.IMG_MUSIC_SELECT)

	local imgEffectOn = layoutEffect:getChildByTag(Tag_popup_setting.IMG_EFFECT_NORMAL)
	local imgEffectOff = layoutEffect:getChildByTag(Tag_popup_setting.IMG_EFFECT_SELECT)

	if MusicManager.getMusicStatus() == 0 then
		-- imgMusicOn:setVisible(false)
		imgMusicOff:setVisible(true)
	else
		imgMusicOff:setVisible(false)
		imgMusicOn:setVisible(true)
	end

	if MusicManager.getEffectStatus() == 0 then
		-- imgEffectOn:setVisible(false)
		imgEffectOff:setVisible(true)
	else
		imgEffectOff:setVisible(false)
		imgEffectOn:setVisible(true)
	end

	-- local isEffectOn = true
	-- local isMusicOn = true
	local function event_effect_handler( p_sender )
		-- layoutEffect:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,0.8),cc.ScaleTo:create(0.05,1)))
		if MusicManager.getEffectStatus() == 1 then
			MusicManager.setEffectStatus(0)
			
			-- imgEffectOn:setVisible(false)
			imgEffectOff:setVisible(true)

		else
			MusicManager.setEffectStatus(1)

			imgEffectOff:setVisible(false)
			imgEffectOn:setVisible(true)
		end
		MusicManager.stopEffect()
		return false
	end
	local function event_music_handler( p_sender )
		-- layoutMusic:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1,0.8),cc.ScaleTo:create(0.05,1)))
		if MusicManager.getMusicStatus() == 1 then
			MusicManager.setMusicStatus(0)
			-- imgMusicOn:setVisible(false)
			imgMusicOff:setVisible(true)

		else
			MusicManager.setMusicStatus(1)
			imgMusicOff:setVisible(false)
			imgMusicOn:setVisible(true)
		end
		MusicManager.stopAllMusic()
		MusicManager.mainMusic()
		return false
	end
	layoutEffect:setOnTouchBeganScriptHandler(event_effect_handler)
	layoutMusic:setOnTouchBeganScriptHandler(event_music_handler)

	local editWord = self:getControl(Tag_popup_setting.PANEL_POPUP_SETTING,Tag_popup_setting.EDIT_WORD)
	editWord:registerScriptEditBoxHandler(event_edit_login)

	local function event_relogoin( p_sender )
		NormalDataProxy:getInstance():set("FirstComeIn",true)
		ServerDataProxy:getInstance():set("switchLogin",1)
		Utils.popUIScene(self)
		Utils.replaceScene("LogInUI")
	end
	local btnReLogin = self:getControl(Tag_popup_setting.PANEL_POPUP_SETTING,Tag_popup_setting.BTN_RETURNLOGIN)
	btnReLogin:setOnClickScriptHandler(event_relogoin)

	TouchEffect.addTouchEffect(self)
	local function onNodeEvent(event)
		if "enter" == event then
			self:show()
			-- print("==true==")
			NormalDataProxy:getInstance():set("isPopup",true)
		end
		if "exit" == event then
			-- print("===exit=")
			NormalDataProxy:getInstance():set("isPopup",false)
		end
	end
	self:registerScriptHandler(onNodeEvent)
end