module("NetManager", package.seeall)

require("proxy/net_proxy")

-- serverUrl = "http://115.28.27.23:82/pokemon.php"
-- serverUrl2 = "http://115.28.27.23:81/request.php"

-- serverUrl = "http://118.26.187.42:81/pokemon.php"
-- serverUrl = "http://118.26.187.42:81/pokemon_develop.php"
-- serverUrl2 = "http://118.26.187.42:82/request.php"

serverUrl = "http://124.193.152.42:81/pokemon_develop.php"
serverUrl2 = "http://124.193.152.42:82/request.php"

errorMsg = {   
	[1]='系统错误',
	[2]='用户不存在',
	[3]='阵容不存在',
	[4]='宠物不存在',
	[5]='道具数量不足',
	[6]='未开启',
	[7]='配置错误',         
	[8]='金币不足',
	[9]='道具不存在',
	[10]='超出限制（时间不到、次数不够等）',
	[11]='技能点不足',
	[12]='条件不足',
	[13]='任务不存在',
	[14]='奖励已经领取',
	[15]='达到等级上限',
	[16]='设备已经更换',
	[17]='认证令牌不匹配',
	[18]='钻石不足',
	-- [19]=''
	[20]='参数错误',
	[21]='体力不足',
	[22]='信息不存在',
	[23]='有剩余动作需要先处理',
	[24]='输入错误',
}


local requestQueue = {}
local requestsAdded = {}
local waitingQueue = {}
local responseHandlers = {} -- 存储回调函数
local permanentResponseHandlers = {}
local errorHandlers = {}

local netProxy = NetProxy:getInstance()

local loadingLayer = nil

--table level must be one
local function generateQuery(t)
	local ans = ""
	for k,v in pairs(t) do
		if type(v) == "table" then
			local tableStr = ""
			for i,m in pairs(v) do
				tableStr  = tableStr .. m
				if i ~= #v then
					tableStr = tableStr .. ","
				end
			end
			v = tableStr 
		end
		ans = ans..k.."="..v.."&"
	end
	local ret = string.sub(ans,1,-2)
	print("QueryString: "..ret)
	return ret
end 

local function post(cmd, query)

	-- LoadingMaskPopup:getInstance():begin()

	print("send cmd: " .. cmd)

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    if cmd == "login" or cmd == "register" then
    	xhr:open("POST", serverUrl2)
    else
    	xhr:open("POST", serverUrl)
    end
    
    local function onReadyStateChange()
        local statusString = "Http Status Code: "..xhr.statusText
        print(statusString)
        if (xhr.status == 200 and xhr.readyState == 4) then
        	local response = xhr.responseText
        	print("response: "..response)
        	local results = netProxy:parseResponse(response)
        	for i,result in ipairs(results) do
        		NormalDataProxy:getInstance():set("isServer",false)
	        	if result == nil then
	        		print("response format error")
	        		for i,q in ipairs(waitingQueue) do
		        		if q[1] == cmd then
		        			waitingQueue[i] = nil
		        		end
		        	end
	        		return
	        	end

	        	local cmd = result["cmd"]
	        	if result["succ"] ~= 0 then
	        		print("错误信息 "..errorMsg[result["succ"]])
	        		if result["succ"]~=6  and result["succ"]~=15 and cmd ~= "loadweekgift" then
	        			MusicManager.error_tip()
	        		end             
	        		-- todo: handle error
	        		--[[
	        			common error handling codes gose here
	        		--]]
	        		-- TipDataProxy:getInstance():set("normal_or_warn",1)
	        		-- TipDataProxy:getInstance():set("content",errorMsg[result["succ"]])
					-- Utils.runUIScene("TipPopup")
	        		if errorHandlers[cmd] then
	        			-- for i, errorHandler in ipairs(errorHandlers[cmd]) do
	        			-- 	errorHandler(result)
	        			-- end
	        			errorHandlers[cmd](result)
	        		else
	        			MusicManager.error_tip()
	        			local msg = errorMsg[result["succ"]] or ("发生错误啦["..result["succ"].."]")
	        			TipManager.showTip(msg)
	        		end
	        	elseif responseHandlers[cmd] ~= nil or permanentResponseHandlers[cmd] ~= nil then
	        		-- for i, handler in ipairs(responseHandlers[cmd]) do
	        		-- 	print("handle response: ", cmd)
	        		-- 	handler(result["content"])
	        		-- 	unregisterResponseHandler(cmd, handler)
	        		-- end
	        		print("handle response: ", cmd)
	        		if responseHandlers[cmd] then
	        			responseHandlers[cmd](result["content"])
	        			unregisterResponseHandler(cmd, handler)
	        		elseif permanentResponseHandlers[cmd] then
	        			permanentResponseHandlers[cmd](result["content"])
	        		end
	        	else
	        		print("no handler for cmd ", result["cmd"])
	        	end

	        	-- remove from waiting queue
	        	for i,q in ipairs(waitingQueue) do
	        		if q[1] == cmd then
	        			waitingQueue[i] = nil
	        		end
	        	end
        	end
        else
        	print("error: "..statusString)
        end

        -- LoadingMaskPopup:getInstance():complete()
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send(query)
    
    print("post waiting...")
    NormalDataProxy:getInstance():set("isServer",true)
    -- Utils.runUIScene("LoadingMaskPopup")
end

function sendCmd(cmd, handler, ...)  --发送消息  用户 信息 
	local arg = {...}
	local queryTable = {}

	registerResponseHandler(cmd, handler)

	queryTable["cmd"] = cmd
	if cmd ~= "login" and cmd ~= "register" then
		queryTable["uid"] = Player:getInstance():get("uid")
		for i = 1, #arg do
			queryTable["param"..i] = arg[i]
		end
	else
		queryTable["user_name"] = arg[1]
		queryTable["password"] = arg[2]
	end
	queryTable["deviceid"] = DeviceUtils:getDeviceID()
	local query = generateQuery(queryTable)

	--post(cmd, query)
	-- for i,v in ipairs(requestsAdded) do
	-- 	if v[1] == cmd then
	-- 		return
	-- 	end
	-- end
	-- for i,v in ipairs(requestQueue) do
	-- 	if v[1] == cmd then
	-- 		return
	-- 	end
	-- end
	-- for i,v in ipairs(waitingQueue) do
	-- 	if v[1] == cmd then
	-- 		return
	-- 	end
	-- end

	table.insert(requestsAdded, {cmd, query})
	-- todo: add waiting mask
end

function registerResponseHandler(cmd, handler, permanent)
	-- responseHandlers[cmd] = responseHandlers[cmd] or {}
	-- for i,v in ipairs(responseHandlers[cmd]) do
	-- 	if handler == v then  --防止重复注册
	-- 		return
	-- 	end
	-- end
	-- table.insert(responseHandlers[cmd], handler)
	-- print("register response handler for: ", cmd, #responseHandlers[cmd])
	if permanent then
		permanentResponseHandlers[cmd] = handler
	else
		responseHandlers[cmd] = handler
	end
end

function unregisterResponseHandler(cmd, handler)
	-- if responseHandlers[cmd] == nil then
	-- 	return
	-- end
	-- for i,v in ipairs(responseHandlers[cmd]) do
	-- 	if handler == v then
	-- 		table.remove(responseHandlers[cmd], i)
	-- 	end
	-- end
	-- table.remove(responseHandlers[cmd], handler)
	responseHandlers[cmd] = nil
end

function registerErrorHandler(cmd, handler)
	-- errorHandlers[cmd] = errorHandlers[cmd] or {}
	-- for i,v in ipairs(errorHandlers[cmd]) do
	-- 	if handler == v then
	-- 		return
	-- 	end
	-- end
	-- table.insert(errorHandlers[cmd], handler)
	errorHandlers[cmd] = handler
end

function unregisterResponseHandler(cmd, handler)
	-- if errorHandlers[cmd] == nil then
	-- 	return
	-- end
	-- for i,v in ipairs(errorHandlers[cmd]) do
	-- 	if handler == v then
	-- 		table.remove(errorHandlers[cmd], i)
	-- 	end
	-- end
	-- table.remove(errorHandlers[cmd], handler)
	errorHandlers[cmd] = nil
end

local function update()
	for i, q in ipairs(requestQueue) do
		post(q[1], q[2])
		table.insert(waitingQueue, q)
	end
	requestQueue = {}

	for i,v in ipairs(requestsAdded) do
		table.insert(requestQueue, v)
	end
	requestsAdded = {}

	if #waitingQueue == 0 then
		--todo remove loadingLayer
	end
end
cc.Director:getInstance():getScheduler():scheduleScriptFunc(update, 0, false)