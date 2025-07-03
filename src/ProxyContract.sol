// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title FlexibleProxyContract
 * @dev A flexible proxy contract that can call buyFor and sellTo methods on any target contract
 */
contract FlexibleProxyContract {
    using SafeERC20 for IERC20;

    error NotAContract(address target);
    error CallFailed(address target, string reason);
    error TransferFailed(address token, address from, address to, uint256 amount);
    error ApprovalFailed(address token, address spender, uint256 amount);

    /**
     * @dev Proxy function to call buyFor method on any target contract
     * @param targetContract The address of the contract to call
     * @param collateralToken The address of the collateral token to use for buying
     * @param depositAmount The amount to deposit for buying
     * @param minAmountOut The minimum amount to receive
     */
    function buy(address targetContract, address collateralToken, uint256 depositAmount, uint256 minAmountOut)
        external
    {
        require(targetContract != address(0), "Target contract cannot be zero address");
        require(collateralToken != address(0), "Collateral token cannot be zero address");
        require(_isContract(targetContract), "Target address is not a contract");
        require(_isContract(collateralToken), "Collateral token address is not a contract");

        IERC20 _collateralToken = IERC20(collateralToken);

        // Transfer collateral tokens from caller to this contract
        _collateralToken.safeTransferFrom(msg.sender, address(this), depositAmount);

        // Approve target contract to spend collateral tokens
        _collateralToken.safeIncreaseAllowance(targetContract, depositAmount);

        // Call buyFor(msg.sender, depositAmount, minAmountOut)
        bytes memory callData = abi.encodeWithSelector(
            0x935b7dbd, // buyFor(address,uint256,uint256)
            msg.sender,
            depositAmount,
            minAmountOut
        );

        (bool success, bytes memory returnData) = targetContract.call(callData);

        if (!success) {
            if (returnData.length > 0) {
                assembly {
                    let returndata_size := mload(returnData)
                    revert(add(32, returnData), returndata_size)
                }
            } else {
                revert CallFailed(targetContract, "buyFor call failed or function does not exist");
            }
        }
    }

    /**
     * @dev Proxy function to call sellTo method on any target contract
     * @param targetContract The address of the contract to call
     * @param tokenToSell The address of the token to sell
     * @param depositAmount The amount to deposit for selling
     * @param minAmountOut The minimum amount to receive
     */
    function sell(address targetContract, address tokenToSell, uint256 depositAmount, uint256 minAmountOut) external {
        require(targetContract != address(0), "Target contract cannot be zero address");
        require(tokenToSell != address(0), "Token to sell cannot be zero address");
        require(_isContract(targetContract), "Target address is not a contract");
        require(_isContract(tokenToSell), "Token to sell address is not a contract");

        IERC20 _tokenToSell = IERC20(tokenToSell);

        // Transfer tokens from caller to this contract
        _tokenToSell.safeTransferFrom(msg.sender, address(this), depositAmount);

        // Approve target contract to spend tokens to sell
        _tokenToSell.safeIncreaseAllowance(targetContract, depositAmount);

        // Call sellTo(msg.sender, depositAmount, minAmountOut)
        bytes memory callData = abi.encodeWithSelector(
            0xc5b27dde, // sellTo(address,uint256,uint256)
            msg.sender,
            depositAmount,
            minAmountOut
        );

        (bool success, bytes memory returnData) = targetContract.call(callData);

        if (!success) {
            if (returnData.length > 0) {
                assembly {
                    let returndata_size := mload(returnData)
                    revert(add(32, returnData), returndata_size)
                }
            } else {
                revert CallFailed(targetContract, "sellTo call failed or function does not exist");
            }
        }
    }

    function _isContract(address _addr) internal view returns (bool) {
        return _addr.code.length > 0;
    }
}
