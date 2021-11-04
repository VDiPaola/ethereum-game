//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.5;

/* @title User Manager */
library UserManagerHelper{

    /* @dev stores exp needed to level up */
    uint constant internal expForLevel = 100;

    /* @dev Game stats per difficulty object */
    struct GameStats{
        uint gamesWon;
        uint gamesLost;
        uint roundsWon;
        uint roundsLost;
    }


    /* @dev user roles */
    enum Role{
        user,
        vip,
        gameMaster
    }

    /* @dev stores all user data */
    struct User{
        address addr;
        uint256 exp;
        uint256 level;
        uint256 reputation;
        uint256 gamemasterReputation;
        uint256 gamesRan;
        uint256 gamesPlayed;
        GameStats easy;
        GameStats medium;
        GameStats hard;
        string winStatus;
        Role role;
    }
}