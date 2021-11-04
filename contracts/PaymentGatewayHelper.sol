//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.5;

/* @title PaymentGatewayHelper  */
library PaymentGatewayHelper {

    /* @dev Struct for Promotional Discount data  */
    struct PromotionalDiscount{
        uint8 discountPercent;
        uint discountEndTimestamp;
    }

    struct PaymentQueueItem{
        address payable addr;
        uint amountToPay;
    }

    /* @dev Converts xDai wei into xDai  */
    function xDaiWeiToXDai(uint _xDaiWei) internal pure returns(uint){
        return _xDaiWei / (10 ** 18);
    }

    /* @dev converts xDai into xDai wei  */
    function xDaiToXDaiWei(uint _xDai) internal pure returns(uint){
        return _xDai * (10 ** 18);
    }

}
