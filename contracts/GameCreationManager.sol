//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.5;

import './GameCreationManagerHelper.sol';


contract GameCreationManager{
    GameCreationManagerHelper.Game[] games;

    uint256 maxEasyGames = 8; //amount of easy games at once
    uint256 maxMedGames = 5; //amount of medium games at once
    uint256 maxHardGames = 2; //amount of hard games at once

    //get game max
    function getMaxGames(uint256 _difficulty) public view returns(uint256 amt){
        require(_difficulty < 4 && _difficulty > 0, 'getMaxGames: invalid difficulty');
        return GameCreationManagerHelper.getGameCount(_difficulty, games);
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
    

    //create game 1 = easy 2 = med 3 = hard
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
            games.length,
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

    //add player to game
    function _addPlayer(address addr, uint256 gameId) internal{
        games[gameId].players.push(addr);
    }

    /**
        -unofficial games require list of challenges before hand, top suggestion gets added on creation

     */

}