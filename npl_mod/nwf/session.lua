--[[
title: NPL web framework session manager
author: zenghui
date: 2017/3/3
]]

local session = commonlib.gettable("nwf.session");
local manager = commonlib.gettable("nwf.session.manager");
local nwf = commonlib.gettable("nwf");
local string_util = commonlib.gettable("nwf.util.string");
nwf.session.timeoutSeconds = 1200;

manager.idList = {};
manager.latestAccess = {};
manager.data = {};


-- create a new guid
local function new_guid()
    local guidStr = "";
    repeat
        guidStr = string_util.new_guid();
    until(not manager.latestAccess[guidStr])
    return guidStr;
end


local function getIndex(id)
    for i, v in ipairs(manager.idList) do
       if (v == id) then
           return i;
       end
    end
    return nil;
end


--  garbage collection
local function gc()
    local n = os.time();
    if (n % 60 > 10) then
        return;
    end

    local bc = table.getn(manager.idList);

    local firstInvalidIndex = -1;
    for i, v in ipairs(manager.idList) do
        local t = manager.latestAccess[v];
        if (not t) then
            error(string.format([[latest access time lost. session id [%s].]]
                , v));
        end
        if ((n - t) > nwf.session.timeoutSeconds) then
            if (firstInvalidIndex == -1) then
                    firstInvalidIndex = i;
            end
            manager.latestAccess[v] = nil;
            manager.data[v] = nil;
        end
    end
    if (firstInvalidIndex > 0) then
        for i = table.getn(manager.idList), firstInvalidIndex, -1 do
            table.remove(manager.idList, i);
        end
        --table.setn(manager.idList, firstInvalidIndex - 1);
    end

    local ac = table.getn(manager.idList);
    print(string.format([[session manager gc: %d session expired. total: %d.]]
        , bc - ac, ac));
end


--  create a new session
local function newSession()
    gc();
    local id = new_guid();
    table.insert(manager.idList, 1, id);
    manager.latestAccess[id] = os.time();
    local s = {id = id};
    manager.data[id] = s;
    return s;
end


--  get session by specified session id
--  it will return a new session if id is nil.
local function get(id)
    if (id) then
        local t = manager.latestAccess[id];
        if (t) then
            local n = os.time();
            if (n - t > nwf.session.timeoutSeconds) then
                return newSession();
            else
                manager.latestAccess[id] = os.time();
                local ci = getIndex(id);
                if (not ci) then
                    error("session id is valid but not found in id list.");
                end
		table.remove(manager.idList, ci);
                table.insert(manager.idList, 1, id);
                return manager.data[id];
            end
        else
            return newSession();
        end
    else
        return newSession();
    end
end


--  save session(refresh session data)
local function save(s)
    if (not s) then
        error("session can not be nil");
    end
    if (not s.id) then
        error("session.id can not be nil");
    end
    local t = manager.latestAccess[s.id];
    if (t) then
        local n = os.time();
        if (n - t > nwf.session.timeoutSeconds) then
            error("session was expired.");
        else
            manager.latestAccess[s.id] = os.time();
            local ci = getIndex(s.id);
            if (not ci) then
                error("session id is valid but not found in id list.");
            end
            table.remove(manager.idList, ci)
            table.insert(manager.idList, 1, s.id);
            manager.data[s.id] = s;
        end
    else
        error("session.id is not a valid id.");
    end
    gc();
end

session.get = get;
session.save = save;
session.gc = gc;

-- register session filter
nwf.registerFilter(function(ctx, doNext)
    local req = ctx.request;
    local res = ctx.response;

    local sessionIdKey = nwf.config.session_cookie_key or "sid";
    local sessionTimeout = nwf.config.session_timeout or nwf.session.timeoutSeconds
    if (sessionTimeout) then
        if (sessionTimeout > 1) then
            nwf.session.timeoutSeconds = sessionTimeout
        else
            error("error: config session timeout seconds invalid.")
        end
    else
        error("error: config session timeout seconds can not be nil.")
    end

    local sid = req:get_cookie(sessionIdKey);
    ctx.session = nwf.session.get(sid);
    doNext();
    res:set_cookie(sessionIdKey,
        {
            value = ctx.session.id,
            expire= os.time() + nwf.session.timeoutSeconds,
            path="/ ;HttpOnly"
        });
    nwf.session.save(ctx.session);
end);
