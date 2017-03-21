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

	关联查询约定：
	使用关联查询的时候需要注意的点
		1.为每个表的字段设置别名
			格式为[prefix]_[fieldName]
				prefix：别名前缀 同一个表下的数据，prefix相同（可以理解为类名）
				fieldName：字段名 自定义
		2.必须查询每个表的id字段 命名为[prefix]_id
		3.调用queryFirst 或 queryList时 传入所有别名前缀组成的table
			{mainTbPrefix，fromTbPrefix1，fromTbPrefix2, ...}
			其中第一个table的第一项必须为主表的别名前缀， 其他的为从表的别名前缀
	e.g.
	local sql = SELECT c.id as class_id,
					c.name as class_name,
					s.id as student_id,
					s.name as student_name,
					s.age as student_age,
					s.class_id as student_classId ,
					x.id as xxx_id,
					x.name as xxx_name,
					x.class_id as xxx_classId
				FROM class c
				LEFT JOIN student s ON s.class_id = c.id
				LEFT JOIN xxx x ON x.class_id = c.id
				WHERE c.id = 2;
	local data,err = dbTemplate:queryFirst(sql, {"class","student","xxx"});

	分页查询约定：
		调用queryList时传入countSql，pageIndex，pageSize三个参数
		传入的sql中的分页子句 LIMIT %d OFFSET %d

		分页查询和关联查询的时候需要注意sql的写法
	e.g.
	local sql = SELECT c.id as class_id,
					c.name as class_name,
					s.id as student_id,
					s.name as student_name,
					s.age as student_age,
					s.class_id as student_classId ,
					x.id as xxx_id,
					x.name as xxx_name,
					x.class_id as xxx_classId
				FROM (SELECT id, name FROM class LIMIT %d OFFSET %d) c
				LEFT JOIN student s ON s.class_id = c.id
				LEFT JOIN xxx x ON x.class_id = c.id;
	local data,err = dbTemplate:queryList(sql, {"class","student","xxx"}, " select count(1) from class ", 1, 3);
]]

local dbTemplate = commonlib.gettable("nwf.db.dbTemplate");
local connectionManager = commonlib.gettable("nwf.db.connectionManager");

--[[
	将游标中的数据装进list并返回，支持关联查询
	@Param cursor 游标对象
	@Param tbAliasPrefix 别名前缀组成的table
	@Return array: 列表
]]
local function getListFromCursor(cursor, tbAliasPrefix)
	local array = commonlib.Array:new();
	if(tbAliasPrefix and #tbAliasPrefix > 1) then
		local fromTbAliasPrefix = {};-- 从表前缀为key，存放从表的id的set为value的table
		for k,v in pairs(tbAliasPrefix) do
			if( k > 1) then
				local set = commonlib.UnorderedArraySet:new();
				fromTbAliasPrefix[v] = {idSet = set};
			end
		end
		local mainIdSet = commonlib.UnorderedArraySet:new();
		local mainTbAliasPrefix = tbAliasPrefix[1];

		for row in function() return cursor:fetch({}, "a"); end do
			local id = row[mainTbAliasPrefix.."_id"];
			if(mainIdSet:add(id)) then
				local item = {};
				for prefix,content in pairs(fromTbAliasPrefix) do
					content.idSet:clear();
					local fromTbId = row[prefix.."_id"];
					if(fromTbId) then
						content.idSet:add(fromTbId);
						local fromTbItemList = commonlib.Array:new();
						local fromTbItem = {};
						fromTbItemList:add(fromTbItem);
						item[prefix] = fromTbItemList;
					end
				end
				for k,v in pairs(row) do
					local _prefix, _alias = k:match("(%w+)_([%w_]+)");
					if(_prefix == mainTbAliasPrefix) then
						item[_alias] = v;
					else
						for prefix,content in pairs(fromTbAliasPrefix) do
							if(_prefix == prefix) then
								local fromTbItemList = item[prefix];
								local fromTbItem = fromTbItemList:first();
								fromTbItem[_alias] = v;
								break;
							end
						end
					end
				end
				array:add(item);
			else
				local item = array:last();
				for prefix,content in pairs(fromTbAliasPrefix) do
					if(content.idSet:add(row[prefix.."_id"])) then
						local fromTbItemList = item[prefix];
						local fromTbItem = {};
						for k,v in pairs(row) do
							local _prefix, _alias = k:match("(%w+)_([%w_]+)");
							if(_prefix == prefix) then
								fromTbItem[_alias] = v;
								row[k] = nil;
							elseif(_prefix == mainTbAliasPrefix) then
								row[k] = nil;
							end
						end
						fromTbItemList:add(fromTbItem);
					end
				end
			end
		end
	else
		for row in function() return cursor:fetch({}, "a"); end do
			array:add(row);
		end
	end
	return array;
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
	assert(not err, err.." occurs when execute: "..sql);
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
			if((err) then
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
	@Param tbAliasPrefix 别名前缀table
	@Param countSql 查询记录数的sql语句 分页的时候用到 与pageIndex、pageSize共用
	@Param pageIndex 当前页，为nil时查全部，否则pageIndex > 0
	@Param pageSize 页数，为nil时查全部，否则pageSize > 0
	@Return _data:数据
]]
function dbTemplate:queryList(sql, tbAliasPrefix, countSql, pageIndex, pageSize)
	if( countSql == nil or pageIndex == nil or pageSize == nil) then
		local cursor, err = self.execute(sql);
		local _data = nil;
		if(cursor) then
			local res = getListFromCursor(cursor, tbAliasPrefix);
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
					local res = getListFromCursor(cursor, tbAliasPrefix);
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
	@Param tbAliasPrefix 别名前缀table
	@Return _data:数据
]]
function dbTemplate:queryFirst(sql, tbAliasPrefix)
	local cursor, err = self.execute(sql);
	local _data = nil;
	if(cursor) then
		if(tbAliasPrefix) then
			local res = getListFromCursor(cursor, tbAliasPrefix);
			_data = res:first();
		else
			_data = cursor:fetch({}, "a");
		end
	end
	return _data or {};
end
