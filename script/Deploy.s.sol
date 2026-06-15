// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "../src/TokenUpgradeable.sol";
import "../src/TokenFactory.sol";

contract DeployScript is Script {
    function run() external {
        vm.startBroadcast();

        TokenUpgradeable impl = new TokenUpgradeable();
        console.log("Implementation deployed at:", address(impl));

        UpgradeableBeacon beacon = new UpgradeableBeacon(address(impl), msg.sender);
        console.log("Beacon deployed at:", address(beacon));

        TokenFactory factory = new TokenFactory(address(beacon));
        console.log("Factory deployed at:", address(factory));

        vm.stopBroadcast();
    }
}
