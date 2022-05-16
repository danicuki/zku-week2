pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/comparators.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;
    component poseidons[2**(n-1)];

    var pCounter = 0; //counter for the poseidons component
    var size = n;
    var temp[2**n];
    
    //populate temp array with original leaves hashes
    for (var i = 0; i < 2**n; i++) {
        temp[i] = leaves[i];
    }

    //for every level
    for (var l = n; l > 0; l--) {
        // scan the array, take every two elements
        // calculate the hash and populate again
        // from the begining of the array the new hash values 
        for (var i = 0; i < 2**l; i += 2) {
            poseidons[pCounter] = Poseidon(2);
            poseidons[pCounter].inputs[0] <== temp[i];
            poseidons[pCounter].inputs[1] <== temp[i + 1];
            temp[i/2] = poseidons[pCounter].out;
            pCounter++;
        }
    }

    root <== temp[0];
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating 
    // whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    signal a[n];
    signal b[n];
    signal c[n];
    signal d[n];

    component poseidons[n];

    signal partial_results[n + 1];

    partial_results[0] <== leaf;

    for(var i = 0; i < n; i++) {
        poseidons[i] = Poseidon(2);

        a[i] <== partial_results[i] * (1 - path_index[i]);
        b[i] <== path_elements[i] * path_index[i];
        c[i] <== path_elements[i] * (1 - path_index[i]);
        d[i] <== partial_results[i] * path_index[i];
        poseidons[i].inputs[0] <== a[i] + b[i];
        poseidons[i].inputs[1] <== c[i] + d[i];

        partial_results[i+1] <== poseidons[i].out;
    }

    root <== partial_results[n];
}

