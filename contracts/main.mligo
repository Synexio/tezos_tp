#import "ligo-extendable-fa2/lib/multi_asset/fa2.mligo" "FA2"

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

let add_operator (new_operator: address) (store: extended_storage) : extended_storage =
  let () = if (store.admin <> Tezos.get_sender ()) then (failwith Errors.only_admin) in
  let updated_operators = store.operators |> Map.add new_operator false in
  ([], { store with operators = updated_operators })

let main(action: parameter)(store: extended_storage): operation list * storage =
    match action with
    | Transfer (p) -> FA2.transfer p store
    | Balance_of (p) -> FA2.balance_of p store
    | Update_operators (p) -> FA2.update_ops p store
