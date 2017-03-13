local demoValidator = commonlib.gettable("nwf.validators.DemoValidator");

function demoValidator.testLogin(params)
	print("~~~~~~~~~~~~~~~~~~~~~~ 1");
    log(params);
	print("~~~~~~~~~~~~~~~~~~~~~~ 2");
	return false, {
	                username = "field username could not be nil",
	                password = "field password could not be nil"
	              }
end



