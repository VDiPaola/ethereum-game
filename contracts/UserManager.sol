//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.5;

import './UserManagerHelper.sol';

/* User Manager */
contract UserManager{
    uint256 totalPlayers;
    mapping(address => UserManagerHelper.User) users;

    event RegisteredUser(address Address, uint Timestamp);
    event GameWon(address Address, uint Timestamp);
    event GameLost(address Address, uint Timestamp);
    event RoundWon(address Address, uint Timestamp);
    event RoundLost(address Address, uint Timestamp);
    event AddExp(address Address, uint Amount, uint Timestamp);

    //register user if they dont exist
    function _registerUser() private{
        UserManagerHelper.User storage user = users[msg.sender];
        if(user.addr != msg.sender){
            user.addr = msg.sender;
            totalPlayers++;
            emit RegisteredUser(msg.sender, block.timestamp);
        }
    }

    //get game stats from difficulty
    function _getGameStats(address _address, uint8 _difficulty)private view returns(UserManagerHelper.GameStats memory stats){
        require(_difficulty < 4 && _difficulty > 0, '_getGameStats: invalid difficulty');
        if(_difficulty == 1)
        {
            return users[_address].easy;
        }
        if(_difficulty == 2)
        {
            return users[_address].medium;
        }
        if(_difficulty == 3)
        {
            return users[_address].hard;
        }
    }

    //set game stats by difficulty
    function _setGameStats(address _address, uint8 _difficulty, UserManagerHelper.GameStats memory _stats)private{
        require(_difficulty < 4 && _difficulty > 0, '_setGameStats: invalid difficulty');
        if(_difficulty == 1)
        {
            users[_address].easy = _stats;
        }
        if(_difficulty == 2)
        {
            users[_address].medium = _stats;
        }
        if(_difficulty == 3)
        {
            users[_address].hard = _stats;
        }
    }

    /* SETTERS */

    //Add to users game wins
    function _addGameWin(address _address, uint8 _difficulty) internal returns(uint256 wins){
        _registerUser();
        UserManagerHelper.GameStats memory stats = _getGameStats(_address, _difficulty);
        stats.gamesWon++;

        _setGameStats(_address, _difficulty, stats);
        emit GameWon(_address, block.timestamp);

        return stats.gamesWon;
    }

    //Add to users game loss
    function _addGameLoss(address _address, uint8 _difficulty) internal returns(uint256 wins){
        _registerUser();
        UserManagerHelper.GameStats memory stats = _getGameStats(_address, _difficulty);
        stats.gamesLost++;

        _setGameStats(_address, _difficulty, stats);
        emit GameLost(_address, block.timestamp);

        return stats.gamesLost;
    }

    //Add to users round wins
    function _addRoundWin(address _address, uint8 _difficulty) internal returns(uint256 wins){
        _registerUser();
        UserManagerHelper.GameStats memory stats = _getGameStats(_address, _difficulty);
        stats.roundsWon++;

        _setGameStats(_address, _difficulty, stats);
        emit RoundWon(_address, block.timestamp);

        return stats.roundsWon;
    }

    //Add to users round loss
    function _addRoundLoss(address _address, uint8 _difficulty) internal returns(uint256 wins){
        _registerUser();
        UserManagerHelper.GameStats memory stats = _getGameStats(_address, _difficulty);
        stats.roundsLost++;

        _setGameStats(_address, _difficulty, stats);
        emit RoundLost(_address, block.timestamp);

        return stats.roundsLost;
    }

    //add exp + level up
    function _addExp(address _address, uint _amount) internal{
        _registerUser();
        users[_address].exp += _amount;
        if(users[_address].exp >= UserManagerHelper.expForLevel){
            uint excess = users[_address].exp - UserManagerHelper.expForLevel;
            users[_address].exp = excess;
            users[_address].level++;
        }
        emit AddExp(_address, _amount, block.timestamp);
    }

    //add reputation
    function _addReputation(address _address, uint _amount) internal{
        _registerUser();
        users[_address].reputation += _amount;
    }

    //add gamemaster reputation
    function _addGameMasterReputation(address _address, uint _amount) internal{
        _registerUser();
        users[_address].gamemasterReputation += _amount;
    }

    //add games ran to user
    function _addGamesRan(address _address) internal{
        _registerUser();
        users[_address].gamesRan++;
    }

    /* GETTERS */

    //Get user by address
    function getUser(address _address) public view returns(UserManagerHelper.User memory user){
        return users[_address];
    }

    /* games */

    //Get users game wins
    function getGameWins(address _address) public view returns(uint256 wins){
        return users[_address].easy.gamesWon + users[_address].medium.gamesWon + users[_address].hard.gamesWon;
    }

    //Get users games won by difficulty
    function getGamesWonByDifficulty(address _address, uint8 _difficulty) public view returns(uint256 wins){
        UserManagerHelper.GameStats memory stats = _getGameStats(_address, _difficulty);
        return stats.gamesWon;
    }

    //Get users games lost by difficulty
    function getGamesLostByDifficulty(address _address, uint8 _difficulty) public view returns(uint256 wins){
        UserManagerHelper.GameStats memory stats = _getGameStats(_address, _difficulty);
        return stats.gamesLost;
    }

    //get games played
    function getGamesPlayed(address _address) public view returns (uint256 gamesPlayed){
        uint gamesLost = users[_address].easy.gamesLost + users[_address].medium.gamesLost + users[_address].hard.gamesLost;
        uint gamesWon = users[_address].easy.gamesWon + users[_address].medium.gamesWon + users[_address].hard.gamesWon;
        return gamesLost + gamesWon;
    }

    /* rounds */

    //Get users round wins
    function getRoundWins(address _address) public view returns(uint256 wins){
        return users[_address].easy.roundsWon + users[_address].medium.roundsWon + users[_address].hard.roundsWon;
    }

    //Get rounds won by difficulty
    function getRoundsWonByDifficulty(address _address, uint8 _difficulty) public view returns(uint256 wins){
        UserManagerHelper.GameStats memory stats = _getGameStats(_address, _difficulty);
        return stats.roundsWon;
    }
    //Get rounds lost by difficulty
    function getRoundsLostByDifficulty(address _address, uint8 _difficulty) public view returns(uint256 wins){
        UserManagerHelper.GameStats memory stats = _getGameStats(_address, _difficulty);
        return stats.roundsLost;
    }


    //get rounds played
    function getRoundsPlayed(address _address) public view returns(uint256 roundsPlayed){
        uint roundsWon = users[_address].easy.roundsWon + users[_address].medium.roundsWon + users[_address].hard.roundsWon;
        uint roundsLost = users[_address].easy.roundsLost + users[_address].medium.roundsLost + users[_address].hard.roundsLost;
        return roundsWon + roundsLost;
    }

    /* exp and level */

    //get exp
    function getExp(address _address) public view returns (uint256 exp){
        return users[_address].exp;
    }

    //get level
    function getLevel(address _address) public view returns (uint256 level){
        return users[_address].level;
    }

    /* reputation */

    //get reputation
    function getReputation(address _address) public view returns (uint256 reputation){
        return users[_address].reputation;
    }

    /* gamemaster functions */

    //get gamemaster reputation
    function getGameMasterReputation(address _address) public view returns (uint256 gamemasterReputation){
        return users[_address].gamemasterReputation;
    }

    //get games ran
    function getGamesRan(address _address) public view returns (uint256 gamesRan){
        return users[_address].gamesRan;
    }




}