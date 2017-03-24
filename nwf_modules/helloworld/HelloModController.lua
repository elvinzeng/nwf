local helloModController = commonlib.gettable("nwf.controllers.HelloModController");


-- http://localhost:8099/helloMod/test1
function helloModController.test1(ctx)
    return "helloworld/hello", {message = "Hello, Elvin!"};
end
