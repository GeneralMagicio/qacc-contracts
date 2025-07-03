// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {FlexibleProxyContract} from "../src/FlexibleProxyContract.sol";
import {console} from "forge-std/console.sol";
import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import {TransparentUpgradeableProxy} from
    "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract DeployProxyContract is Script {
    FlexibleProxyContract public flexibleProxyContract;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        ProxyAdmin proxyAdmin = new ProxyAdmin();
        FlexibleProxyContract implementation = new FlexibleProxyContract();
        TransparentUpgradeableProxy proxy =
            new TransparentUpgradeableProxy(address(implementation), address(proxyAdmin), "");

        flexibleProxyContract = FlexibleProxyContract(address(proxy));

        console.log("proxyAdmin: ", address(proxyAdmin));
        console.log("implementation: ", address(implementation));
        console.log("flexibleProxyContract: ", address(flexibleProxyContract));

        vm.stopBroadcast();
    }
}
