// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

contract TokenFactory {
    address public immutable beacon;
    address[] public allBeaconProxies;

    event TokenCreated(address indexed proxyAddress, address indexed admin);

    constructor(address _beacon) {
        beacon = _beacon;
    }

    function createToken(
        string memory name, 
        string memory symbol, 
        address admin
    ) external returns (address) {
        bytes memory initData = abi.encodeWithSignature(
            "initialize(string,string,address)", 
            name, 
            symbol, 
            admin
        );

        BeaconProxy proxy = new BeaconProxy(beacon, initData);
        
        address proxyAddress = address(proxy);
        allBeaconProxies.push(proxyAddress);
        
        emit TokenCreated(proxyAddress, admin);
        return proxyAddress;
    }

    function getProxiesCount() external view returns (uint256) {
        return allBeaconProxies.length;
    }
}

