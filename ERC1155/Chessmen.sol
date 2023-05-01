// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Chessmen is ERC1155, Ownable {
    using Strings for uint;

    string public constant name = "Chessmen";

    mapping(uint => uint) private _maxSupply;
    mapping(uint => uint) private _totalSupply;
    mapping(address => bool) private whiteList;
    uint256 private currentPrice = 0.1 ether;
    uint8 public maxId = 12;

    constructor() ERC1155("ipfs://QmW6VV3RqiXhVXCPnvFCtJ9a4JYLKeXtW2Wx1s245vNYqs/{id}.json") {
        
        _maxSupply[0] = _maxSupply[1] = 8;
        for (uint i = 2; i < 8; i++) {
            _maxSupply[i] = 2;
        }
        for (uint i = 8; i < 12; i++) {
            _maxSupply[i] = 1;
        }
    }

    function maxSupply(uint _tokenId) public view returns(uint) {
        return _maxSupply[_tokenId];
    }

    function totalSupply(uint _tokenId) public view returns(uint) {
        return _totalSupply[_tokenId]; 
    }

    // function uri(uint256 _tokenId) public view override returns (string memory) {
    //     return string(abi.encodePacked(baseURI, _tokenId.toString(), ".json"));
    // }

    function mint(address account, uint256 id, uint256 amount) public onlyOwner {
        mint_(account, id, amount);
    }

    function buyNft(uint256 id, uint256 amount) public payable {
        require(msg.value == currentPrice * amount, "incorrect price");
        require(whiteList[msg.sender] == true, "you are not in whitelist!");
        mint_(msg.sender, id, amount);
    }

    function mint_(address account, uint256 id, uint256 amount) private {
        require(id < maxId, "not token with this ID");
        require(_totalSupply[id] + amount <= _maxSupply[id], "Supply limit for this id will be exceeded");
        _mint(account, id, amount, "");
        _totalSupply[id] += amount;
    }

    function addWhitelist(address buyer, bool state) public onlyOwner {
        whiteList[buyer] = state;
    }
}