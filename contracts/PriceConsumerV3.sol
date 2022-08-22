// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {Objects} from "./Objects.sol";
import "hardhat/console.sol";

contract PriceConsumerV3 is Objects {
    /// @dev The price feed contract that this consumer uses to get the price of the assets.
    AggregatorV3Interface[] public priceFeeds;

    /// @dev The assets that this consumer is tracking.
    mapping(address => address) public assetToFeedMapping;

    /// @notice save needed pirce feeds addresses
    constructor(address[] memory _priceFeeds, address[] memory _assets) {
        require(_priceFeeds.length == _assets.length, "Data length must match");
        for (uint256 i = 0; i < _priceFeeds.length; i++) {
            priceFeeds.push(AggregatorV3Interface(_priceFeeds[i]));
            assetToFeedMapping[_priceFeeds[i]] = _assets[i];
        }
    }

    /// @notice add data price feed to support additional token
    /// @param _feed address of price feed for binded token
    /// @param _asset address of token
    function addFeed(AggregatorV3Interface _feed, address _asset) internal {
        assetToFeedMapping[address(_feed)] = _asset;
        priceFeeds.push(_feed);
    }

    /// @notice return array of assets info (asset address, price)
    function batchGetter() public view returns (AssetInfo[] memory) {
        AssetInfo[] memory assetsInfo = new AssetInfo[](priceFeeds.length);

        for (uint256 i = 0; i < priceFeeds.length; i++) {
            assetsInfo[i] = AssetInfo({
                asset: assetToFeedMapping[address(priceFeeds[i])],
                price: getLatestPrice(priceFeeds[i])
            });
        }
        return assetsInfo;
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice(AggregatorV3Interface _feed)
        public
        view
        returns (int256)
    {
        (, int256 price, , , ) = _feed.latestRoundData();
        return price;
    }
}
