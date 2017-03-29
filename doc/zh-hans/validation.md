服务端校验是每个网站都需要做的事情，并且工作量还比较大。为了不让控制器中的逻辑过多，我们提出了校验器的概念。校验器，作为一个组建，专门负责对客户端传给服务端的参数进行校验。
# 文件和处理函数
校验器的url映射规则与控制器的[请求映射规则](https://github.com/elvinzeng/nwf/blob/master/doc/zh-hans/request-mappings.md)完全一致，不同的是文件名与查找根路径。校验器文件名总是与Validator后缀结尾，查找根路径为“www/validator”，类似于[控制器](https://github.com/elvinzeng/nwf/blob/master/doc/zh-hans/controller.md)的“www/controller”目录。
# 处理函数与参数
每一个控制器中用于处理客户端有数据提交的且有过滤需求的请求处理函数在控制器中都可以添加一个对应的函数，用于进行参数校验。如下：
www/validator/UserValidator.lua
```lua
local userValidator = commonlib.gettable("nwf.validators.UserValidator");
local validation = nwf.validation;

local function isNull(model, fieldName)
	if (model[fieldName]) then
		return false;
	else
		return true, string.format("field %s can not be nil", fieldName);
	end
end

function userValidator.checkPassword(params)
	local isNilValue, msg = isNull(params, "username");
	if (isNilValue) then return false, msg; end;
	isNilValue, msg = isNull(params, "password");
	if (isNilValue) then return false, msg; end;
end

function userValidator.register(params)
	local isNilValue, msg = isNull(params, "username");
	if (isNilValue) then return false, msg; end;
	isNilValue, msg = isNull(params, "password");
	if (isNilValue) then return false, msg; end;

	local valid, fields, errors = validation.new{
		username = validation.string:len(5, 10),
		password = validation.string:len(8, 16)
	}(params);

	return valid, fields;
end
```
该校验器对应的控制器为"www/controller/UserController.lua"  
在校验器中进行参数校验你可以自己进行校验，也可以借助 [resty-validation](https://github.com/bungle/lua-resty-validation), 我们已经将 [resty-validation](https://github.com/bungle/lua-resty-validation)预先加载到应用中了，你只需要像下面这样做去使用[resty-validation](https://github.com/bungle/lua-resty-validation):
```lua
local validation = nwf.validation;
```  
校验器除了params参数之外，还有第二个参数，request对象。如下：
```lua
-- @param params: request parameters
-- @param req: http request object
function userValidator.login(params, req)
	return true;
end
```
或者，你也可以直接在校验器中访问特殊变量 [special variables](https://github.com/elvinzeng/nwf/wiki/special-variables).
# 校验器的返回值
校验器的第一个返回值是isValid，布尔型，用于表示校验是否成功。第二个返回值是fields，是一个table，用于携带错误信息。在对应的控制器中，你可以通过ctx.validation访问到校验结果相关的数据。如果不知道具体是什么样子的对象，建议在控制器中像下面这样试探一下：
```lua
function userController.register(ctx)
	return ctx;
end
```
