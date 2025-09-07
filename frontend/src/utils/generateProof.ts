import { Noir } from "@noir-lang/noir_js";
import { UltraHonkBackend } from "@aztec/bb.js";
import circuit from "./../../../circuits/target/circuits.json";
import type {CompiledCircuit} from "@noir-lang/types";

export async function generateProof(guess: string, _address: string, showLog:(content: string) => void): Promise<{ proof: Uint8Array, publicInputs: string[] }>{
    try{
        const noir = new Noir(circuit as CompiledCircuit);
        const honk = new UltraHonkBackend(circuit.bytecode, {threads: 1});
        const inputs ={
            guess: guess,
            _address: _address
        }

        showLog("generating witness");
        const {witness} =await noir.execute(inputs);

        const {proof, publicInputs } = await honk.generateProof(witness, {keccak: true});
        const offChainProof = await honk.generateProof(witness);
        const isValid = honk.verifyProof(offChainProof);
        return {proof, publicInputs};
    } catch(error) {
        console.log(error);
        throw error;
    }
}