// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "./USDT.sol";
import "./TokenOne.sol";

contract Staking {
    TokenOne private tokenStacking;
    USDT private tokenPayment;
    uint256 private rewardToToken;
    uint8 private exchangeRate = 1;
    uint256 private duration; 

    mapping (address => uint256) _balancesTokenStacking;

    struct State {
        uint256 amount;
        uint256 startTime;
        bool isEnd;
    }

    mapping(address => State) statesStacking; 

    constructor(address _tokenStacking, address _tokenPayment, uint256 _rewardToToken, uint256 _duration) {
        tokenStacking = TokenOne(_tokenStacking);
        tokenPayment = USDT(_tokenPayment);
        rewardToToken = _rewardToToken;
        duration = _duration * 1 minutes;
    }


    function buyToken(uint256 amountTokenStacking) external {
        uint256 amountTokenPayment = amountTokenStacking * exchangeRate;
        tokenPayment.transferFrom(msg.sender, address(this), amountTokenPayment);
        _balancesTokenStacking[msg.sender] = amountTokenStacking;
    }

    function stake(uint256 amountTokenStacking) public {
        require(statesStacking[msg.sender].startTime == 0 || statesStacking[msg.sender].isEnd == true, "token already staking");
        require(amountTokenStacking >= 10 ** 18 && amountTokenStacking % (10 ** 18) == 0, "you can stake only integer amount ( > 1 * 10 ** 18)");
        statesStacking[msg.sender] = State(amountTokenStacking, block.timestamp, false);
        _balancesTokenStacking[msg.sender] -= amountTokenStacking;
    }

    function claim() external {
        require(statesStacking[msg.sender].startTime + duration <= block.timestamp, "not enough time has passed");
        uint256 reward = statesStacking[msg.sender].amount * rewardToToken / 10 ** 18;
        _balancesTokenStacking[msg.sender] += statesStacking[msg.sender].amount + reward;
        statesStacking[msg.sender].amount = 0;
        statesStacking[msg.sender].isEnd = true;
    }

    function balanceOfTokenStacking(address _addr) public view returns(uint256) {
        return _balancesTokenStacking[_addr];
    }

    function withdraw(uint256 amountTokenStacking) external {
        require(amountTokenStacking <= balanceOfTokenStacking(msg.sender), "not enough money on your balance");
        tokenStacking.mint(msg.sender, amountTokenStacking);
        _balancesTokenStacking[msg.sender] -= amountTokenStacking;
    }

}

//1000000000000000
//