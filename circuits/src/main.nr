use poseidon::poseidon2::{self, Poseidon2};
mod merkle_tree;
fn main(
    root: pub Field,
    NulifierHash: pub Field,
    recipient: pub Field,
    Nulifier: Field,
    Secret: Field,
    merkle_proof: [Field; 20],
    is_even: [bool; 20],
) {
    //Calculate Comitment
    let Commitment: Field = Poseidon2::hash([Nulifier, Secret], 2);
    //Calculate NulifierHash
    let NulifierHashCalculated: Field = Poseidon2::hash([Nulifier], 1);

    assert(NulifierHashCalculated == NulifierHash, "NulifierHash does not match");

    let Computed_root: Field = merkle_tree::compute_merkle_root(Commitment, merkle_proof, is_even);
    assert(Computed_root == root, "Computed Merkle root does not match the expected root");

    assert(recipient != 0); // dummy usage to silence warning

}
