// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {AssetInfo} from "./Objects.sol";

/// @notice kontrakt odpowiadający za dostarczanie informacji o tokenach
contract PriceConsumerV3 {
    address[] public supportedAssets;

    /// @notice hasz mapa adresów tokenów do kontraków dostarczających informacji o ich cenie
    mapping(address => AggregatorV3Interface) public assetToFeedMapping;

    /// @notice konstruktor inicjalizujący wspierane tokeny i kontrakty dostarczające dane o ich cenie
    /// @param _priceFeeds adresy kontraktów dostarczających dane o cenach tokenów
    /// @param _assets adresy wspierancych tokenów
    constructor(address[] memory _priceFeeds, address[] memory _assets) {
        for (uint256 i = 0; i < _assets.length; i++) {
            supportedAssets.push(_assets[i]);
            assetToFeedMapping[_assets[i]] = AggregatorV3Interface(
                _priceFeeds[i]
            );
        }
    }

    /// @notice grupowo zaktualizuj infomację o cenach wspieranych tokenów
    function batchGetter() external view returns (AssetInfo[] memory) {
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
        return assetsInfo;
    }

    /// @notice funkcja zwracająca najnowszą cene
    /// @param _feed adres kontraktu dostarczającego dane o tokenie
    function getLatestPrice(
        AggregatorV3Interface _feed
    ) public view returns (int256) {
        (, int256 price, , , ) = _feed.latestRoundData();
        return price;
    }
}
