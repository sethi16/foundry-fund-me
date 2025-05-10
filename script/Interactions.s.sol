//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script,console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract fundMeScript is Script{

    uint256 constant send=0.2 ether;
    function fund(address recentdeployment) public {
        vm.startBroadcast();
        FundMe(payable(recentdeployment)).fund{value: send}();    
        vm.stopBroadcast();
        console.log("Funded", send);
        }

        function run() external{
            address recentdeployment = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
            fund(recentdeployment);
        }

}
      contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).cheaperwithdraw();
        vm.stopBroadcast();
        console.log("Withdraw FundMe balance!");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentlyDeployed);
    }

}