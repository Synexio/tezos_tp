#import "ligo-extendable-fa2/lib/multi_asset/fa2.mligo" "FA2"
#import "./errors.mligo" "Errors"
#import "./parameter.mligo" "Parameter"
#import "./storage.mligo" "Storage"


//type storage = FA2.storage
//type storage = extension storage

type return = operation list * Storage.t


let add_operator (new_operator: address) (store: Storage.t): Storage.t =
  let () = if (store.admin <> Tezos.get_sender()) then (failwith Errors.only_admin) in
  match Map.find_opt new_operator store.operators with
    Some (_) -> failwith Errors.already_operator
    | None ->
        let updated_operators = store.operators |> Map.add new_operator false in
        { store with operators = updated_operators }


let remove_operator (operator: address) (store: Storage.t): Storage.t =
  let () = if (store.admin <> Tezos.get_sender()) then (failwith Errors.only_admin) in
    match Map.find_opt operator store.operators with
      None -> failwith Errors.not_operator
      | Some (_) ->
          let updated_operators = store.operators |> Map.remove operator in
          { store with operators = updated_operators }

let accept_operator_role (store: Storage.t): Storage.t =
    match Map.find_opt (Tezos.get_sender ()) store.operators with
        None -> failwith Errors.only_pending
        | Some (x) -> if x then failwith Errors.already_operator else
                let updated_operators = Map.update (Tezos.get_sender ()) (Some(true)) store.operators in
                {store with operators = updated_operators}

let ban_creator (creator: address) (store: Storage.t): Storage.t =
  let () = if (store.admin <> Tezos.get_sender()) then (failwith Errors.only_admin) in
  match Map.find_opt creator store.blacklist with
    Some (_) -> failwith Errors.already_banned
    | None ->
        let updated_blacklist = store.blacklist |> Map.add creator true in
        { store with blacklist = updated_blacklist }

let add_whitelist (store: Storage.t): Storage.t =
    let current_whitelist_price: tez = 10tez in
    let () = if (Tezos.get_amount ()) <> current_whitelist_price then failwith Errors.not_enough_tez in
    match Map.find_opt (Tezos.get_sender ()) store.whitelist with
            Some (_) -> failwith Errors.already_whitelisted
            | None ->
                let updated_whitelist = Map.update (Tezos.get_sender ()) (Some(true)) store.whitelist in
                {store with whitelist = updated_whitelist}


/////////////////////////////

(* 1er essai CREATE_CONTRACT
let create_collection (owner: address) (name: string) (store: Storage.t): Storage.t =
    let collection_contract = FA2.storage in

    let (contract_address: (operation * address)) = create_contract(FA2, collection_contract) in
    let updated_collection = Map.add (Tezos.get_sender ()) contract_address store.collections in
    {store with collections = updated_collections}
*)

/////////////////////////////

(* Test NFT-factory-cameligo mais ça fait pas 2 lignes
let generateCollection(param, store : Parameter.generate_collection_param * Storage.t) : return =
    // create new collection
    let token_ids = param.token_ids in
    let sender = Tezos.get_sender () in
    let ledger = (Big_map.empty : NFT_FA2.Storage.Ledger.t) in
    let myfunc(acc, elt : NFT_FA2.Storage.Ledger.t * nat) : NFT_FA2.Storage.Ledger.t = Big_map.add elt sender acc in
    let new_ledger : NFT_FA2.Storage.Ledger.t = List.fold myfunc token_ids ledger in

    let token_usage = (Big_map.empty : NFT_FA2.TokenUsage.t) in
    let initial_usage(acc, elt : NFT_FA2.TokenUsage.t * nat) : NFT_FA2.TokenUsage.t = Big_map.add elt 0n acc in
    let new_token_usage = List.fold initial_usage token_ids token_usage in

    let token_metadata = param.token_metas in
    let operators = (Big_map.empty : NFT_FA2.Storage.Operators.t) in


    let initial_storage : ext_storage = {
        ledger=new_ledger;
        operators=operators;
        token_ids=token_ids;
        token_metadata=token_metadata;
        extension = {
          admin=sender;
          token_usage=new_token_usage;
        }
    }  in

    let initial_delegate : key_hash option = (None: key_hash option) in
    let initial_amount : tez = 1tez in
    let create_my_contract : lambda_create_contract =
      [%Michelson ( {| {
            UNPAIR ;
            UNPAIR ;
            CREATE_CONTRACT
#include "generic_fa2/compiled/fa2_nft.tz"
               ;
            PAIR } |}
              : lambda_create_contract)]
    in
    let originate : operation * address = create_my_contract(initial_delegate, initial_amount, initial_storage) in
    // insert into collections
    let new_all_collections = Big_map.add originate.1 sender store.all_collections in
    // insert into owned_collections
    let new_owned_collections = match Big_map.find_opt sender store.owned_collections with
    | None -> Big_map.add sender ([originate.1]: address list) store.owned_collections
    | Some addr_lst -> Big_map.update sender (Some(originate.1 :: addr_lst)) store.owned_collections
    in
    ([originate.0], { store with all_collections=new_all_collections; owned_collections=new_owned_collections})
*)

/////////////////////////////

(* View bug en rapport avec l'option
[@view] let check_collections (creator: address option) (store: Storage.t): (address, address) map =
  if (Option.is_none creator)
    then
        store.collections
    else
        let user_collections = Map.find_opt creator store.collections in
        user_collections
*)

let main(action: Parameter.t) (store: Storage.t): return =
  match action with
  | Add_operator (p) -> ([], add_operator p store)
  | Remove_operator (p) -> ([], remove_operator p store)
  | Accept_operator_role -> ([], accept_operator_role store)
  | Ban_creator (p) -> ([], ban_creator p store)
  | Add_whitelist -> ([], add_whitelist store)
//  | Create_collection (p) -> (create_collection p store, store)
