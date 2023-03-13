// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {IContractMap} from "./interfaces/IContractMap.sol";
import {ISpokeBridge} from "./interfaces/ISpokeBridge.sol";
import {IDstSpokeBridge} from "./interfaces/IDstSpokeBridge.sol";

import {SpokeBridge} from "./SpokeBridge.sol";

import {ERC721} from "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import {Counters} from "openzeppelin-solidity/contracts/utils/Counters.sol";

// FIXME comments
/**
 * @notice
 */
abstract contract DstSpokeBridge is IDstSpokeBridge, SpokeBridge {
    using Counters for Counters.Counter;

    constructor(address _contractMap, address _messageSender) SpokeBridge(_contractMap, _messageSender) {
    }

    function createBid(
        address _receiver,
        uint256 _tokenId,
        address _erc721Contract,
        uint256 _incomingBidId) public override payable {
        require(msg.value > 0, "SrcSpokenBridge: there is no fee for relayers!");
        require(incomingBids[_incomingBidId].status == IncomingBidStatus.Relayed, "SrcSpokenBridge: there is no fee for relayers!");
        require(incomingBids[_incomingBidId].timestampOfRelayed + 4 hours < block.timestamp, "SrcSpokenBridge: there is no fee for relayers!");

        ERC721(_erc721Contract).safeTransferFrom(msg.sender, address(this), _tokenId);

        outgoingBids[id.current()] = OutgoingBid({
            id:id.current(),
            status:OutgoingBidStatus.Created,
            fee:uint16(msg.value),
            maker:_msgSender(),
            receiver:_receiver,
            tokenId:_tokenId,
            erc721Contract:_erc721Contract,
            timestampOfBought:0,
            buyer:address(0)
        });

        id.increment();
    }

    function buyBid(uint256 _bidId) public override(ISpokeBridge, SpokeBridge) onlyActiveRelayer() {
        super.buyBid(_bidId);
        // FIXME but burning is necessary
    }

    function challengeMinting(uint256 _bidId) public override payable {
        require(msg.value == CHALLENGE_AMOUNT);
        require(incomingBids[_bidId].status == IncomingBidStatus.Relayed);
        require(incomingBids[_bidId].timestampOfRelayed + 4 hours > block.timestamp);

        challengedIncomingBids[_bidId].challenger = _msgSender();
        challengedIncomingBids[_bidId].status = ChallengeStatus.Challenged;

        relayers[incomingBids[_bidId].relayer].status = RelayerStatus.Challenged;
    }

    function sendProof(bool _isOutgoingBid, uint256 _bidId) public override {
        // TODO
    }

    function receiveProof(uint256 _bidId) public override {
        // TODO
    }

    function minting(
        uint256 _bidId,
        address _to,
        uint256 _tokenId,
        address _erc721Contract
    )  public override onlyActiveRelayer {
        // require(outgoingBids[_lockingBidId].status == OutgoingBidStatus.Bought);
        require(incomingBids[_bidId].status == IncomingBidStatus.None);
        require(ERC721(_erc721Contract).ownerOf(_tokenId) == address(0));

        // outgoingBids[_lockingBidId].status = OutgoingBidStatus.Unlocked;

        incomingBids[_bidId] = IncomingBid({
            remoteId:_bidId,
            lockingId:0, // FIXME 
            status:IncomingBidStatus.Relayed,
            receiver:_to,
            tokenId:_tokenId,
            localErc721Contract:_erc721Contract,
            timestampOfRelayed:block.timestamp,
            relayer:_msgSender()
        });
    }
}