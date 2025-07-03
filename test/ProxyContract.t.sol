// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {FlexibleProxyContract} from "../src/ProxyContract.sol";
import {MockBondingCurve} from "../src/MockBondingCurve.sol";
import {MockERC20} from "../src/MockERC20.sol";

contract FlexibleProxyContractTest is Test {
    FlexibleProxyContract proxyContract;
    MockBondingCurve bondingCurve;
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
        mockCollateralToken = new MockERC20("Mock Collateral", "MCOL");
        mockTokenToSell = new MockERC20("Mock Token", "MTOK");
        bondingCurve = new MockBondingCurve(address(mockCollateralToken), address(mockTokenToSell));

        mockCollateralToken.mint(address(bondingCurve), 10000 ether);
        mockTokenToSell.mint(address(bondingCurve), 10000 ether);
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
        proxyContract.buy(address(bondingCurve), address(0), depositAmount, minAmountOut);
    }

    function testBuyOnBondingCurve() public {
        uint256 depositAmount = 1 ether;
        uint256 minAmountOut = 0.95 ether;
        // Approve proxy to spend tokens from addr1
        vm.startPrank(addr1);
        mockCollateralToken.mint(addr1, depositAmount); // Mint tokens to addr1 for testing
        mockCollateralToken.approve(address(proxyContract), depositAmount);
        // Should not revert
        proxyContract.buy(address(bondingCurve), address(mockCollateralToken), depositAmount, minAmountOut);
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
        proxyContract.sell(address(bondingCurve), address(0), depositAmount, minAmountOut);
    }

    function testSellOnBondingCurve() public {
        uint256 depositAmount = 1 ether;
        uint256 minAmountOut = 0.95 ether;
        // Approve proxy to spend tokens from addr1
        vm.startPrank(addr1);
        mockTokenToSell.mint(addr1, depositAmount); // Mint tokens to addr1 for testing
        mockTokenToSell.approve(address(proxyContract), depositAmount);
        // Should not revert
        proxyContract.sell(address(bondingCurve), address(mockTokenToSell), depositAmount, minAmountOut);
        vm.stopPrank();
    }

    // // --- isContract Function ---
    // function testIsContractReturnsTrueForContracts() public {
    //     assertTrue(proxyContract.isContract(address(bondingCurve)));
    //     assertTrue(proxyContract.isContract(address(mockCollateralToken)));
    // }

    // function testIsContractReturnsFalseForEOA() public {
    //     assertFalse(proxyContract.isContract(addr1));
    //     assertFalse(proxyContract.isContract(addr2));
    // }
}
