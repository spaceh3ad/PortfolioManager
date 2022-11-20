// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

/// @notice this is contract interface for WETH (wrapped ETH)
/// @notice turn ETH into token
interface IWETH {
    /// @notice deposit ETH to receive WETH
    function deposit() external payable;

    /// @notice allows approving someone to spend on your behalf
    function approve(address spender, uint256 amount) external;
}
