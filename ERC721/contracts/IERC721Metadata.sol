// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

import "./IERC721.sol";

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory _name);
    function symbol() external view returns (string memory _symbol);
    function tokenURI(uint256 _tokenId) external view returns (string memory);
}
