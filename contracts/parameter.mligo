type t =
      Add_operator of address
    | Remove_operator of address
    | Accept_operator_role of unit
    | Ban_creator of address
    | Add_whitelist of unit
    | Create_collection of (address * string)