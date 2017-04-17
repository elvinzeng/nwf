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
├── module_source_repos.conf     --> 模块源的配置文件
├── dependencies.conf            --> 配置此项目依赖的模块
├── reinitialize.sh              --> 重新初始化项目的工具脚本（项目小组其他成员clone了项目之后可以运行这个脚本初始化所有git子模块）
├── npl_packages                 --> npl packages 根目录
│   ├── main                     --> NPL main package
│   └── nwf                      --> nwf package
├── .nwf                         --> 一些框架自动生成的文件，用于保存框架的内部数据。
│   ├── init_flag                --> 项目初始化信息
│   └── md5sum                   --> nwf自动生成的文件的校验和信息
├── pack.sh                      --> 源码压缩脚本
├── restart_debug.sh             --> 重启服务器(linux)
├── shutdown.sh                  --> 关闭服务器(linux)
├── start.sh                     --> 启动服务器(linux)
├── start_win.bat                --> 启动服务器(Windows)
├── update_packages.sh           --> 更新main package以及nwf框架的包(linux and Windows)
└── www                          --> web应用运行时的根目录
    ├── app_initialized.lua      --> 网站完成启动之后执行的脚本
    ├── controller               --> 控制器搜索目录
    │   ├── DemoController.lua
    │   └── RootController.lua
    ├── modules                  --> 项目的模块根目录
    ├── mvc_settings.lua         --> 框架初始化配置文件
    ├── router.lua               --> 框架核心模块
    ├── static                   --> js、css等静态文件所在目录
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

# 安装依赖的模块

首先配置好项目依赖的[模块](https://github.com/elvinzeng/nwf/blob/master/doc/zh-hans/nwf-module.md)

```shell
elvin@elvin-idreamtech ~/workspace/testnwf $ cat dependencies.conf 
preload_controller_mod
helloworld
```

然后执行以下命令安装所有配置文件中的[模块](https://github.com/elvinzeng/nwf/blob/master/doc/zh-hans/nwf-module.md)

```shell
~ $ ./nwf_module_manage.sh -I
```

如果你还不熟悉nwf模块，可以暂时跳过这一步直接启动服务器。

# 运行服务器
* Linux: sh start.sh
* Windows: 运行update_packages.sh更新包，然后运行start_win.bat
* 打开浏览器访问"http://localhost:8099/ ". 如果看到页面上显示"it works!"则表示运行成功。
