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
    address runnerUp = makeAddr("runneruphe");

    function setUp() public{
        verifier = new HonkVerifier();
        panagram = new Panagram(verifier);

        panagram.createRound(ANSWER);
    }

    function _getProof(bytes32 guess, bytes32 correctAnswer, address sender) internal returns(bytes memory _proof){
        uint256 NUM_ARGS = 6;
        string[] memory inputs = new string[](NUM_ARGS);
        inputs[0] = "npx";
        inputs[1] = "tsx";
        inputs[2] = "js-scripts/generateProof.ts";
        inputs[3] = vm.toString(guess);
        inputs[4] = vm.toString(correctAnswer);
        inputs[5] = vm.toString(sender);

        bytes memory encodedProof = vm.ffi(inputs);
        _proof = abi.decode(encodedProof, (bytes));
    }

    //test if user get nft 0
    function testCorrectGuessPass() public {
        vm.prank(user);
        bytes memory proof = _getProof(ANSWER, ANSWER, user);
        panagram.submitGuess(proof);
        vm.assertEq(panagram.balanceOf(user,0),1);
        vm.assertEq(panagram.balanceOf(user,1),0);

        vm.prank(user);
        vm.expectRevert();
        panagram.submitGuess(proof);
    }

    //tewst isf user gets nft 1
    function testSecondCorrectGuess() public {
        vm.prank(user);
        bytes memory proof = _getProof(ANSWER, ANSWER, user);
        panagram.submitGuess(proof);
        vm.assertEq(panagram.balanceOf(user,0),1);
        vm.assertEq(panagram.balanceOf(user,1),0);

        vm.prank(runnerUp);
        bytes memory proof2 = _getProof(ANSWER, ANSWER, runnerUp);
        panagram.submitGuess(proof2);
        vm.assertEq(panagram.balanceOf(runnerUp,0),0);
        vm.assertEq(panagram.balanceOf(runnerUp,1),1);
    }

    function testStartNewRound() public {
        vm.prank(user);
        bytes memory proof = _getProof(ANSWER, ANSWER, user);
        panagram.submitGuess(proof);
        vm.assertEq(panagram.balanceOf(user,0),1);
        vm.assertEq(panagram.balanceOf(user,1),0);

        vm.warp(panagram.MIN_ROUND_DURATION() + 1);
        bytes32 NEW_ANSWER = bytes32((uint256(keccak256("aloha")))%FIELD_MODULUS);
        panagram.createRound(NEW_ANSWER);
        vm.assertEq(panagram.s_currentRound(), 2);
        vm.assertEq(panagram.s_currentRoundWinner(), address(0));
        vm.assertEq(panagram.getCurrentPanagram(), NEW_ANSWER);
    }

    function testIncorrectGuessFails() public {
        bytes32 INCORRECT_ANSWER = bytes32((uint256(keccak256("aloha")))%FIELD_MODULUS);
        bytes memory incorrectProof = _getProof(INCORRECT_ANSWER, INCORRECT_ANSWER, user);
        vm.prank(user);
        vm.expectRevert();
        panagram.submitGuess(incorrectProof);
    }

}