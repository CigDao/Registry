import Constants "../Constants";

module {

    public func getCanistersByPK(pk:Text) : async [Text] {
        let canister = actor(Constants.exploreCanister) : actor { 
            getCanistersByPK: (Text)  -> async [Text];
        };

        await canister.getCanistersByPK(pk);
    };

    public func createCollectionServiceCanisterByGroup(pk:Text) : async ?Text {
        let canister = actor(Constants.exploreCanister) : actor { 
            createCollectionServiceCanisterByGroup: (Text)  -> async ?Text;
        };
        await canister.createCollectionServiceCanisterByGroup(pk);
    };

}