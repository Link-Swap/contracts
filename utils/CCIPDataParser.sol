// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @dev convert LinkSwap Information on chain for CCIP process
 * Used in CCIP to validate tokens, payments on chains in storage efficient and
 * easy transferrable format
 */
library CCIPDataParser {
    struct Data {
        address reciever;
        uint16 tokenId;
        uint80 value;
    }

    /**
     * @dev converts data struct to uint256 type
     */
    function pack(Data memory data) internal pure returns (uint256) {
        return
            uint160(data.reciever) |
            (uint256(data.value) << 160) |
            (uint256(data.tokenId) << (160 + 80));
    }

    function packAsString(
        Data memory data
    ) internal pure returns (string memory) {
        return Strings.toString(pack(data));
    }

    /**
     * @dev converts uint256 to data struct for ccip
     */
    function parse(uint256 data) internal pure returns (Data memory) {
        address reciever = address(uint160(data));
        uint80 value = uint80(data >> 160);
        uint16 tokenId = uint16(data >> (160 + 80));
        return Data(reciever, tokenId, value);
    }

    function parseAsStringCallData(
        string calldata ccipData
    ) internal pure returns (Data memory data) {
        return parse(stringCallDataToUint256(ccipData));
    }

    function parseAsString(
        string memory ccipData
    ) internal pure returns (Data memory data) {
        return parse(stringToUint256(ccipData));
    }

    /**
     * @dev converts a string calldata to uint256 type
     */
    function stringCallDataToUint256(
        string calldata data
    ) internal pure returns (uint256) {
        return stringToUint256(data);
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
