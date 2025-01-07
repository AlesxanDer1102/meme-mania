// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

contract Token is ERC20 {
    address payable public owner;
    address public creator;

    constructor(address _creator, string memory _name, string memory _symbol, uint256 _totalSupply)
        ERC20(_name, _symbol)
    {
        owner = payable(msg.sender);
        creator = _creator;
        _mint(msg.sender, _totalSupply);
    }
}
