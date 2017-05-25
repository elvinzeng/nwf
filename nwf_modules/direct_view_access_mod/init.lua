--
-- desc: Supports direct access to the views via file path for front-end debugging
-- Author: Elvin
-- Date: 17-5-25
-- others: It is only enabled when the nwf.config.echoDebugInfo configuration is set to true.
--

print("direct_view_access_mod module init...");

if (nwf.config.echoDebugInfo) then
    nwf.registerRequestMapper(function(requestPath)
        return function(ctx)
            local filePath = "www/view" .. requestPath
            if (ParaIO.DoesFileExist(filePath, false)) then
                return;
            end
            local f = assert(io.open(filePath, "r"))
            local str = f:read("*all");
            f:close();
            return "raw", {content = str}
        end;
    end);
    print("warning: direct_view_access_mod module is enabled.");
end
