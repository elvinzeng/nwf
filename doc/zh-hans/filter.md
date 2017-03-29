# concept
filter is a function that can do something before or after handle http request. it is the same as jsp filter, .NET http module, nodejs and django middleware.
# define
you should register you filter in www/mvc_settings.lua like below:
```lua
------------------------------------------------------------------
--  这里注册web应用的各种过滤器
------------------------------------------------------------------
nwf.registerFilter(function(ctx, doNext)
    local req = ctx.request;
    local res = ctx.response;
    doSomething();
    doNext();
    doSomething();
end);
```
parameter ctx is the same as [controller](https://github.com/elvinzeng/nwf/wiki/controller).  
parameter doNext is a function, you should invoke it anyway while your work was done to avoid terminate process http request. invoke doNext will call the next filter or handle request by [controller](https://github.com/elvinzeng/nwf/wiki/controller).