// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import {Token} from "./Token.sol";

contract Factory {
    uint256 public fee;
    address public owner;

    uint256 public tokenCount;
    address[] public tokens;

    constructor(uint256 _fee) {
        fee = _fee;
        owner = msg.sender;
    }

    function create(string memory name, string memory symbol) external payable {
        //Create the new token
        Token newToken = new Token(msg.sender, name, symbol, 1000000 ether);

        //Save the token for later use
        tokens.push(address(newToken));

        tokenCount++;
        //List the token for sale

        //Tell peopleit's live
    }
}
