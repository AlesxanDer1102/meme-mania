// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import {Token} from "./Token.sol";

contract Factory {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error Factory__InsufficientFee();

    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/

    struct TokenSale {
        address token;
        string name;
        address creator;
        uint256 sold;
        uint256 raised;
        bool isOpen;
    }

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    uint256 public fee;
    address public owner;

    uint256 public totalTokens;
    address[] public tokens;
    mapping(address => TokenSale) public tokenToSale;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event CreatedToken(address indexed token);
    event Buy(address indexed token, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    constructor(uint256 _fee) {
        fee = _fee;
        owner = msg.sender;
    }

    function create(string memory name, string memory symbol) external payable {
        if (msg.value < fee) {
            revert Factory__InsufficientFee();
        }
        //Create the new token
        Token newToken = new Token(msg.sender, name, symbol, 1000000 ether);

        //Save the token for later use
        tokens.push(address(newToken));

        totalTokens++;
        //List the token for sale
        TokenSale memory sale =
            TokenSale({token: address(newToken), name: name, creator: msg.sender, sold: 0, raised: 0, isOpen: true});
        tokenToSale[address(newToken)] = sale;
        //Tell peopleit's live
        emit CreatedToken(address(newToken));
    }

    function buy(address _token, uint256 _amount) external payable {
        TokenSale storage sale = tokenToSale[_token];

        sale.sold += _amount;

        Token(_token).transfer(msg.sender, _amount);
        emit Buy(_token, _amount);
    }

    /*//////////////////////////////////////////////////////////////
                     PUBLIC & EXTERNAL VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function getTokenSale(uint256 _index) public view returns (TokenSale memory) {
        return tokenToSale[tokens[_index]];
    }
}
