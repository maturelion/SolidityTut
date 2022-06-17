// SPDX-License-Identifier: MIT

// Get funds from users
// Withdraw funds
// Set a minimum funding value in usd

pragma solidity ^0.8.8;

import "./PriceConverter.sol";

// constant, immutable

/* -----------------------------*/
/* MINIMUM_USD Trasaction cost. */
/* No constant 874,577          */
/* Constant 855,066             */
/* -----------------------------*/
/* MINIMUM_USD Execution cost   */
/* No constant 23,515           */
/* Constant 21,415              */
/* -----------------------------*/
contract FundMe {
    using PriceConverter for uint256;
    uint256 public constant MINIMUM_USD = 50 * 1e18;

    address[] public funders;

    mapping(address => uint256) public addressToAmountFunded;

    address public immutable i_owner;
    /*    Immutable gas: 831,559        */
    /*    No immutable gas: 855,054     */

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        // Set min fund amount
        // 1. How do we send eth to this contract

        require(
            msg.value.getConversionRate() >= MINIMUM_USD,
            "Did not send enough!"
        ); // 1 * 10 ** 18 = 1000000000000000000
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner balanceRequired {
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++ ){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

        // // transfer method
        // payable(msg.sender).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // call
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Send failed");
    }

    modifier onlyOwner {
        require(msg.sender == i_owner, "Sender is not owner!");
        _;
    }

    modifier balanceRequired {
        require(address(this).balance > 0, "Insuficient balance");
        _;
    }

    
}
