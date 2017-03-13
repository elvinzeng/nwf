local demoController = commonlib.gettable("nwf.controllers.DemoController");


-- http://localhost:8099/demo/sayHello
function demoController.sayHello(ctx)
	return "test", {message = "Hello, Elvin!"};
end


--  return json string
function demoController.testJson(ctx)
	return {content = "hello, elvin!", title = "test json"};
end


-- access session
function demoController.testSession(ctx)
	local session = ctx.session;
	local count = session.count;
	if (not count) then count = 0; end
	count = count + 1;
	session.count = count;
	return {content = "request count:" .. tostring(count), title = "test session"};
end


-- send recirect
function demoController.testRedirect(ctx)
        return "redirect:/demo/sayHello";
end


-- home page
function demoController.index(ctx)
        return "test", {message = "demo module, index page!", title = "index - demo"};
end

