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


//let create_collection (owner: address) (name: string) (store: Storage.t): Storage.t =
//    let collection_contract = FA2.storage in
//
//    let (contract_address: (operation * address)) = create_contract(FA2, collection_contract) in
//    let updated_collection = Map.add (Tezos.get_sender ()) contract_address store.collections in
//    {store with collections = updated_collections}




[@view] let check_collections (creator: address option) (store: Storage.t): (address, address) map =
  if (Option.is_none creator)
    then
        store.collections
    else
        let user_collections = Map.find_opt creator store.collections in
        user_collections

let main(action: Parameter.t)(store: Storage.t): operation list * Storage.t =
    match action with
    | Add_operator (p) -> add_operator p store
    | Remove_operator (p) -> remove_operator p store
    | Accept_operator_role -> accept_operator_role store
    | Ban_creator (p) -> ban_creator p store
    | Add_whitelist -> add_whitelist store
    | Create_collection (p) -> create_collection p store
