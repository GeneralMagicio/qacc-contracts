// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title MockBondingCurve
 * @dev A mock contract that implements the buyFor and sellTo functions for testing
 */
contract MockBondingCurve {
    using SafeERC20 for IERC20;

    event BuyForCalled(address buyer, uint256 depositAmount, uint256 minAmountOut);
    event SellToCalled(address seller, uint256 depositAmount, uint256 minAmountOut);

    IERC20 public collateralToken;
    IERC20 public tokenToSell;

    /**
     * @dev Constructor to set the collateral token and token to sell
     * @param _collateralToken The address of the collateral token
     * @param _tokenToSell The address of the token to sell
     */
    constructor(address _collateralToken, address _tokenToSell) {
        collateralToken = IERC20(_collateralToken);
        tokenToSell = IERC20(_tokenToSell);
    }

    /**
     * @dev Mock buyFor function that just emits an event
     * @param _buyer The address of the buyer
     * @param _depositAmount The amount to deposit for buying
     * @param _minAmountOut The minimum amount to receive
     */
    function buyFor(address _buyer, uint256 _depositAmount, uint256 _minAmountOut) external {
        collateralToken.safeTransferFrom(msg.sender, address(this), _depositAmount);
        tokenToSell.safeTransfer(_buyer, _minAmountOut); // Mock transfer of token to sell
        emit BuyForCalled(_buyer, _depositAmount, _minAmountOut);
        // Mock successful execution
    }

    /**
     * @dev Mock sellTo function that just emits an event
     * @param _seller The address of the seller
     * @param _depositAmount The amount to deposit for selling
     * @param _minAmountOut The minimum amount to receive
     */
    function sellTo(address _seller, uint256 _depositAmount, uint256 _minAmountOut) external {
        tokenToSell.safeTransferFrom(msg.sender, address(this), _depositAmount);
        collateralToken.safeTransfer(_seller, _minAmountOut); // Mock transfer of collateral token
        emit SellToCalled(_seller, _depositAmount, _minAmountOut);
    }
}
