------------------------------------------------------------------
--      desc: MVC框架配置文件
--      author: zenghui
--      date: 2017-3-1
--      attention: 网站启动时将自动执行此文件一次。
--       注意此文件执行之时服务器尚未启动，但是框架已经初始化完毕。
------------------------------------------------------------------
-- local nwf = commonlib.gettable("nwf");
local config = commonlib.gettable("nwf.config");

config.echoDebugInfo = true;  -- 是否在页面上显示调试信息

-- 是否在错误发生时自动跳转到错误页面
-- 该配置项仅当nwf.config.echoDebugInfo设置为false时有效
config.redirectToErrorPage = false;

-- nwf模块项目的模块basedir相对与本项目的根目录的路径
-- local moduleSearchPath = '../nwfModules/nwf_modules/';
-- 把功能模块项目加入模块搜索路径，且优先于项目内安装的模块（用于调试模块）。
-- table.insert(nwf.mod_path, 1, moduleSearchPath);

