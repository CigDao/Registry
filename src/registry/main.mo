import Prim "mo:prim";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Float "mo:base/Float";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Nat32 "mo:base/Nat32";
import Nat64 "mo:base/Nat64";
import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import TrieMap "mo:base/TrieMap";
import List "mo:base/List";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Http "./helpers/http";
import Utils "./helpers/Utils";
import JSON "./helpers/JSON";
import Response "./models/Response";
import Dao "./models/Dao";
import Result "./models/Result";
import Cycles "mo:base/ExperimentalCycles";
import Error "mo:base/Error";
import Constants "./Constants";
import DatabaseService "services/DatabaseService";

actor {

  private type Dao = Dao.Dao;
  private type JSON = JSON.JSON;
  private type Result = Result.Result;

  private stable var daoEntries : [(Text, Dao)] = [];
  private var daos = HashMap.fromIter<Text, Dao>(daoEntries.vals(), 0, Text.equal, Text.hash);

  system func preupgrade() {
    daoEntries := Iter.toArray(daos.entries());
  };

  system func postupgrade() {
    daoEntries := [];
  };

  public query func exist(value : Text) : async Bool {
    let exist = daos.get(value);
    switch (exist) {
      case (?exist) {
        true;
      };
      case (null) {
        false;
      };
    };
  };

  public query func fetchDaos() : async [Dao] {
    _fetchDaos();
  };

  public shared ({ caller }) func setName(value : Text) : async Result {
    let exist = daos.get(value);
    switch (exist) {
      case (?exist) {
        #Err(#Unauthorized);
      };
      case (null) {
        let dao = {
          owner = caller;
          name = value;
          governace = "";
          database = "";
          token = "";
          treasury = "";
        };
        daos.put(value, dao);
        #Ok("Success");
      };
    };
  };

  public shared ({ caller }) func addDao(value : Dao) : async Result {
    let composerCanister = Principal.fromText(Constants.composerCanister);
    assert (caller == composerCanister);
    let exist = daos.get(value.name);
    switch (exist) {
      case (?exist) {
        let dao = {
          owner = exist.owner;
          name = exist.name;
          governace = value.governace;
          database = value.database;
          token = value.token;
          treasury = value.treasury;
        };
        try {
          let _ = await DatabaseService.createCollectionServiceCanisterByGroup(value.token);
          daos.put(exist.name, dao);
          #Ok("Success");
        } catch (e) {
          throw (e);
        };

      };
      case (null) {
        #Err(#NotFound);
      };
    };
  };

  private func _fetchDaos() : [Dao] {
    var _daos : [Dao] = [];
    for ((key, value) in daos.entries()) {
      _daos := Array.append(_daos, [value]);
    };
    _daos;
  };

  public query func http_request(request : Http.Request) : async Http.Response {
    let path = Iter.toArray(Text.tokens(request.url, #text("/")));

    if (path.size() == 1) {
      switch (path[0]) {
        case ("fetchDaos") return _fetchDaoResponse();
        case (_) return Http.BAD_REQUEST();
      };
    } else if (path.size() == 2) {
      switch (path[0]) {
        case ("dao") return _daoResponse(path[1]);
        case (_) return Http.BAD_REQUEST();
      };
    } else {
      return Http.BAD_REQUEST();
    };
  };

  private func _natResponse(value : Nat) : Http.Response {
    let json = #Number(value);
    let blob = Text.encodeUtf8(JSON.show(json));
    let response : Http.Response = {
      status_code = 200;
      headers = [("Content-Type", "application/json")];
      body = blob;
      streaming_strategy = null;
    };
  };

  private func _textResponse(value : Text) : Http.Response {
    let json = #String(value);
    let blob = Text.encodeUtf8(JSON.show(json));
    let response : Http.Response = {
      status_code = 200;
      headers = [("Content-Type", "application/json")];
      body = blob;
      streaming_strategy = null;
    };
  };

  private func _fetchDaoResponse() : Http.Response {
    let _does = _fetchDaos();
    var result : [JSON] = [];

    for (obj in _does.vals()) {
      let json = Utils._daoToJson(obj);
      result := Array.append(result, [json]);
    };

    let json = #Array(result);
    let blob = Text.encodeUtf8(JSON.show(json));
    let response : Http.Response = {
      status_code = 200;
      headers = [("Content-Type", "application/json")];
      body = blob;
      streaming_strategy = null;
    };
  };

  private func _daoResponse(value : Text) : Http.Response {
    let exist = daos.get(value);
    switch (exist) {
      case (?exist) {
        let json = Utils._daoToJson(exist);
        let blob = Text.encodeUtf8(JSON.show(json));
        let response : Http.Response = {
          status_code = 200;
          headers = [("Content-Type", "application/json")];
          body = blob;
          streaming_strategy = null;
        };
      };
      case (null) {
        return Http.NOT_FOUND();
      };
    };
  };
};
