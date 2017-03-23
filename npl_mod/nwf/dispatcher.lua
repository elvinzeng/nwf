--[[
title: NPL web framework dispatcher
author: zenghui
date: 2017/3/1
desc: dispatcher is core of NPL Web framework.
]]

-- init objects
local nwf = commonlib.gettable("nwf");
local string_util = commonlib.gettable("nwf.util.string");
nwf.dispatcher = {};
local dispatcher = nwf.dispatcher;

local controller_not_found_message_template = [[<p>controller [%s] founded, but it seen not been registed as an controller.</p>
you can register a controller like this:<br />
<pre>
local demoController = commonlib.gettable("nwf.controllers.DemoController");

function demoController.sayHello(ctx)
        return "test2", {message = "Hello, Elvin!"}; -- return www/view/test2.html
end
</pre>
]];

local validator_not_found_message_template = [[
validator [%s] founded, but it seen not been registed as an validator.
you can register a validator like this:
local demoValidator = commonlib.gettable("nwf.validators.DemoValidator");

function demoValidator.testlogin(params)
    -- local username = params.username;
    -- local password = params.password;
    -- do validation here
	return false, {
	                username = "field username could not be nil",
	                password = "field password could not be nil"
	              }
end
]];


local function file_exists(path)
	return ParaIO.DoesFileExist(path, false);
end


-- get specified action
-- @param controllerPath: controller path
-- @param controllerName: controller name
-- @pram func: function
local function getAction(controllerPath, controllerName, func)
    if(not file_exists(controllerPath)) then
        return {status = 500, message = string.format("controller file not found: %s"
            , controllerPath)};
    end
    NPL.load(controllerPath);
    if (not nwf.controllers[controllerName]) then
        return {status = 500, message = string.format(controller_not_found_message_template
            , controllerPath)};
    end
    local action = nwf.controllers[controllerName][func];
    if (not action) then
        return {status = 404, message = string.format("function [%s] of [%s] not found."
            , func, controllerName)};
    else
        return action;
    end
end


-- get specified validator
-- @param validatorPath: validator path
-- @param validatorName: validator name
-- @pram func: function
local function getValidator(validatorPath, validatorName, func)
    if(not file_exists(validatorPath)) then
        return {message = string.format("validator file not found: %s"
            , validatorPath)};
    end
    NPL.load(validatorPath);
    if (not nwf.validators[validatorName]) then
        return {message = string.format(validator_not_found_message_template
            , validatorPath)};
    end
    local validatorFunc = nwf.validators[validatorName][func];
    if (not validatorFunc) then
        return {message = string.format("function [%s] of [%s] not found. [%s]"
            , func, validatorName, validatorPath)};
    else
        return validatorFunc;
    end
end


-- dispatch request
-- @param: request path. like '/demo/sayHello'
local function dispatch(requestPath)
    local controllerPath = "www/controller/";
    local validatorPath = "www/validator/";
    local ctrl, func = false, false;

    if ("/" == requestPath) then
        return getAction(controllerPath .. "RootController.lua"
            , "RootController", "index"), getValidator(validatorPath .. "RootValidator.lua"
            , "RootValidator", "index");
    end

    func = false;
    func = string.match(requestPath, "^/([%w_]+)$");
    if (func) then
        return getAction(controllerPath .. "RootController.lua"
            , "RootController", func), getValidator(validatorPath .. "RootValidator.lua"
            , "RootValidator", func);
    end

    ctrl = false;
    ctrl = string.match(requestPath, "^/([%w_]+)/$");
    if (ctrl) then
        local controllerName = string_util.upperFirstChar(ctrl) .. "Controller";
        controllerPath = controllerPath .. controllerName .. ".lua";
        local validatorName = string_util.upperFirstChar(ctrl) .. "Validator";
        validatorPath = validatorPath .. validatorName .. ".lua";
        return getAction(controllerPath, controllerName, "index"),
             getValidator(validatorPath, validatorName, "index");
    end

    ctrl = false;
    func = false;
    local ctrl, func = requestPath:match("^/([%w_]+)/([^/]+)$");
    if (ctrl and func) then
        local controllerName = string_util.upperFirstChar(ctrl) .. "Controller";
        controllerPath = controllerPath .. controllerName .. ".lua";
        local validatorName = string_util.upperFirstChar(ctrl) .. "Validator";
        validatorPath = validatorPath .. validatorName .. ".lua";
        return getAction(controllerPath, controllerName, func),
             getValidator(validatorPath, validatorName, func);
    end

    ctrl = false;
    func = false;
    local parts = string_util.split(requestPath, "/");
    if (parts and #parts > 2 and parts[1] == "") then
        ctrl = parts[#parts - 1];
        if (parts[#parts] == "") then
            func = "index";
        else
            func = parts[#parts];
        end
        local controllerName = string_util.upperFirstChar(ctrl) .. "Controller";
        local validatorName = string_util.upperFirstChar(ctrl) .. "Validator";

        local p = "";
        for i, v in ipairs(parts) do
            if (v ~= "" and i < #parts - 1) then
                p = p .. v .. "/";
            end
        end
        controllerPath = controllerPath .. p .. controllerName .. ".lua";
        validatorPath = validatorPath .. p .. validatorName .. ".lua";
        return getAction(controllerPath, controllerName, func),
             getValidator(validatorPath, validatorName, func);
    end

    return {status = 404, message = "can not found route rules." },
        {message = "can not found specified validator."};
end


-- render the view with specified model
-- @param ctx: request context
-- @param view: view
-- @param model: model to render a view
-- @param im: specified whether if need to send response immediately
local function render(ctx, view, model, im)
    if (not model) then
        model = {}
    end
    local res = ctx.response;
    if (not view or view == "") then
        if (nwf.config.echoDebugInfo) then
            res:status(500):send([[<html><body>view cannot be nil or empty!</body></html>]]);
            res:finish();
        else
            print("view cannot be nil or empty!");
            res:status(500):send([[<html><body>server error</body></html>]]);
            res:finish();
        end
    end
    if (type(view) == "table") then
        res:set_header('Content-Type', 'application/json');
        res:SetContent(nil); -- discard any previous text
        view = commonlib.Json.Encode(view);
        res:sendsome(view);
        if (im) then
            res:finish();
        end
        --res:finish();
    elseif (string.match(view, "^redirect:")) then
        -- send redirect
        local target = string.sub(view, 10, -1)
        res:status(302):set_header("Location", target);
        if (im) then
            res:send("");
        end
    else
        view = "www/view/" .. view .. ".html";
        if(not file_exists(view)) then
            res:status(404):send(string.format([[<html><body>specified view not found: %s
                </body></html>]], view));
            res:finish();
        end
        local resbody = "";
        local template = commonlib.gettable("nwf.template");
        template.print = function(s)
            resbody = resbody .. s;
        end
        template.render(view, model);
        res:sendsome(resbody);
        if (im) then
            res:finish();
            res:End();
        end
        --res:finish();
    end
end


-- process a http request
-- @param ctx: request context
local function process(ctx)
    local req = ctx.request;
    local res = ctx.response;
	local requestPath = req:url();

    local si = string.find(requestPath, "%?");
    if (si and si > 1) then
       requestPath =  string.sub(requestPath, 1, si -1);
    end

    local _, func = requestPath:match("^/([%w_]+)/(.+)");
	local action, validator = dispatch(requestPath);
	if (type(action) == "table") then
        if (nwf.config.echoDebugInfo) then
            res:status(action.status):send(string.format([[<html><body>%s</body></html>]]
                , action.message));
            res:finish();
        else
            res:status(action.status):send(string.format([[<html><body>%s</body></html>]]
                , "server error"));
            print(action.message);
            res:finish();
        end
    end

    xpcall(function()
        local g = {
            requestContext = ctx,
            ctx = ctx,
            request = ctx.request,
            response = ctx.response,
            session = ctx.session
        }
        setmetatable(g, {__index = _G})

        if (type(validator) == "table") then
            ctx.validation = {isEnabled = false, message = validator.message}
        else
            setfenv(validator, g);
            local isValid, fields = validator(req:getparams(), req);
            ctx.validation = {isValid = isValid, fields = fields, isEnabled = true}
        end

        setfenv(action, g);
        local view, model = action(ctx);
        if (not view) then
           error("return value of action can not be nil.");
        end
        if (view and type(view) == "function") then
            setfenv(view, g);
            ctx.request._isAsync = true;
            view(ctx, function(view, model)
                if (not model) then
                    model = {};
                end
                render(ctx, view, model, true);
            end);
        else
            render(ctx, view, model);
        end
    end, function(m)
        local info = debug.getinfo(action);
        local e = string.format([[error: function [%s], file [%s], line number [%s].]]
            , func, info.source, info.linedefined);
        print(e);
        print(m);

        local tb = debug.traceback();
        print(tb);

        if (nwf.config.echoDebugInfo) then
            res:status(500):send(string.format([[<html><head><title>error</title></head>
            <body><h3>%s</h3><h4>%s</h4><pre>%s</pre></body></html>]], e, m, tb));
            res:finish();
        else
            res:status(500):send([[<html><head><title>error</title></head>
            <body>server error</body></html>]]);
            res:finish();
        end
    end)
end


-- do filter chain
-- @param filters: filter chain
-- @param i: index of filter to execute
-- @param ctx: request context
local function doFilter(filters, i, ctx)
    xpcall(function()
        filters[i](ctx, function()
            if (i < #filters) then
                doFilter(filters, i + 1, ctx)
            else
                xpcall(function()
                    process(ctx);
                end, function(m)
                    print("error: dispatcher.process execution failed.");
                    print(m);
                    print(debug.traceback())
                end)
            end
        end);
    end, function(m)
        --print("error: filter execution failed.");
        --print(debug.traceback())
        local info = debug.getinfo(filters[i]);
        local e = string.format([[error: an error throws from a filter, file [%s], line number [%s].]]
            , info.source, info.linedefined);
        print(e);
        print(m);

        local tb = debug.traceback();
        print(tb);

        local res = ctx.response;
        if (nwf.config.echoDebugInfo) then
            res:status(500):send(string.format([[<html><head><title>error</title></head>
            <body><h3>%s</h3><h4>%s</h4><pre>%s</pre></body></html>]], e, m, tb));
            res:finish();
        else
            res:status(500):send([[<html><head><title>error</title></head>
            <body>server error</body></html>]]);
            res:finish();
        end
    end)

end


-- handle a http message
local function handle(message)
	local req = WebServer.request:new():init(msg);
	--local requestPath = req:url();
	local filters = commonlib.gettable("nwf.filters");
    if (#filters > 0) then
        doFilter(filters, 1, {
            request = req,
            response = req.response
        });
    else
        xpcall(function()
            process({
                request = req,
                response = req.response
            });
        end, function(m)
            print("error: dispatcher.process execution failed.");
            print(m);
            print(debug.traceback())
        end)
    end

    if (string.find(req.response.statusline, "302")) then
        req.response:send("");
    elseif (req._isAsync) then
        print("a async request.");
    else
        req.response:finish();
        req.response:End();
    end
end

dispatcher.handle = handle;
