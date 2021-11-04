//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.5;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./PaymentGatewayHelper.sol";

contract PaymentGateway is ReentrancyGuard {

    //price vars
    uint easyGameMasterPrice = PaymentGatewayHelper.xDaiToXDaiWei(1000);
    uint mediumGameMasterPrice = PaymentGatewayHelper.xDaiToXDaiWei(5000);
    uint hardGameMasterPrice = PaymentGatewayHelper.xDaiToXDaiWei(10000);

    //active promotional discount
    PaymentGatewayHelper.PromotionalDiscount currentPromotionalDiscount;


    //events
    event PayOut(address Address, uint Amount);
    event SetGameMasterPrice(uint OldPrice, uint NewPrice, string Type);
    event GameMasterPurchase(address Address, uint Price, string Type);
    event PromotionalDiscountApplied(uint8 Percent, uint EndTimestamp);

    //Checks that they sent the exact amount
    modifier valueEquals(uint _price){
        require(msg.value == _price, "msg.value does not equal the given price");
        _;
    }

    //Checks that they sent the exact amount
    modifier enoughContractBalance(uint _price){
        require(address(this).balance >= _price, "contract doesnt have enough funds");
        _;
    }

    function getPromotionalDiscount() external view returns(PaymentGatewayHelper.PromotionalDiscount memory){
        return currentPromotionalDiscount;
    }


    //get game master prices in Dollars
    function getEasyGameMasterPrice() public view returns(uint){
        return PaymentGatewayHelper.xDaiWeiToXDai(easyGameMasterPrice);
    }
    function getMediumGameMasterPrice() public view returns(uint){
        return PaymentGatewayHelper.xDaiWeiToXDai(mediumGameMasterPrice);
    }
    function getHardGameMasterPrice() public view returns(uint){
        return PaymentGatewayHelper.xDaiWeiToXDai(hardGameMasterPrice);
    }


    //internal functions

    function _setPromotionalDiscount( uint8 _discountPercent, uint8 _daysForPromotionToLast) internal{
        uint timestamp = block.timestamp + (_daysForPromotionToLast * 1 days);
        currentPromotionalDiscount = PaymentGatewayHelper.PromotionalDiscount(_discountPercent, timestamp);
        emit PromotionalDiscountApplied(_discountPercent, timestamp);
    }

    //set game master prices in Dollars (will store as xDai Wei)
    function _setEasyGameMasterPrice(uint _newPrice) internal{
        uint price = PaymentGatewayHelper.xDaiToXDaiWei(_newPrice);
        emit SetGameMasterPrice(easyGameMasterPrice, _newPrice, "Easy");
        easyGameMasterPrice = price;
    }
    function _setMediumGameMasterPrice(uint _newPrice) internal{
        uint price = PaymentGatewayHelper.xDaiToXDaiWei(_newPrice);
        emit SetGameMasterPrice(mediumGameMasterPrice, _newPrice, "Medium");
        mediumGameMasterPrice = price;
    }
    function _setHardGameMasterPrice(uint _newPrice) internal{
        uint price = PaymentGatewayHelper.xDaiToXDaiWei(_newPrice);
        emit SetGameMasterPrice(hardGameMasterPrice, _newPrice, "Hard");
        hardGameMasterPrice = price;
    }


    //private functions

    //pays out native currency(xDai Wei) to address
    function _payOut(address payable _address, uint _amount) internal nonReentrant{
        (bool status,) = _address.call{value:_amount}("");

        require(status, "transaction failed");
        emit PayOut(_address, _amount);
    }



}
