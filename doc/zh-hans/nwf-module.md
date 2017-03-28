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
你可以添加多个模块源，为此仅需要给配置文件添加多行配置。每一行对应一个模块源。每一行分为两个字段，以一个空格分割。第一个字段为仓库名，第二个字段为仓库的路径。仓库名将会决定仓库被导入项目之后在项目中的目录名，这个是不允许重复的，通常情况下建议仓库名保持与仓库路径中的名称一致。为了避免出错，注意文件换行符使用unix风格，编码为UTF-8。如果是在windows下操作，请使用notepad++之类的程序员用的文本编辑器去编辑配置文件，不要使用Windows自带的记事本。  
然后，再次运行脚本就能查看新的数据了。
# 模块编写
