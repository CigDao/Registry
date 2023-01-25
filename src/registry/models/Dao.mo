import Principal "mo:base/Principal";
module {
    public type Dao = {
        owner:Principal;
        name:Text;
        dao:Text;
        database:Text;
        multisig:Text;
        swap:Text;
        token:Text;
        topup:Text;
        treasury:Text;
        vesting:Text;
    };
}