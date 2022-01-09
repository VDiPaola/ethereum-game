//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.5;

import './GameCreationManagerHelper.sol';
import "@openzeppelin/contracts/utils/Counters.sol";


contract GameCreationManager{
    using Counters for Counters.Counter;
    using GameCreationManagerHelper for GameCreationManagerHelper.Game;

    GameCreationManagerHelper.Game[] games;

    uint256 maxEasyGames = 8; //amount of easy games at once
    uint256 maxMedGames = 5; //amount of medium games at once
    uint256 maxHardGames = 2; //amount of hard games at once

    Counters.Counter curGameId;

    event AddFunds(uint gameId, address funder, uint amount, uint timestamp);
    event GameCreated(GameCreationManagerHelper.Game game);
    event NextRound(uint gameId, uint currentRound, uint totalRound, bool votingRound);
    event RefundedGame(uint gameId, uint timestamp);
    event Refund(address player, uint amount, uint gameId, uint timestamp);
    event AddChallenge(address gameMaster, uint gameId, string challenge);

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
    uint256 submissionLengthHours, 
    uint256 votingLengthHours, 
    uint256 entryLengthHours, 
    uint8 difficulty, 
    uint256 numberOfRounds,
    uint256 numberOfWinners,
    string[] memory challenges,
    uint16 entryPrice,
    GameCreationManagerHelper.RoundStrategy roundStrategy,
    GameCreationManagerHelper.PrizeDistribution prizeDistributionStrategy)
    internal {
        require(difficulty < 4 && difficulty > 0, '_createGame: invalid difficulty');
        require(official || challenges.length >= numberOfRounds, '_createGame: not enough challenges');
        curGameId.increment();
        GameCreationManagerHelper.Game memory newGame = GameCreationManagerHelper.Game(
            title,
            official ? roundStrategy : GameCreationManagerHelper.RoundStrategy.none,
            official ? prizeDistributionStrategy : GameCreationManagerHelper.PrizeDistribution.topX,
            curGameId.current(),
            numberOfWinners,
            maxPlayers,
            minPlayers,
            numberOfRounds,
            submissionLengthHours,
            votingLengthHours,
            entryLengthHours,
            0, //current round
            block.timestamp,
            0, //prize pool
            difficulty,
            entryPrice,
            false, //isVotingRound
            official,
            challenges,
            new address[](0), //players
            msg.sender);
        games.push(newGame);

        emit GameCreated(newGame);
    }
    


    // go to next round of game
    function _nextRound(uint256 _gameId) internal {
        GameCreationManagerHelper.Game storage game = GameCreationManagerHelper.getGame(_gameId, games);
        game.nextRound();
    }

    //add player to game
    function _addPlayer(address _addr, uint256 _gameId) internal{
        GameCreationManagerHelper.Game storage game = GameCreationManagerHelper.getGame(_gameId, games);
        bool alreadyExists = GameCreationManagerHelper.inArray(_addr, game.players);
        if (!alreadyExists) {
            game.players.push(_addr);
        }
    }
    //add player to game, fails if player already exists
    function _addPlayerSafe(address _addr, uint256 _gameId) internal{
        GameCreationManagerHelper.Game storage game = GameCreationManagerHelper.getGame(_gameId, games);
        bool alreadyExists = GameCreationManagerHelper.inArray(_addr, game.players);
        require(!alreadyExists, "_addPlayerSafe: address already exists in this game");
        game.players.push(_addr);
    }

    //remove player, admin only
    function _removePlayer(address _addr, uint256 _gameId) internal{
        GameCreationManagerHelper.Game storage game = GameCreationManagerHelper.getGame(_gameId, games);
        bool alreadyExists = GameCreationManagerHelper.inArray(_addr, game.players);
        require(!alreadyExists, "_addPlayerSafe: address already exists in this game");
        game.players.push(_addr);
    }

    //adds to prize pool for game
    function _addFunds(uint256 _gameId) internal {
        require(msg.value >= 1, "_addFunds: minimum to add is $1");
        GameCreationManagerHelper.Game storage game = GameCreationManagerHelper.getGame(_gameId, games);
        game.prizePool += msg.value;
        emit AddFunds(_gameId, msg.sender, msg.value, block.timestamp);
    }


    //refund players in a game
    function _refund(uint256 _gameId) internal {
        GameCreationManagerHelper.Game storage game = GameCreationManagerHelper.getGame(_gameId, games);
        for (uint playerIndex = 0; playerIndex < game.players.length; playerIndex++) {
            address payable addr = payable(game.players[playerIndex]);
            addr.transfer(game.entryPrice);
            emit Refund(addr, game.entryPrice, _gameId, block.timestamp);
        }
        GameCreationManagerHelper.deleteGame(_gameId, games);
    }

    //add challenge to challenge list
    function _addChallenge(uint256 _gameId, string memory _challenge) internal {
        GameCreationManagerHelper.Game storage game = GameCreationManagerHelper.getGame(_gameId, games);
        game.challenges.push(_challenge);
        emit AddChallenge(msg.sender, _gameId, _challenge);
    }

    //prompt game for start/next round
    function _promptGame(uint _gameId) internal {
        GameCreationManagerHelper.Game storage game = GameCreationManagerHelper.getGame(_gameId, games);
        //check start game condition
        if (game.currentRound == 0) {
            if (GameCreationManagerHelper.canGameStart(game)){
                //initialise game
                GameCreationManagerHelper.gameInit(game);
                //go to next round
                GameCreationManagerHelper.nextRound(game);
                emit NextRound(_gameId, game.currentRound, game.numberOfRounds, game.isVotingRound);
            }
        }else{
            GameCreationManagerHelper.nextRound(game);
            emit NextRound(_gameId, game.currentRound, game.numberOfRounds, game.isVotingRound);
        }
    }

    /**
        -fill in game event parameters
        -integrate gamesubmissiongateway into here instead
        -hardcore games
        -game end
     */

}