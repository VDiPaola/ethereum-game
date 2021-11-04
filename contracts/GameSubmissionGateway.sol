//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.5;

import "./GameSubmissionGatewayHelper.sol";

contract GameSubmissionGateway {

    event GameSubmissionComment(uint gameId, address submissionCreator, address commenter, string comment, uint timestamp);
    event Submission(uint gameId, string video, address creator);

    event Vote(uint gameId, address submissionCreator, bool isUpvote, address voter);

    mapping(uint => GameSubmissionGatewayHelper.GameSubmission[]) gameSubmissions;

    //create comment
    function _createComment(uint _gameId, address _creator, string memory _comment) internal{
        //get submissions
        GameSubmissionGatewayHelper.GameSubmission[] storage submissions = gameSubmissions[_gameId];
        bool submissionFound = false;

        emit GameSubmissionComment(_gameId, _creator, msg.sender, _comment, block.timestamp);
        
        //get submission if it exists push a comment
        for(uint i=0;i < submissions.length; i++){
            if(submissions[i].creator == _creator){
                submissions[i].comments.push(GameSubmissionGatewayHelper.Comment(msg.sender, _comment, block.timestamp));
                submissionFound = true;
                break;
            }
        }

        require(submissionFound, "New Comment: Submission not found");

    }


    //gets list of comments for specific submission in specific game
    function _getComments(uint _gameId, address _creator) internal view returns(GameSubmissionGatewayHelper.Comment[] memory){
        GameSubmissionGatewayHelper.GameSubmission[] memory submissions = gameSubmissions[_gameId];

        for(uint i=0;i < submissions.length; i++){
            if(submissions[i].creator == _creator){
                return submissions[i].comments;
            }
        }

        return new GameSubmissionGatewayHelper.Comment[](0);
    }

    //gets list of submissions by game id
    function _getAllSubmissions(uint _gameId) internal view returns(GameSubmissionGatewayHelper.GameSubmission[] memory){
        return gameSubmissions[_gameId];
    }


    //add submission to game by id
    function _addSubmission(uint _gameId, string memory _video) internal{
        //get submissions
        GameSubmissionGatewayHelper.GameSubmission[] storage submissions = gameSubmissions[_gameId];

        emit Submission(_gameId, _video, msg.sender);
        
        //check if they already have a submission and replace it if they do
        for(uint i=0;i < submissions.length; i++){
            if(submissions[i].creator == msg.sender){
                submissions[i] = GameSubmissionGatewayHelper.GameSubmission(_video, msg.sender, 0,0, new address[](0) ,new GameSubmissionGatewayHelper.Comment[](0));
                break;
            }
        }

        //add submission
        submissions.push(GameSubmissionGatewayHelper.GameSubmission(_video, msg.sender, 0,0, new address[](0) ,new GameSubmissionGatewayHelper.Comment[](0)));
    }

    //remove a submission
    function _removeSubmissions(uint _gameId) internal{
        delete gameSubmissions[_gameId];
    }

    //add votes to list of submissions
    function _handleSubmissionVotes(uint _gameId, GameSubmissionGatewayHelper.Vote[] memory _votes) internal{
        GameSubmissionGatewayHelper.GameSubmission[] storage submissions = gameSubmissions[_gameId];

        //check if any of the submissions creators are in any of the votes
        for(uint i=0;i < submissions.length; i++){
            for(uint index=0; index < _votes.length; index++){
                if(submissions[i].creator == _votes[index].submissionAddress){
                    //make sure they dont vote twice for the same submission
                    bool alreadyVoted = GameSubmissionGatewayHelper._isInArray(submissions[i].voters, _votes[index].submissionAddress);
                    if(!alreadyVoted){
                        //vote
                        int8 vote = _votes[index].isUpvote ? int8(1) : int8(-1);
                        submissions[i].votes += vote;
                        submissions[i].totalVotes++;

                        emit Vote(_gameId, _votes[index].submissionAddress, _votes[index].isUpvote, msg.sender);

                        submissions[i].voters.push(_votes[index].submissionAddress);
                    }
                    
                    break;
                }
            }
        }
    }


}
