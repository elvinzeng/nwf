--
-- Search all controller and validator and preload it at website startup.
-- Author: Elvin
-- Date: 17-4-14
-- desc: By default nwf will load validator and controller file until first
-- request comming. So, it is impossible to explicit register validator
-- or controller in your validator or controller file by default.
-- This module will search all controller and validator and preload it at website startup.
--

print("preload_controller_mod module init...");

NPL.load("(gl)script/ide/Files.lua");
lfs = commonlib.Files.GetLuaFileSystem();

function loadFileRecursive(basedir, pattern)
  for entry in lfs.dir(basedir) do
    if entry ~= '.' and entry ~= '..' then
        local path = basedir .. '/' .. entry;
        local attr = lfs.attributes(path)
        if(not (type(attr) == 'table')) then
          error("get attributes of '" .. path .. "' failed.");
        end

        if attr.mode == 'directory' then
            loadFileRecursive(path, pattern);
        else
            if (string.match(path, pattern)) then
              print("load: " .. path);
              NPL.load(path);
            else
              print("invalid file name: " .. path);
            end

        end
    end
  end
end

print("scanning controllers and validators...");

loadFileRecursive("www/controller", "Controller.lua$");
loadFileRecursive("www/validator", "Validator.lua$");

print("preload controllers and validators completed.");
