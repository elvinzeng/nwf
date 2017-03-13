local rootController = commonlib.gettable("WebServer.nwf.controllers.RootController");

function rootController.index(ctx)
        return "test", {message = "it works!", title = "home - nwf"};
end
