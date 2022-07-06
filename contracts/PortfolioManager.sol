// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// KeeperCompatible.sol imports the functions from both ./KeeperBase.sol and
// ./interfaces/KeeperCompatibleInterface.sol

import {PriceConsumerV3} from "./PriceConsumerV3.sol";
import "hardhat/console.sol";

/// @title PortfoliManager order executor
/// @author spaceh3ad
/// @notice Contract allows to add your tokens and submit orders for them
contract PortfolioManager is PriceConsumerV3 {
    /// @notice store which assets
    mapping(address => Orders) internal userOrdersMapping;

    address[] public userAddresses;

    /// @notice store assets prices
    // mapping(address => uint256) public assetPrices;

    enum OrderType {
        SELL,
        BUY
    }

    /// @param token `address` of token ex. 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2 (WETH)
    struct Order {
        address asset;
        OrderType orderType;
        int256 price;
    }

    struct Orders {
        Order[] orders;
    }

    constructor(address[] memory _priceFeeds, address[] memory _assets)
        PriceConsumerV3(_priceFeeds, _assets)
    {}

    function getEligibleOrders() public view {
        /// get prices for tracking assets
        AssetInfo[] memory assetsInfo = batchGetter();
        // uint

        for (uint256 i = 0; i < assetsInfo.length; i++) {
            address asset = assetsInfo[i].asset;
            int256 assetPrice = assetsInfo[i].price;
            for (uint256 j = 0; j < userAddresses.length; j++) {
                int256 orderPrice = userOrdersMapping[userAddresses[i]].price;
                address orderAsset = userOrdersMapping[userAddresses[i]].asset;
                OrderType orderType = userOrdersMapping[userAddresses[i]]
                    .orderType;
                if (orderAsset == asset) {
                    if (
                        orderType == OrderType.SELL && assetPrice >= orderPrice
                    ) {}
                }
            }
        }
    }
}
