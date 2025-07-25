import { Barretenberg, Fr } from "@aztec/bb.js";
import { ethers } from "ethers";

export default async function generateCommitment(): Promise<string> {
    const bb = await Barretenberg.new();

    const nulifier = Fr.random()
    const secret = Fr.random()

    const commitment: Fr = await bb.poseidon2Hash([nulifier, secret])

    const result = ethers.AbiCoder.defaultAbiCoder().encode(["bytes32" , "bytes32" , "bytes32"], [commitment.toBuffer() , nulifier.toBuffer(), secret.toBuffer()])
    
    return result  ;
}

(async () => {
    generateCommitment()
    .then((result) => {
        process.stdout.write(result);
      })
      .catch((error) => {
        console.error("Error in Commitment generation:", error);
      });
})();