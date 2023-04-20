// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

contract TokenErc20 {
    address private owner;

    string private tokenName;
    string private tokenSymbol;
    uint8 private tokenDecimals;
    uint256 private tokenTotalSupply;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint)) private allowances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value, uint256 _tax);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    constructor(string memory name_, string memory symbol_, uint8 decimals_, uint256 initialSupply) {
        owner = msg.sender;
        tokenName = name_;
        tokenSymbol = symbol_;
        tokenDecimals = decimals_;

        mint(owner, initialSupply);    
    }

    function name() public view returns(string memory) {
        return tokenName;
    }

    function symbol() public view returns(string memory) {
        return tokenSymbol;
    }

    function decimals() public view returns(uint8) {
        return tokenDecimals;
    }

    function totalSupply() public view returns(uint256) {
        return tokenTotalSupply;
    }

    function balanceOf(address _addr) public view returns(uint256) {
        return (balances[_addr]);
    }

    modifier required(address _from, uint256 _amount) {
        uint256 tax = _feeCalculate(_amount);
        require(balances[_from] >= _amount + tax, "Not enough token!");
        _;
    }

    modifier ownable() {
        require(msg.sender == owner, "You are not an owner!");
        _;
    }

    function _feeCalculate(uint256 _amount) private pure returns(uint256) {
        if (_amount >= 20 wei) {
            return (_amount * 500 / 10000);
        } else if (_amount > 0) {
            return 1 wei;
        }        
        return 0;
    }

    function transfer(address _to, uint256 _amount) public required(msg.sender, _amount) returns(bool success) {
        uint256 tax = _feeCalculate(_amount);
        balances[msg.sender] -= _amount + tax;
        balances[_to] += _amount;
        balances[owner] += tax;

        emit Transfer(msg.sender, _to, _amount, tax);
        return true;

    }

    function transferFrom(address _from, address _to, uint256 _amount) public required(_from, _amount) returns(bool success) {
        uint256 tax = _feeCalculate(_amount);
        require(allowances[_from][_to] >= (_amount + tax), "Not allowance to transfer");
        allowances[_from][_to] -= _amount + tax;
        balances[_from] -= _amount + tax;
        balances[_to] += _amount;
        balances[owner] += tax;


        emit Transfer(_from, _to, _amount, tax);
        return true;
    }

    function approve(address _spender, uint256 _amount) public returns(bool success) {
        allowances[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;

    }

    function allowance(address _owner, address _spender) public view returns(uint256 remaining) {
        remaining = allowances[_owner][_spender];
        return remaining;
    }

    function mint(address _to, uint256 _amount) public ownable returns(bool success) {
        tokenTotalSupply += _amount;
        balances[_to] += _amount;
        emit Transfer(address(0), _to, _amount, 0);
        return true;
    }
}