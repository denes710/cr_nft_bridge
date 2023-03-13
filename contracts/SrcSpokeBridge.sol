// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {IContractMap} from "./interfaces/IContractMap.sol";
import {ISrcSpokeBridge} from "./interfaces/ISrcSpokeBridge.sol";

import {Ownable} from "openzeppelin-solidity/contracts/access/Ownable.sol";
import {ERC721} from "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import {Counters} from "openzeppelin-solidity/contracts/utils/Counters.sol";

// FIXME comments
/**
 * @notice
 */
contract SrcSpokeBridge is ISrcSpokeBridge, Ownable {
    using Counters for Counters.Counter;

    enum ChallengeStatus {
        None,
        Challenged,
        Proved
    }

    struct Challenge {
        address challenger;
        ChallengeStatus status;
    }

    /**
     * @notice FIXME
     */
    mapping(uint256 => IncomingBid) public incomingBids;

    /**
     * @notice FIXME
     */
    mapping(uint256 => OutgoingBid) public outgoingBids;

    /**
     * @notice FIXME
     */
    mapping(address => Relayer) public relayers;

    /**
     * @notice FIXME
     */
    mapping(uint256 => Challenge) public challengedIncomingBids;

    /**
     * @notice FIXME
     */
    mapping(uint256 => Challenge) public challengedOutgoingBids;

    uint256 public immutable STAKE_AMOUNT;

    uint256 public immutable CHALLENGE_AMOUNT;

    uint256 public immutable TIME_LIMIT_OF_UNDEPOSIT;

    Counters.Counter public id;

    address public contractMap;

    address public messageSender;

    constructor(address _contractMap, address _messageSender) {
        contractMap = _contractMap;
        messageSender = _messageSender;
        STAKE_AMOUNT = 20 ether;
        CHALLENGE_AMOUNT = 10 ether;
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

    function createBid(
        address _receiver,
        uint256 _tokenId,
        address _erc721Contract,
        uint32 _chainId) public override payable {
        require(msg.value > 0, "SrcSpokenBridge: there is no fee for relayers!");

        ERC721(_erc721Contract).safeTransferFrom(msg.sender, address(this), _tokenId);

        outgoingBids[id.current()] = OutgoingBid({
            id:id.current(),
            status:OutgoingBidStatus.Created,
            fee:uint16(msg.value),
            maker:_msgSender(),
            receiver:_receiver,
            tokenId:_tokenId,
            erc721Contract:_erc721Contract,
            chainId:_chainId,
            timestampOfBought:0,
            buyer:address(0)
        });

        id.increment();
    }

    function buyBid(uint256 _bidId) public override onlyActiveRelayer() {
        require(outgoingBids[_bidId].status == OutgoingBidStatus.Created,
            "SrcSpokeBridge: bid does not have Created state");
        outgoingBids[_bidId].status = OutgoingBidStatus.Bought;
        outgoingBids[_bidId].buyer = _msgSender();
        outgoingBids[_bidId].timestampOfBought = block.timestamp;
    }

    function challengeUnlocking(uint256 _bidId) public override payable {
        require(msg.value == CHALLENGE_AMOUNT);
        require(incomingBids[_bidId].status == IncomingBidStatus.Relayed);
        require(incomingBids[_bidId].timestampOfRelayed + 4 hours > block.timestamp);

        challengedIncomingBids[_bidId].challenger = _msgSender();
        challengedIncomingBids[_bidId].status = ChallengeStatus.Challenged;

        relayers[incomingBids[_bidId].relayer].status = RelayerStatus.Challenged;
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

    function unlocking(
        uint256 _lockingBidId,
        uint256 _bidId,
        address _to,
        uint256 _tokenId,
        address _remoteErc721Contract
    )  public override onlyActiveRelayer {
        require(outgoingBids[_lockingBidId].status == OutgoingBidStatus.Bought);
        require(incomingBids[_bidId].status == IncomingBidStatus.None);
        address localErc721Contract = IContractMap(contractMap).getLocal(_remoteErc721Contract);
        require(ERC721(localErc721Contract).ownerOf(_tokenId) == address(this));

        outgoingBids[_lockingBidId].status = OutgoingBidStatus.Unlocked;

        incomingBids[_bidId] = IncomingBid({
            remoteId:_bidId,
            lockingId:_lockingBidId,
            status:IncomingBidStatus.Relayed,
            receiver:_to,
            tokenId:_tokenId,
            localErc721Contract:localErc721Contract,
            timestampOfRelayed:block.timestamp,
            relayer:_msgSender()
        });
    }
}