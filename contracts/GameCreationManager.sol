//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.5;

import './GameCreationManagerHelper.sol';


contract GameCreationManager{
    GameCreationManagerHelper.Game[] games;

    uint256 maxEasyGames = 8; //amount of easy games at once
    uint256 maxMedGames = 5; //amount of medium games at once
    uint256 maxHardGames = 2; //amount of hard games at once

    //get game max
    function getGames(uint256 _difficulty) public view returns(uint256 amt){
        require(_difficulty < 4 && _difficulty > 0, 'getMaxGames: invalid difficulty');
        return GameCreationManagerHelper.getGameCount(_difficulty, games);
    }

    //get max amount of easy games
    function getMaxEasyGames() public view returns(uint256 number){
        return maxEasyGames;
    }
    //get max amount of medium games
    function getMaxMediumGames() public view returns(uint256 number){
        return maxMedGames;
    }
    //get max amount of hard games
    function getMaxHardGames() public view returns(uint256 number){
        return maxHardGames;
    }

    //get games
    function getGames() public view returns(GameCreationManagerHelper.Game[] memory res){
        return games;
    }

    //get current challenge
    function getCurrentChallenge(uint256 id) public view returns(string memory challenge){
        return games[id].challenges[games[id].currentRound];
    }

    //set max games
    function _setMaxGame(uint256 _difficulty, uint256 _amount) internal {
        require(_difficulty < 4 && _difficulty > 0, '_setMaxGames: invalid difficulty');
        if(_difficulty == 1){
            maxEasyGames = _amount;
        }
        if(_difficulty == 2){
            maxMedGames = _amount;
        }
        if(_difficulty == 3){
            maxHardGames = _amount;
        }
    }
    

    //create game, difficulty - 1 = easy 2 = med 3 = hard
    function _createGame
    (bool official,
    string memory title,
    uint256 maxPlayers, 
    uint256 minPlayers,  
    uint256 submissionlengthHours, 
    uint256 votinglengthHours, 
    uint8 difficulty, 
    uint256 numberOfRounds,
    uint256 numberOfWinners,
    string[] memory challenges)
    internal {
        require(difficulty < 4 && difficulty > 0, 'invalid difficulty');
        GameCreationManagerHelper.Game memory newGame = GameCreationManagerHelper.Game(
            title,
            GameCreationManagerHelper.RoundStrategy.none,
            GameCreationManagerHelper.PrizeDistribution.topX,
            games.length, //id
            numberOfWinners,
            maxPlayers,
            minPlayers,
            numberOfRounds,
            submissionlengthHours,
            votinglengthHours,
            0, //current round
            block.timestamp,
            difficulty,
            false, //isVotingRound
            official,
            challenges,
            new address[](0), //players
            msg.sender);
        games.push(newGame);

    }

    function _createGame
    (bool official,
    string memory title,
    uint256 maxPlayers, 
    uint256 minPlayers,  
    uint256 submissionlengthHours, 
    uint256 votinglengthHours, 
    uint8 difficulty, 
    uint256 numberOfRounds,
    uint256 numberOfWinners,
    string[] memory challenges,
    GameCreationManagerHelper.RoundStrategy roundStrategy,
    GameCreationManagerHelper.PrizeDistribution prizeDistributionStrategy)
    internal {
        require(difficulty < 4 && difficulty > 0, 'invalid difficulty');
        GameCreationManagerHelper.Game memory newGame = GameCreationManagerHelper.Game(
            title,
            roundStrategy,
            prizeDistributionStrategy,
            games.length, //id
            numberOfWinners,
            maxPlayers,
            minPlayers,
            numberOfRounds,
            submissionlengthHours,
            votinglengthHours,
            0, //current round
            block.timestamp,
            difficulty,
            false, //isVotingRound
            official,
            challenges,
            new address[](0), //players
            msg.sender);
        games.push(newGame);

    }


    // change round of game
    function nextRound(uint256 id) public returns(bool success){
        games[id].currentRound++;
        
        if(games[id].currentRound == games[id].numberOfRounds){
            //endGame
            return true;
        }
        
        games[id].isVotingRound = false;
        return true;
    }

    //singular game prompt
    //all game propmt

    //add player to game
    function _addPlayer(address _addr, uint256 _gameId) internal{
        bool alreadyExists = GameCreationManagerHelper.inArray(_addr, games[_gameId].players);
        if (!alreadyExists) {
            games[_gameId].players.push(_addr);
        }
    }
    //add player to game, fails if player already exists
    function _addPlayerSafe(address _addr, uint256 _gameId) internal{
        bool alreadyExists = GameCreationManagerHelper.inArray(_addr, games[_gameId].players);
        require(!alreadyExists, "_addPlayerSafe: address already exists in this game");
        games[_gameId].players.push(_addr);
    }

    /**
        -unofficial games require list of challenges before hand, top suggestion gets added on creation

     */

}