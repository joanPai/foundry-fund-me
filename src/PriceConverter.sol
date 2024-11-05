// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) public view returns (uint) {
        (, int price, , , ) = priceFeed.latestRoundData();
        return uint(price * 1e10);
    }

    function getConversionRate(
        uint _ethAmount,
        AggregatorV3Interface priceFeed
    ) public view returns (uint) {
        uint ethPrice = getPrice(priceFeed);
        uint ethAmountInUsd = (_ethAmount * ethPrice) / 1e18;
        return ethAmountInUsd;
    }
}
