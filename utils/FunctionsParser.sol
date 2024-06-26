// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @dev convert Chainlinks CCIP Data to uint256 and vice versa
 * Used in Chainlink Functions to get ccip router address and reciver for CCIP
 * contracts
 */
library FunctionsParser {
    struct CCIPArgs {
        uint64 destinationChainSelector;
        address receiver;
        // 32 bytes remaining for payload
    }

    /**
     * @dev convert Chainlinks CCIP Data to uint256
     */
    function pack(uint64 destinationChainSelector, address receiver)
        internal
        pure
        returns (uint256)
    {
        return uint160(receiver) | (uint256(destinationChainSelector) << 160);
    }

    function packAsBytes(uint64 destinationChainSelector, address receiver)
        internal
        pure
        returns (bytes32)
    {
        return bytes32(pack(destinationChainSelector, receiver));
    }

    function packAsBytesMemory(
        uint64 destinationChainSelector,
        address receiver
    ) internal pure returns (bytes memory) {
        return
            abi.encodePacked(packAsBytes(destinationChainSelector, receiver));
    }

    /**
     * @dev converts uint256 to Chainlink CCIP Data for CCIP contracts
     */
    function parse(uint256 data) internal pure returns (CCIPArgs memory) {
        address reciever = address(uint160(data));
        uint64 destinationChainSelector = uint64(data >> 160);
        // uint32 future = uint32(ccipData >> (160 + 32));
        return CCIPArgs(destinationChainSelector, reciever);
    }

    function parseAsBytes(bytes32 data)
        internal
        pure
        returns (CCIPArgs memory)
    {
        return parse(uint256(data));
    }

    function parseAsBytesMemory(bytes memory data)
        internal
        pure
        returns (CCIPArgs memory)
    {
        return parseAsBytes(abi.decode(data, (bytes32)));
    }

    function parseAsString(string memory data)
        internal
        pure
        returns (CCIPArgs memory)
    {
        return parse(stringToUint256(data));
    }

    /**
     * @dev converts a string memory to uint256 type
     * @notice very expensive and may fail
     */
    function stringToUint256(string memory data)
        internal
        pure
        returns (uint256)
    {
        uint256 val = 0;
        bytes memory b = bytes(data);
        for (uint256 i = 0; i < b.length; i++) {
            uint256 c = uint256(uint8(b[i]));
            if (c >= 48 && c <= 57) {
                val = val * 10 + (c - 48);
            }
        }

        return val;
    }
}
