#import "ligo-extendable-fa2/lib/multi_asset/fa2.mligo" "FA2"
#import "./errors.mligo" "Errors"

type extension = {
    admin : address;
    operators : map(address, bool);
    whitelist : map(address, bool);
    blacklist : map(address, bool);
}

type storage = FA2.Storage
type extended_storage = extension storage

type return = operation list * storage

type parameter = FA2.parameter

let add_operator (new_operator: address) (store: extended_storage): extended_storage =
  let () = if (store.admin <> Tezos.get_sender()) then (failwith Errors.only_admin) in
  match Map.find_opt new_operator store.operators with
    Some (x) -> failwith Errors.already_operator
    | None ->
        let updated_operators = store.operators |> Map.add new_operator false in
        ([], { store with operators = updated_operators })


let remove_operator (operator: address) (store: extended_storage): extended_storage =
  let () = if (store.admin <> Tezos.get_sender()) then (failwith Errors.only_admin) in
    match Map.find_opt operator store.operators with
      None -> failwith Errors.not_operator
      | Some (x) ->
          let updated_operators = store.operators |> Map.remove noperator in
          ([], { store with operators = updated_operators })

let accept_operator_role (store: extended_storage): extended_storage =
    match Map.find_opt (Tezos.get_sender ()) store.operators with
        None -> failwith Errors.only_pending
        | True -> failwith Errors.already_operator
        | False ->
            let updated_operators = Map.update (Tezos.get_sender ()) true store.operators in
            ([], {store with operators = updated_operators})

let ban_creator (creator: address) (store: extended_storage): extended_storage =
  let () = if (store.admin <> Tezos.get_sender()) then (failwith Errors.only_admin) in
  match Map.find_opt creator store.blacklist with
    Some (x) -> failwith Errors.already_banned
    | None ->
        let updated_blacklist = store.blacklist |> Map.add creator true in
        ([], { store with blacklist = updated_blacklist })

let add_whitelist (store: extended_storage): extended_storage =
    let current_whitelist_price: tez = 10
    let () = if (Tezos.get_amount ()) <> current_purchase_price then failwith Errors.not_enough_tez in
    match Map.find_opt (Tezos.get_sender ()) store.whitelist with
            Some (x) -> failwith Errors.already_whitelisted
            | None ->
                let updated_whitelist = Map.update (Tezos.get_sender ()) true store.whitelist in
                ([], {store with whitelist = updated_whitelist})

let main(action: parameter)(store: extended_storage): operation list * storage =
    match action with
    | Transfer (p) -> FA2.transfer p store
    | Balance_of (p) -> FA2.balance_of p store
    | Update_operators (p) -> FA2.update_ops p store
