# 基本规则
nwf的请求映射规则遵守约定优于配置的规则，主要的映射规则模仿了.NET。
# 具体规则
| 请求路径           | 处理函数          | 示例请求路径 |  示例处理函数  |
| ------------------- | ------------------ | ------------ | ------------ |
| /     | www/controller/RootController.index(ctx); | - |       -     |
| /xxx    | www/controller/RootController.xxx(ctx); | /about | www/controller/RootController.about(ctx); |
| /xxx/    | www/controller/XxxController.index(ctx); | /demo/ | www/controller/DemoController.index(ctx); |
| /xxx/aaa    | www/controller/XxxController.aaa(ctx); | /demo/sayHello | www/controller/DemoController.sayHello(ctx); |
| /aaa/bbb/ccc    | www/controller/aaa/BbbController.ccc(ctx); | /sys/config/update | www/controller/sys/ConfigController.update(ctx); |

你可以嵌套任意层目录，框架会根据请求路径的最后两个部分来搜索controller。
