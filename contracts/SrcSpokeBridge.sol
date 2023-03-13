// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {IContractMap} from "./interfaces/IContractMap.sol";
import {ISrcSpokeBridge} from "./interfaces/ISrcSpokeBridge.sol";

import {SpokeBridge} from "./SpokeBridge.sol";

import {ERC721} from "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";
import {Counters} from "openzeppelin-solidity/contracts/utils/Counters.sol";

// FIXME comments
/**
 * @notice
 */
abstract contract SrcSpokeBridge is ISrcSpokeBridge, SpokeBridge {
    using Counters for Counters.Counter;

    constructor(address _contractMap, address _messageSender) SpokeBridge(_contractMap, _messageSender) {
    }

    function createBid(
        address _receiver,
        uint256 _tokenId,
        address _erc721Contract) public override payable {
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
            timestampOfBought:0,
            buyer:address(0)
        });

        id.increment();
    }

    function challengeUnlocking(uint256 _bidId) public override payable {
        require(msg.value == CHALLENGE_AMOUNT);
        require(incomingBids[_bidId].status == IncomingBidStatus.Relayed);
        require(incomingBids[_bidId].timestampOfRelayed + 4 hours > block.timestamp);

        challengedIncomingBids[_bidId].challenger = _msgSender();
        challengedIncomingBids[_bidId].status = ChallengeStatus.Challenged;

        relayers[incomingBids[_bidId].relayer].status = RelayerStatus.Challenged;
    }

    function sendProof(bool _isOutgoingBid, uint256 _bidId) public override {
        if (_isOutgoingBid) {
            OutgoingBid memory bid = outgoingBids[_bidId];
            bytes memory data = abi.encode(
                _isOutgoingBid,
                _bidId,
                bid.status,
                bid.receiver,
                bid.tokenId,
                bid.erc721Contract,
                bid.buyer
            );
            _sendMessage(data);
        } else {
            IncomingBid memory bid = incomingBids[_bidId];
            bytes memory data = abi.encode(
                _isOutgoingBid,
                _bidId,
                bid.status,
                bid.receiver,
                bid.tokenId,
                bid.localErc721Contract,
                bid.relayer,
                bid.lockingId
            );
            _sendMessage(data);
        }
    }

    function receiveProof(uint256 _bidId) public override {
        // TODO
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