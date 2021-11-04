//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.5;

import './GameSuggestionManagerHelper.sol';

/*
game suggestion manager:
-post suggestion --DONE
-users can vote --DONE
-be able to get all the active suggestions --DONE
-at end of voting phase(maybe a day) the top suggestion variable is assigned to that --DONE
-function for game creation manager where you give it the top suggestion(if one exists) and then null the variable -- done
 */

contract GameSuggestionManager{
    GameSuggestionManagerHelper.Suggestions topSuggestion;
    GameSuggestionManagerHelper.Suggestions[] suggestions;

    uint256 targetVotes;
    uint256 duration;

    /* @dev get duration of suggestion */
    function getDurationOfSuggestions() public view returns(uint256 dur){
        return duration;
    }

    /* @dev set duration of suggestions */
    function setSurationOfSuggestions(uint256 dur) public returns(bool success){
        duration = dur;
        return true;
    }

    /* @dev check duration of suggestions */
    function checkSuggestionsExpired() public view returns(GameSuggestionManagerHelper.Suggestions memory res){
        if(duration > block.timestamp){
            return topSuggestion;
        }
    }

    /* @dev check duration of suggestion */
    function checkSuggestionExpired(uint id, string memory suggestion) public view returns(bool success){
        if(keccak256(abi.encodePacked(suggestions[id].title)) == keccak256(abi.encodePacked(suggestion)))
        {
            if(suggestions[id].expiry >= block.timestamp){
                return true;
            }
            return false;
        }
        return false;
    }

    /* @dev get top suggestion */
    function getTopSuggestion() public view returns(GameSuggestionManagerHelper.Suggestions memory res){
        return topSuggestion;
    }

    /* @dev accept top suggestion */
    function acceptTopSuggestion() public returns(GameSuggestionManagerHelper.Suggestions memory res){
        GameSuggestionManagerHelper.Suggestions memory suggestion = topSuggestion;
        delete topSuggestion;
        return suggestion;
    }

    /* @dev get target votes */
    function getTargetVotes() public view returns(uint256 targetvotes){
        return targetVotes;
    }

    /* @dev set target votes */
    function setTargetVotes(uint256 targetvotes) public returns(bool success){
        targetVotes = targetvotes;
        return true;
    }

    /* @dev post suggestion */
    function createSuggestion
    (string memory title, string[] memory challenges, uint256 maxPlayers, uint256 minPlayers, uint256 submissionLength, uint256 votingLength, uint256 difficulty, uint256 numberOfWinners)
    public returns(bool success){
        uint256 exp = block.timestamp + duration;
        GameSuggestionManagerHelper.Suggestions memory newSuggestion = GameSuggestionManagerHelper.Suggestions
        (title, 1, exp, targetVotes, block.timestamp, challenges, maxPlayers, minPlayers, challenges.length, submissionLength, votingLength, difficulty, numberOfWinners);
        suggestions.push(newSuggestion);
        return true;
    }

    /* @dev get suggestions */
    function getSuggestions() public view returns(GameSuggestionManagerHelper.Suggestions[] memory res){
        return suggestions;
    }

    /* @dev submit vote */
    function vote(uint256 id, string memory suggestion) public returns(bool success){
        if(keccak256(abi.encodePacked(suggestions[id].title)) == keccak256(abi.encodePacked(suggestion)))
        {
            if(checkSuggestionExpired(id, suggestion)){
                return false;
            }
            suggestions[id].votes++;
            uint index = GameSuggestionManagerHelper.topSuggestion(suggestions);
            topSuggestion = suggestions[index];
            return true;
        }
        return false;
    }


}