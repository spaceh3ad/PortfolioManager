// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

/// @notice kontrakt odpowiadający z zarządzanie uprawnieniami
contract AccessControl {
    address immutable keeper;
    address immutable admin;

    /// @notice modifier funkcji zezwalający na wykonanie danej fukcji
    /// @notice tylko i wyłącznie gdy osobą wywołującą jest keeper
    modifier onlyKeeper() {
        require(msg.sender == keeper, "Only keeper");
        _;
    }

    /// @notice modifier funkcji zezwalający na wykonanie danej fukcji
    /// @notice tylko i wyłącznie gdy osobą wywołującą jest administrator
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin");
        _;
    }

    constructor(address _admin, address _keeper) {
        admin = _admin;
        keeper = _keeper;
    }
}
