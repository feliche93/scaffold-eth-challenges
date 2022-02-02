pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "hardhat/console.sol";

// learn more: https://docs.openzeppelin.com/contracts/3.x/erc20

contract YourToken is ERC20 {
    constructor() ERC20("Felix", "FLX") {
        _mint(msg.sender, 1000 * 10**18);
        console.log("Minted 1000 Felix Token to %s", msg.sender);
    }
}
