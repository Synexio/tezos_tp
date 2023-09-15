# Project : NFT Factory

![Logo](https://bakingtacos.com/img/profile.png)
NFT Factory

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
- [Usage](#usage)
- [Smart Contract Details](#smart-contract-details)
    - [Storage Structure](#storage-structure)
    - [Entry Points](#entry-points)
- [License](#license)

## Overview

The purpose of this project is to create a complete Tezos dApp acting as an FA2 NFT factory.

## Features

The project should allow:

* Interacting with contracts through a Makefile at the root (compile, test, deploy).
* Start/stop a Tezos node on Flextesa locally.
* Deploy smart contracts on Flextesa.

## Getting Started

### Prerequisites

* Docker
* Make
* Node

### Installation

Install Ligo libraries
```make install```

## Usage

Compile LIGO Smart Contract
```make compile```

Run LIGO tests
```make test```

Deploy
```make run-deploy```

Start Flextesa sandbox
```make sandbox-start```

Stop Flextesa sandbox
```make sandbox-stop```

## Smart Contract Details

### Storage Structure

Storage is of type :
```ocaml
type t = {
    admin: address;
    operators: (address, bool) map;
    whitelist: (address, bool) map;
    blacklist: (address, bool) map;
    collections: (address, address) map;
}
```

### Entry Points

List of the entrypoints 
```ocaml
      Add_operator of address
    | Remove_operator of address
    | Accept_operator_role of unit
    | Ban_creator of address
    | Add_whitelist of unit
    | Create_collection of (address * string) // WORK IN PROGRESS
```

## License

GNU Affero General Public License v3.0