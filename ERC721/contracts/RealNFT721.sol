// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "./ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RealNFT721 is ERC721, Ownable {
    address private _owner;
    mapping (uint => uint) _prices;
    uint currentTokenId = 0;
    uint public maxSupply = 20;
    string baseURI = "ipfs://QmTXMRW7i7zTbjEbcqdLVQvv85y4qL7imCyrktn9URSPDt/";

    constructor() ERC721("Space", "SP") {
        _owner = msg.sender;
    }

    function _baseURI() internal override view returns(string memory) {
        return baseURI;
    }

    function createItem() public onlyOwner {
        require(currentTokenId < maxSupply, "token ends");
        _mint(msg.sender, currentTokenId);
        currentTokenId++;
    }

    function listItem(uint _price, uint _tokenId) external {
        require(_isApprovedOrOwner(msg.sender, _tokenId), "not allowance");
        _prices[_tokenId] = _price; 
    }

    function cancel(uint _tokenId) public {
        require(_isApprovedOrOwner(msg.sender, _tokenId), "not allowance");
        delete _prices[_tokenId];
    }

    function getPrice(uint tokenId) public view returns(uint) {
        require(_prices[tokenId] != 0, "token not sell");
        return _prices[tokenId];
    }

    function buyItem(uint _tokenId) external payable {
        require(_prices[_tokenId] != 0, "token not sell");
        require(msg.value == getPrice(_tokenId), "incorrect price");
        _transfer(ownerOf(_tokenId), msg.sender, _tokenId);
        cancel(_tokenId);
    }
}