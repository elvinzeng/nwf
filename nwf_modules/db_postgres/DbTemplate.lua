--[[
title: NPL web framework dbTemplate
author: links
date: 2017/3/6

method:
		dbTemplate.execute
		dbTemplate.executeWithReleaseCtrl
		dbTemplate.executeWithTransaction
		dbTemplate:queryList
		dbTemplate:queryFirst

]]

local dbTemplate = commonlib.gettable("nwf.modules.db_postgres.dbTemplate");
local connectionManager = commonlib.gettable("nwf.modules.db_postgres.connectionManager");

--[[
	将游标中的数据装进list并返回，支持关联查询
	@Param cursor 游标对象
	@Param mapper 关联映射集
	@Return array: 列表
]]
local function getListFromCursor(cursor, mapper)
    if (mapper) then
        for row in function() return cursor:fetch({}, "a"); end do
            mapper:setValue(mapper.selMapper, row);
        end
        return mapper:get();
    else
        local array ;
        for row in function() return cursor:fetch({}, "a"); end do
            if (not array) then
                array = commonlib.Array:new()
            end
            array:add(row);
        end
        return array;
    end
end


--[[
	执行sql语句
	@Param sql sql语句
	@Return res: 执行结果 （游标对象或更新行数）
]]
function dbTemplate.execute(sql)
    local conn = connectionManager.getConnection();
    local res, err = conn:execute(sql);
    conn:commit();
    connectionManager.releaseConnection(conn);
    if (err) then
        assert(false, err .. " occurs when execute: " .. sql);
    end
    return res;
end

--[[
	执行sql语句，支持事务，同时控制连接对象是否释放
	@Param sql sql语句
	@Param conn 数据库连接对象
	@Param release 执行完sql后是否释放conn，true:是
	@Param openTransaction 是否开启事务
	@Return res: 执行结果 （游标对象或更新行数），conn: connection对象
]]
function dbTemplate.executeWithReleaseCtrl(sql, conn, release, openTransaction)
    if (not conn) then
        conn = connectionManager.getConnection();
        local _ = openTransaction and conn:execute("BEGIN;");
    end
    local res, err = conn:execute(sql);
    if (err) then
        if (openTransaction) then
            conn:execute("ROLLBACK;");
            conn:commit();
        end
        connectionManager.releaseConnection(conn);
        assert(false, err .. " occurs when execute: " .. sql);
    end
    if (release) then
        conn:commit();
        connectionManager.releaseConnection(conn);
        return res;
    else
        return res, conn;
    end
end

--[[
	执行sql语句，事务
	@Param ... n条sql语句
]]
function dbTemplate.executeWithTransaction(...)
    local conn = connectionManager.getConnection();
    conn:execute("BEGIN;");
    local args = { ... };
    for _, v in ipairs(args) do
        if (type(v) == "string") then
            local _, err = conn:execute(v);
            if (err) then
                conn:execute("ROLLBACK;");
                conn:commit();
                connectionManager.releaseConnection(conn);
                assert(false, err .. " occurs when execute: " .. v);
            end
        end
    end
    conn:commit();
    connectionManager.releaseConnection(conn);
end

--[[
	查询列表数据，支持关联查询，支持分页
	@Param sql sql语句
	@Param mapper mapper 关联查询的时候使用
	@Param countSql 查询记录数的sql语句 分页的时候用到 与pageIndex、pageSize共用
	@Param pageIndex 当前页，为nil时查全部，否则pageIndex > 0
	@Param pageSize 页数，为nil时查全部，否则pageSize > 0
	@Return _data:数据
]]
function dbTemplate:queryList(sql, mapper, countSql)
    if (countSql == nil) then
        local cursor = self.execute(sql);
        local _data;
        if (cursor) then
            local res = getListFromCursor(cursor, mapper);
            if (res and not res:empty()) then
                _data = res;
            end
        end
        return _data;
    else
        local limit, offset = string.match(string.upper(sql), "LIMIT (%d+) OFFSET (%d+)");
        if (not limit or not offset) then
            assert(false, [[can not match param limit and offset,
					make sure your sql has script like 'LIMIT 5 OFFSET 0']]);
        end
        local cursor, conn = self.executeWithReleaseCtrl(countSql, nil, false);
        local _data;
        if (cursor) then
            local count = cursor:fetch({}, "a").count + 0;
            if (count ~= 0) then
                local pageIndex = offset / limit + 1;
                local pageSize = limit + 0;
                local pageCount = math.ceil(count / pageSize);
                local pagination = {
                    currentPageIndex = pageIndex,
                    pageCount = pageCount,
                    pageSize = pageSize,
                    recordCount = count
                };
                _data = { pagination = pagination };

                cursor = self.executeWithReleaseCtrl(sql, conn, true);
                if (cursor) then
                    local list;
                    local res = getListFromCursor(cursor, mapper);
                    if (res and not res:empty()) then
                        list = res;
                    end
                    _data.list = list or {};
                end
            end
        end
        return _data;
    end
end

--[[
	查询单条记录 支持关联查询
	@Param sql sql语句
	@Param mapper mapper 关联查询的时候使用
	@Return _data:数据
]]
function dbTemplate:queryFirst(sql, mapper)
    local cursor = self.execute(sql);
    local _data;
    if (cursor) then
        if (mapper) then
            local res = getListFromCursor(cursor, mapper);
            _data = res and res:first();
        else
            _data = cursor:fetch({}, "a");
        end
    end
    return _data;
end
