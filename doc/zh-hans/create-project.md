# 创建项目
首先，将你的NPLRuntime更新到最新的版本，然后设置好环境变量。  
接着打开终端执以下命令(Windows下可以在git-bash中执行)：
```shell
~ $ cd ~/workspace
~/workspace $ curl -O https://raw.githubusercontent.com/elvinzeng/nwf/master/nwf_init.sh
~/workspace $ sh ./nwf_init.sh "project-name"  
```

脚本的参数为想要创建的项目的项目名称。初始化脚本会自动创建好目录结构并生成必要的文件。
# 项目结构
<pre>
.                                --> 项目根目录
├── init_flag                    --> 用于存储项目初始化信息
├── npl_packages                 --> npl packages 根目录
│   ├── main                     --> NPL main package
│   └── nwf                      --> nwf package
├── pack.sh                      --> 源码压缩脚本
├── restart_debug.sh             --> 重启服务器(linux)
├── shutdown.sh                  --> 关闭服务器(linux)
├── start.sh                     --> 启动服务器(linux)
├── start_win.bat                --> 启动服务器(Windows)
├── update_packages.sh           --> 更新main package以及nwf框架的包(linux and Windows)
└── www                          --> web应用运行时的根目录
    ├── controller               --> 控制器搜索目录
    │   ├── DemoController.lua
    │   └── RootController.lua
    ├── mvc_settings.lua         --> 框架初始化配置文件
    ├── router.lua               --> 框架核心模块
    ├── validator                --> 校验器搜索目录
    │   └── DemoValidator.lua
    ├── view                     --> 模板文件搜索目录
    │   └── test.html
    ├── webapp.lua               --> 框架核心模块
    └── webserver.config.xml     --> NPL WebServer配置文件
</pre>

# 修改数据库配置
```xml
  <config>
    <string name='DEV_MODE'>debug</string>
    <table name='db'>
      <string name='host'>localhost</string>
      <string name='user_name'>postgres</string>
      <string name='user_password'>123456</string>
      <string name='database'>test</string>
      <string name='port'>5432</string>
    </table>
  </config>

```

## 运行服务器
* Linux: sh start.sh
* Windows: 运行update_packages.sh更新包，然后运行start_win.bat
* 打开浏览器访问"http://localhost:8099/ ". 如果看到页面上显示"it works!"则表示运行成功。
