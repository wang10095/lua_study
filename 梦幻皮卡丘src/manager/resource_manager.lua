module("ResourceManager", package.seeall)

local resource_ref_count = {}
local res_count = 0
local res_loaded_count = 0
local on_load_complete = nil
local loaded_resources = {}
local loadingPopup = nil

function showLoading(shouldShowLoading)
	loadingPopup = LoadingMaskPopup:getInstance()
	loadingPopup:begin(shouldShowLoading)
end

local function parseResource(res)
	if string.sub(res, -3) == "jpg" or string.sub(res, -3) == "png" then
		res = "component_separate/" .. res
	else
		res = res .. "/" .. res .. ".png"
	end
	return res
end

function loadResource(resList, async, loadCompleteCallback)
	-- print(">>>>>>>>>>>>>>>>>>>>>  load resources start")
	res_count = #resList
	res_loaded_count = 0
	on_load_complete = loadCompleteCallback

	if async then
		local loadNext
		loadNext = function()
			local res = table.remove(resList)
			-- print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<< start loading", res)
			cc.Director:getInstance():getTextureCache():addImageAsync(res, function()
				loaded_resources[res] = cc.Director:getInstance():getTextureCache():getTextureForKey(res)
				resource_ref_count[res] = resource_ref_count[res] or 0
				resource_ref_count[res] = resource_ref_count[res] + 1
				-- print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<< finished loading", res, resource_ref_count[res])
				onResourceLoaded(res)
				if #resList > 0 then
					loadNext()
				end
			end)
		end
		loadNext()
		return
	end

	for _, res in ipairs(resList) do
		res = parseResource(res)
		cc.Director:getInstance():getTextureCache():addImage(res)
		loaded_resources[res] = cc.Director:getInstance():getTextureCache():getTextureForKey(res)
		resource_ref_count[res] = resource_ref_count[res] or 0
		resource_ref_count[res] = resource_ref_count[res] + 1

		onResourceLoaded(res)
	end
end

function loadResourceOfView(viewName, loadCompleteCallback)
	local resourceList = {}
	local resList = {}
	if ResMap.RES_MAP[viewName] then
		for _,res in ipairs(ResMap.RES_MAP[viewName]) do
			res = parseResource(res)
			table.insert(resourceList, res)
			table.insert(resList, res)
		end
	end
	loadResource(resourceList, false, function()
		for k,res in pairs(resList) do
			if string.sub(res, 1, 18) ~= "component_separate" then
				res = string.sub(res, 1, -4) .. "plist"
				cc.SpriteFrameCache:getInstance():addSpriteFrames(res)
			end
		end
		loadCompleteCallback()
	end) 
end

function loadResourceOfViewAsync(viewName, loadCompleteCallback, shouldShowLoading)
	showLoading(shouldShowLoading)

	local resourceList = {}
	local resList = {}
	if ResMap.RES_MAP[viewName] then
		for _,res in ipairs(ResMap.RES_MAP[viewName]) do
			res = parseResource(res)
			table.insert(resourceList, res)
			table.insert(resList, res)
		end
	end
	loadResource(resourceList, true, function()
		for k,res in pairs(resList) do
			if string.sub(res, 1, 18) ~= "component_separate" then
				res = string.sub(res, 1, -4) .. "plist"
				cc.SpriteFrameCache:getInstance():addSpriteFrames(res)
			end
		end
		loadCompleteCallback()
	end)
end

function removeResources(resourceList)
	for _, res in ipairs(resourceList) do
		resource_ref_count[res] = resource_ref_count[res] or 0
		resource_ref_count[res] = resource_ref_count[res] - 1
		-- 为什么会减到小于0？
		if resource_ref_count[res] < 0 then
			resource_ref_count[res] = 0
		end
		if resource_ref_count[res] <= 0 then
			print("&&&&&&& remove texture", res)
			cc.Director:getInstance():getTextureCache():removeTextureForKey(res)
		end
	end
end

function removeResourceOfView(viewName)
	-- print(">>>>>>>> remove resources of view", viewName)
	local resourceList = {}
	if ResMap.RES_MAP[viewName] then
		for _,res in ipairs(ResMap.RES_MAP[viewName]) do
			res = parseResource(res)
			resource_ref_count[res] = resource_ref_count[res] or 0
			if resource_ref_count[res] - 1 <= 0 then
				if string.sub(res, 1, 18) ~= "component_separate" then
					local resPlist = string.sub(res, 1, -4) .. "plist"
					print("&&&&&&& remove spriteframes", resPlist)
					cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(resPlist)
				end
			end
			table.insert(resourceList, res)
		end
	end
	removeResources(resourceList)
end

function onResourceLoaded(res)
	res_loaded_count = res_loaded_count + 1
	if res_loaded_count == res_count then
		if loadingPopup then
			loadingPopup:complete(on_load_complete)
			loadingPopup = nil
		else
			on_load_complete()
		end
	end
end