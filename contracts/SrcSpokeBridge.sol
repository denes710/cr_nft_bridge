// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {ISrcSpokeBridge} from "./interfaces/ISrcSpokeBridge.sol";

import {Ownable} from "openzeppelin-solidity/contracts/access/Ownable.sol";
import {Counters} from "openzeppelin-solidity/contracts/utils/Counters.sol";

// FIXME comments
/**
 * @notice
 */
contract SrcSpokeBridge is ISrcSpokeBridge, Ownable {
    using Counters for Counters.Counter;

    enum ChallengeStatus {
        NONE,
        CHALLENGED,
        PROVED
    }

    struct Challenge {
        address challenger;
        ChallengeStatus status;
    }

    /**
     * @notice FIXME
     */
    mapping(uint256 => Bid) public incomingBids;

    /**
     * @notice FIXME
     */
    mapping(uint256 => Bid) public outgoingBids;

    /**
     * @notice FIXME
     */
    mapping(address => Relayer) public relayers;

    /**
     * @notice FIXME
     */
    mapping(uint256 => Bid) public challengedIncomingBids;

    /**
     * @notice FIXME
     */
    mapping(uint256 => Bid) public challengedOutgoingBids;

    // TODO another for challenging
    uint256 public immutable STAKE_AMOUNT;

    uint256 public immutable TIME_LIMIT_OF_UNDEPOSIT;

    Counters.Counter public id;

    address public contractMap;

    address public messageSender;

    constructor(address _contractMap, address _messageSender) {
        contractMap = _contractMap;
        messageSender = _messageSender;
        STAKE_AMOUNT = 20 ether;
        TIME_LIMIT_OF_UNDEPOSIT = 2 days;
    }

    modifier onlyActiveRelayer() {
        require(RelayerStatus.Active == relayers[_msgSender()].status, "SrcSpokenBridge: caller is not a relayer!");
        _;
    }

    modifier onlyUndepositedRelayer() {
        require(RelayerStatus.Undeposited == relayers[_msgSender()].status,
            "SrcSpokenBridge: caller is not in undeposited state!");
        _;
    }

    function createBid() public override payable {
        // TODO
    }

    function buyBid(uint256 _bidId) public override {
        // TODO
    }

    function challengeUnlocking(uint256 _bidId) public override payable {
        // TODO
    }

    function sendProof(uint256 _bidId) public override {
        // TODO
    }

    function receiveProof(uint256 _bidId) public override {
        // TODO
    }

    function deposite() public override payable {
        require(RelayerStatus.None == relayers[_msgSender()].status, "SrcSpokenBridge: caller cannot be a relayer!");
        require(msg.value == STAKE_AMOUNT);

        relayers[_msgSender()].status = RelayerStatus.Active;
        relayers[_msgSender()].stakedAmount = msg.value;
    }

    function undeposite() public override onlyActiveRelayer {
        relayers[_msgSender()].status = RelayerStatus.Undeposited;
        relayers[_msgSender()].dateOfUndeposited = block.timestamp;
    }

    function claimDeposite() public override onlyUndepositedRelayer {
        require(block.timestamp > relayers[_msgSender()].dateOfUndeposited + TIME_LIMIT_OF_UNDEPOSIT,
            "SrcSpokenBridge: 2 days is not expired from the undepositing!");

        (bool isSent,) = _msgSender().call{value: STAKE_AMOUNT}("");
        require(isSent, "Failed to send Ether");

        relayers[_msgSender()].status = RelayerStatus.None;
    }

    function unlocking(uint256 _lockingBidId, uint256 _bidId, address _to, address erc721Contract) public override {
        // TODO
    }
}