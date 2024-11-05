// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
get funds
withdrawfunds
min investment of 5$
*/
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__notOwner();

contract FundMe {
    using PriceConverter for uint;

    uint public constant MINIMUM_USD = 5e18;
    address[] private s_funders;
    mapping(address funder => uint amountFunded) private s_addressToAmountFunded;
    AggregatorV3Interface public s_priceFeed;
    address public immutable i_owner;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) > MINIMUM_USD,
            "Please send more eth"
        );
        //  require(getConversionRate(msg.value) ;
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] =
            s_addressToAmountFunded[msg.sender] +
            msg.value;
    }

    function getVersion() public view returns (uint) {
        return s_priceFeed.version();
    }

      function cheaperWithdraw() public onlyOwner {
        uint fundersLength = s_funders.length;
        for (
            uint funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "call failed");
    }

    function withdraw() public onlyOwner {
        for (
            uint funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "call failed");
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMe__notOwner();
        }
        //require(msg.sender == owner, "sender is not owner");
        _;
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    //view and pure function getter
    function getAddressToAmountfunded(
        address fundedAddress
    ) public view returns (uint) {
        return s_addressToAmountFunded[fundedAddress];
    }

    function getFunder(uint index) public view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
