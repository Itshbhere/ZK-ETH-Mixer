// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IncrementalMerkleTree, Poseidon2} from "./IncrementalMerkleTree.sol";
import {IVerifier} from "./Verifier.sol";

contract Mixer is IncrementalMerkleTree {
    IVerifier public immutable verifier;
    uint256 public constant DENOMINATION = 1 ether;

    mapping(bytes32 => bool) public Commitments;
    mapping(bytes32 => bool) public NulifierHash;

    error CommitmentAlreadyUsed(bytes32 commitment);
    error InvalidDenomination(uint256 sent, uint256 expected);
    error UnknownMerkleRoot(bytes32 root);
    error NulifierHashAlreadyUsed(bytes32 nulifierHash);
    error TransferFailed();
    error InvalidProof();

    event Deposit(bytes32 indexed commitment, uint32 LeafIndex, uint256 timestamp);
    event Withdrawal(bytes32 NulifierHash, address indexed recipient, uint256 timestamp);

    constructor(IVerifier _verifier, uint32 MerkleTreeDepth, Poseidon2 Hasher)
        IncrementalMerkleTree(MerkleTreeDepth, Hasher)
    {
        verifier = _verifier;
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
        uint32 StoredLeafIndex = insert(_commitment);
        Commitments[_commitment] = true;
        emit Deposit(_commitment, StoredLeafIndex, block.timestamp);
    }

    function isknownRoot(bytes32 _root) public returns (bool) {
        // Check if the root is 0
        if (_root == bytes32(0)) {
            return false; // The zero root is not a valid Merkle root
        }
        // Check if the root is known
        uint32 StartingRootIndex = CurrentRootIndex;
        do {
            if (MerkleRoots[CurrentRootIndex] == _root) {
                return true;
            }
            if (CurrentRootIndex == 0) {
                CurrentRootIndex = MAX_STORED_ROOTS; // Wrap around to the last root
            }
            CurrentRootIndex--;
        } while (CurrentRootIndex != StartingRootIndex);
        return false;
    }

    /// @notice Withdraw funds from the mixer privately.
    /// @param _proof the zk proof that the user has the right to withdraw
    function withdraw(bytes memory _proof, bytes32 _root, bytes32 nulifierHash, address payable _recipient) external {
        // Check the root used to create the prrof is the root on chain
        if (!isknownRoot(_root)) {
            revert UnknownMerkleRoot(_root);
        }
        bytes32[] memory inputs = new bytes32[](3);
        inputs[0] = (_root);
        inputs[1] = (nulifierHash);
        inputs[2] = bytes32(uint256(uint160(address(_recipient))));

        // check that the proof is valid by calling the verifier contract
        if (!verifier.verify(_proof, inputs)) {
            revert InvalidProof();
        }

        // check that the nulifier has not been used to prevent double spending
        if (NulifierHash[nulifierHash]) {
            revert NulifierHashAlreadyUsed(nulifierHash);
        }
        // transfer the funds to the user
        NulifierHash[nulifierHash] = true;

        // Transfer the funds to the recipient
        (bool success,) = _recipient.call{value: DENOMINATION}("");
        if (!success) {
            revert TransferFailed();
        }

        emit Withdrawal(nulifierHash, _recipient, block.timestamp);
    }
}
