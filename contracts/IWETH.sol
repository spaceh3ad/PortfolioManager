// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity 0.8.16;

interface IWETH {
    function deposit() external payable;

    function approve(address spender, uint256 amount) external;

    function transfer(address from, uint256 amount) external;

    function balanceOf(address _address) external view returns (uint256);
}
