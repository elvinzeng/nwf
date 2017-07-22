--[[ 
    DESC: StringUtil
    Author: Links
    Date: 2017/7/20
--]]
local StringUtil = commonlib.gettable("nwf.modules.db_postgres.StringUtil");
local util = commonlib.gettable("nwf.util.string");
local excludeFuncs = commonlib.gettable("nwf.modules.db_postgres.ExcludeFuncs");

function StringUtil.escapeSql(value)
    if (type(value) == "string") then
        if StringUtil.isExcludeFunc(value) == false then
            local newValue = util.escape_sql(value);
            return newValue;
        end
        return value
    end
    return value;
end

function StringUtil.isExcludeFunc(value)
    for _, v in pairs(excludeFuncs) do
        if string.match(value, v) then
            return true;
        end
    end
    return false;
end
