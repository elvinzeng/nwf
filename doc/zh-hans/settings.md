# settings
nwf settings should be set in www/mvc_settings.lua.
# e.g.
```lua
local nwf = commonlib.gettable("nwf");
local config = commonlib.gettable("nwf.config");

config.echoDebugInfo = true;  -- 是否在页面上显示调试信息
```
# properties
| name           | value| type | desc |
| ------------------- | ------------------ | ------------ |------------ |
| nwf.config.echoDebugInfo | true/false | boolean | set true to enable echo of debug info in response stream |
