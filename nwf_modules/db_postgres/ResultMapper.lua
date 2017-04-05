local resultMapper = commonlib.inherit(nil, commonlib.gettable("nwf.db.mapper"));

resultMapper.selMapper = nil;

function resultMapper:get()
    return self.selMapper.arrays;
end

function resultMapper:setResMapper(mapper)
    self.selMapper = mapper;
end

function resultMapper:setValue(mapper, row, prefix, flag, isObj)
    local id = row[mapper.primaryKey];
    if (id) then
        if (not mapper.idSet) then
            mapper.idSet = commonlib.UnorderedArraySet:new();
        end
        if (mapper.idSet:add(id)) then
            local item = {};
            for k, v in pairs(mapper) do
                if (type(v) == "table" and v.type == "list") then
                    local _item = self:setValue(v.mapper, row, k, true, false);
                    if (_item) then
                        if (not item[v.prop or k]) then
                            item[v.prop or k] = commonlib.Array:new();
                        end
                        item[v.prop or k]:add(_item);
                    end
                elseif (type(v) == "table" and v.type == "obj") then
                    item[k] = self:setValue(v.mapper, row, k, true, true);
                end
            end
            for k, v in pairs(row) do
                if (prefix == k:match("(%w+)_")) then
                    item[mapper[k].prop or k] = v;
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
                    local _item = self:setValue(v.mapper, row, k, true, false);
                    if (_item) then
                        if (not item[k]) then
                            item[k] = commonlib.Array:new();
                        end
                        item[k]:add(_item);
                    end
                elseif (type(v) == "table" and v.type == "obj") then
                    item[k] = self:setValue(v.mapper, row, k, true, true);
                end
            end
            if (isObj) then
                return item;
            end
        end
    end
end
