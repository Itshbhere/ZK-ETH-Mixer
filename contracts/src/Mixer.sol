// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Mixer {
    // Iverifier public immutable verifier;
    mapping(bytes32 => bool) public Commitments;
    uint256 public constant DENOMINATION = 1 ether;

    error CommitmentAlreadyUsed(bytes32 commitment);
    error InvalidDenomination(uint256 sent, uint256 expected);

    constructor( /*Iverifier _verifier*/ ) {
        // verifier = _verifier;
    }

    /// @notice Deposit funds into the mixer.
    /// @param _commitment the poseidon commitment of the nulifier and secret(Off Chain Generation)
    function deposit(bytes32 _commitment) external payable {
        // Check wether the commitment has already been used so we can prevent double spending
        if (Commitments[_commitment]) {
            revert CommitmentAlreadyUsed(_commitment);
        }

        // Check that the user has sent the correct denomination of ETH
        if (msg.value != DENOMINATION) {
            revert InvalidDenomination(msg.value, DENOMINATION);
        }
        // Allow the user to send ETH of Fixed Denomination
        // Push the commitment to the data structure containing all of the commitments
        // insert(_commitment);
        Commitments[_commitment] = true;
    }

    /// @notice Withdraw funds from the mixer privately.
    /// @param _proof the zk proof that the user has the right to withdraw
    function withdraw(bytes memory _proof) external {
        // check that the proof is valid by calling the verifier contract
        // check that the nulifier has not been used to prevent double spending
        // transfer the funds to the user
    }
}
