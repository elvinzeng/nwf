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
	@Param tbAliasPrefix 别名前缀组成的table
	@Return array: 列表
]]

local function getListFromCursor(cursor, mapper)
	for row in function() return cursor:fetch({}, "a"); end do
		mapper:setValue(mapper.selMapper, row, mapper.prefix);
	end
	return mapper:get();
end


--[[
	执行sql语句
	@Param sql sql语句
	@Return res: 执行结果 （游标对象或更新行数）
]]
function dbTemplate.execute(sql)
	local conn = connectionManager.getConnection();
	local res, err = conn:execute(sql);
	connectionManager.releaseConnection(conn);
	if(err) then
		assert(false, err.." occurs when execute: "..sql);
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
	if(not conn) then
		conn = connectionManager.getConnection();
		local _ = openTransaction and conn:execute("BEGIN;");
	end
	local res,err = conn:execute(sql);
	if(err) then
		if(openTransaction) then
			conn:execute("ROLLBACK;");
			conn:commit();
		end
		connectionManager.releaseConnection(conn);
		assert(false, err.." occurs when execute: "..sql);
	end
	if(release) then
		local _ = openTransaction and conn:commit();
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
	local args = {...};
	for i,v in ipairs(args) do
		if(type(v) == "string") then
			local res, err = conn:execute(v);
			if(err) then
				conn:execute("ROLLBACK;");
				conn:commit();
				connectionManager.releaseConnection(conn);
				assert(false, err.." occurs when execute: "..v);
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
function dbTemplate:queryList(sql, mapper, countSql, pageIndex, pageSize)
	if( countSql == nil or pageIndex == nil or pageSize == nil) then
		local cursor, err = self.execute(sql);
		local _data = nil;
		if(cursor) then
			local res = getListFromCursor(cursor, mapper);
			if(not res:empty()) then
				_data = res;
			end
		end
		return _data or {};
	elseif( pageIndex <= 0) then
		assert(false, "pageIndex must be lager then 0");
	elseif( pageSize <= 0) then
		assert(false, "pageSize must be lager then 0");
	else
		local cursor, conn = self.executeWithReleaseCtrl(countSql, nil, false);
		local _data = nil;
		if(cursor) then
			local count = cursor:fetch({}, "a").count + 0;
			if(count ~= 0) then
				local pageCount = math.ceil(count / pageSize);
				local pagination = {
					currentPageIndex = pageIndex,
					pageCount = pageCount,
					pageSize = pageSize,
					recordCount = count};
				_data = { pagination = pagination };

				local sql = string.format(sql, pageSize, (pageIndex - 1 ) * pageSize);
				cursor = self.executeWithReleaseCtrl(sql, conn, true);
				if(cursor) then
					local list = nil;
					local res = getListFromCursor(cursor, mapper);
					if(not res:empty()) then
						list = res;
					end
					_data.list = list or {};
				end
			end
		end
		return _data or {};
	end
end

--[[
	查询单条记录 支持关联查询
	@Param sql sql语句
	@Param mapper mapper 关联查询的时候使用
	@Return _data:数据
]]
function dbTemplate:queryFirst(sql, mapper)
	local cursor, err = self.execute(sql);
	local _data = nil;
	if(cursor) then
		if(mapper) then
			local res = getListFromCursor(cursor, mapper);
			_data = res:first();
		else
			_data = cursor:fetch({}, "a");
		end
	end
	return _data or {};
end
