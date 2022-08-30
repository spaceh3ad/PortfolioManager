// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;
pragma experimental ABIEncoderV2;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

import {PriceConsumerV3} from "./PriceConsumerV3.sol";
import {Objects} from "./Objects.sol";
import {Uniswap} from "./Uniswap.sol";
//
import "hardhat/console.sol";

/// @title PortfoliManager order executor
/// @author spaceh3ad
/// @notice Contract allows to add your tokens and submit orders for them
contract PortfolioManager is Objects, AccessControl {
    /// @notice store which assets
    Order[] internal orders;

    PriceConsumerV3 public priceConsumer;
    Uniswap public uniswap;

    IERC20 public weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    bytes32 public constant KEEPER_ROLE = keccak256("KEEPER_ROLE");

    /// @notice store assets prices
    enum OrderType {
        BUY,
        SELL
    }

    /// @param token `address` of token ex. 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2 (WETH)
    struct Order {
        address asset;
        OrderType orderType;
        int256 price;
        uint256 amount;
        address owner;
    }

    constructor(
        address[] memory _priceFeeds,
        address[] memory _assets,
        address swapRouter,
        address _keeper
    ) {
        priceConsumer = new PriceConsumerV3(_priceFeeds, _assets);
        uniswap = new Uniswap(swapRouter);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(KEEPER_ROLE, _keeper);
    }

    function getOrders() public view returns (Order[] memory) {
        return orders;
    }

    function addOrder(
        address _asset,
        OrderType _orderType,
        int256 _price,
        uint256 _amount
    ) public {
        require(
            priceConsumer.assetToFeedMapping(_asset) != address(0),
            "Asset not supported"
        );
        console.log("asset: ", _asset);
        console.log(
            IERC20(_asset).allowance(msg.sender, address(this)),
            _amount
        );

        // IERC20(_asset).transferFrom(msg.sender, address(this), _amount);

        orders.push(
            Order({
                asset: _asset,
                orderType: _orderType,
                price: _price,
                amount: _amount,
                owner: msg.sender
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
                if (asset == orders[j].asset) {
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
                    console.log("asset: ", asset);
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

    function executeOrders(uint256[] memory _orders) external {
        require(hasRole(KEEPER_ROLE, msg.sender), "Only keeper");
        for (uint256 i = 0; i < _orders.length; i++) {
            address tokenIn;
            address tokenOut;
            if (orders[i].orderType == OrderType.BUY) {
                tokenIn = address(weth);
                tokenOut = orders[i].asset;
            } else {
                tokenIn = orders[i].asset;
                tokenOut = address(weth);
            }
            IERC20(tokenIn).approve(
                address(uniswap),
                uint256(orders[i].amount)
            );
            uniswap.swapExactInputSingle(
                uint256(orders[i].amount),
                tokenIn,
                tokenOut
            );
        }
    }
}
