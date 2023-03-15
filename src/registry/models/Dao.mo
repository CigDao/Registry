import Principal "mo:base/Principal";
module {
    public type Dao = {
        owner:Principal;
        name:Text;
        governace:Text;
        database:Text;
        token:Text;
        treasury:Text;
    };
}