# 概念
过滤器是一个请求过滤函数，用于对请求进行一些特殊处理。类似于java的filter，.NET的http module，nodejs和django的middleware。
# 注册一个过滤器
通常我们会在www/mvc_settings.lua文件中注册过滤器，注册方法像下面这样：
```lua
------------------------------------------------------------------
--  这里注册web应用的各种过滤器
------------------------------------------------------------------
nwf.registerFilter(function(ctx, doNext)
    local req = ctx.request;
    local res = ctx.response;
    doSomething();
    doNext();  -- 千万记得不要漏掉这句，漏掉会导致一直无响应。
    doSomething();
end);
```
参数ctx就是请求上下文，与[控制器](https://github.com/elvinzeng/nwf/blob/master/doc/zh-hans/controller.md)中拿到的是同一个对象。  
参数doNext是一个函数。千万记得一定要调用这个函数，漏掉会导致一直无响应。调用doNext将会调用下一个过滤器，如果没有下一个过滤器则会将请求转交给控制器进行处理。
