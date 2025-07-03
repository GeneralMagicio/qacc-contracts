// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import {ITransparentUpgradeableProxy} from
    "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {FlexibleProxyContract} from "../src/FlexibleProxyContract.sol";
import {console} from "forge-std/console.sol";

contract DeployProxyContract is Script {
    FlexibleProxyContract public flexibleProxyContract;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        ProxyAdmin proxyAdmin = ProxyAdmin(0x7a204cd133ea477f51ac55825A8D08f323467BF3);
        address proxy = 0x84Ed70229D6Fc49d3624a81C8334cC0748ff0f5B;

        FlexibleProxyContract newImplementation = new FlexibleProxyContract();

        proxyAdmin.upgrade(ITransparentUpgradeableProxy(proxy), address(newImplementation));

        console.log("proxyAdmin: ", address(proxyAdmin));
        console.log("Proxy: ", address(proxy));
        console.log("implementation: ", address(newImplementation));

        vm.stopBroadcast();
    }
}
