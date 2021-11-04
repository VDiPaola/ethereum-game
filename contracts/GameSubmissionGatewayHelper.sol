//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.5;


library GameSubmissionGatewayHelper {

    /* @dev Holds data for comments on submissions  */
    struct Comment{
        address addr;
        string comment;
        uint timestamp;
    }

    /* @dev holds each video submission data  */
    struct GameSubmission{
        string video;
        address creator;
        int votes;
        uint totalVotes;
        address[] voters;
        Comment[] comments;
    }

    /* @dev Vote object used for bulk voting  */
    struct Vote{
        address submissionAddress;
        bool isUpvote;
    }
    
    /* @dev checks if an address is in the given array */
    function _isInArray(address[] memory _addrArray, address _addr)internal pure returns(bool){
        for(uint i=0;i<_addrArray.length;i++){
            if(_addrArray[i] == _addr){
                return true;
            }
        }
        return false;
    }

}

