// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import {IContractMap} from "./interfaces/IContractMap.sol";

import {Ownable} from "openzeppelin-solidity/contracts/access/Ownable.sol";

// FIXME comments
/**
 * @notice
 */
contract ContractMap is IContractMap, Ownable {
    /**
     * @notice FIXME
     */
    mapping(address => address) public localToRemote;

    /**
     * @notice FIXME
     */
    mapping(address => address) public remoteToLocal;

    function addPair(address _local, address _remote) public override onlyOwner {
        require(localToRemote[_local] == address(0), "ContractMap: addr is already in the localToRemote!");
        require(remoteToLocal[_remote] == address(0), "ContractMap: addr is already in the remoteToLocal!");

        localToRemote[_local] = _remote;
        remoteToLocal[_remote] = _local;
    }

    function getRemote(address _local) public view override onlyOwner returns (address) {
        require(localToRemote[_local] != address(0), "ContractMap: addr is not in the localToRemote!");
        return localToRemote[_local];
    }

    function getLocal(address _remote) public view override onlyOwner returns (address) {
        require(remoteToLocal[_remote] != address(0), "ContractMap: addr is not in the remoteToLocal!");
        return remoteToLocal[_remote];
    }
}