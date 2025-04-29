// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/LotteryGame.sol"; // change LotteryGame to LotteryGame

contract LotteryGameTest is
    Test // change LotteryGame to LotteryGame
{
    LotteryGame public game; // change LotteryGame to LotteryGame
    address public owner;
    address public player1;
    address public player2;
    address public player3;

    function setUp() public {
        owner = address(this);
        player1 = makeAddr("player1");
        player2 = makeAddr("player2");
        player3 = makeAddr("player3");

        // Fund test accounts
        vm.deal(player1, 1 ether);
        vm.deal(player2, 1 ether);
        vm.deal(player3, 1 ether);

        game = new LotteryGame(); // change LotteryGame to LotteryGame
    }

    function testRegisterWithCorrectAmount() public {
        vm.prank(player1);
        game.register{value: 0.02 ether}();

        (uint256 attempts, bool active) = game.players(player1);
        assertEq(attempts, 0);
        assertTrue(active);
        assertEq(game.totalPrizePool(), 0.02 ether);
    }

    function testRegisterWithIncorrectAmount() public {
        vm.prank(player1);
        vm.expectRevert("Please stake 0.02 ETH");
        game.register{value: 0.01 ether}();
    }

    function testGuessNumberInValidRange() public {
        // Register player
        vm.startPrank(player1);
        game.register{value: 0.02 ether}();

        // Make a valid guess
        game.guessNumber(5);
        vm.stopPrank();

        // Check attempts were incremented
        (uint256 attempts,) = game.players(player1);
        assertEq(attempts, 1);
    }

    function testGuessNumberOutOfRange() public {
        // Register player
        vm.startPrank(player1);
        game.register{value: 0.02 ether}();

        // Try to guess with invalid numbers
        vm.expectRevert("Number must be between 1 and 9");
        game.guessNumber(0);

        vm.expectRevert("Number must be between 1 and 9");
        game.guessNumber(10);

        vm.stopPrank();
    }

    function testUnregisteredPlayerCannotGuess() public {
        vm.prank(player1);
        vm.expectRevert("Player is not active");
        game.guessNumber(5);
    }

    function testPlayerLimitedToTwoAttempts() public {
        // Register player
        vm.startPrank(player1);
        game.register{value: 0.02 ether}();

        // Make two guesses
        game.guessNumber(5);
        game.guessNumber(6);

        // Try to make a third guess
        vm.expectRevert("Player has already made 2 attempts");
        game.guessNumber(7);

        vm.stopPrank();
    }

    function testDistributePrizesNoWinners() public {
        vm.expectRevert("No winners to distribute prizes to");
        game.distributePrizes();
    }

    // To test that a correct guess actually adds the player to the winners list
    // function testCorrectGuessAddsWinner() public {
    //     vm.startPrank(player1);
    //     game.register{value: 0.02 ether}();

    //     // Mock the random number
    //     vm.mockCall(address(game), abi.encodeWithSelector(game._generateRandomNumber.selector), abi.encode(5));
        
    //     game.guessNumber(5);
    //     vm.stopPrank();

    //     address[] memory winners = game.getWinners();
    //     assertEq(winners.length, 1);
    //     assertEq(winners[0], player1);
    // }

    //To make sure winners receive ETH correctly and the prize pool is reset
    // function testDistributePrizesWithWinners() public {
    //     vm.startPrank(player1);
    //     game.register{value: 0.02 ether}();

    //     // Simulate a correct guess
    //     vm.mockCall(address(game), abi.encodeWithSelector(game._generateRandomNumber.selector), abi.encode(5));
    //     game.guessNumber(5);
    //     vm.stopPrank();

    //     uint256 balanceBefore = player1.balance;

    //     // Distribute prizes
    //     game.distributePrizes();

    //     // Check if prize is transferred
    //     assertGt(player1.balance, balanceBefore);
    //     assertEq(game.totalPrizePool(), 0);
    // }

    // Ensure getPrevWinners() returns correct data after prize distribution
    // function testPreviousWinnersAreStored() public {
    //     vm.startPrank(player1);
    //     game.register{value: 0.02 ether}();

    //     vm.mockCall(address(game), abi.encodeWithSelector(game._generateRandomNumber.selector), abi.encode(5));
    //     game.guessNumber(5);
    //     vm.stopPrank();

    //     game.distributePrizes();
        
    //     address[] memory prevWinners = game.getPrevWinners();
    //     assertEq(prevWinners.length, 1);
    //     assertEq(prevWinners[0], player1);
    // }

    // A player shouldn't register more than once.
    function testPlayerCannotRegisterTwice() public {
        vm.startPrank(player1);
        game.register{value: 0.02 ether}();

        vm.expectRevert("Player already registered");
        game.register{value: 0.02 ether}();
        vm.stopPrank();
    }


}
