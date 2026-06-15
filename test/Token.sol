// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "../src/TokenUpgradeable.sol";
import "../src/TokenFactory.sol";

contract TokenV2 is TokenUpgradeable {
    function version() pure external returns (string memory) {
        return "v2";
    }
}

contract TokenBeaconTest is Test {
    TokenUpgradeable public implementationV1;
    UpgradeableBeacon public beacon;
    TokenFactory public factory;

    address public admin = address(1);
    address public user = address(2);
    
    uint256 public ownerPrivateKey = 0xA11CE;
    address public tokenOwner;

    function setUp() public {
        tokenOwner = vm.addr(ownerPrivateKey);

        implementationV1 = new TokenUpgradeable();

        beacon = new UpgradeableBeacon(address(implementationV1), address(this));

        factory = new TokenFactory(address(beacon));
    }

    function testBeaconProxyCreation() public {
        address proxyAddress = factory.createToken("BeaconToken", "BTK", admin);
        TokenUpgradeable token = TokenUpgradeable(proxyAddress);

        assertEq(token.name(), "BeaconToken");
        assertEq(token.symbol(), "BTK");

        vm.prank(admin);
        token.mint(user, 1000);
        assertEq(token.balanceOf(user), 1000);

        vm.prank(user);
        vm.expectRevert();
        token.mint(user, 500);
    }

    function testPermitMetaTx() public {
        address proxyAddress = factory.createToken("BeaconToken", "BTK", admin);
        TokenUpgradeable token = TokenUpgradeable(proxyAddress);

        uint256 allowanceAmount = 500;
        uint256 deadline = block.timestamp + 1 days;
        uint256 nonce = token.nonces(tokenOwner);

        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                tokenOwner,
                user,
                allowanceAmount,
                nonce,
                deadline
            )
        );
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", token.DOMAIN_SEPARATOR(), structHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        vm.prank(user);
        token.permit(tokenOwner, user, allowanceAmount, deadline, v, r, s);

        assertEq(token.allowance(tokenOwner, user), allowanceAmount);
    }

    function testBeaconUpgradeAllProxies() public {
        address tokenAAddress = factory.createToken("TokenA", "TKA", admin);
        address tokenBAddress = factory.createToken("TokenB", "TKB", admin);

        TokenV2 implementationV2 = new TokenV2();

        beacon.upgradeTo(address(implementationV2));

        TokenV2 tokenAV2 = TokenV2(tokenAAddress);
        TokenV2 tokenBV2 = TokenV2(tokenBAddress);

        assertEq(tokenAV2.version(), "v2");
        assertEq(tokenBV2.version(), "v2");
    }
}


