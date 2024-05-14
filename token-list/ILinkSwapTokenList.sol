// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

// should be able to map over 60k+ tokens
interface ILinkSwapTokenList {
    struct Token {
        address tokenAddress;
        uint16 tokenId;
    }

    function addToken(Token memory _token) external;

    function removeToken(uint16 _tokenId) external;

    function getToken(uint16 _tokenId) external view returns (address);
}
