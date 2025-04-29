// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {LotteryGame} from "../src/LotteryGame.sol";
import "forge-std/console.sol"; // import console.sol to use console.log

contract LotteryScript is Script {
    LotteryGame public lottery;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        lottery = new LotteryGame();
        console.log("LotteryGame deployed at:", address(lottery));

        vm.stopBroadcast();
    }
}
