local resultMapper = commonlib.inherit(nil, commonlib.gettable("nwf.db.mapper"));

NPL.load("(gl)www/db/mapper/GradeMapper.lua")

resultMapper.selMapper = nil;

local function init(mapper, isObj)
	if(isObj) then
		mapper.obj = {};
	else
		mapper.arrays = commonlib.Array:new();
	end
	mapper.idSet = commonlib.UnorderedArraySet:new();
	for k, v in pairs(mapper) do
		if(type(v) == "table" and v.type == "list") then
			init(v.mapper, false);
		elseif(type(v) == "table" and v.type == "obj") then
			init(v.mapper, true);
		end
	end
end

function resultMapper:get()
	return self.selMapper.arrays;
end

function resultMapper:setResMapper(mapper)
	self.selMapper = mapper;
	init(mapper);
end

function resultMapper:setValue(mapper, row, prefix, flag)
	local id = row[mapper.primaryKey];
	if(id) then
		if(mapper.idSet:add(id)) then
			local item = {};
			for k, v in pairs(mapper) do
				if(type(v) == "table" and v.type == "list") then
					item[ k ] = commonlib.Array:new();
					local _item = self:setValue(v.mapper, row, k, true);
					if(_item)then
						item[ v.prop or k ]:add(_item);
					end 
				elseif(type(v) == "table" and v.type == "obj")then
					item[k] = self:setValue(v.mapper, row, k, true);
				end
			end
			for k, v in pairs(row) do
				if(prefix == k:match("(%w+)_")) then
					item[ mapper[k].prop or k ] = v;
					row[k] = nil;
				end
			end
			if(mapper.obj) then
				mapper.obj = item;
			else
				if(not mapper.arrays) then
					mapper.arrays = commonlib.Array:new();
				end
				mapper.arrays:add(item);
			end
			if(flag == true) then
				return item;
			end
		else
			local item = mapper.obj;
			local isObj = false;
			if(not item) then
				for k, v in pairs(mapper.arrays) do
					if((v[mapper[mapper.primaryKey].prop] or v[mapper.primaryKey]) == id) then
						item = v;
						break;
					end
				end
			else
				isObj = true;
			end
			for k, v in pairs(mapper) do
				if(type(v) == "table" and v.type == "list") then
					local _item = self:setValue(v.mapper, row, k, true);
					if(_item) then
						item[ k ]:add(_item);
					end
				elseif(type(v) == "table" and v.type == "obj") then
					item[ k ] = self:setValue(v.mapper, row, k, true);
				end
			end
			if(isObj) then
				return item;
			end
		end
	end
end
