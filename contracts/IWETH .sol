// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

/// @notice interfejs dla WETH (tokenu wrapped Ethereum)
interface IWETH {
    /// @notice funkcja do depozytu ETH, która zwraca ekwiwalent w tokenie WETH (zwrapowane ETH)
    function deposit() external payable;

    /// @notice funckja zezwalająca adresowi na wydanie pewnej ilości tokenów w imieniu osoby wywołującej tą funkcje
    function approve(address spender, uint256 amount) external;
}
