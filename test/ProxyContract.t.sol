// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {FlexibleProxyContract} from "../src/ProxyContract.sol";
import {MockTargetContract} from "../src/MockTargetContract.sol";
import {MockERC20} from "../src/MockERC20.sol";

contract FlexibleProxyContractTest is Test {
    FlexibleProxyContract proxyContract;
    MockTargetContract mockTargetContract;
    MockERC20 mockCollateralToken;
    MockERC20 mockTokenToSell;
    address owner;
    address addr1;
    address addr2;

    function setUp() public {
        owner = address(this);
        addr1 = makeAddr("addr1");
        addr2 = makeAddr("addr2");

        proxyContract = new FlexibleProxyContract();
        mockTargetContract = new MockTargetContract();
        mockCollateralToken = new MockERC20("Mock Collateral", "MCOL", 18);
        mockTokenToSell = new MockERC20("Mock Token", "MTOK", 18);

        // Transfer some tokens to addr1 for testing
        mockCollateralToken.transfer(addr1, 1000 ether);
        mockTokenToSell.transfer(addr1, 1000 ether);
    }

    function testDeployment() public view {
        assertTrue(address(proxyContract) != address(0));
    }

    // --- Buy Function ---
    function testBuyRevertZeroTargetAddress() public {
        uint256 depositAmount = 1 ether;
        uint256 minAmountOut = 0.95 ether;
        vm.expectRevert(bytes("Target contract cannot be zero address"));
        proxyContract.buy(address(0), address(mockCollateralToken), depositAmount, minAmountOut);
    }

    function testBuyRevertZeroCollateralToken() public {
        uint256 depositAmount = 1 ether;
        uint256 minAmountOut = 0.95 ether;
        vm.expectRevert(bytes("Collateral token cannot be zero address"));
        proxyContract.buy(address(mockTargetContract), address(0), depositAmount, minAmountOut);
    }

    function testBuyCallsBuyForOnTargetContract() public {
        uint256 depositAmount = 1 ether;
        uint256 minAmountOut = 0.95 ether;
        // Approve proxy to spend tokens from addr1
        vm.startPrank(addr1);
        mockCollateralToken.approve(address(proxyContract), depositAmount);
        // Should not revert
        proxyContract.buy(address(mockTargetContract), address(mockCollateralToken), depositAmount, minAmountOut);
        vm.stopPrank();
    }

    // --- Sell Function ---
    function testSellRevertZeroTargetAddress() public {
        uint256 depositAmount = 1 ether;
        uint256 minAmountOut = 0.95 ether;
        vm.expectRevert(bytes("Target contract cannot be zero address"));
        proxyContract.sell(address(0), address(mockTokenToSell), depositAmount, minAmountOut);
    }

    function testSellRevertZeroTokenToSell() public {
        uint256 depositAmount = 1 ether;
        uint256 minAmountOut = 0.95 ether;
        vm.expectRevert(bytes("Token to sell cannot be zero address"));
        proxyContract.sell(address(mockTargetContract), address(0), depositAmount, minAmountOut);
    }

    function testSellCallsSellToOnTargetContract() public {
        uint256 depositAmount = 1 ether;
        uint256 minAmountOut = 0.95 ether;
        // Approve proxy to spend tokens from addr1
        vm.startPrank(addr1);
        mockTokenToSell.approve(address(proxyContract), depositAmount);
        // Should not revert
        proxyContract.sell(address(mockTargetContract), address(mockTokenToSell), depositAmount, minAmountOut);
        vm.stopPrank();
    }

    // // --- isContract Function ---
    // function testIsContractReturnsTrueForContracts() public {
    //     assertTrue(proxyContract.isContract(address(mockTargetContract)));
    //     assertTrue(proxyContract.isContract(address(mockCollateralToken)));
    // }

    // function testIsContractReturnsFalseForEOA() public {
    //     assertFalse(proxyContract.isContract(addr1));
    //     assertFalse(proxyContract.isContract(addr2));
    // }
}
