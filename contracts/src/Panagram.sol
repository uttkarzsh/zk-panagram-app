//SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import { ERC1155 } from "openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import { Ownable } from "openzeppelin-contracts/contracts/access/Ownable.sol";
import { IVerifier } from "./Verifier.sol";

contract Panagram is ERC1155, Ownable {

    IVerifier public s_verifier;
    bytes32 s_answer;

    uint256 public constant MIN_ROUND_DURATION = 3600;
    uint256 public s_roundStartTime;
    address public s_currentRoundWinner;
    uint256 public s_currentRound;

    mapping(address => uint256) public s_lastCorrectGuessByUser;


    event Panagram_VerifierUpdated(IVerifier _verifier);
    event Panagram_NewRoundStarted();
    event Panagram_ProofVerified(bool result);
    event Panagram_NFTMinted(address winner, uint256 tokenID);

    error Panagram_MinTimeNotPassed(uint256 minTime, uint256 timePassed);
    error Panagram_NoRoundWinner();
    error Panagram_FirstPanagramNotSet();
    error Panagram_AlreadyAnsweredCorrectly();
    error Panagram_IncorrectGuess();


    constructor(IVerifier _verifier) ERC1155("ipfs://bafybeif3eqgdkh37u6s4gfg3mqk7uvqtwford5g3lnisi6ks7laddpz6xy/{id}.json") Ownable(msg.sender){
        s_verifier = _verifier;
    }

    function contractURI() external pure returns(string memory){
        return "ipfs://bafybeif3eqgdkh37u6s4gfg3mqk7uvqtwford5g3lnisi6ks7laddpz6xy/{id}.json";
    }

    function createRound(bytes32 _answer) external onlyOwner{
        if(s_roundStartTime == 0) {
            s_roundStartTime == block.timestamp;
            s_answer = _answer;
        } else {
            if(block.timestamp > s_roundStartTime + MIN_ROUND_DURATION){
                revert Panagram_MinTimeNotPassed(MIN_ROUND_DURATION, block.timestamp - s_roundStartTime);
            }
            if(s_currentRoundWinner==address(0)){
                revert Panagram_NoRoundWinner();
            }

            s_answer = _answer;
            s_roundStartTime = block.timestamp;
            s_currentRoundWinner = address(0);
        }
        s_currentRound++;
        emit Panagram_NewRoundStarted();
    }

    function submitGuess(bytes calldata proof) external returns(bool) {
        if(s_currentRound == 0){
            revert Panagram_FirstPanagramNotSet();
        }

        bytes32[] memory inputs = new bytes32[](1);
        inputs[0] = s_answer;

        if(s_lastCorrectGuessByUser[msg.sender] == s_currentRound){
            revert Panagram_AlreadyAnsweredCorrectly();
        }
        bool proofResult = s_verifier.verify(proof, inputs);
        emit Panagram_ProofVerified(proofResult);
        if(!proofResult){
            revert Panagram_IncorrectGuess();
        }
        s_lastCorrectGuessByUser[msg.sender] = s_currentRound;

        if(s_currentRoundWinner == address(0)){
            s_currentRoundWinner == msg.sender;
            _mint(msg.sender,0, 1, "");
            emit Panagram_NFTMinted(msg.sender, 1);
        } else {
            _mint(msg.sender,1,1,"");
            emit Panagram_NFTMinted(msg.sender, 0);
        }
        return proofResult;
    }

    function setVerifier(IVerifier _verifier) external onlyOwner{
        s_verifier = _verifier;
        emit Panagram_VerifierUpdated(_verifier);
    }

    function getCurrentRoundStatus() external view returns(address){
        return (s_currentRoundWinner);
    }

    function getCurrentPanagram() external view returns(bytes32){
        return s_answer;
    }
}

