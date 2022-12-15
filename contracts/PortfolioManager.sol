// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

import {PriceConsumerV3} from "./PriceConsumerV3.sol";
import {AssetInfo} from "./Objects.sol";
import {Uniswap} from "./Uniswap.sol";

/// @title Menadżer Portfolia
/// @author Jan KwiatkowskiswapExactInputSingle
/// @notice inteligentny kontrakt pozwalający na składanie zleceń na dane tokeny
contract PortfolioManager is AccessControl, Uniswap {
    /// @notice tablica zleceń
    Order[] internal orders;

    /// @notice kontrakt dostarczajacy dane o cenach tokenów
    PriceConsumerV3 public priceConsumer;

    /// @notice adres tokenu Wrapped Ethereum
    address public weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    /// @notice hasz roli KEEPER_ROLE
    bytes32 public constant KEEPER_ROLE = keccak256("KEEPER_ROLE");

    /// @notice event dla dodania zlecenia
    event OrderAdded(address indexed _asset, int256 price);

    /// @notice enumeracja typów zleceń
    enum OrderType {
        BUY,
        SELL
    }

    /// @notice struktura zlecenia
    struct Order {
        address asset;
        OrderType orderType;
        int256 price;
        uint256 amount;
        address owner;
    }

    /// @notice konstruktor inicjalizujący wspierane tokeny, dostarczycieli danych o cenie tych tokenów oraz kotrakt do wymiany tokenów (Uniswap)
    /// @param _priceFeeds adresy kontraktów dostarczających dane o cenach tokenów
    /// @param _assets adresy wspierancych tokenów
    /// @param swapRouter adres routera do wymiany tokenów
    /// @param _keeper adres keepera do wykonywania zleceń
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

    /// @notice funkcja pozwalająca na dodawanie zleceń
    /// @param _asset adres tokenu którego dotyczy zlecenie
    /// @param _orderType typ zlecenia kupno/sprzedaż
    /// @param _price cena realizacji zlecenia
    /// @param _amount ilość tokenów które chcemy kupić/sprzedać
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

    /// @notice funkcja pomocnicza zwracająca ilość zleceń
    function getOrderRange(
        AssetInfo[] memory assetsInfo
    ) internal view returns (uint256) {
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

    /// @notice zwraca zlecenia które kwalifikuja się do wykonania
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

    /// @notice funkcja wykonująca zlecenia przekazane w tabeli
    /// @param _orders zlecenia kwalifikujące się do wykonania
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
