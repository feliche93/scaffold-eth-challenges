pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";
import "hardhat/console.sol";

contract Vendor is Ownable {
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

    YourToken public yourToken;

    constructor(address tokenAddress) {
        yourToken = YourToken(tokenAddress);
    }

    // conversion rate 1 ETH = 100 ERC-20 tokens
    uint256 public constant tokensPerEth = 100;

    /**
     * @notice Allow users to buy tokens for ETH
     */
    function buyTokens() public payable {
        require(msg.value >= 0, "Send ether to buy tokens");

        uint256 amountOfTokens = msg.value * tokensPerEth;

        uint256 tokenBalance = yourToken.balanceOf(address(this));
        require(tokenBalance >= amountOfTokens, "Not enough tokens to sell");

        bool sent = yourToken.transfer(msg.sender, amountOfTokens);
        require(sent, "Could not transfer tokens");

        emit BuyTokens(msg.sender, msg.value, amountOfTokens);
    }

    /**
     * @notice Allow the owner of the contract to withdraw ETH
     */
    function withdraw() public onlyOwner {
        uint256 ownerBalance = address(this).balance;
        require(ownerBalance > 0, "Owner has no balance to withdraw");

        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send user balance back to the owner");
    }

    // ToDo: create a sellTokens() function:
}
