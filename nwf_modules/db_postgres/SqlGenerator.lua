--[[
title: NPL web framework sqlGenerator 一个简单的sql语句生成工具
author: links
date: 2017/3/6

	数据库实体类模板，这个主要是用于生产insert和update语句使用的
	tbName:表名
	fields:表字段
	字段属性：notNil: 非空 (生成insert语句的时候会检查是否输入)
			  type: 数据类型
			  isPrimaryKey: 主键不能更新

	local student = commonlib.gettable("nwf.db.entity.student");
	student.tbName = "student";
	student.fields = {
		id = {notNil = true, isPrimaryKey = true},
		name = {notNil = true},
		age = {notNil = true},
		class_id = {notNil = false},
		create_time = {notNil = false},
		is_deleted = {notNil = false}
	}

	e.g.
	local tb = {id="nextval('pf_upm_sys_user_sys_user_id_seq')", name="zhangsan", age=10};

	local sql = sqlGenerator:insert(commonlib.gettable("nwf.db.entity.student"))
							:value(tb)
							:get();

	sql = sqlGenerator:update(commonlib.gettable("nwf.db.entity.student"))
					  :value(tb)
					  :where("id = ",tb.id)
					  :_and(nil,"create_time = now()")
					  :get();

	sql = sqlGenerator:select(" s.name , s.age ")
					  :append("FROM student s LEFT JOIN class c ON c.id = s.id")
					  :where(nil,"create_time = now()")
					  :get();

]]
local sqlGenerator = commonlib.inherit(nil, commonlib.gettable("nwf.modules.db_postgres.sqlGenerator"));

sqlGenerator.type = nil;
sqlGenerator.TYPE_INSERT = "INSERT";
sqlGenerator.TYPE_UPDATE = "UPDATE";
sqlGenerator.TYPE_DELETE = "DELETE";
sqlGenerator.TYPE_SELECT = "SELECT";

local function handleValue(value)
    local res;
    if (value ~= nil) then
        local type = type(value);
        if (type == "table") then
            res = "";
            for _, v in pairs(value) do
                local temp = handleValue(v);
                if (temp) then
                    res = res .. "," .. temp;
                end
            end
            res = string.sub(res, 2);
        elseif (type == "string" and not string.match(value, "%w-%([%'%s]-[%w_]*[%'%s]-%)")) then
            if (#value > 0 and not value:find("^%s*$")) then
                res = "'" .. value .. "'";
            else
                assert(false, "value can not be blank");
            end
        else
            res = value;
        end
    end
    return res;
end

local function handleFiledValue(field, ...)
    local value = ...;
    if (field and value) then
        if (field:find("{%d+}")) then
            local args = { ... };
            for i, v in ipairs(args) do
                local content = v;
                if (type(content) == "table") then
                    content = handleValue(v);
                end
                content = tostring(content);
                if (content and #content > 0 and not content:find("^%s*$")) then
                    field = string.gsub(field, "{" .. i .. "}", content);
                end
            end
            if (field:find("{%d+}")) then
                value = nil;
            else
                value = "";
            end
        else
            value = handleValue(value);
        end
    end
    return field or "", value;
end

--[[
	生成insert语句
	@Param tbEntity 实体
	@Return newInstance
]]
function sqlGenerator:insert(tbEntity)
    local newInstance = self:new();
    newInstance.type = sqlGenerator.TYPE_INSERT;
    newInstance.tbEntity = tbEntity;
    newInstance.fields = {};
    newInstance.values = {};
    return newInstance;
end

--[[
	生成update语句
	@Param tbEntity 实体
	@Return newInstance
]]
function sqlGenerator:update(tbEntity)
    local newInstance = self:new();
    newInstance.type = sqlGenerator.TYPE_UPDATE;
    newInstance.tbEntity = tbEntity;
    newInstance.content = {};
    newInstance.whereStr = "";
    return newInstance;
end

--[[
	生成delete语句
	@Param tbName 表名
	@Return newInstance
]]
function sqlGenerator:delete(tbName)
    local newInstance = self:new();
    newInstance.type = sqlGenerator.TYPE_DELETE;
    newInstance.tbName = tbName;
    newInstance.whereStr = "";
    return newInstance;
end

--[[
	生成select语句
	@Param fields 查找的字段
	@Return newInstance
]]
function sqlGenerator:select(fields)
    local newInstance = self:new();
    newInstance.type = sqlGenerator.TYPE_SELECT;
    newInstance.sql = "SELECT {0} ";
    newInstance.whereStr = "";
    newInstance.fields = fields;
    return newInstance;
end

--[[
	在sql语句末尾追加内容，只有select语句可以使用
	@Param content 追加的sql片段
	@Return self
]]
function sqlGenerator:append(content)
    if (self.type == sqlGenerator.TYPE_SELECT) then
        if (self.whereStr ~= "") then
            self.sql = self.sql .. " " .. self.whereStr;
            self.whereStr = "";
        end
        self.sql = self.sql .. " " .. content;
    end
    return self;
end

--[[
	设置insert和update时的更新内容，键值对
	@Param tb insert和update时的更新内容
	@Return self
]]
function sqlGenerator:value(tb)
    if (self.type == sqlGenerator.TYPE_INSERT) then
        for k, v in pairs(self.tbEntity.entity) do
            local value = tb[k] or tb[v.prop];
            if (v.notNil and value == nil) then
                local prop = v.prop or k;
                assert(false, prop .. " can not be nil");
            end
            local value = handleValue(value);
            if (value ~= nil) then
                table.insert(self.fields, k);
                table.insert(self.values, tostring(value));
            end
        end
    elseif (self.type == sqlGenerator.TYPE_UPDATE) then
        for k, v in pairs(self.tbEntity.entity) do
            local value = tb[k] or tb[v.prop];
            if (self.tbEntity.entity.primaryKey ~= k) then
                local value = handleValue(value);
                if (value ~= nil) then
                    self.content[k] = value;
                end
            end
        end
    end
    return self;
end

--[[
	追加where子句，只调一次即可
	@Param field 查询字段 可为nil , 为空时直接使用value作为拼接的内容
	@Param value 查询条件 field 不为nil时，value会根据类型自动添加转换，类似string型的会加上'',如果value为nil时,那这条语句不会被拼接上去
	@Return self
]]
function sqlGenerator:where(field, ...)
    if (self.type ~= sqlGenerator.TYPE_INSERT) then
        if (self.whereStr == "") then
            local value ;
            field, value = handleFiledValue(field, ...);
            if (value) then
                self.whereStr = "WHERE " .. field .. " " .. value;
            else
                self.whereStr = "WHERE 1 = 1";
            end
        end
    end
    return self;
end

--[[
	追加and子句,在where子句之后调用才有效
	@Param field 查询字段 可为nil , 为空时直接使用value作为拼接的内容
	@Param value 查询条件 field 不为nil时， value会根据类型自动添加转换，类似string型的会加上'',如果value为nil时,那这条语句不会被拼接上去
	@Return self
]]
function sqlGenerator:_and(field, ...)
    if (self.type ~= sqlGenerator.TYPE_INSERT) then
        local value;
        field, value = handleFiledValue(field, ...);
        if (value and self.whereStr ~= "") then
            self.whereStr = self.whereStr .. " AND " .. field .. " " .. value;
        end
    end
    return self;
end

--[[
	追加or子句,在where子句之后调用才有效
	@Param field 查询字段 可为nil , 为空时直接使用value作为拼接的内容
	@Param value 查询条件 field 不为nil时， value会根据类型自动添加转换，类似string型的会加上'',如果value为nil时,那这条语句不会被拼接上去
	@Return self
]]
function sqlGenerator:_or(field, ...)
    if (self.type ~= sqlGenerator.TYPE_INSERT) then
        local value;
        field, value = handleFiledValue(field, ...);
        if (value and self.whereStr ~= "") then
            self.whereStr = self.whereStr .. " OR " .. field .. " " .. value;
        end
    end
    return self;
end

function sqlGenerator:limit(pageIndex, pageSize)
    if (self.type == sqlGenerator.TYPE_SELECT) then
        if (not pageIndex or pageIndex <= 0) then
            assert(false, "pageIndex in function sqlGenerator:limit() must be lager then 0");
        end
        if (not pageSize or pageSize <= 0) then
            assert(false, "pageSize in function sqlGenerator:limit() must be lager then 0");
        end
        self.limitSql = "LIMIT "..pageSize.." OFFSET "..((pageIndex - 1 ) * pageSize);
    end
    return self;
end

function sqlGenerator:orderBy(field)
    if (self.type == sqlGenerator.TYPE_SELECT) then
        self.orderBySql = "ORDER BY "..field;
    end
    return self;
end

--[[
	获取最终结果
]]
function sqlGenerator:get()
    if (self.type == sqlGenerator.TYPE_INSERT) then
        local sql = "INSERT INTO ";
        local fieldStr = table.concat(self.fields, ",");
        local valueStr = table.concat(self.values, ",");
        return sql .. self.tbEntity.tbName .. " (" .. fieldStr .. ") VALUES (" .. valueStr .. ")";
    elseif (self.type == sqlGenerator.TYPE_UPDATE) then
        local sql = "UPDATE "
        local fieldStr = "";
        for k, v in pairs(self.content) do
            fieldStr = fieldStr .. ", " .. k .. '=' .. tostring(v);
        end
        fieldStr = string.sub(fieldStr, 2);
        return sql .. self.tbEntity.tbName .. " SET " .. fieldStr .. " " .. self.whereStr;
    elseif (self.type == sqlGenerator.TYPE_DELETE) then
        local sql = "DELETE FROM ";
        return sql .. self.tbName .. " " .. self.whereStr;
    elseif (self.type == sqlGenerator.TYPE_SELECT) then
        if (self.whereStr ~= "") then
            self.sql = self.sql .. " " .. self.whereStr;
        end
        local sql = string.gsub(self.sql, "{0}", self.fields);
        local countSql = string.gsub(self.sql, "{0}", "COUNT(1)")
        return sql.." "..(self.orderBySql or "").." "..(self.limitSql or ""), countSql;
    end
end
