// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import {Token} from "./Token.sol";

contract Factory {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error Factory__InsufficientFee();
    error Factory__InsufficientEtherSend();
    error Factory__BuyingClosed();
    error Factory__AmountTooLow();
    error Factory__AmountTooHigh();
    error Factory__BuyingIsOpen();
    error Factory__TransferEtherFaild();

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

    uint256 public constant TARGET = 3 ether;
    uint256 public constant TOKEN_LIMIT = 500_000 ether;

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

        if (sale.isOpen == false) {
            revert Factory__BuyingClosed();
        }
        if (_amount < 1 ether) {
            revert Factory__AmountTooLow();
        }
        if (_amount > 10000 ether) {
            revert Factory__AmountTooHigh();
        }

        //Calculete the price of 1 token based uponn total bought
        uint256 cost = getCost(sale.sold);

        uint256 price = cost * (_amount / 1e18);

        //Make sure enough ether was sent
        if (msg.value < price) {
            revert Factory__InsufficientEtherSend();
        }

        sale.sold += _amount;
        sale.raised += price;

        //Make sure funds raising goal isn't met
        if (sale.raised >= TARGET || sale.sold >= TOKEN_LIMIT) {
            sale.isOpen = false;
        }

        Token(_token).transfer(msg.sender, _amount);
        emit Buy(_token, _amount);
    }

    function deposit(address _token) external {
        // The remain token balance and the ETH raised
        // Would go into a liquidity pool like UniSwap V3.
        // For simplicity, we will just transfer remaining
        // tokens and ETH to the creator

        Token token = Token(_token);
        TokenSale memory sale = tokenToSale[_token];
        if (sale.isOpen) {
            revert Factory__BuyingIsOpen();
        }
        token.transfer(sale.creator, token.balanceOf(address(this)));

        (bool success,) = payable(sale.creator).call{value: sale.raised}("");
        if (!success) {
            revert Factory__TransferEtherFaild();
        }
    }

    function getCost(uint256 _sold) public pure returns (uint256) {
        uint256 floor = 0.0001 ether;
        uint256 step = 0.0001 ether;
        uint256 increment = 10000 ether;

        uint256 cost = (step * (_sold / increment)) + floor;
        return cost;
    }

    /*//////////////////////////////////////////////////////////////
                     PUBLIC & EXTERNAL VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function getTokenSale(uint256 _index) public view returns (TokenSale memory) {
        return tokenToSale[tokens[_index]];
    }
}
