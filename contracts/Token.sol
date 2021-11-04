// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Token is ERC20, ERC20Burnable {
    constructor() ERC20("TheGame", "TG") {
        _mint(msg.sender, 1000000000 * 10 ** decimals());
    }

    //makes sure address has enough tokens
    modifier hasEnoughTokens(address _address, uint _amount){
        require(balanceOf(_address) >= _amount, "doesnt have enough tokens");
        _;
    }
}