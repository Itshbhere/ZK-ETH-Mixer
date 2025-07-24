// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Poseidon2, Field} from "@poseidon/src/Poseidon2.sol";

contract IncrementalMerkleTree {
    Poseidon2 public immutable HasherContract;

    uint32 public immutable MAX_DEPTH;
    uint32 public constant MAX_STORED_ROOTS = 30;
    uint32 public NextLeafIndex;
    uint32 public CurrentRootIndex;

    mapping(uint256 => bytes32) public MerkleRoots;
    mapping(uint32 => bytes32) public CachedSubtrees;

    error IncrementalMerkleTreeDepthCannotBeZero();
    error IncrementalMerkleTreeDepthCannotBeGreaterThan32();
    error DepthOutOfBound();
    error MerkleTreeFull();

    constructor(uint32 _maxDepth, Poseidon2 _HasherContract) {
        if (_maxDepth == 0) {
            revert IncrementalMerkleTreeDepthCannotBeZero();
        }
        if (_maxDepth >= 32) {
            revert IncrementalMerkleTreeDepthCannotBeGreaterThan32();
        }
        MAX_DEPTH = _maxDepth;
        HasherContract = _HasherContract;
        // Initialize the Merkle tree with a zeros (Precompute all the zero subtrees)
        // Store the initial root in storage
        MerkleRoots[0] = _zeroInitiating(_maxDepth);
    }

    function insert(bytes32 _leaf) internal returns (uint32) {
        // Insert a new leaf into the Merkle tree
        uint32 Nextindex = NextLeafIndex;
        // Check if the index exceeds the Merkle tre Bound
        if (Nextindex >= uint32(2) ** MAX_DEPTH) {
            revert MerkleTreeFull();
        }
        // Figure out if the index is even

        uint32 CurrentIndex = Nextindex;
        bytes32 CurrentHash = _leaf;
        bytes32 left;
        bytes32 right;
        for (uint32 i = 0; i < MAX_DEPTH; i++) {
            if (CurrentIndex % 2 == 0) {
                // If it is even, put the new leaf at the left side and a zero tree on the right side
                left = CurrentHash;
                right = _zeroInitiating(i);
                // Store the result as cached subtree
                CachedSubtrees[i] = CurrentHash;
            } else {
                // If it is odd, put the new leaf at the right and cached subtree on the left side
                left = CachedSubtrees[i];
                right = CurrentHash;
            }
            // Hash(left, right)
            CurrentHash = Field.toBytes32(HasherContract.hash_2(Field.toField(left), Field.toField(right)));
            CurrentIndex = CurrentIndex / 2;
        }
        // Update the IncrementalRoot with the new hash
        uint32 NewRootIndex = (CurrentRootIndex + 1) % MAX_STORED_ROOTS;
        CurrentRootIndex = NewRootIndex;
        MerkleRoots[NewRootIndex] = CurrentHash;

        // Increment the NextLeafIndex
        NextLeafIndex = Nextindex + 1;
        return Nextindex;
    }

    function _zeroInitiating(uint32 i) internal pure returns (bytes32) {
        if (i == 0) return bytes32(0x2a8d2e6f5510193d5ca22830bb860c4a0cc4bd307b50c6472ad6dc54b351d4b0);
        else if (i == 1) return bytes32(0x24c8b9d5d2ce025c1c2e5af14db8fc2ae95380d9ee020a531e1256a45659f28c);
        else if (i == 2) return bytes32(0x218432a81a04ba0f233ba47ae7b860ca4374977efe290a5a28b7c110a8735aa8);
        else if (i == 3) return bytes32(0x1a09c92899af48e930fb01bf9f0bd51b83d8f3e578c76705521eca87d1fb3461);
        else if (i == 4) return bytes32(0x23b61b2d21e17e2d8f6d390b2e0b6f8d296456daa36d84b2ee427f751464af04);
        else if (i == 5) return bytes32(0x25748d26b4a4baff1ccd5c353c5940054a17908d935d399cd6d02c51e3804f26);
        else if (i == 6) return bytes32(0x2006a03267848aee6db19c493927efc28616408793223c8c36db96573b080010);
        else if (i == 7) return bytes32(0x1541b5ea87bbc9673adad481933b5d8f042e3eb81d18fe2d59440074b1e12789);
        else if (i == 8) return bytes32(0x0452a0f37ec6b5cd65667bfa4f5a1ccef767c97708f6f547180804c1cf081b07);
        else if (i == 9) return bytes32(0x067500962de4f718aedd4910f37bc97f552a5eb938c03d99bf299992c7ba8bc0);
        else if (i == 10) return bytes32(0x054808e333bc539743f70766001bd6b657a03f890cc56390191965e594d7d812);
        else if (i == 11) return bytes32(0x2a2d825f63f7beabaae3dcf6c8f78dff8257bf100d25d9100052e97657d1c05f);
        else if (i == 12) return bytes32(0x033f5ebcc276ee22a4cd16fa43723bab448a5b190379c22d1aa514c1fa22a618);
        else if (i == 13) return bytes32(0x004e2fb418d5bb0477f9e0f131a8256001cb947990b45173a86262b75e907a8f);
        else if (i == 14) return bytes32(0x0268b688c0a6e07b1c8614c8b09312cdb63509eb6ba524295850e9d658e0ace0);
        else if (i == 15) return bytes32(0x017ab703c88c05e0e5e3bb1d07ffc0c06295864edbfda6f94dcfd655663361c9);
        else if (i == 16) return bytes32(0x1ebe50b08a3243ec3c6524d71bff445e2b2b8c199679fa62da304b6861c74fad);
        else if (i == 17) return bytes32(0x0cd869d2327c56da931f6106fea456b5aaadc73b6d2a11e63e23335b3234d90a);
        else if (i == 18) return bytes32(0x1a51675dfc22dc8d1f26882549bea7be8546e870dffeafaddc3228c9777a9edf);
        else if (i == 19) return bytes32(0x115c29146e85014d86b2ffa62558fe021564429c30ee85679e2233cfa5ecb95d);
        else if (i == 20) return bytes32(0x120b533c908470be071212d40168690cfb8d0560d231b39b9309da1963d334fc);
        else if (i == 21) return bytes32(0x067c47487801ab44e614096f5c6c63bb99c1f06bd9a16fdd3dda76061d2e2443);
        else if (i == 22) return bytes32(0x0216040bc3d5db339f5a489115f8b7e945d02f0f7e1bb1e637ba5400857566a3);
        else if (i == 23) return bytes32(0x211f76e9d0ddc4a8c7f957268c4dd8dbc4a8cd8ade7d385e31b52decc5568ed9);
        else if (i == 24) return bytes32(0x116c595c1fc95f06d48c62d2521ae522647ec9a683e7c2740c51edc56b4c7bed);
        else if (i == 25) return bytes32(0x00da92a423cbe51daf7ae02d9423a9798f99073d2392ad703097e629fa4645e5);
        else if (i == 26) return bytes32(0x2f7cac43ba8712df7049766e33239c121c12124c625bb5b1cc7e30bd2bf20235);
        else if (i == 27) return bytes32(0x25205f76f10309ae66fc1df2d59dc2953c9675b4c7f5de5cf342c19b5924553a);
        else if (i == 28) return bytes32(0x1fa34b9beb17e62b54962b9ca4f07ff25d04a0f1200eea45cc59a5be5c494883);
        else if (i == 29) return bytes32(0x1ccc681f8e93f7016e902c978dca837a58ef27ded0f59ca732c71bc28a0adee8);
        else if (i == 30) return bytes32(0x23c657ad6446925f796afabf37b9c3291ba41002adfda9f3c1e98287aefed489);
        else if (i == 31) return bytes32(0x14d028475713cadfcefeed87f06490870ae240217ba044c5c3f87852e94ce78c);
        else revert DepthOutOfBound();
    }
}
