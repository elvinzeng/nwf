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
