# IWETH





interfejs dla WETH (tokenu wrapped Ethereum)



## Methods

### approve

```solidity
function approve(address spender, uint256 amount) external nonpayable
```

funckja zezwalająca adresowi na wydanie pewnej ilości tokenów w imieniu osoby wywołującej tą funkcje



#### Parameters

| Name | Type | Description |
|---|---|---|
| spender | address | undefined |
| amount | uint256 | undefined |

### deposit

```solidity
function deposit() external payable
```

funkcja do depozytu ETH, która zwraca ekwiwalent w tokenie WETH (zwrapowane ETH)







