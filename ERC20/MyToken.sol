// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

import "./TokenErc20.sol";

contract MyToken is TokenErc20 {
    constructor() TokenErc20("Example Token", "EXT", 18, 5000) {

    }
}