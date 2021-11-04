//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.5;

import './GameCreationManagerHelper.sol';


contract GameCreationManager{
    GameCreationManagerHelper.Game[] games;

    uint256 maxEasyGames;
    uint256 maxMedGames;
    uint256 maxHardGames;

    address[] verifiedUsers;

    //get game max
    function getMaxGames(uint256 _difficulty) public view returns(uint256 amt){
        require(_difficulty < 4 && _difficulty > 0, 'getMaxGames: invalid difficulty');
        return GameCreationManagerHelper.getGameCount(_difficulty, games);
    }

    //set max games
    function _setMaxGames(uint256 _difficulty, uint256 _amount) internal {
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

    //add verified users
    function addVerifiedUser(address addr) public returns(bool success){
        verifiedUsers.push(addr);
        return true;
    }

    function getVerifiedUsers() public view returns(address[] memory res){
        return verifiedUsers;
    }

    //create game 1 = easy 2 = med 3 = hard
    function createGame
    (string memory title, uint256 numberOfWinners, uint256 maxPlayers, uint256 minPlayers, uint256 numberOfRounds, uint256 submissionlength, uint256 votinglength, uint256 difficulty, string[] memory challenges, address[] memory players)
    internal {
        require(difficulty < 4 && difficulty > 0, 'invalid difficulty');
        GameCreationManagerHelper.Game memory newGame = GameCreationManagerHelper.Game(games.length,title,
        numberOfWinners, maxPlayers, minPlayers, numberOfRounds, submissionlength, votinglength, 0, block.timestamp, difficulty, false, true, challenges, players, msg.sender);
        games.push(newGame);

    }

    //get games
    function getGames() public view returns(GameCreationManagerHelper.Game[] memory res){
        return games;
    }

    //get current challenge
    function getCurrentChallenge(uint256 id) public view returns(string memory challenge){
        return games[id].challenges[games[id].currentRound];
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

    //add new player
    function addPlayer(address addr, uint256 gameId) public returns(bool success){
        games[gameId].players.push(addr);
        return true;
    }

    /* @dev add top suggestion 
    function addTopSuggestion(GSM.Suggestions memory sug) public returns(bool success){
        //    (string memory title, uint256 numberOfWinners, uint256 maxPlayers, uint256 minPlayers, uint256 numberOfRounds, uint256 submissionlength, uint256 votinglength, uint256 difficulty, string[] memory challenges, bool official, address[] memory players)
        address[] memory arr;
        createGame(sug.title,
        sug.numberOfWinners, sug.maxPlayers, sug.minPlayers, sug.numberOfRounds, sug.submissionLength, sug.votingLength, sug.difficulty, sug.challenges, true, arr);
    } */

}