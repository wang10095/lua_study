module ("Debug", package.seeall)

function printTable(name, table)
	-- print("############ table: "..name)
	if (table == nil) then
		print ("nil talbe")
	else
		for k,v in pairs(table) do
			if type(v) == "table" then
				printTable(k,v)
			elseif type(v) ~= "function" then
				print("key : value==> ("..k.." : "..tostring(v)..")")
			end
		end
		-- print("############ end "..name)
	end
end

function printPropertyTable(name, table)
	-- print("############ table: "..name)
	if (table == nil) then
		print ("nil talbe")
	else
		for k,v in pairs(table) do
			if type(v) == "table" and k == "__properties" then
				printTable(k,v)
			elseif type(v) ~= "function" then
				print("key : value==> ("..k.." : "..tostring(v)..")")
			end
		end
		-- print("############ end "..name)
	end
end

function simplePrintTable(tb)
	local tbToStr
	tbToStr = function(t)
		local str = ""
		if type(t) == "table" then
			str = "{"
			if #t > 0 and t[1] then
				for i,v in ipairs(t) do
					str = str .. tbToStr(v) .. ", "
				end
			else
				for k,v in pairs(t) do
					str = str .. k .. "=" .. tbToStr(v) .. ", "
				end
			end
			str = str .. "}"
		elseif type(t) == "boolean" then
			str = "" .. (t and "true" or "false")
		elseif type(t) == "string" then
			str = "'" .. t .. "'"
		else
			str = "" .. t
		end
		return str
	end
	-- print("#################")
	-- print(tbToStr(tb))
	-- print("-----------------")
end