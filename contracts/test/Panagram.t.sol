//SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {Test, console} from "forge-std/Test.sol";
import {Panagram} from "./../src/Panagram.sol";
import {HonkVerifier} from "./../src/Verifier.sol";

contract PanagramTest is Test {
    HonkVerifier verifier;
    Panagram panagram;
    uint256 constant FIELD_MODULUS = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    bytes32 ANSWER = bytes32((uint256(keccak256("barcelona"))) % FIELD_MODULUS);
    address user = makeAddr("user");

    function setUp() public{
        verifier = new HonkVerifier();
        panagram = new Panagram(verifier);

        panagram.createRound(ANSWER);
    }

    function _getProof(bytes32 guess, bytes32 correctAnswer) internal returns(bytes memory _proof){
        uint256 NUM_ARGS = 5;
        string[] memory inputs = new string[](NUM_ARGS);
        inputs[0] = "npx";
        inputs[1] = "tsx";
        inputs[2] = "js-scripts/generateProof.ts";
        inputs[3] = vm.toString(guess);
        inputs[4] = vm.toString(correctAnswer);

        bytes memory encodedProof = vm.ffi(inputs);
        _proof = abi.decode(encodedProof, (bytes));
    }

    //test if user get nft 1
    function testCorrectGuessPass() public {
        vm.prank(user);
        bytes memory proof = _getProof(ANSWER, ANSWER);
        panagram.submitGuess(proof);
    }

    //tewst isf user gets nft 2


}