import { envConfig } from "../config/env";
import { PriceConsumerV3 } from "../typechain/";

export enum OrderType {
  BUY,
  SELL,
}

export async function getOrderPrice(
  priceConsumer: PriceConsumerV3,
  asset: string,
  orderType: OrderType
) {
  let order = 0;
  if (orderType == OrderType.BUY) {
    order = 100;
  } else {
    order = -100;
  }
  const price = +(await priceConsumer.getLatestPrice(asset)) + order;
  return price;
}
