--[[
title: NPL web framework dispatcher
author: zenghui
date: 2017/3/1
desc: dispatcher is core of NPL Web framework.

          .,:,,,                                        .::,,,::.
        .::::,,;;,                                  .,;;:,,....:i:
        :i,.::::,;i:.      ....,,:::::::::,....   .;i:,.  ......;i.
        :;..:::;::::i;,,:::;:,,,,,,,,,,..,.,,:::iri:. .,:irsr:,.;i.
        ;;..,::::;;;;ri,,,.                    ..,,:;s1s1ssrr;,.;r,
        :;. ,::;ii;:,     . ...................     .;iirri;;;,,;i,
        ,i. .;ri:.   ... ............................  .,,:;:,,,;i:
        :s,.;r:... ....................................... .::;::s;
        ,1r::. .............,,,.,,:,,........................,;iir;
        ,s;...........     ..::.,;:,,.          ...............,;1s
       :i,..,.              .,:,,::,.          .......... .......;1,
      ir,....:rrssr;:,       ,,.,::.     .r5S9989398G95hr;. ....,.:s,
     ;r,..,s9855513XHAG3i   .,,,,,,,.  ,S931,.,,.;s;s&BHHA8s.,..,..:r:
    :r;..rGGh,  :SAG;;G@BS:.,,,,,,,,,.r83:      hHH1sXMBHHHM3..,,,,.ir.
   ,si,.1GS,   sBMAAX&MBMB5,,,,,,:,,.:&8       3@HXHBMBHBBH#X,.,,,,,,rr
   ;1:,,SH:   .A@&&B#&8H#BS,,,,,,,,,.,5XS,     3@MHABM&59M#As..,,,,:,is,
  .rr,,,;9&1   hBHHBB&8AMGr,,,,,,,,,,,:h&&9s;   r9&BMHBHMB9:  . .,,,,;ri.
  :1:....:5&XSi;r8BMBHHA9r:,......,,,,:ii19GG88899XHHH&GSr.      ...,:rs.
  ;s.     .:sS8G8GG889hi.        ....,,:;:,.:irssrriii:,.        ...,,i1,
  ;1,         ..,....,,isssi;,        .,,.                      ....,.i1,
  ;h:               i9HHBMBBHAX9:         .                     ...,,,rs,
  ,1i..            :A#MBBBBMHB##s                             ....,,,;si.
  .r1,..        ,..;3BMBBBHBB#Bh.     ..                    ....,,,,,i1;
   :h;..       .,..;,1XBMMMMBXs,.,, .. :: ,.               ....,,,,,,ss.
    ih: ..    .;;;, ;;:s58A3i,..    ,. ,.:,,.             ...,,,,,:,s1,
    .s1,....   .,;sh,  ,iSAXs;.    ,.  ,,.i85            ...,,,,,,:i1;
     .rh: ...     rXG9XBBM#M#MHAX3hss13&&HHXr         .....,,,,,,,ih;
      .s5: .....    i598X&&A&AAAAAA&XG851r:       ........,,,,:,,sh;
      . ihr, ...  .         ..                    ........,,,,,;11:.
         ,s1i. ...  ..,,,..,,,.,,.,,.,..       ........,,.,,.;s5i.
          .:s1r,......................       ..............;shs,
          . .:shr:.  ....                 ..............,ishs.
              .,issr;,... ...........................,is1s;.
                 .,is1si;:,....................,:;ir1sr;,
                    ..:isssssrrii;::::::;;iirsssssr;:..
                         .,::iiirsssssssssrri;;:.

]]

-- init objects
local nwf = commonlib.gettable("nwf");
local string_util = commonlib.gettable("nwf.util.string");
nwf.dispatcher = {};
local dispatcher = nwf.dispatcher;

local controller_not_found_message_template = [[<p>controller [%s] founded, but it seen not been registed as an controller.</p>
you can register a controller like this:<br />
<pre>
local controller = commonlib.gettable("nwf.controllers.%s");

function controller.%s(ctx)
    if (ctx.validation.isEnabled) then
        return "test", {message = "Hello, Elvin!"}; -- return www/view/test.html
    else
        return "raw", {content=ctx.validation.message};
    end
end
</pre>
]];

local validator_not_found_message_template = [[
validator [%s] founded, but it seen not been registed as an validator.
you can register a validator like this:
local validator = commonlib.gettable("nwf.validators.%s");

function validator.%s(params)
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
    if (not nwf.controllers[controllerName]) then
        if(not file_exists(controllerPath)) then
            return {status = 500, message = string.format("controller file not found: %s"
                , controllerPath)};
        end
        NPL.load(controllerPath);
        if (not nwf.controllers[controllerName]) then
            return {status = 500, message = string.format(controller_not_found_message_template
                , controllerPath, controllerName, func)};
        end

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
    if (not nwf.validators[validatorName]) then
        if(not file_exists(validatorPath)) then
            return {message = string.format("validator file not found: %s"
                , validatorPath)};
        end
        NPL.load(validatorPath);
        if (not nwf.validators[validatorName]) then
            return {message = string.format(validator_not_found_message_template
                , validatorPath, validatorName, func)};
        end
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
    if (nwf.requestMappings[requestPath]) then
        return nwf.requestMappings[requestPath].action or {status = 500
            , message = "controller already registered, but function of "
                    .. requestPath .. " not found"}
            , nwf.requestMappings[requestPath].validator or {status = 500
            , message = "validator of " .. requestPath .. " not found"};
    end

    --  get action and validator from custom requestMapper.
    for i, mapper in ipairs(nwf.requestMapper) do
        local act, vali = mapper(requestPath);
        if (act) then
            if (vali) then
                return act, vali;
            else
                return act, {message = "can not found specified validator."};
            end
            break
        end
    end

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
        local name_prifix = "";
        for i, v in ipairs(parts) do
            if (v ~= "" and i < #parts - 1) then
                p = p .. v .. "/";
                if (name_prifix == "") then
                    name_prifix = v;
                else
                    name_prifix = name_prifix .. "_" .. v;
                end
            end
        end
        controllerPath = controllerPath .. p .. controllerName .. ".lua";
        validatorPath = validatorPath .. p .. validatorName .. ".lua";
        controllerName = name_prifix .. "_" .. controllerName;
        validatorName = name_prifix .. "_" .. validatorName;
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
        model = {ctx = ctx }
    else
        if (not model.ctx) then
            model.ctx = ctx
        end
    end
    local res = ctx.response;
    if (not view or view == "") then
        if (nwf.config.echoDebugInfo) then
            res:status(500):send([[<html><body>view cannot be nil or empty!</body></html>]]);
            res:finish();
        else
            print("view cannot be nil or empty!");
            if (nwf.config.redirectToErrorPage) then
                nwf.redirectToErrorPage(ctx)
            else
                res:status(500):send([[<html><body>server error</body></html>]]);
                res:finish();
            end
        end
    end
    if (type(view) == "table") then
        res:set_header('Content-Type', 'application/json;charset=utf-8');
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
            if (nwf.config.redirectToErrorPage) then
                nwf.redirectToErrorPage(ctx, 404)
            else
                res:status(404):send(string.format([[<html><body>specified view not found: %s
                </body></html>]], view));
                res:finish();
            end
        end
        local resbody = "";
        local template = commonlib.gettable("nwf.template");
        template.print = function(s)
            resbody = resbody .. s;
        end
        template.render(view, model);
        res:set_header('Content-Type', 'text/html;charset=utf-8');
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
    if (ctx.request:GetMethod() == 'OPTIONS') then
        return
    end

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
            res:set_header('Content-Type', 'text/html;charset=utf-8');
            res:status(action.status):send(string.format([[<html><body>%s</body></html>]]
                , action.message));
            res:finish();
        else
            print(action.message);
            if (nwf.config.redirectToErrorPage) then
                if (action.status == 404) then
                    nwf.redirectToErrorPage(ctx, 404)
                else
                    nwf.redirectToErrorPage(ctx)
                end
            else
                res:set_header('Content-Type', 'text/html;charset=utf-8');
                res:status(action.status):send(string.format([[<html><body>%s</body></html>]]
                    , "server error"));
                res:finish();
            end
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
            res:set_header('Content-Type', 'text/html;charset=utf-8');
            res:status(500):send(string.format([[<html><head><title>error</title></head>
            <body><h3>%s</h3><h4>%s</h4><pre>%s</pre></body></html>]], e, m, tb));
            res:finish();
        else
            if (nwf.config.redirectToErrorPage) then
                nwf.redirectToErrorPage(ctx)
            else
                res:status(500):send([[<html><head><title>error</title></head>
            <body>server error</body></html>]]);
                res:finish();
            end
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
            res:set_header('Content-Type', 'text/html;charset=utf-8');
            res:status(500):send(string.format([[<html><head><title>error</title></head>
            <body><h3>%s</h3><h4>%s</h4><pre>%s</pre></body></html>]], e, m, tb));
            res:finish();
        else
            if (nwf.config.redirectToErrorPage) then
                nwf.redirectToErrorPage(ctx)
            else
                res:status(500):send([[<html><head><title>error</title></head>
            <body>server error</body></html>]]);
                res:finish();
            end
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

-- render the view with specified model
-- @param ctx: request context
-- @param view: view
-- @param model: model to render a view
nwf.render = function(ctx, view, model)
    if (not ctx) then
        error("parameter ctx can not be nil.");
    end
    if (not view) then
        error("parameter view can not be nil.");
    end
    if (not model) then
        model = {};
    end
    render(ctx, view, model, true);
end

-- @param ctx: request context
-- @param code: error code
function nwf.redirectToErrorPage(ctx, code)
    if (not code) then
        code = "error";
    end
    local view = "www/view/" .. tostring(code) .. ".html";

    if(not file_exists(view)) then
        if (nwf.config.echoDebugInfo) then
            print("error: 404.html not found");
            ctx.response:status(404):send(string.format([[<html><body>404.html not found</html>]]));
            ctx.response:finish();
        else
            print("error: " .. code .. ".html not found");
            ctx.response:status(500):send([[<html><head><title>error</title></head>
        <body>server error</body></html>]]);
            ctx.response:finish();
        end
    else
        ctx.response:status(302):set_header("Location", "/" .. code);
        ctx.response:send("");
    end
end

-- register request mapping
-- @param requestPath: request path
-- @param controllerFunc: function of controller
-- @param validatorFunc: function of validator
function nwf.registerRequestMapping(requestPath, controllerFunc, validatorFunc)
    nwf.requestMappings[requestPath] = {action = controllerFunc, validator = validatorFunc};
end

-- register controller
-- @param requestPath: request path
-- @param controllerFunc: function of controller
function nwf.registerController(requestPath, controllerFunc)
    if (not nwf.requestMappings[requestPath]) then
        nwf.requestMappings[requestPath] = {
            action = controllerFunc,
            validator = {
                message = string.format("validator of '%s' not registered."
                    , requestPath)
            }
        };
    else
        nwf.requestMappings[requestPath].action = controllerFunc;
    end
end

-- register validator
-- @param requestPath: request path
-- @param validatorFunc: function of validator
function nwf.registerValidator(requestPath, validatorFunc)
    if (not nwf.requestMappings[requestPath]) then
        nwf.requestMappings[requestPath] = {
            action = {
                status = 404,
                message = string.format("controller of '%s' not registered."
                    , requestPath)
            },
            validator = validatorFunc
        };
    else
        nwf.requestMappings[requestPath].validator = validatorFunc;
    end
end
