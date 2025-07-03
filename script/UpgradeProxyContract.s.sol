// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import {
    ITransparentUpgradeableProxy,
    TransparentUpgradeableProxy
} from "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {FlexibleProxyContract} from "../src/FlexibleProxyContract.sol";
import {console} from "forge-std/console.sol";

contract DeployProxyContract is Script {
    FlexibleProxyContract public flexibleProxyContract;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        console.log("=== Deployment Phase ===");
        console.log("Deployer address:", msg.sender);

        ProxyAdmin proxyAdmin = new ProxyAdmin();
        console.log("ProxyAdmin deployed:", address(proxyAdmin));
        console.log("ProxyAdmin owner:", proxyAdmin.owner());

        FlexibleProxyContract implementation = new FlexibleProxyContract();
        console.log("Implementation deployed:", address(implementation));

        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(implementation), address(proxyAdmin), abi.encodeCall(FlexibleProxyContract.initialize, ())
        );
        console.log("Proxy deployed:", address(proxy));

        // Test proxy is working
        flexibleProxyContract = FlexibleProxyContract(address(proxy));
        console.log("Proxy initialized successfully");

        console.log("=== Upgrade Phase ===");
        FlexibleProxyContract newImplementation = new FlexibleProxyContract();
        console.log("New implementation deployed:", address(newImplementation));

        // Debug before upgrade
        console.log("About to call upgradeAndCall...");
        console.log("Proxy address:", address(proxy));
        console.log("New implementation:", address(newImplementation));
        console.log("ProxyAdmin owner:", proxyAdmin.owner());
        console.log("Current msg.sender:", msg.sender);

        // Try upgradeAndCall with detailed error catching
        try proxyAdmin.upgrade{gas: 1000000}(ITransparentUpgradeableProxy(address(proxy)), address(newImplementation)) {
            console.log("UpgradeAndCall successful!");
        } catch Error(string memory reason) {
            console.log("UpgradeAndCall failed with reason:", reason);
            revert(reason);
        } catch Panic(uint256 errorCode) {
            console.log("UpgradeAndCall failed with panic code:", errorCode);
            revert("Panic occurred");
        } catch (bytes memory lowLevelData) {
            console.log("UpgradeAndCall failed with low-level error");
            console.logBytes(lowLevelData);
            revert("Low-level error");
        }

        vm.stopBroadcast();
    }
}
