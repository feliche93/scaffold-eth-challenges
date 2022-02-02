pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// learn more: https://docs.openzeppelin.com/contracts/3.x/erc20

contract YourToken is ERC20 {
    constructor() ERC20("Felix", "FLX") {
        _mint(0xe2f9a662DE63a5AB99F937fC82A93381262740c3, 1000 * 10**18);
    }
}
