// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {Objects} from "./Objects.sol";

contract PriceConsumerV3 is Objects {
    address[] public supportedAssets;

    /// @dev The assets that this consumer is tracking.

    // TODO fix mapping
    mapping(address => AggregatorV3Interface) public assetToFeedMapping;

    /// @notice save needed pirce feeds addresses
    constructor(address[] memory _priceFeeds, address[] memory _assets) {
        require(_priceFeeds.length == _assets.length, "Data length must match");
        for (uint256 i = 0; i < _assets.length; i++) {
            supportedAssets.push(_assets[i]);
            assetToFeedMapping[_assets[i]] = AggregatorV3Interface(
                _priceFeeds[i]
            );
        }
    }

    /// @notice add data price feed to support additional token
    /// @param _feed address of price feed for binded token
    /// @param _asset address of token
    function addFeed(AggregatorV3Interface _feed, address _asset) internal {
        assetToFeedMapping[_asset] = AggregatorV3Interface(_feed);
        supportedAssets.push(_asset);
    }

    /// @notice return array of assets info (asset address, price)
    function batchGetter() public view returns (AssetInfo[] memory) {
        AssetInfo[] memory assetsInfo = new AssetInfo[](supportedAssets.length);

        for (uint256 i = 0; i < supportedAssets.length; i++) {
            assetsInfo[i] = AssetInfo({
                asset: supportedAssets[i],
                price: getLatestPrice(
                    AggregatorV3Interface(
                        assetToFeedMapping[supportedAssets[i]]
                    )
                )
            });
        }
        require(assetsInfo.length > 0, "Feed returned no data");
        return assetsInfo;
    }

    function decimals(AggregatorV3Interface _feed) public view returns (uint8) {
        return _feed.decimals();
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
