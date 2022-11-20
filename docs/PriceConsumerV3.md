# PriceConsumerV3









## Methods

### assetToFeedMapping

```solidity
function assetToFeedMapping(address) external view returns (contract AggregatorV3Interface)
```



*The assets that this consumer is tracking.*

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
function batchGetter() external view returns (struct Objects.AssetInfo[])
```

batch update all prices for supported assets




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | Objects.AssetInfo[] | array of assets info (asset address, price) |

### decimals

```solidity
function decimals(contract AggregatorV3Interface _feed) external view returns (uint8)
```

function for retireval of decimals for token



#### Parameters

| Name | Type | Description |
|---|---|---|
| _feed | contract AggregatorV3Interface | address of data feed |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint8 | decimals of asset |

### getLatestPrice

```solidity
function getLatestPrice(contract AggregatorV3Interface _feed) external view returns (int256)
```

returns the latest price for given feed



#### Parameters

| Name | Type | Description |
|---|---|---|
| _feed | contract AggregatorV3Interface | address of data feed |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | int256 | price of an asset |

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




