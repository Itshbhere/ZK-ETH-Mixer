// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Mixer} from "../src/Mixer.sol";
import {HonkVerifier} from "../src/Verifier.sol";
import {IncrementalMerkleTree, Poseidon2} from "../src/IncrementalMerkleTree.sol";
import {Test, console} from "forge-std/Test.sol";

contract MixerTest is Test {

    HonkVerifier public verifier;
    Poseidon2 public hasher;
    Mixer public mixer;
    address public Recipient = makeAddr("Recipient");

    function setUp() public {
        // deploy the Verifier
        verifier = new HonkVerifier();
        // deploy the hasher contracts
        hasher = new Poseidon2();
        // deploy the mixer contract
        mixer = new Mixer(verifier, 20 ,hasher);
        }

    function generateCommitment() public returns (bytes32 commitment , bytes32 nullifier , bytes32 secret) {
        // generate a commitment from Script via ffi
        string[] memory inputs = new string[](3);
        inputs[0] = "npx";
        inputs[1] = "tsx";
        inputs[2] = "js-scripts/GenerateCommitment.ts";
        bytes memory result = vm.ffi(inputs);
        (commitment, nullifier, secret) = abi.decode(result, (bytes32, bytes32, bytes32));
        return (commitment, nullifier, secret);
    }
    
    function test_deposit() public {
        // generate a random commitment
        bytes32 nullifier ;
        bytes32 secret ;
        bytes32 commitment;
        (commitment, nullifier, secret) = generateCommitment();
        console.log("Commitment");
        console.logBytes32(commitment);
        vm.expectEmit(true, false, false, true);
        emit Mixer.Deposit(commitment,0,block.timestamp);
        mixer.deposit{value: mixer.DENOMINATION()}(commitment);

    }
    function testMakeWithdrawal() public {
        bytes32 nullifier;
        bytes32 secret;
        bytes32 commitment;
        (commitment, nullifier, secret) = generateCommitment();
        console.log("Commitment");
        console.logBytes32(commitment);
        vm.expectEmit(true, false, false, true);
        emit Mixer.Deposit(commitment,0,block.timestamp);
        mixer.deposit{value: mixer.DENOMINATION()}(commitment);

        bytes32[] memory leaves = new bytes32[](1);
        leaves[0] =  commitment;

        // Create a proof
        bytes memory proof = _getProof(nullifier , secret , Recipient , leaves);

    }

    function _getProof(bytes32 nullifier , bytes32 secret , address _recipient , bytes32[] memory leaves) internal returns (bytes memory proof)
    {
        string[] memory inputs = new string[](6 + leaves.length);
        inputs[0] = "npx";
        inputs[1] = "tsx";
        inputs[2] = "js-scripts/GenerateCommitment.ts";
        inputs[3] = vm.toString(nullifier);
        inputs[4] = vm.toString(secret);
        inputs[5] = vm.toString(bytes32(uint256(uint160(_recipient))));

        for(uint256 i = 0 ; i < leaves.length ; i++)
        {
            inputs[6 + i] = vm.toString(leaves[i]);
        }

        bytes memory result = vm.ffi(inputs);
        bytes memory proof = abi.decode(result,(bytes));
        console.logBytes32(bytes32(proof));
    }
    
}