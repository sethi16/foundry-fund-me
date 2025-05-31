// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address user;
    uint256 transferFund = 6 ether;
    uint256 send = 0.1 ether;   
    uint256 constant GAS = 1;
    

    modifier funded(){
        vm.prank(user);
        fundMe.fund{value: transferFund}();
        assert(address(fundMe).balance>0); // assert hold the conditions & checks if the condition is true or not
        _; // while assertEq is used to check if two values are equal or not
    }
    
    function setUp() public {
        HelperConfig config = new HelperConfig();
        user = makeAddr("user");
        vm.deal(user, 99 ether); // Give user 9 ether
        address priceFeed = config.activeNetworkConfig();
        fundMe = new FundMe(priceFeed); // Pass the real price feed address
    }

    function testOwnerIsMsgSender() public {
        console.log("Minimum USD", fundMe.MINIMUM_USD());
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testsender() public {
        console.log("Owner is", fundMe.i_owner());
        assertEq(fundMe.i_owner(), address(this));
    }

    function testVersion() public {
        uint256 version = fundMe.getVersion();
        console.log("Version", version);
        assertEq(version, 4);
    }
    function fundfailcheck() public {
        vm.expectRevert(); // revert if not enough ETH sent
        fundMe.fund{value: 2 ether}();
    }
    function fundmefunction() public {
        vm.prank(user);
        fundMe.fund{value: transferFund}();
        uint256 AddressToAmountFunded = fundMe.addressToAmountFunded(user);  
        assertEq(AddressToAmountFunded, transferFund);
    }
    function testAddsFunderToArrayOfFunders() public funded(){
        address fundry = fundMe.getFunder(0); // this hold address of the first funder
        assertEq(fundry, user); // Remember, no need to write msg.sender or address(this)
        // when we have vm.prank(user) because this hold the address of the user
// we need to use vm.prank(user) againa & again after every usecase like this funding or withdraw
        vm.prank(user);
        fundMe.fund{value: transferFund}();
        address fundry2 = fundMe.getFunder(1); // this hold address of the second funder
        assertEq(fundry2, user); // here we are checking if the funder is same as the user, wo funded
    }
    function testWithdrawFromMultipleFunders() public {
        // Arrange
            uint160 indexOfFunders = 0;
            uint160 i; // Declare the variable 'i'
            indexOfFunders = i;
            uint160 numberOfFunders=10;
            uint256 startingfundingbalance = address(fundMe).balance;
            uint256 startingownerbalance = fundMe.getOwner().balance;    
            for (i = 0; i < numberOfFunders; i++) {
                hoax(address(i), send); // Create a new address and send 10 ether to it
                                            // hoax() is a combination of vm.startPrank() and vm.deal()
                fundMe.fund{value: send}(); // here i called many address to fund, all the address will be funded
            }
            // Act
                uint256 gasStart = gasleft(); // gasleft() it's a predefined dunction in forge std library
                vm.txGasPrice(GAS);
                vm.startPrank(fundMe.getOwner()); // here i called the owner of the fundMe contract
                fundMe.cheaperwithdraw(); // here i called the withdraw function

                uint256 gasEnd = gasleft();
                uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
                console.log("gasUsed", gasUsed); 

                assertEq(address(fundMe).balance, 0); // here i checked if the balance of fundMe is 0 or not
                vm.stopPrank();
               //Assert
                uint256 endingfundMeBalance = address(fundMe).balance;
                uint256 endingownerbalance  = fundMe.getOwner().balance;
                assert(endingownerbalance == startingfundingbalance + startingownerbalance); 
                assertEq(numberOfFunders * send , endingownerbalance - startingownerbalance); 
                // here i checked if the balance of funder is same as the number of funders
                assertEq(fundMe.getFunderValue(address(i)), transferFund);
            }

           
        }
    

