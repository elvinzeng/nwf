local helloModValidator = commonlib.gettable("nwf.validators.HelloModValidator");

function helloModValidator.test1(params, req)
    print("~~~~~~~~~~~~~~~~~~~~~~ 1");
    log(params);
    print("~~~~~~~~~~~~~~~~~~~~~~ 2");
    log(req);
    print("~~~~~~~~~~~~~~~~~~~~~~ 3");
    return false, {
        aaa = "field aaa could not be nil",
        bbb = "field bbb could not be nil"
    }
end
