# settings
## www/mvc_settings.lua
这个文件将在框架加载的时候自动被执行，并且是在模块被加载之前。你可以在这个文件里放入一些加载公共组件的代码。
### 示例
```lua
local nwf = commonlib.gettable("nwf");
local config = commonlib.gettable("nwf.config");

config.echoDebugInfo = true;  -- 是否在页面上显示调试信息
```
### 可以设置的配置项
| 配置项名           | 值 | 值的类型 | 描述信息 |
| ------------------- | ------------------ | ------------ |------------ |
| nwf.config.echoDebugInfo | true/false | boolean | 如果设置为true则表示将直接在网页中输出调试信息 |
## www/app_initialized.lua
这个文件将会在框架完全加载完毕并且服务器启动之后执行，你可以在这个文件中加入应用启动之后需要执行的代码。
### e.g.
```lua
------------------------------------------------------------------
--      desc: 服务器、框架完全加载之后的处理脚本
--      author: zenghui
--      date: 2017-3-27
--      attention: 网站启动时将自动执行此文件一次。
--      注意此文件执行之时服务器、框架、模块已经完全加载完毕。
--      可以在这个文件里加入一些业务脚本
--	e.g. NPL.load("(gl)www/service/xxx.lua");
------------------------------------------------------------------

print("nwf application starting completed.");
```
