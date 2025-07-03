// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {FlexibleProxyContract} from "../src/FlexibleProxyContract.sol";
import {ProxyAdmin} from "openzeppelin-contracts/contracts/proxy/transparent/ProxyAdmin.sol";
import {TransparentUpgradeableProxy} from
    "openzeppelin-contracts/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";

contract FlexibleProxyContractTest is Test {
    FlexibleProxyContract proxyContract;
    address admin = vm.addr(1);

    function setUp() public virtual {
        ProxyAdmin proxyAdmin = new ProxyAdmin();
        FlexibleProxyContract implementation = new FlexibleProxyContract();
        TransparentUpgradeableProxy proxy =
            new TransparentUpgradeableProxy(address(implementation), address(proxyAdmin), "");
        proxyContract = FlexibleProxyContract(address(proxy));
    }
}
