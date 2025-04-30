// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title LotteryGame
 * @dev A simple number guessing game where players can win ETH prizes
 */
contract LotteryGame {
    struct Player {
        uint256 attempts;
        bool active;
    }

    // TODO: Declare state variables
    // - Mapping for player information
    mapping(address => Player) public players;
    // - Array to track player addresses
    address[] public playerAddresses;
    // - Total prize pool
    uint256 public totalPrize;
    // - Array for winners
    address[] public winners;
    // - Array for previous winners
    address[] public previousWinners;

    // TODO: Declare events
    // - PlayerRegistered
    event PlayerRegistered(address indexed player);
    // - GuessResult
    event GuessResult(address indexed player, bool success, uint256 correctNumber);
    // - PrizesDistributed
    event PrizesDistributed(address[] winners, uint256 prizeAmount);

    /**
     * @dev Register to play the game
     * Players must stake exactly 0.02 ETH to participate
     */
    function register() public payable {
        // TODO: Implement registration logic
        // - Verify correct payment amount
        require(msg.value == 0.02 ether, "Please stake 0.02 ETH");
        require(!players[msg.sender].active, "Player already registered");
        // - Add player to mapping
        players[msg.sender] = Player({
            attempts: 0,
            active: true
        });
        // - Add player address to array
        playerAddresses.push(msg.sender);
        // - Update total prize
        totalPrize += msg.value;
        // - Emit registration event
        emit PlayerRegistered(msg.sender);
    }

    /**
     * @dev Make a guess between 1 and 9
     * @param guess The player's guess
     */
    function guessNumber(uint256 guess) public {
        // TODO: Implement guessing logic
        // - Validate guess is between 1 and 9
        require(guess >= 1 && guess <= 9, "Number must be between 1 and 9");
        // - Check player is registered and has attempts left
        require(players[msg.sender].active, "You are not registered");
        require(players[msg.sender].attempts < 2, "Player has already made 2 attempts");
        // - Generate "random" number
        uint256 random = _generateRandomNumber();
        // - Compare guess with random number
        if(guess == random){
            // - Handle correct guesses
            winners.push(msg.sender); //add to winners
            emit GuessResult(msg.sender, true, random);
            players[msg.sender].active = false ;//make inactive to ensure 1 win per player
        } else {
            emit GuessResult(msg.sender, false, random);
        }
        // - Update player attempts
        players[msg.sender].attempts++;
        // - Emit appropriate event
        // emit GuessResult(msg.sender, guess, random, isCorrect);
    }

    /**
     * @dev Distribute prizes to winners
     */
    function distributePrizes() public {
        // TODO: Implement prize distribution logic
        //check that there is a winner
        require(winners.length > 0, "No winners to distribute prizes to");
        // - Calculate prize amount per winner
        uint256 prizePerWinner = totalPrize / winners.length;
        // - Transfer prizes to winners
        for (uint256 i = 0; i < winners.length; i++){
            address winner = winners[i];
            (bool sent, ) = winner.call{value: prizePerWinner}("");
            require(sent, "Failed to send prize");

            // - Update previous winners list
            previousWinners.push(winner);
        }

        // - Emit event
        emit PrizesDistributed(winners, prizePerWinner);
        // - Reset game state
        delete winners;
        delete playerAddresses;
        totalPrize = 0;
        //reset player mappings
        for (uint256 i = 0; i < playerAddresses.length; i++){
            delete players[playerAddresses[i]];
        }
    }

    /**
     * @dev View function to get previous winners
     * @return Array of previous winner addresses
     */
    function getPrevWinners() public view returns (address[] memory) {
        // TODO: Return previous winners array
        return previousWinners;
    }

    /**
     * @dev Helper function to generate a "random" number
     * @return A uint between 1 and 9
     * NOTE: This is not secure for production use!
     */
    function _generateRandomNumber() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender))) % 9 + 1;
    }
}
