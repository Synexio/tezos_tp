type t = {
    admin: address;
    operators: (address, bool) map;
    whitelist: (address, bool) map;
    blacklist: (address, bool) map;
    collections: (address, address) map;
}