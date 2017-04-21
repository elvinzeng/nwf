local resultMapper = commonlib.inherit(nil, commonlib.gettable("nwf.modules.db_postgres.mapper"));

resultMapper.selMapper = nil;

local function transformValue(type, value)
    if (type == "number") then
        return tonumber(value);
    elseif(type == "bool") then
        if (value == "f" or value == "false") then
            return false;
        elseif(value == "t" or value == "true") then
            return true;
        end
        return value;
    end
    return value;
end

function resultMapper:get()
    return self.selMapper.arrays;
end

function resultMapper:setResMapper(mapper)
    local copy = commonlib.copy(mapper);
    self.selMapper = copy;
    return self.selMapper;
end

function resultMapper:setValue(mapper, row, flag, isObj)
    if (mapper == nil) then
        mapper = self:setResMapper(self.entity);
    end

    local id;
    local typePrimaryKey = type(mapper.primaryKey);
    if (typePrimaryKey == "table") then
        local idTb = {};
        for _, v in pairs(mapper.primaryKey) do
            table.insert(idTb, row[v]);
        end
        id = table.concat(idTb, "_");

    elseif (typePrimaryKey == "string") then
        id = row[mapper.primaryKey];
    end

    if (id) then
        if (not mapper.idSet) then
            mapper.idSet = commonlib.UnorderedArraySet:new();
        end
        if (mapper.idSet:add(id)) then
            local item = {};
            for k, v in pairs(mapper) do
                if (type(v) == "table" and v.type == "list") then
                    local _item = self:setValue(v.mapper, row, true, false);
                    if (_item) then
                        if (not item[v.prop or k]) then
                            item[v.prop or k] = commonlib.Array:new();
                        end
                        item[v.prop or k]:add(_item);
                    end
                elseif (type(v) == "table" and v.type == "obj") then
                    item[k] = self:setValue(v.mapper, row, true, true);
                end
            end
            for k, v in pairs(row) do
                if (mapper[k]) then
                    local value = transformValue(mapper[k].luaType, v);
                    item[mapper[k].prop or k] = value;
                    row[k] = nil;
                end
            end
            if (not mapper.arrays) then
                mapper.arrays = commonlib.Array:new();
            end
            mapper.arrays:add(item);

            if (flag == true) then
                return item;
            end
        else
            local item;
            for _, v in pairs(mapper.arrays) do
                if ((v[mapper[mapper.primaryKey].prop] or v[mapper.primaryKey]) == id) then
                    item = v;
                    break;
                end
            end
            for k, v in pairs(mapper) do
                if (type(v) == "table" and v.type == "list") then
                    local _item = self:setValue(v.mapper, row, true, false);
                    if (_item) then
                        if (not item[k]) then
                            item[k] = commonlib.Array:new();
                        end
                        item[k]:add(_item);
                    end
                elseif (type(v) == "table" and v.type == "obj") then
                    item[k] = self:setValue(v.mapper, row, true, true);
                end
            end
            if (isObj) then
                return item;
            end
        end
    end
end
