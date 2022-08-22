// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;
pragma experimental ABIEncoderV2;

// KeeperCompatible.sol imports the functions from both ./KeeperBase.sol and
// ./interfaces/KeeperCompatibleInterface.sol

import {PriceConsumerV3} from "./PriceConsumerV3.sol";
import {Objects} from "./Objects.sol";

import "hardhat/console.sol";

/// @title PortfoliManager order executor
/// @author spaceh3ad
/// @notice Contract allows to add your tokens and submit orders for them
contract PortfolioManager is Objects {
    /// @notice store which assets
    Order[] internal orders;

    PriceConsumerV3 public priceConsumer;

    /// @notice store assets prices
    enum OrderType {
        SELL,
        BUY
    }

    /// @param token `address` of token ex. 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2 (WETH)
    struct Order {
        address asset;
        OrderType orderType;
        int256 price;
        int256 amount;
    }

    constructor(address[] memory _priceFeeds, address[] memory _assets) {
        priceConsumer = new PriceConsumerV3(_priceFeeds, _assets);
    }

    function getOrders() public view returns (Order[] memory) {
        return orders;
    }

    function addOrder(
        address _asset,
        OrderType _orderType,
        int256 _price,
        int256 _amount
    ) public {
        // TODO: check if asset is in the list of assets
        // TODO: if SELL order then check if user has asset

        orders.push(
            Order({
                asset: _asset,
                orderType: _orderType,
                price: _price,
                amount: _amount
            })
        );
    }

    function getOrderRange(AssetInfo[] memory assetsInfo)
        internal
        view
        returns (uint256)
    {
        uint256 counter = 0;
        for (uint256 i = 0; i < assetsInfo.length; i++) {
            address asset = assetsInfo[i].asset;
            int256 assetPrice = assetsInfo[i].price;
            for (uint256 j = 0; j < orders.length; j++) {
                console.log(asset, orders[j].asset);
                if (asset == orders[j].asset) {
                    console.log("ELDO");
                    int256 orderPrice = orders[j].price;
                    OrderType orderType = orders[j].orderType;
                    if (
                        (orderType == OrderType.SELL &&
                            assetPrice >= orderPrice) ||
                        (orderType == OrderType.BUY && assetPrice <= orderPrice)
                    ) {
                        counter++;
                    }
                }
            }
        }
        return counter;
    }

    /// @notice returns `EligibleOrders[]` orders
    function getEligibleOrders() public view returns (uint256[] memory) {
        /// get prices for tracking assets
        AssetInfo[] memory assetsInfo = priceConsumer.batchGetter();
        uint256[] memory eligibleOrdersIds = new uint256[](
            getOrderRange(assetsInfo)
        );

        uint256 pointer = 0;

        for (uint256 i = 0; i < assetsInfo.length; i++) {
            address asset = assetsInfo[i].asset;
            int256 assetPrice = assetsInfo[i].price;
            for (uint256 j = 0; j < orders.length; j++) {
                if (asset == orders[j].asset) {
                    int256 orderPrice = orders[j].price;
                    console.log(
                        "assetPrice: ",
                        uint256(assetPrice),
                        "orderPrice: ",
                        uint256(orderPrice)
                    );
                    OrderType orderType = orders[j].orderType;
                    if (
                        (orderType == OrderType.SELL &&
                            assetPrice >= orderPrice) ||
                        (orderType == OrderType.BUY && assetPrice <= orderPrice)
                    ) {
                        console.log("orderId: ", j);
                        eligibleOrdersIds[pointer] = j;
                        pointer++;
                    }
                }
            }
        }
        return eligibleOrdersIds;
    }
}