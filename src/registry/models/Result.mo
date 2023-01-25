module {
    public type Result = {
        #Ok: Text;
        #Err: {
            #Unauthorized;
            #NotFound;
            #Other: Text;
        };
    };
}