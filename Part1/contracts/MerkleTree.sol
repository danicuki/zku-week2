//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import {PoseidonT3} from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root
    uint256 private max_levels = 4;

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves
        hashes = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        uint256 levelStartIdx = 0;
        uint256 level = max_levels - 1;

        hashes[index] = hashedLeaf;
        for (uint256 i = index; level > 0; level--) {
            uint256 levelSize = 2**level;
            uint256 parentIdx = levelStartIdx +
                levelSize +
                ((i - levelStartIdx) / 2);
            if (i % 2 == 0) {
                hashes[parentIdx] = PoseidonT3.poseidon(
                    [hashes[i], hashes[i + 1]]
                );
            } else {
                hashes[parentIdx] = PoseidonT3.poseidon(
                    [hashes[i - 1], hashes[i]]
                );
            }
            levelStartIdx += levelSize;
            i = parentIdx;
        }
        index++;
        return 0;
    }

    function verify(
        uint256[2] memory a,
        uint256[2][2] memory b,
        uint256[2] memory c,
        uint256[1] memory input
    ) public view returns (bool) {
        return Verifier.verifyProof(a, b, c, input);
    }
}
