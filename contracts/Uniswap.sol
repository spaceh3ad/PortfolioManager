// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.16;
pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract Uniswap {
    // https://docs.uniswap.org/protocol/guides/swaps/single-swaps#a-complete-single-swap-contract

    ISwapRouter public immutable swapRouter;

    // For this example, we will set the pool fee to 0.3%.
    uint24 public constant poolFee = 3000;

    constructor(address _swapRouter) {
        swapRouter = ISwapRouter(_swapRouter);
    }

    /// @notice swapExactInputSingle swaps a fixed amount of tokenIn for a maximum possible amount of tokenOut
    /// @dev The calling address must approve this contract to spend at least `amountIn`
    /// @param amountIn The exact amount of tokenIn that will be swapped for tokenOut
    /// @param tokenIn The token that we pay in
    /// @param tokenOut The token that will be received
    /// @return amountOut The amount of WETH9 received.
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
                fee: poolFee,
                recipient: recipient,
                deadline: block.timestamp + 100,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = swapRouter.exactInputSingle(params);
    }
}
