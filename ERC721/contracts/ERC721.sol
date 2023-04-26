// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "./IERC721Metadata.sol";
import "./IERC721Receiver.sol";
import "./ERC165.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";

contract ERC721 is IERC721Metadata, IERC721Receiver, ERC165 {
    using Strings for uint256;

    string private _name;
    string private _symbol;

    mapping(address => uint) _balances;
    mapping(uint => address) _owners;
    mapping(uint => address) _tokenApprovals;
    mapping(address => mapping(address => bool)) _operatorApprovals; //operator => owner => can operator operate  owner's nft or not

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    modifier _requireMinted(uint tokenId) {
        require(_exists(tokenId), 'NFT not enough minted');
        _;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory){
        return _symbol;
    }

    function _baseURI() internal view virtual returns(string memory) {
        return "";
    }

    function tokenURI(uint256 _tokenId) public view _requireMinted(_tokenId) returns (string memory){
        string memory baseURI = _baseURI();
            return (bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, _tokenId.toString(), ".json"))
                : "");
    }

    function balanceOf(address _owner) public view returns (uint256){
        require(_owner != address(0), "incorrect address");
        return _balances[_owner];
    }

    function ownerOf(uint256 _tokenId) public view _requireMinted(_tokenId) returns (address){
        return _owners[_tokenId];
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable{
        require(_isApprovedOrOwner(msg.sender, _tokenId), "not an owner or approval"); //You shall not pass!
        _transfer(_from, _to, _tokenId);
        require(_checkOnERC721received(_from, _to , _tokenId, bytes('')), "non erc721 receiver");        
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) public payable{
        require(_isApprovedOrOwner(msg.sender, _tokenId), "not an owner or approval"); //You shall not pass!
        _transfer(_from, _to, _tokenId);
        require(_checkOnERC721received(_from, _to , _tokenId, data), "non erc721 receiver");
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
        require(_isApprovedOrOwner(msg.sender, _tokenId), "not an owner or approval"); //You shall not pass!
        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId) public payable {
        address _owner = ownerOf(_tokenId);
        require (_owner == msg.sender || isApprovedForAll(_owner, msg.sender), "not allowance");
        _tokenApprovals[_tokenId] = _approved;

        emit Approval(msg.sender, _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) public {
        _operatorApprovals[_operator][msg.sender] = _approved;

        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) public view _requireMinted(_tokenId) returns (address){
        return _tokenApprovals[_tokenId];
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return _operatorApprovals[_operator][_owner];
    }

    function _exists(uint tokenId) internal view returns(bool) {
        return _owners[tokenId] != address(0);  //The Flying Dutchman must always have a captain :-)
    }

    function _isApprovedOrOwner(address spender, uint tokenId) internal view returns(bool) {
        address owner = ownerOf(tokenId);
        return (
            spender == owner ||
            isApprovedForAll(owner, spender) ||
            getApproved(tokenId) == spender
        );
    }

    function _checkOnERC721received(address from, address to, uint tokenId, bytes memory data) private returns(bool) {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 ret) {
                return ret == IERC721Receiver.onERC721Received.selector;
            } catch(bytes memory reason) {
                if (reason.length == 0) {
                    revert("Non ERC721 receiver");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _transfer(address from, address to, uint tokenId) internal {
        require (ownerOf(tokenId) == from, "incorrect from address");
        require (to != address(0), "zero address");

        _balances[from]--;
        _balances[to]++;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _safeMint(address to, uint tokenId) internal virtual {
        _mint(to, tokenId);

        require(_checkOnERC721received(msg.sender, to , tokenId, bytes('')), "non erc721 receiver");
    }

    function _mint(address to, uint tokenId) internal virtual {
        require(to != address(0), "null address");
        require(!_exists(tokenId), "alrady exists");

        _owners[tokenId] = to;
        _balances[to]++;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint tokenId) internal virtual {
        require(_isApprovedOrOwner(msg.sender, tokenId), "not allowance");
        address _owner = ownerOf(tokenId);
        delete _tokenApprovals[tokenId];
        _balances[_owner]--;
        delete _owners[tokenId];

        emit Transfer(_owner, address(0), tokenId);
    }

    function onERC721Received(
    address,
    address,
    uint,
    bytes calldata
  ) external pure returns(bytes4) {
    return IERC721Receiver.onERC721Received.selector;
  }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(IERC721).interfaceId || super.supportsInterface(interfaceId);
    }
}