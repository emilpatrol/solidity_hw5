// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract TokenUpgradeable is Initializable, ERC20PermitUpgradeable, AccessControlUpgradeable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory name, 
        string memory symbol, 
        address admin
    ) public initializer {
        __ERC20_init(name, symbol);
        __ERC20Permit_init(name);
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }
}
