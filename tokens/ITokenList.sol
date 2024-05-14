// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @dev List of Token mappings for Link Swap CCIP Transfer
 * Listable ~60k tokens
 */
interface ITokenList {
    struct Token {
        address tokenAddress;
        uint16 tokenId;
    }

    /**
     * @dev List a token. This must match for other Token List on other chains
     * [1, 0x11f00b9fcefc58cdFe2FFD311c4aB490d964f3C0]
     */
    function add(Token memory _token) external;

    function remove(uint16 _tokenId) external;

    function getToken(uint16 _tokenId) external view returns (address);

    function getTokens(
        uint16 _start,
        uint16 _limit
    ) external view returns (Token[] memory);
}
