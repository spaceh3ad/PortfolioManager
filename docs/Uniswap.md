# Uniswap





kontrakt odpowiadający za wymianę tokenów



## Methods

### poolFee

```solidity
function poolFee() external view returns (uint24)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint24 | undefined |

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




