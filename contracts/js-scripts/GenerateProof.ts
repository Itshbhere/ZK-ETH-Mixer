import { Barretenberg, Fr, UltraHonkBackend } from "@aztec/bb.js";
import { ethers } from "ethers";
import { Noir } from "@noir-lang/noir_js";
import fs from "fs";
import path from "path";

const circuit = JSON.parse(
  fs.readFileSync(
    path.resolve(__dirname, "../../circuits/target/circuits.json"),
    "utf8"
  )
);

export default async function GenerateProof() {
  const inputs = process.argv.slice(2);
  const bb = await Barretenberg.new();
  const Nulifier = Fr.fromString(inputs[0]);
  const NulifierHash = bb.poseidon2Hash([Nulifier]);
  const Secret = inputs[1];
  const recipient = inputs[2];
  const leaves = inputs.slice(3);
  const tree = await merkleTree(leaves);

  try {
    const noir = new Noir(circuit);
    const honk = new UltraHonkBackend(circuit.bytecode, { threads: 1 });

    // Public
    // root: pub Field,
    // NulifierHash: pub Field,
    // recipient: pub Field,

    // Private
    // Nulifier: Field,
    // Secret: Field,
    // merkle_proof: [Field; 20],
    // is_even: [bool; 20],

    const input = {
      root: Fr.random(),
      NulifierHash: NulifierHash.toString(),
      recipient: recipient,
      Nulifier: Nulifier.toString(),
      Secret: Secret,
      merkle_proof: Array.from({ length: 20 }, () => Fr.random()),
      is_even: Array.from({ length: 20 }, () => Math.random() < 0.5),
    };
    const { witness } = await noir.execute(input);

    const { proof } = await honk.generateProof(witness, { keccak: true });
    const result = ethers.AbiCoder.defaultAbiCoder().encode(["bytes"], [proof]);
    return result;
  } catch (error) {
    console.error("Error in proof generation:", error);
    throw error;
  }
}

(async () => {
  GenerateProof()
    .then((result) => {
      process.stdout.write(result);
    })
    .catch((error) => {
      console.error("Error in Commitment generation:", error);
    });
})();
