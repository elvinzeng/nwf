# nwf模块是什么
为了更好的复用业务功能模块，nwf模块的概念被抽象出来，用来表述一个可以被nwf管理的可在项目间复用的功能模块。一个nwf模块是一个可以被框架管理的具有一定业务功能的可安装或者卸载的软件包。
# helloworld模块
为了演示nwf模块的功能，这里先给出一个例子。helloworld模块。  
## 安装helloworld模块
### 列出所有的可用模块
```shell
elvin@elvin-idreamtech ~/temp/nwf/demoproject $ ./nwf_module_manage.sh -a


db_postgres
数据库访问层api-postgres版
-------
helloworld
A demo module for nwf.
-------
```
### 安装
```shell
elvin@elvin-idreamtech ~/temp/nwf/demoproject $ ./nwf_module_manage.sh -i helloworld
Already up-to-date.
Already up-to-date.
module 'helloworld' founded in repository 'nwf'
start install module helloworld...
copy files...
executing www/modules/helloworld/install.sh
helloworld module install...
module helloworld installattion completed.
```
### 启动网站
```shell
elvin@elvin-idreamtech ~/temp/nwf/demoproject $ sh ./start.sh
Already up-to-date.
/home/elvin/temp/nwf/demoproject
            ---ParaEngine Server V1.1---  
```
### 效果
访问 http://localhost:8099/helloMod/test1
# 模块管理命令
不带任何参数直接运行模块管理脚本可以看到帮助信息。
```shell
elvin@elvin-idreamtech ~/temp/nwf/demoproject $ ./nwf_module_manage.sh
options:
    -i 'module name'
        install module
    -d 'module name'
        delete module
    -u 'module name'
        reinstall module
    -m
        list all installed modules
    -a
        list all available modules
```
截至文档更新时，有如上几个参数。最新的参数请以命令输出的信息为准。
# 模块源配置
模块有两种可能的来源，一个是nwf内置模块，另一种是用户自己的私有模块源。  
下面介绍如何配置私有模块源。
修改项目根目录下的module_source_repos.conf文件，改成如下配置：
```shell
elvin@elvin-idreamtech ~/temp/nwf/demoproject $ cat module_source_repos.conf
nwfModules git@git.idreamtech.com.cn:rddept/nwfModules.git
nwfm git@git.xxxx.com:rddept/nwfm.git
```
你可以添加多个模块源，为此仅需要给配置文件添加多行配置。每一行对应一个模块源。每一行分为两个字段，以一个空格分割。第一个字段为仓库名，第二个字段为仓库的路径。如果该行以井号打头，则为注释行。仓库名将会决定仓库被导入项目之后在项目中的目录名，这个是不允许重复的，通常情况下建议仓库名保持与仓库路径中的名称一致。为了避免出错，注意文件换行符使用unix风格，编码为UTF-8。如果是在windows下操作，请使用notepad++之类的程序员用的文本编辑器去编辑配置文件，不要使用Windows自带的记事本。  
然后，再次运行脚本就能查看新的数据了。  

除此之外，每个配置行还可以有第三个字段。第三个字段为可选字段，用于指定模块源仓库的分支。如果不指定，则默认为master分支。  

```shell
elvin@elvin-idreamtech ~/temp/nwf/demoproject $ cat module_source_repos.conf
nwfModules git@git.idreamtech.com.cn:rddept/nwfModules.git dev
nwfm git@git.xxxx.com:rddept/nwfm.git dev
```

# 模块编写
首先，创建好一个nwf的应用。然后，在"www/modules"目录下创建一个以模块名命名的目录。这里以helloworld模块为例。www/modules/目录的文件结构如下：  
<pre>
.
└── helloworld                     --> 模块根目录，目录名即为模块名。
    ├── del.sh                     --> 模块卸载脚本(可以不存在)
    ├── desc.txt                   --> 模块简要描述信息(可以不存在)
    ├── hello.html                 --> demo
    ├── dependencies.conf          --> 依赖的模块列表(如果没有依赖的模块则可以不存在)
    ├── HelloModController.lua     --> demo
    ├── HelloModValidator.lua      --> demo
    ├── init.lua                   --> 模块初始化程序(没有这个文件模块无法被框架加载)
    └── install.sh                 --> 模块安装脚本(可以不存在)
</pre>
install.sh
```shell
#!/bin/bash

echo helloworld module install...

mkdir ../../view/helloworld
cp hello.html ../../view/helloworld
```
del.sh  
```shell
#!/bin/bash

echo helloworld module delete...

rm ../../view/helloworld/hello.html
rmdir ../../view/helloworld
```
desc.txt
```shell
elvin@elvin-idreamtech ~/temp/nwf/demoproject/www/modules/helloworld $ cat desc.txt
A demo module for nwf.
```
init.lua
```lua
--
-- init script for helloworld module
-- Author: elvin
-- Date: 17-3-24
-- Time: 10:46
-- desc: this script will be load at mvc framework loaded..
--

print("helloworld module init...");

NPL.load("(gl)www/modules/helloworld/HelloModController.lua");
NPL.load("(gl)www/modules/helloworld/HelloModValidator.lua");
```
init.lua中你还可以直接[显式注册控制器和校验器](https://github.com/elvinzeng/nwf/blob/master/doc/zh-hans/request-mappings.md)。或者你也可以在你的控制器中调用这个进行注册。  
```lua
nwf.registerRequestMapping("/aaa/bbb/ccc/ddd", function(ctx)
    return "test", {message = "Hello, Elvin!"};
end, function(params) 
    -- do validation here
    -- return validation result here;
end);
```

在模块中创建全局变量建议创建到`nwf.modules.moduleName`下。比如`nwf.modules.helloworld.xxx`、`nwf.modules.helloworld.constant`、`nwf.modules.helloworld.abc`。  

模块根目录下的dependencies.conf文件是一个特殊文件。这是个纯文本文件，用于记录依赖的模块。格式为每个依赖模块的模块名占一行。UTF-8编码，换行符为unix风格。  
注意：给模块取名的时候，需要选取一个全局唯一的名称，以避免出错。
# 发布模块
## 作为框架内建模块发布
将helloworld模块的整个目录提交到nwf项目根目录下的nwf_modules目录中，然后发个pull request。
## 发布到私有源
将helloworld模块的整个目录提交到到私有模块源git仓库的根目录下的nwf_modules中。

# 在私有模块源目录中调试
通过nwf模块机制，我们可以很方便的将多项目的系统中的公共代码提取出来，作为一个独立的项目被其他项目引用。
  
## 实际场景
下面以我当前手头上的中药溯源系统为例。这个系统被拆分为5个子项目，目录结构如下：

```
.
├── nwf_init.sh
├── nwfModules
├── zysy-collector
├── zysy-company
├── zysy-consumer
├── zysy-modules
└── zysy-platform
```
zysy-collector、zysy-company、zysy-consumer、zysy-platform四个项目是四个网站。
zysy-modules项目则是中药溯源系统这四个网站用到的公共模块。
nwfModules是我们小组的内部公共模块项目，也被这四个网站所引用。
## 如何调试
假设我现在想直接在zysy-modules这个项目中开发模块，然后直接启动网站项目就能查看模块的效果。
那么只需要在网站项目的mvc_settings.lua中插入如下配置：  
```lua
-- nwf模块项目的模块basedir相对于本项目的根目录的路径
local moduleSearchPath = '../zysy-modules/nwf_modules/';
-- 把功能模块项目加入模块搜索路径，且优先于项目内安装的模块（用于调试模块）。
table.insert(nwf.mod_path, 1, moduleSearchPath);
```
加入这个配置之后，网站启动的时候就会优先去加载zysy-modules这个模块项目下的nwf模块。
这样做可以非常方便的调试模块代码。模块代码修改之后，只需要重启一下web项目，即可直接预览最新的变更情况。
当模块代码调试结束之后，再提交zysy-modules这个模块项目。并在发布网站之前重新安装一遍web项目依赖的模块即可。
更详细的配置描述请参考[项目配置文档](https://github.com/elvinzeng/nwf/blob/master/doc/zh-hans/settings.md)。
## nwf模块中的load函数
为了支持这种特殊的模块调试方式，在模块中加载其他的lua文件时不能再用`NPL.load`了。
因为`NPL.load`无法用相对路径加载文件。为了解决这个问题，nwf框架提供了一个用于在模块中按相对路径加载文件的函数`load`。
在你的模块的init.lua中，如果需要load当前目录下或者子目录下的某个文件，只需要用相对于init.lua的路径作为参数，即可加载文件。
比如：
```
.
├── db_postgres
├── helloworld
│   ├── del.sh
│   ├── desc.txt
│   ├── hello.html
│   ├── HelloModController.lua
│   ├── HelloModValidator.lua
│   ├── init.lua
│   └── install.sh
└── preload_controller_mod

```

helloworld模块中的init.lua只需要像下面这样加载文件：
```lua
print("helloworld module init...");

load("HelloModController.lua");
load("HelloModValidator.lua");
-- load("aaa/bbb/ccc.lua");

```
注意`load`函数只能用于模块中按相对路径加载文件，无法用在控制器、校验器、过滤器中。


