# PortfolioManager

*spaceh3ad*

> PortfoliManager order executor

Contract allows to add your tokens and submit orders for them



## Methods

### DEFAULT_ADMIN_ROLE

```solidity
function DEFAULT_ADMIN_ROLE() external view returns (bytes32)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### KEEPER_ROLE

```solidity
function KEEPER_ROLE() external view returns (bytes32)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### addOrder

```solidity
function addOrder(address _asset, enum PortfolioManager.OrderType _orderType, int256 _price, uint256 _amount) external nonpayable
```

allows adding order if the asset is supported



#### Parameters

| Name | Type | Description |
|---|---|---|
| _asset | address | the asset that we want to place order for |
| _orderType | enum PortfolioManager.OrderType | can be either buy or sell |
| _price | int256 | price that meets our order |
| _amount | uint256 | of asset that we want to buy/sell |

### executeOrders

```solidity
function executeOrders(uint256[] _orders) external nonpayable
```

executes the orderscan be only called by keeperorders can be null



#### Parameters

| Name | Type | Description |
|---|---|---|
| _orders | uint256[] | that are eligble for execution |

### getEligibleOrders

```solidity
function getEligibleOrders() external view returns (uint256[])
```

returns orders that are eligble for execution




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256[] | undefined |

### getRoleAdmin

```solidity
function getRoleAdmin(bytes32 role) external view returns (bytes32)
```



*Returns the admin role that controls `role`. See {grantRole} and {revokeRole}. To change a role&#39;s admin, use {_setRoleAdmin}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| role | bytes32 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### grantRole

```solidity
function grantRole(bytes32 role, address account) external nonpayable
```



*Grants `role` to `account`. If `account` had not been already granted `role`, emits a {RoleGranted} event. Requirements: - the caller must have ``role``&#39;s admin role. May emit a {RoleGranted} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| role | bytes32 | undefined |
| account | address | undefined |

### hasRole

```solidity
function hasRole(bytes32 role, address account) external view returns (bool)
```



*Returns `true` if `account` has been granted `role`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| role | bytes32 | undefined |
| account | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### poolFee

```solidity
function poolFee() external view returns (uint24)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint24 | undefined |

### priceConsumer

```solidity
function priceConsumer() external view returns (contract PriceConsumerV3)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract PriceConsumerV3 | undefined |

### renounceRole

```solidity
function renounceRole(bytes32 role, address account) external nonpayable
```



*Revokes `role` from the calling account. Roles are often managed via {grantRole} and {revokeRole}: this function&#39;s purpose is to provide a mechanism for accounts to lose their privileges if they are compromised (such as when a trusted device is misplaced). If the calling account had been revoked `role`, emits a {RoleRevoked} event. Requirements: - the caller must be `account`. May emit a {RoleRevoked} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| role | bytes32 | undefined |
| account | address | undefined |

### revokeRole

```solidity
function revokeRole(bytes32 role, address account) external nonpayable
```



*Revokes `role` from `account`. If `account` had been granted `role`, emits a {RoleRevoked} event. Requirements: - the caller must have ``role``&#39;s admin role. May emit a {RoleRevoked} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| role | bytes32 | undefined |
| account | address | undefined |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool)
```



*See {IERC165-supportsInterface}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| interfaceId | bytes4 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

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

### weth

```solidity
function weth() external view returns (address)
```

address of weth token




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |



## Events

### OrderAdded

```solidity
event OrderAdded(address indexed _asset, int256 price)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _asset `indexed` | address | undefined |
| price  | int256 | undefined |

### RoleAdminChanged

```solidity
event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| role `indexed` | bytes32 | undefined |
| previousAdminRole `indexed` | bytes32 | undefined |
| newAdminRole `indexed` | bytes32 | undefined |

### RoleGranted

```solidity
event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| role `indexed` | bytes32 | undefined |
| account `indexed` | address | undefined |
| sender `indexed` | address | undefined |

### RoleRevoked

```solidity
event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| role `indexed` | bytes32 | undefined |
| account `indexed` | address | undefined |
| sender `indexed` | address | undefined |



