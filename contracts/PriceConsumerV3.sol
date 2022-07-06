// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceConsumerV3 {
    AggregatorV3Interface[] internal priceFeeds;
    mapping(address => address) public assetToFeedMapping;

    struct AssetInfo {
        address asset;
        int256 price;
    }

    /// @notice save needed pirce feeds addresses
    constructor(address[] memory _priceFeeds, address[] memory _assets) {
        require(_priceFeeds.length == _assets.length, "Data length must match");
        for (uint256 i = 0; i < _priceFeeds.length; i++) {
            priceFeeds[i] = AggregatorV3Interface(_priceFeeds[i]);
            assetToFeedMapping[_priceFeeds[i]] = _assets[i];
        }
    }

    function addFeed(AggregatorV3Interface _feed, address _asset) internal {
        assetToFeedMapping[address(_feed)] = _asset;
        priceFeeds.push(_feed);
    }

    function batchGetter() public view returns (AssetInfo[] memory) {
        AssetInfo[] memory assetsInfo;
        for (uint256 i = 0; i < priceFeeds.length; i++) {
            assetsInfo[i].price = getLatestPrice(priceFeeds[i]);
            assetsInfo[i].asset = assetToFeedMapping[address(priceFeeds[i])];
        }
        return assetsInfo;
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice(AggregatorV3Interface _feed)
        internal
        view
        returns (int256)
    {
        (
            ,
            /*uint80 roundID*/
            int256 price, /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/
            ,
            ,

        ) = _feed.latestRoundData();
        return price;
    }
}
