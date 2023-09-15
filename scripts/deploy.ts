import { outputFile } from 'fs-extra';
import { char2Bytes } from "@taquito/utils";
import { InMemorySigner } from "@taquito/signer";
import { TezosToolkit, MichelsonMap } from "@taquito/taquito";

import * as dotenv from 'dotenv';
import code from "../compiled/main.json";
import accounts from './accounts';
import networks from './config';

dotenv.config(( { path: '.env' } ));

const TezosNodeRPC : string = networks.ghostnet.node_url;
const publicKey : string = accounts.ghostnet.alice.publickey;
const privateKey : string = accounts.ghostnet.alice.privatekey;

const signature = new InMemorySigner(privateKey);
const Tezos = new TezosToolkit(TezosNodeRPC);
Tezos.setProvider({ signer: signature });

Tezos.tz.getBalance(publicKey)
    .then((balance) => console.log(`Address Balance : ${balance.toNumber() / 1000000} ꜩ`))
    .catch((error) => console.log(JSON.stringify(error)));

const saveContractAddress = (name: string, address: string) => {
    outputFile(`./scripts/deployments/${name}.ts`,
        `export default "${address}" `)
}

const deploy = async () => {
    try {
        const storage = {
            admin: publicKey,
            operators: new MichelsonMap(),
            whitelist: new MichelsonMap(),
            blacklist: new MichelsonMap(),
            collections: new MichelsonMap(),
        }
        const origination = await Tezos.contract.originate({
            code : code,
            storage: storage
        });
        console.log(`Contract originated at ${origination.contractAddress}`);
        saveContractAddress("deployed_contract", origination.contractAddress)
    }
    catch (error) {
        console.log(error)
    }


}

deploy()