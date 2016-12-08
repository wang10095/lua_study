require "view/tagMap/Tag_popup_login"

LogInPopup = class("LogInPopup", function()
	return Popup:create()
end)

LogInPopup.__index = LogInPopup
local __instance = nil

function LogInPopup:create()
	local ret = LogInPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function LogInPopup:getControl(tagPanel, tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function LogInPopup:getPanel(tagPanel)
	local ret = nil
	if  tagPanel == Tag_popup_login.PANEL_POPUP_LOGIN then
		ret = self:getChildByTag(tagPanel)
	end
	return ret
end

local function event_close()
	Utils.popUIScene(__instance)
end

local function event_edit(strEventName,pSender)
	if strEventName == "return" then
		print(pSender:getText())
	end
end

local function event_register(p_sender)
	Utils.popUIScene(__instance)
	Utils.runUIScene("RegisterPopup")
end

local function event_login(p_sender)
	local account = edit_account:getText()
	local password = edit_password:getText()
	-- if  account == account_old  and password == password_old then
	-- TipManager.showTip("此用户已登录!")
	-- 	return
	-- end
	--本地判断
	if string.len(account) == 0   then
		TipManager.showTip("用户名不可以为空!")
		return
	end

	if string.len(password) == 0 then
		TipManager.showTip("密码不可以为空!")
		return
	end

	if  string.find(account,' ') ~= nil then
		TipManager.showTip("用户名不能有空格")
		return
	end

	if string.find(password,' ') ~= nil then
		TipManager.showTip("密码不能有空格")
		return
	end

	for i=1,string.len(account) do
		if string.find(string.sub(account,i,i),'[%W]') and  string.find(string.sub(account,i,i),'[^_]') then
			TipManager.showTip("账号只能是字母数字下划线")
			return
		end
	end

	for i=1,string.len(password) do
		if string.find(string.sub(password,i,i),'[%W]') and  string.find(string.sub(password,i,i),'[^_]') then
			TipManager.showTip("密码只能是字母数字下划线")
			return
		end
	end

	--返回数据判断 
	local function eventListener(result)
		print("登录成功")
		TDGAAccount:setAccount(result["uid"])
		TDGAAccount:setAccountName(account)

		Player:getInstance():set("uid",result["uid"])
		Player:getInstance():set("auth_code",result["auth_code"])
		cc.UserDefault:getInstance():setStringForKey("account", account)
		cc.UserDefault:getInstance():setStringForKey("password", password)
		Utils.popUIScene(__instance)
	end
 	NetManager.sendCmd("login",eventListener,account,password)
 	NetManager.registerErrorHandler("login", function(result)
 		local errorMsg = {"系统错误", "用户不存在", "密码错误", "用户名已经存在", "用户名不能为空", "密码不能为空"}
 		TipManager.showTip(errorMsg[result.succ])
 	end)
end

function LogInPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_login",PATH_POPUP_LOGIN)

	edit_account  = self:getControl(Tag_popup_login.PANEL_POPUP_LOGIN, Tag_popup_login.EDIT_ACCOUNT)
	edit_account:setFontColor(cc.c3b(0,0,0))
	edit_account:registerScriptEditBoxHandler(event_edit)

	edit_password  = self:getControl(Tag_popup_login.PANEL_POPUP_LOGIN, Tag_popup_login.EDIT_PASSWORD)
	edit_password:setFontColor(cc.c3b(0,0,0))
	edit_password:setReturnType(1)
	edit_password:registerScriptEditBoxHandler(event_edit)
	--从userdefault得到原用户信息
	account_old = cc.UserDefault:getInstance():getStringForKey("account")
	password_old = cc.UserDefault:getInstance():getStringForKey("password")
	if string.len(account_old) ~= 0 then
		edit_account:setText(account_old)
		edit_password:setText(password_old)
	end

	local btn_register = self:getControl(Tag_popup_login.PANEL_POPUP_LOGIN, Tag_popup_login.BTN_REGISTER)
	btn_register:setOnClickScriptHandler(event_register)
	local btn_login = self:getControl(Tag_popup_login.PANEL_POPUP_LOGIN, Tag_popup_login.BTN_SURE_LOGIN)
	btn_login:setOnClickScriptHandler(event_login)
	TouchEffect.addTouchEffect(self)
end






