// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./TokenUpgradeable.sol";

contract TokenUpgradeableV2 is TokenUpgradeable {
    function version() pure external returns (string memory) {
        return "v2";
    }
}

