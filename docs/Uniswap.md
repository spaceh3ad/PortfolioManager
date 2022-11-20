# Uniswap









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

swapExactInputSingle swaps a fixed amount of tokenIn for a maximum possible amount of tokenOut

*The calling address must approve this contract to spend at least `amountIn`*

#### Parameters

| Name | Type | Description |
|---|---|---|
| amountIn | uint256 | The exact amount of tokenIn that will be swapped for tokenOut |
| tokenIn | address | The token that we pay in |
| tokenOut | address | The token that will be received |
| recipient | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| amountOut | uint256 | The amount of WETH9 received. |

### swapRouter

```solidity
function swapRouter() external view returns (contract ISwapRouter)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract ISwapRouter | undefined |




