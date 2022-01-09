//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.5;

/* @title Game Creation Manager Helper */
library GameCreationManagerHelper{

    /* @dev round calculation strategy */
    enum RoundStrategy{
        none,
        halfing
    }

    /* @dev prize distribution strategy */
    enum PrizeDistribution{
        topX,
        xPercent
    }

    /* @dev stores information for a game */
    struct Game{
        string title;
        RoundStrategy roundStrategy;
        PrizeDistribution prizeDistribution;
        uint id;
        uint numberOfWinners;
        uint maxPlayers;
        uint minPlayers;
        uint numberOfRounds;
        uint submissionLengthHours; //how long to enter a submission
        uint votingLengthHours;
        uint entryLengthHours; //how long to join a game
        uint currentRound;
        uint date;
        uint prizePool;
        uint8 difficulty;
        uint16 entryPrice;
        bool isVotingRound;
        bool official;
        string[] challenges;
        address[] players;
        address gameMaster;
    }
    
    /* @dev Checks title exists in game array */
    // function checkTitle(string memory _string, Game[] memory _games) internal pure returns(bool exists){
    //     for(uint i = 0; i < _games.length; i++){
    //         if(keccak256(abi.encodePacked(_games[i].title)) == keccak256(abi.encodePacked(_string))){return true;}
    //     }
    //     return false;
    // }


    /* @dev get game from id */
    function getGame(uint _gameId, Game[] storage _games) internal view returns(Game storage game){
        for(uint i = 0; i < _games.length; i++){
            if (_games[i].id == _gameId) {
                return _games[i];
            }
        }
        revert("getGame: game with that id doesnt exist");
    }

    /* @dev deletes game from array */
    function deleteGame(uint _gameId, Game[] storage _games) internal{
        for(uint i = 0; i < _games.length; i++){
            if (_games[i].id == _gameId) {
                delete _games[i];
                return;
            }
        }
        revert("deleteGame: game with that id doesnt exist");
    }

    /* @dev Checks string matches */
    function equals(string memory _string1, string memory _string2) internal pure returns(bool equal){
        if(keccak256(abi.encodePacked(_string1)) == keccak256(abi.encodePacked(_string2))){return true;}
        return false;
    }

    /* @dev check if address is in array */
    function inArray(address _address, address[] memory _users) internal pure returns(bool success){
        for(uint i = 0; i < _users.length; i++){
            if(_users[i] == _address){return true;}
        }
        return false;
    }

    /* @dev game count per difficulty */
    function getGameCount(uint _difficulty, Game[] memory _games) internal pure returns(uint256 amt){
        uint counter;
        for(uint i = 0; i < _games.length; i++){
            if(_games[i].difficulty == _difficulty){counter++;}
        }
        return counter;
    }

    /* @dev get round number by strategy */
    function calculateRounds(RoundStrategy _strategy, uint _numberOfRounds, uint _playerCount) internal pure returns(uint numberOfRounds){
        if(_strategy == RoundStrategy.none){
            return _numberOfRounds;
        }
        else if(_strategy == RoundStrategy.halfing){
            uint roundCount = 1;
            while(_playerCount < _numberOfRounds){
                roundCount++;
                _playerCount /= 2;
            }
            return roundCount;
        }
    }

    /* @dev returns if the game can start */
    function canGameStart(Game storage _game) internal view returns(bool canStart) {
        //max players reached
        if(_game.players.length >= _game.maxPlayers){
            return true;
        }

        //has enough time past
        uint secondsPast = block.timestamp - _game.date;
        if (secondsPast > (_game.entryLengthHours*60)*60) {
            return true;
        }

        //meet min player requirement
        if(_game.players.length >= _game.minPlayers){
            return true;
        }

        return false;

    }

    /* @dev go to next round in game */
    function nextRound(Game storage _game) internal {
        _game.currentRound++;
        _game.isVotingRound = !_game.isVotingRound;

        if(_game.currentRound == _game.numberOfRounds){
            //game has finished
            
        }else{
            if (!_game.isVotingRound) {
                //apply the votes and update submissions from the previous voting round
            }
        }
    }

    /* @dev initialises the game*/
    function gameInit(Game storage _game) internal {
        require(_game.currentRound == 0, "gameInit: game already initialised");
        _game.numberOfRounds = calculateRounds(_game.roundStrategy, _game.numberOfRounds, _game.players.length);
        
    }

    /* @dev remove submissions based on strategy */
    function submissions(Game storage _game) internal returns(uint numberOfRounds){
        if(_game.roundStrategy == RoundStrategy.none){
            uint loserCount = _game.players.length / _game.numberOfRounds;

        }
        else if(_game.roundStrategy == RoundStrategy.halfing){

        }
    }
}