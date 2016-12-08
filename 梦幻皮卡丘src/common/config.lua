module("Config", package.seeall)

local function parseLine(line)
	-- local str2 = string.gsub(str1, ";", ",")
	local res = "do t = {"..line.."}; return t end"
	-- print("line = "..line)
	local t = loadstring(res)()
	
	return t
end

local function parseConfigs(key, suffix)
	suffix = suffix or ".debug"
	local basePath = "res/config/"
	local path = cc.FileUtils:getInstance():fullPathForFilename(basePath..key..suffix)
	print("load config:", path)
	local strData = cc.FileUtils:getInstance():getStringFromFile(path)
	if strData == nil or strData == "" then
		return nil
	end

	local lines = Utils.splitString(strData, "\n")
	local propertyLine = lines[1]
	local property = parseLine(propertyLine)
	local config = config or {}
	for i=2, #lines do
		local line = lines[i]
		if line ~= nil and line ~= "" then
   			local tuple = parseLine(line)
   			table.insert(config, tuple)
   		end
	end
	return property, config
end

--table of stored configration file--
Configs = Configs or {}
function getConfigs(key, suffix)
	if (Configs[key] == nil) then
		local p_table, c_table = parseConfigs(key, suffix)
		if (p_table == nil) then
			return nil
		end
		local res_table = res_table or {}
		for k1, v1 in pairs(c_table) do
			local res2_table = res2_table or {}
			for k2, v2 in pairs(p_table) do
				res2_table[v2] = v1[k2] 
			end
			res_table[k1] = res2_table
		end
		Configs[key] = res_table
	end
	-- Debug.printTable("Configs", Configs)
	return Configs
end
