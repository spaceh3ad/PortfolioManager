# PriceConsumerV3





kontrakt odpowiadający za dostarczanie informacji o tokenach oraz pozwalający na dodawanie wsparcia dla nowych tokenów



## Methods

### assetToFeedMapping

```solidity
function assetToFeedMapping(address) external view returns (contract AggregatorV3Interface)
```

hasz mapa adresów tokenów do kontraków dostarczających informacji o ich cenie



#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract AggregatorV3Interface | undefined |

### batchGetter

```solidity
function batchGetter() external view returns (struct AssetInfo[])
```

grupowo zaktualizuj infomację o cenach wspieranych tokenów




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | AssetInfo[] | undefined |

### getLatestPrice

```solidity
function getLatestPrice(contract AggregatorV3Interface _feed) external view returns (int256)
```

funkcja zwracająca najnowszą cene



#### Parameters

| Name | Type | Description |
|---|---|---|
| _feed | contract AggregatorV3Interface | adres kontraktu dostarczającego dane o tokenie |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | int256 | undefined |

### supportedAssets

```solidity
function supportedAssets(uint256) external view returns (address)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |




