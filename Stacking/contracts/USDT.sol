// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract USDT is ERC20, Ownable {

    mapping(address => bool) _testMint;

    constructor() ERC20("USDT", "USDT") {

    }

    function mint(address to, uint256 amount) external onlyOwner() {
        _mint(to, amount);
    }

    function mintForTest(address to) external {
        require(_testMint[msg.sender] == false, "already minted");
        _mint(to, 1 *10 ** 18);
        _testMint[msg.sender] = true;
    }
}