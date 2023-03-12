// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

// FIXME comments
/**
 * @notice This interface hides the sending mechanism.
 */
interface IMessageSender {
    function sendMessage(bytes memory _data) external;
}