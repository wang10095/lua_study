Model = {}

function Model:create(classname, properties)
    local model = {}
    model.__properties = properties or {}
    model.__cname = classname or "Model"
    model.__index = model 
    
    --register event name
    -- if Message.EventMsg[classname] == nil then
    --     Message.EventMsg[classname] = "event_" .. classname
    -- end
    
    function model:get(prop)
        if self.__properties[prop] ~= nil then
            return self.__properties[prop]
        else 
            print(self.__cname .. "." .. prop .. " not found")
            return nil
        end
    end

    function model:set(prop, value)
        if (type(value) == "table") then
            --only print key of the table at the current version--
            local mt = {}
            mt.__tostring = function (value)
                local s = "tableKey {"
                local sep = ""
                for e in pairs(value) do
                   s = s .. sep .. e
                   sep = ", "
                end
                return s .. "}"
            end
            setmetatable(value, mt)
        end
        
        if self.__properties[prop] ~= nil then
            if type(value) ~= type(self.__properties[prop]) then
                print("type error: " .. self.__cname .. "." .. prop)
                return
            end
            -- print("update " .. self.__cname .. "." .. prop .. "    " .. tostring(self.__properties[prop]) .. " ==> " .. tostring(value))
            local equal = (tostring(self.__properties[prop]) == tostring(value))
            self.__properties[prop] = value
        else
            print(self.__cname .. "." .. prop .. " not found")
        end
    end
   
    return model
end
