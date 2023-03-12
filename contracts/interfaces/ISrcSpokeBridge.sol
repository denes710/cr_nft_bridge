// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {ISpokeBridge} from "./ISpokeBridge.sol";

// FIXME comments
/**
 * @notice
 */
interface ISrcSpokeBridge is ISpokeBridge {
    function challengeUnlocking(uint256 _bidId) external payable;

    function unlocking(
        uint256 _lockingBidId,
        uint256 _bidId,
        address _to,
        uint256 _tokenId,
        address _originErc721Contract) external;
}