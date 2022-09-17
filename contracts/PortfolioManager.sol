// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

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
contract PortfolioManager is Objects, AccessControl, Uniswap {
    /// @notice store which assets
    Order[] internal orders;

    PriceConsumerV3 public priceConsumer;
    // Uniswap public uniswap;

    address public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    bytes32 public constant KEEPER_ROLE = keccak256("KEEPER_ROLE");

    event OrderAdded(address indexed _asset, int256 price);

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
    ) Uniswap(swapRouter) {
        priceConsumer = new PriceConsumerV3(_priceFeeds, _assets);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(KEEPER_ROLE, _keeper);
    }

    function addOrder(
        address _asset,
        OrderType _orderType,
        int256 _price,
        uint256 _amount
    ) external {
        require(
            address(priceConsumer.assetToFeedMapping(_asset)) != address(0),
            "Asset not supported"
        );
        address assetToCharge = _orderType == OrderType.BUY ? weth : _asset;

        require(
            IERC20(assetToCharge).balanceOf(msg.sender) >= _amount,
            "Balance too low"
        );

        require(
            IERC20(assetToCharge).allowance(msg.sender, address(this)) >=
                _amount,
            "No allowance"
        );

        IERC20(assetToCharge).transferFrom(msg.sender, address(this), _amount);

        orders.push(
            Order({
                asset: _asset,
                orderType: _orderType,
                price: _price,
                amount: _amount,
                owner: msg.sender
            })
        );

        emit OrderAdded(_asset, _price);
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

                    OrderType orderType = orders[j].orderType;

                    if (
                        (orderType == OrderType.SELL &&
                            assetPrice >= orderPrice) ||
                        (orderType == OrderType.BUY && assetPrice <= orderPrice)
                    ) {
                        eligibleOrdersIds[pointer] = j;
                        pointer++;
                    }
                }
            }
        }
        return eligibleOrdersIds;
    }

    function executeOrders(uint256[] memory _orders) external {
        require(_orders.length != 0);
        require(hasRole(KEEPER_ROLE, msg.sender), "Only keeper");
        for (uint256 i = 0; i < _orders.length; i++) {
            address tokenIn;
            address tokenOut;

            if (orders[i].orderType == OrderType.BUY) {
                tokenIn = weth;
                tokenOut = orders[i].asset;
            } else {
                tokenIn = orders[i].asset;
                tokenOut = weth;
            }
            swapExactInputSingle(
                uint256(orders[i].amount),
                tokenIn,
                tokenOut,
                orders[i].owner
            );
        }
    }
}
