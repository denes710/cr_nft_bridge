// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {IHub} from "../interfaces/IHub.sol";

import {DstSpokeBridge} from "../DstSpokeBridge.sol";

// FIXME comments
/**
 * @notice
 */
contract SimpleGatewayDstSpokenBrdige is DstSpokeBridge {
    // FIXME contractMap address is not useful for the dst side
    constructor(address _hub, address _contractMap) DstSpokeBridge(_contractMap, _hub) {
    }

    function _sendMessage(bytes memory _data) internal override {
        IHub(HUB).processMessage(_data);
    }

    function _getCrossMessageSender() internal override returns (address) {
        return _msgSender();
    }
}