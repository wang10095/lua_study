require "view/tagMap/Tag_popup_register"

RegisterPopup = class("RegisterPopup", function()
	return Popup:create()
end)

RegisterPopup.__index = RegisterPopup
local __instance = nil

function RegisterPopup:create()
	local ret = RegisterPopup.new()
	__instance = ret
	ret:setOnLoadSceneScriptHandler(function() ret:onLoadScene() end)
	return ret
end

function RegisterPopup:getControl(tagPanel, tagControl)
	local ret = nil
	ret = self:getPanel(tagPanel):getChildByTag(tagControl)
	return ret
end

function RegisterPopup:getPanel(tagPanel)
	local ret = nil
	if  tagPanel == Tag_popup_register.PANEL_POPUP_REGISTER then
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

local function event_sure_register(p_sender)
	local account = edit_account:getText()
	local password = edit_password:getText()
	local sure_password = edit_sure_password:getText()

	--判断是否符合注册规定
	if string.len(account) == 0   then
		TipManager.showTip("用户名不可以为空!")
		return
	end

	if string.len(password) == 0 then
		TipManager.showTip("密码不可以为空")
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

	if  password ~= sure_password then
		TipManager.showTip("两次输入的密码不一致")
		return
	end

	--符合注册条件发往后端	
	local function eventListener()
		print("注册成功可以登录")
 		local function eventListener(result)
 			Player:getInstance():set("uid",result["uid"])
    		Player:getInstance():set("auth_code", result["auth_code"])
 			cc.UserDefault:getInstance():setStringForKey("account",account)
    		cc.UserDefault:getInstance():setStringForKey("password",password)
          	print("注册后登录成功!")  
          	TDGAAccount:setAccount(result["uid"])
		    TDGAAccount:setAccountName(account)
		    TDGAAccount:setAccountType(kAccountRegistered)
		    TDGAAccount:setLevel(1)
        end
        NetManager.sendCmd("login",eventListener,account,password)
		Utils.popUIScene(__instance)
	end
	NetManager.sendCmd("register", eventListener,account,password) 
	NetManager.registerErrorHandler("register", function(result)
 		local errorMsg = {"系统错误", "用户不存在", "密码错误", "用户名已经存在", "用户名不能为空", "密码不能为空"}
 		TipManager.showTip(errorMsg[result.succ])
 	end)
end

local function event_return_login(p_sender)
	Utils.popUIScene(__instance)
	Utils.runUIScene("LogInPopup")
end


function RegisterPopup:onLoadScene()
	TuiManager:getInstance():parseScene(self,"panel_popup_register",PATH_POPUP_REGISTER)
	
	edit_account  = self:getControl(Tag_popup_register.PANEL_POPUP_REGISTER, Tag_popup_register.EDIT_ACCOUNT2)
	edit_account:setFontColor(cc.c3b(0,0,0))
	edit_account:registerScriptEditBoxHandler(event_edit)

	edit_password  = self:getControl(Tag_popup_register.PANEL_POPUP_REGISTER, Tag_popup_register.EDIT_PASSWORD2)
	edit_password:setFontColor(cc.c3b(0,0,0))
	edit_password:registerScriptEditBoxHandler(event_edit)

	edit_sure_password = self:getControl(Tag_popup_register.PANEL_POPUP_REGISTER, Tag_popup_register.EDIT_SURE_PASSWORD)
	edit_sure_password:setFontColor(cc.c3b(0,0,0))
	edit_sure_password:registerScriptEditBoxHandler(event_edit)

	local btn_register = self:getControl(Tag_popup_register.PANEL_POPUP_REGISTER, Tag_popup_register.BTN_REGISTER2)
	btn_register:setOnClickScriptHandler(event_sure_register)
	local btn_login = self:getControl(Tag_popup_register.PANEL_POPUP_REGISTER, Tag_popup_register.BTN_RETURN_LOGIN)
	btn_login:setOnClickScriptHandler(event_return_login)
	
	TouchEffect.addTouchEffect(self)

end