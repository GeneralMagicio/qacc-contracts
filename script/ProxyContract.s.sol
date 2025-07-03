// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {FlexibleProxyContract} from "../src/ProxyContract.sol";

contract FlexibleProxyContractScript is Script {
    FlexibleProxyContract public flexibleProxyContract;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        flexibleProxyContract = new FlexibleProxyContract();

        vm.stopBroadcast();
    }
}
