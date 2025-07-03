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
     * @param _bondingCurve The address of the bonding curve contract to call
     * @param _collateralToken The address of the collateral token to use for buying
     * @param _depositAmount The amount to deposit for buying
     * @param _minAmountOut The minimum amount to receive
     */
    function buy(address _bondingCurve, address _collateralToken, uint256 _depositAmount, uint256 _minAmountOut)
        external
    {
        require(_bondingCurve != address(0), "Target contract cannot be zero address");
        require(_collateralToken != address(0), "Collateral token cannot be zero address");
        require(_isContract(_bondingCurve), "Target address is not a contract");
        require(_isContract(_collateralToken), "Collateral token address is not a contract");

        IERC20 collateralToken = IERC20(_collateralToken);

        // Transfer collateral tokens from caller to this contract
        collateralToken.safeTransferFrom(msg.sender, address(this), _depositAmount);

        // Approve target contract to spend collateral tokens
        collateralToken.safeIncreaseAllowance(_bondingCurve, _depositAmount);

        // Call buyFor(msg.sender, _depositAmount, _minAmountOut)
        bytes memory callData = abi.encodeWithSelector(
            0x935b7dbd, // buyFor(address,uint256,uint256)
            msg.sender,
            _depositAmount,
            _minAmountOut
        );

        (bool success, bytes memory returnData) = _bondingCurve.call(callData);

        if (!success) {
            if (returnData.length > 0) {
                assembly {
                    let returndata_size := mload(returnData)
                    revert(add(32, returnData), returndata_size)
                }
            } else {
                revert CallFailed(_bondingCurve, "buyFor call failed or function does not exist");
            }
        }

        require(collateralToken.balanceOf(address(this)) == 0, "Collateral tokens not fully consumed");
    }

    /**
     * @dev Proxy function to call sellTo method on any target contract
     * @param _bondingCurve The address of the bonding curve contract to call
     * @param _tokenToSell The address of the token to sell
     * @param _depositAmount The amount to deposit for selling
     * @param _minAmountOut The minimum amount to receive
     */
    function sell(address _bondingCurve, address _tokenToSell, uint256 _depositAmount, uint256 _minAmountOut)
        external
    {
        require(_bondingCurve != address(0), "Target contract cannot be zero address");
        require(_tokenToSell != address(0), "Token to sell cannot be zero address");
        require(_isContract(_bondingCurve), "Target address is not a contract");
        require(_isContract(_tokenToSell), "Token to sell address is not a contract");

        IERC20 tokenToSell = IERC20(_tokenToSell);

        // Transfer tokens from caller to this contract
        tokenToSell.safeTransferFrom(msg.sender, address(this), _depositAmount);

        // Approve target contract to spend tokens to sell
        tokenToSell.safeIncreaseAllowance(_bondingCurve, _depositAmount);

        // Call sellTo(msg.sender, _depositAmount, _minAmountOut)
        bytes memory callData = abi.encodeWithSelector(
            0xc5b27dde, // sellTo(address,uint256,uint256)
            msg.sender,
            _depositAmount,
            _minAmountOut
        );

        (bool success, bytes memory returnData) = _bondingCurve.call(callData);

        if (!success) {
            if (returnData.length > 0) {
                assembly {
                    let returndata_size := mload(returnData)
                    revert(add(32, returnData), returndata_size)
                }
            } else {
                revert CallFailed(_bondingCurve, "sellTo call failed or function does not exist");
            }
        }

        require(tokenToSell.balanceOf(address(this)) == 0, "Tokens not fully consumed");
    }

    function _isContract(address _addr) internal view returns (bool) {
        return _addr.code.length > 0;
    }
}
