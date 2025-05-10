//SPDX-LISCENSED-Identifier: MIT

pragma solidity ^0.8.18;

import{Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.t.sol";

contract HelperConfig is Script {

    uint8 public constant Decimal=18;
    int256 public constant InitialAnswer=4000e8;
    struct NetworkConfig{
        address priceFeed;  
    }
        NetworkConfig public activeNetworkConfig;

        constructor(){
            if(block.chainid == 11155111){
                activeNetworkConfig = SepoliaConfig();
                }
                else if(block.chainid == 1){
                    activeNetworkConfig = ethConfig();
                }
                else{
                    activeNetworkConfig = testConfig();
                }
        } 
        function SepoliaConfig() public pure returns(NetworkConfig memory){
             NetworkConfig memory Sepolia=NetworkConfig({
                priceFeed:0x694AA1769357215DE4FAC081bf1f309aDC325306
                });
                return Sepolia;
        }
        function ethConfig() public pure returns(NetworkConfig memory){
            NetworkConfig memory ethConfig = NetworkConfig({
                priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
            });
            return ethConfig;
        }
        function testConfig() public returns (NetworkConfig memory){
            // Deploy a mock price feed contract

            vm.startBroadcast();
            MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(Decimal,InitialAnswer);
            vm.stopBroadcast();

            NetworkConfig memory testConfig = NetworkConfig({
                priceFeed: address(mockV3Aggregator)
            });
            return testConfig;
        }
        }