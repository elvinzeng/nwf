local rootController = commonlib.gettable("nwf.controllers.RootController");

function rootController.index(ctx)
        return "test", {message = "it works!", title = "home - nwf"};
end
