pragma solidity >=0.4.22 <0.9.0;

import {ISpokeBridge} from "./ISpokeBridge.sol";

// FIXME comments
/**
 * @notice
 */
interface IDstSpokeBridge is ISpokeBridge {
    function challengeMinting(uint256 _bidId) external payable;

    function minting(uint256 _bidId, address _to, address erc721Contract) external;
}