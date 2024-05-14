// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../utils/FunctionsParser.sol";

contract FunctionsParserContract {
    function pack(
        uint64 destinationChainSelector,
        address receiver
    ) public pure returns (uint256) {
        return FunctionsParser.pack(destinationChainSelector, receiver);
    }

    function packAsBytes(
        uint64 destinationChainSelector,
        address receiver
    ) public pure returns (bytes32) {
        return FunctionsParser.packAsBytes(destinationChainSelector, receiver);
    }

    function packAsBytesMemory(
        uint64 destinationChainSelector,
        address receiver
    ) public pure returns (bytes memory) {
        return
            FunctionsParser.packAsBytesMemory(
                destinationChainSelector,
                receiver
            );
    }

    function parse(
        uint256 data
    ) public pure returns (FunctionsParser.CCIPArgs memory) {
        return FunctionsParser.parse(data);
    }

    function parseAsBytes(
        bytes32 data
    ) public pure returns (FunctionsParser.CCIPArgs memory) {
        return FunctionsParser.parseAsBytes(data);
    }

    function parseAsBytesMemory(
        bytes memory data
    ) public pure returns (FunctionsParser.CCIPArgs memory) {
        return FunctionsParser.parseAsBytesMemory(data);
    }
}
