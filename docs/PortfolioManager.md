# PortfolioManager

*Jan Kwiatkowski*

> Menadżer Portfolia

inteligentny kontrakt pozwalający na składanie zleceń na dane tokeny



## Methods

### POOL_FEE

```solidity
function POOL_FEE() external view returns (uint24)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint24 | undefined |

### addOrder

```solidity
function addOrder(address _asset, enum PortfolioManager.OrderType _orderType, int256 _price, uint256 _amount) external nonpayable
```

funkcja pozwalająca na dodawanie zleceń



#### Parameters

| Name | Type | Description |
|---|---|---|
| _asset | address | adres tokenu którego dotyczy zlecenie |
| _orderType | enum PortfolioManager.OrderType | typ zlecenia kupno/sprzedaż |
| _price | int256 | cena realizacji zlecenia |
| _amount | uint256 | ilość tokenów które chcemy kupić/sprzedać |

### executeOrders

```solidity
function executeOrders(uint256[] _orders) external nonpayable
```

funkcja wykonująca zlecenia przekazane w tabeli



#### Parameters

| Name | Type | Description |
|---|---|---|
| _orders | uint256[] | zlecenia kwalifikujące się do wykonania |

### getEligibleOrders

```solidity
function getEligibleOrders() external view returns (uint256[])
```

zwraca zlecenia które kwalifikuja się do wykonania




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256[] | undefined |

### priceConsumer

```solidity
function priceConsumer() external view returns (contract PriceConsumerV3)
```

kontrakt dostarczajacy dane o cenach tokenów




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract PriceConsumerV3 | undefined |

### swapExactInputSingle

```solidity
function swapExactInputSingle(uint256 amountIn, address tokenIn, address tokenOut, address recipient) external nonpayable returns (uint256 amountOut)
```

funkcja wymieniająca jedne tokeny na drugie



#### Parameters

| Name | Type | Description |
|---|---|---|
| amountIn | uint256 | dokładna ilość tokenu wchodzącego, mającego być zamieniony na token wychodzący |
| tokenIn | address | token który sprzedajemy |
| tokenOut | address | token który kupujemy |
| recipient | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| amountOut | uint256 | undefined |

### swapRouter

```solidity
function swapRouter() external view returns (contract ISwapRouter)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract ISwapRouter | undefined |



## Events

### OrderAdded

```solidity
event OrderAdded(address indexed _asset, int256 price)
```

event dla dodania zlecenia



#### Parameters

| Name | Type | Description |
|---|---|---|
| _asset `indexed` | address | undefined |
| price  | int256 | undefined |



