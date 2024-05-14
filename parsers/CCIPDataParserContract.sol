// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../utils/CCIPDataParser.sol";

contract CCIPDataParserContract {
    function pack(
        CCIPDataParser.Data memory data
    ) public pure returns (uint256) {
        return
            uint160(data.reciever) |
            (uint256(data.value) << 160) |
            (uint256(data.tokenId) << (160 + 80));
    }

    function packAsString(
        CCIPDataParser.Data memory data
    ) public pure returns (string memory) {
        return CCIPDataParser.packAsString(data);
    }

    function parse(
        uint256 data
    ) public pure returns (CCIPDataParser.Data memory) {
        return CCIPDataParser.parse(data);
    }

    function parseAsStringCallData(
        string calldata data
    ) public pure returns (CCIPDataParser.Data memory) {
        return CCIPDataParser.parseAsStringCallData(data);
    }

    function parseAsString(
        string memory data
    ) public pure returns (CCIPDataParser.Data memory) {
        return CCIPDataParser.parseAsString(data);
    }
}
