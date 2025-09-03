import { Noir } from "@noir-lang/noir_js";
import { ethers } from "ethers";
import { UltraHonkBackend } from "@aztec/bb.js";
import { fileURLToPath } from "url";
import path from "path";
import fs from "fs";

//etting the circuit file with the bytecode

const circuitPath = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "../../circuits/target/circuits.json")

const circuit =  JSON.parse(fs.readFileSync(circuitPath, "utf8"));

export default async function generateProof(){
    const inputsArray = process.argv.slice(2);

    try{
        //initialize noir with the corcuit
        const noir = new Noir(circuit);
        //initialize the backend using the compiled bytecode
        const bb = new UltraHonkBackend(circuit.bytecode, {threads: 1});

        //create the inputs
        const inputs = {
            //private inputs
            guess_hash: inputsArray[0],
            //public inputs
            answer_hash: inputsArray[1],
            _address: inputsArray[2]
        };

        //execute the circuit to get the witness
        const {witness} = await noir.execute(inputs);
        //generate proof using the backend and the witness
        const originalLog = console.log;
        console.log = ()=>{};       //suppress console.log in the backgroung
        const {proof} = await bb.generateProof(witness, {keccak: true});
        console.log = originalLog;

        //ABI encode the proof in a format that can be used in a test
        const proofEncoded = ethers.AbiCoder.defaultAbiCoder().encode(
            ["bytes"],
            [proof]
        );

        return proofEncoded;

    } catch(error){
        console.log(error);
        throw error;
    }

}

(async () => {
    generateProof()
        .then((proof)=>{
            process.stdout.write(proof);
            process.exit(0);
        })
        .catch((error)=>{
            console.log(error);
            process.exit(1);
        })

})();