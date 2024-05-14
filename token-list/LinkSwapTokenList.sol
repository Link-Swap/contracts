// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ILinkSwapTokenList.sol";

contract LinkSwapTokenList is AccessControl, ILinkSwapTokenList {
    mapping(uint16 => Token) private tokenList;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    // [1, 0x11f00b9fcefc58cdFe2FFD311c4aB490d964f3C0]
    function addToken(Token memory _token) external onlyRole(MINTER_ROLE) {
        tokenList[_token.tokenId] = _token;
    }

    function removeToken(uint16 _tokenId) external onlyRole(MINTER_ROLE) {
        delete tokenList[_tokenId];
    }

    function getToken(uint16 _tokenId) external view returns (address) {
        return tokenList[_tokenId].tokenAddress;
    }

    function getTokens(
        uint16 _start,
        uint16 _limit
    ) external view returns (Token[] memory) {
        require(_start >= 0 && _limit > 0, "Invalid pagination parameters");

        uint16 endIndex = _start + _limit;
        if (endIndex > type(uint16).max) {
            endIndex = type(uint16).max; // Prevent overflow
        }

        // Determine the actual number of tokens to fetch
        uint16 numTokens = endIndex - _start;
        Token[] memory tokens = new Token[](numTokens);

        uint16 index = 0;
        for (uint16 i = _start; i < endIndex; i++) {
            if (tokenList[i].tokenAddress != address(0)) {
                tokens[index] = tokenList[i];
                index++;
            }
        }

        return tokens;
    }
}
