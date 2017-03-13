--[[
Title: string utilities
Author: zenghui
Date: 2017/3/6
]]

local util = commonlib.gettable("nwf.util.string");

function util.split(str, delimiter)
    if type(delimiter) ~= "string" or string.len(delimiter) <= 0 then
        return
    end

    local start = 1
    local t = {}
    while true do
        local pos = string.find (str, delimiter, start, true) -- plain find
        if not pos then
            break
        end

        table.insert (t, string.sub (str, start, pos - 1))
        start = pos + string.len (delimiter)
    end
    table.insert (t, string.sub (str, start))

    return t
end

function util.upperFirstChar(str)
    local firstChar = string.sub(str, 1, 1);
    local c = string.byte(firstChar);
    if(c>=97 and c<=122) then
        firstChar = string.upper(firstChar);
    end
    return firstChar .. string.sub(str, 2, #str)
end

function util.new_guid()
    local seed={'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
    local tb = {};
    math.randomseed(tostring(os.time()):reverse():sub(1, 6));
    for i = 1, 32 do
        table.insert(tb, seed[math.random(1, 16)]);
    end
    return table.concat(tb);
end