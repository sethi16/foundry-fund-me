// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

 import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    AggregatorV3Interface private pricefeed;
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    // Could we make this constant?  /* hint: no! We should make it immutable! */
    address public /* immutable */ i_owner;
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;

    constructor(address priceFeedAddress) {
// you must have learnt about casting here the pricefeed is plain we need to convert it into the chainlink AggregatorV3Interface, pricefeed 
// By casting we converted & now one can use that variable which holds the function of the contract belong to the this AggregatorV3InterfacepriceFeed
        pricefeed = AggregatorV3Interface(priceFeedAddress);
// “I promise that the contract at priceFeedAddress follows the Chainlink AggregatorV3Interface rules — like having latestRoundData(), decimals(), etc.”
// Just for checking is it follows the chainlink protocole
// Just sets the location of the price feed
// In case of inheritance, we can directly call the function,
// Here, In importing we need to call the contract.function();
//So, rather than putting AggregatorV3Interface.latestRoundData(pricefeed)
// We actually did is 'pricefeed' holds the function inside value
//So, that we directly call pricefeed.latestRoundData(); 
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate(pricefeed) >= MINIMUM_USD, "You need to spend more ETH!");
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        return pricefeed.version();
    }

    modifier onlyOwner() {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }

    function cheaperwithdraw() public onlyOwner {
        uint256 fundersLength = funders.length; // storage reading & writing cost a lot of gas(x33) times 
        // here we called the storae variable fundersLength only once & stored it in a local variable
        // & we are using local variable fundersLength in the for loop to avoid calling the storage variable fundersLength again & again
        // so we are saving gas here
        for (uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);

        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // call
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \
    //         yes  no
    //         /     \
    //    receive()?  fallback()
    //     /   \
    //   yes   no
    //  /        \
    //receive()  fallback()

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    function getFunderValue(address funder) public view returns (uint256){
        uint value = addressToAmountFunded[funder];
        return value;
    }

    function getFunder(uint index) public view returns (address){
        return funders[index];
    }

    function getOwner() external view returns(address){
        return i_owner; 
    }
}

// Concepts we didn't cover yet (will cover in later sections)
// 1. Enum
// 2. Events
// 3. Try / Catch
// 4. Function Selector
// 5. abi.encode / decode
// 6. Hash with keccak256
// 7. Yul / Assembly
