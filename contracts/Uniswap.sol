// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.16;
pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

/// @notice kontrakt odpowiadający za wymianę tokenów
contract Uniswap {
    // https://docs.uniswap.org/protocol/guides/swaps/single-swaps#a-complete-single-swap-contract

    ISwapRouter public immutable swapRouter;

    uint24 public constant POOL_FEE = 3000;

    constructor(address _swapRouter) {
        swapRouter = ISwapRouter(_swapRouter);
    }

    /// @notice funkcja wymieniająca jedne tokeny na drugie
    /// @param amountIn dokładna ilość tokenu wchodzącego, mającego być zamieniony na token wychodzący
    /// @param tokenIn token który sprzedajemy
    /// @param tokenOut token który kupujemy
    function swapExactInputSingle(
        uint256 amountIn,
        address tokenIn,
        address tokenOut,
        address recipient
    ) public returns (uint256 amountOut) {
        TransferHelper.safeApprove(tokenIn, address(swapRouter), amountIn);
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: POOL_FEE,
                recipient: recipient,
                deadline: block.timestamp + 100,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = swapRouter.exactInputSingle(params);
    }
}
