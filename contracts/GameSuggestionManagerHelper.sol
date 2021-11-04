//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.5;

library GameSuggestionManagerHelper {
    struct Suggestions{
        string title;
        uint256 votes;
        uint256 expiry;
        uint256 voteTarget;
        uint256 createdAt;
        string[] challenges;
        uint256 maxPlayers;
        uint256 minPlayers;
        uint256 numberOfRounds;
        uint256 submissionLength;
        uint256 votingLength;
        uint256 difficulty;
        uint256 numberOfWinners;
    }

    function topSuggestion(Suggestions[] memory sug) internal pure returns(uint index){
        uint topSuggestion;
        uint topSuggestionVotes;
        for(uint i = 0; i < sug.length; i++){
            if(sug[i].votes > topSuggestionVotes){
                topSuggestion = i;
                topSuggestionVotes = sug[i].votes;
            }
        }
        return topSuggestion;
    }
}