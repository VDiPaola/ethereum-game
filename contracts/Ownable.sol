// SPDX-License-Identifier: MIT

pragma solidity ^0.8.5;

import "@openzeppelin/contracts/utils/Context.sol";

/**
 * @dev Contract module which is specifically for 2 owners. based on openZeppelin's contract of the same name
 */
abstract contract Ownable is Context {
    address private _owner1;
    address private _owner2;

    /**
     * @dev Initializes the contract setting the deployer and a given address as the initial owners.
     */
    constructor(address _owner) {
        _setOwner1(_msgSender());
        _setOwner2(_owner);
    }

    /**
     * @dev Returns the address of the first owner.
     */
    function owner1() public view virtual returns (address) {
        return _owner1;
    }

    /**
     * @dev Returns the address of the second owner.
     */
    function owner2() public view virtual returns (address) {
        return _owner2;
    }

    /**
     * @dev Throws if called by any account other either of the owners.
     */
    modifier onlyOwner() {
        require(owner1() == _msgSender() || owner2() == _msgSender(), "Ownable: caller is not an owner");
        _;
    }

    /**
     * @dev Throws if called by any account other than owner1.
     */
    modifier onlyOwner1() {
        require(owner1() == _msgSender(), "Ownable: caller is not owner1");
        _;
    }

    /**
     * @dev Throws if called by any account other than owner2.
     */
    modifier onlyOwner2() {
        require(owner2() == _msgSender(), "Ownable: caller is not owner2");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by owner1.
     */
    function transferOwnership1(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner1(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by owner2.
     */
    function transferOwnership2(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner2(newOwner);
    }

    function _setOwner1(address newOwner) private {
        _owner1 = newOwner;
    }
    function _setOwner2(address newOwner) private {
        _owner2 = newOwner;
    }
}
