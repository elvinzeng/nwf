# Introduction
A simple and easy-to-use MVC framework for NPL Web application. If you are familiar with the jsp/servlet or asp.net mvc, you'll like this.  
## return a view
www/controller/DemoController.lua
```lua
local demoController = commonlib.gettable("nwf.controllers.DemoController");

-- http://localhost:8099/demo/sayHello
function demoController.sayHello(ctx)
	return "test", {message = "Hello, Elvin!"}; -- return www/view/test.html
end
```
www/view/test.html
```html
<!DOCTYPE html>
<html>
<head>
<title>{{title}}</title>
</head>
<body>
  <h1>{{message}}</h1>
</body>
</html>

```
## return json result
www/controller/DemoController.lua
```lua
local demoController = commonlib.gettable("nwf.controllers.DemoController");

--  return json string
function demoController.testJson(ctx)
	return {message = "hello, elvin!", remark = "test json result"};
end
```
Json Result
```json
{"remark":"test json result","message":"hello, elvin!"}
```

# How to use
## Create Project
You only need to run the following command:  
* ~ $ cd ~/workspace
* ~/workspace $ curl -O https://raw.githubusercontent.com/elvinzeng/nwf/master/nwf_init.sh
* ~/workspace $ sh ./nwf_init.sh "project-name"  

Then, this script will use parameter "project-name" to create a directoty as project root directory, it will generate the necessary directory structure and the basic file automatically.  
tips: you can use git-bash to run script if you are Windows user.  
## Run Web Server
* Linux: sh start.sh
* Windows: run update_packages.sh and then run start_win.bat
* Access "http://localhost:8099/ ". "it works!" means web application is start success.

# See Also
* [NPL](https://github.com/LiXizhi/NPLRuntime) - Neural Parallel Language
* [NPLPackages main](https://github.com/NPLPackages/main) - NPL Common Lua library
* [lua-resty-template](https://github.com/bungle/lua-resty-template) — Templating Engine
* [lua-resty-validation](https://github.com/bungle/lua-resty-validation) — Validation and filtering library
