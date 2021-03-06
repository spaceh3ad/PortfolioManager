// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// KeeperCompatible.sol imports the functions from both ./KeeperBase.sol and
// ./interfaces/KeeperCompatibleInterface.sol
import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import {IPortfolioManager} from "./PortfolioManager.sol";

contract Keeper is KeeperCompatibleInterface {
    /**
     * Use an interval in seconds and a timestamp to slow execution of Upkeep
     */
    uint256 public immutable interval;
    uint256 public lastTimeStamp;

    IPortfolioManager public portfolio;

    constructor(uint256 updateInterval, IPortfolioManager _portfolio) {
        portfolio = IPortfolioManager(_portfolio);
        interval = updateInterval;
        lastTimeStamp = block.timestamp;
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        (bool, bytes) = portfolio.checkUpkeep();
    }

    function performUpkeep(
        bytes calldata /* performData */
    ) external override {
        //We highly recommend revalidating the upkeep in the performUpkeep function
        if ((block.timestamp - lastTimeStamp) > interval) {
            lastTimeStamp = block.timestamp;
            latestETHPrice = priceConsumer.getLatestPrice();
        }
        // We don't use the performData in this example. The performData is generated by the Keeper's call to your checkUpkeep function
    }
}
