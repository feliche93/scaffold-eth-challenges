pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";
import "hardhat/console.sol";

contract Vendor is Ownable {
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
    event SellTokens(
        address seller,
        uint256 amountOfETH,
        uint256 amountOfTokens
    );

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

    /**
     * @notice Allows the vendor contract to buy tokens back from the user
     */
    function sellTokens(uint256 amountOfToken) public {
        // Checks wether user wants to sell more than 0 tokens
        require(
            amountOfToken > 0,
            "Amount of tokens to sell must be greater than 0"
        );

        // Checks wether user has enough tokens to sell
        uint256 tokenBalance = yourToken.balanceOf(msg.sender);
        require(tokenBalance >= amountOfToken, "Not enough tokens to sell");

        // Calculates eth amount and checks if required balance available in vendor contract
        uint256 ethAmount = amountOfToken / tokensPerEth;
        require(
            address(this).balance >= ethAmount,
            "Vendor Contract does not have enough eth for sale"
        );

        // Logs the allowance
        uint256 allowance = yourToken.allowance(msg.sender, address(this));
        console.log("Adress Owner %s: ", msg.sender);
        console.log("Adress Spender %s: ", address(this));
        console.log("Allowance %s", allowance);

        bool transfered = yourToken.transferFrom(
            msg.sender,
            address(this),
            amountOfToken
        );
        console.log("transfered: %s", transfered);

        // emit selling
        emit SellTokens(msg.sender, ethAmount, amountOfToken);

        (bool sent, ) = msg.sender.call{value: ethAmount}("");
        require(sent, "Failed to send user ETH back");
    }
}
