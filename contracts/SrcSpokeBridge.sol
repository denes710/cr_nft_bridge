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


    Counters.Counter public id;

    address public contractMap;

    address public messageSender;

    constructor(address _contractMap, address _messageSender) {
        contractMap = _contractMap;
        messageSender = _messageSender;
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
        // TODO
    }

    function undeposite() public override {
        // TODO
    }

    function claimDeposite() public override {
        // TODO
    }

    function unlocking(uint256 _lockingBidId, uint256 _bidId, address _to, address erc721Contract) public override {
        // TODO
    }
}