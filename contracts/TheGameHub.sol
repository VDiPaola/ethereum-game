//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.5;

import "@openzeppelin/contracts/security/Pausable.sol";

import "./Ownable.sol";

import "./PaymentGateway.sol";

import "./Token.sol";

import "./GameSubmissionGateway.sol";

contract TheGameHub is PaymentGateway, Token, Ownable, Pausable {

    constructor(address _owner2) Ownable(_owner2){}
    receive() external payable {}

    //Pausable - modifiers [whenNotPaused] [whenPaused]
    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }
    
    //Payment Gateway

    function setPromotionalDiscount(uint8 _discountPercent, uint8 _daysForPromotionToLast) external onlyOwner{
        _setPromotionalDiscount(_discountPercent, _daysForPromotionToLast);
    }

    function setEasyGameMasterPrice(uint _newPrice) external onlyOwner{
        _setEasyGameMasterPrice(_newPrice);
    }
    function setMediumGameMasterPrice(uint _newPrice) external onlyOwner{
        _setMediumGameMasterPrice(_newPrice);
    }
    function setHardGameMasterPrice(uint _newPrice) external onlyOwner{
        _setHardGameMasterPrice(_newPrice);
    }


    function buyEasyGameMaster() external payable whenNotPaused valueEquals(easyGameMasterPrice){
        
    }

    function buyMediumGameMaster() external payable whenNotPaused valueEquals(mediumGameMasterPrice){
        
    }

    function buyHardGameMaster() external payable whenNotPaused valueEquals(hardGameMasterPrice){
        
    }

    //GameSubmissionGateway

    
}
