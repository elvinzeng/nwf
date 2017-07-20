--[[ 
    DESC: StringUtil
    Author: Links
    Date: 2017/7/20
--]]
local StringUtil = commonlib.inherit(nil, commonlib.gettable("nwf.modules.db_postgres.StringUtil"));
local util = commonlib.gettable("nwf.util.string");
local excludeFuncs = commonlib.gettable("nwf.modules.db_postgres.ExcludeFuncs");

function StringUtil.escapeSql(text)
    if (type(text) == "string") then
        local newText = util.escape_sql(text);
        return newText;
    end
    return text;
end

function StringUtil.isExcludeFunc(value)
    for _, v in pairs(excludeFuncs) do
        if string.match(value, v) then
            return true;
        end
    end
    return false;
end