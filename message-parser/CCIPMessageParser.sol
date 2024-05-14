// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Strings.sol";

library CCIPMessageParser {
    struct CCIPData {
        address reciever;
        uint16 tokenId;
        uint80 value;
    }

    function _parseCCIPData(uint256 ccipData)
        internal
        pure
        returns (CCIPData memory data)
    {
        address reciever = address(uint160(ccipData));
        uint80 value = uint80(ccipData >> 160);
        uint16 tokenId = uint16(ccipData >> (160 + 80));
        return CCIPData(reciever, tokenId, value);
    }

    function _packCCIPData(CCIPData memory data)
        internal
        pure
        returns (uint256)
    {
        return
            uint160(data.reciever) |
            (uint256(data.value) << 160) |
            (uint256(data.tokenId) << (160 + 80));
    }

    function _parseCCIPDataAsString(string calldata ccipData)
        internal
        pure
        returns (CCIPData memory data)
    {
        return _parseCCIPData(stringToUint256(ccipData));
    }

    function _parseCCIPDataAsStringMemory(string memory ccipData)
        internal
        pure
        returns (CCIPData memory data)
    {
        return _parseCCIPData(stringMemoryToUint256(ccipData));
    }

    function _packCCIPDataAsString(CCIPData memory data)
        internal
        pure
        returns (string memory)
    {
        return Strings.toString(_packCCIPData(data));
    }

    function stringToUint256(string calldata numString)
        internal
        pure
        returns (uint256)
    {
        uint256 val = 0;
        bytes memory stringBytes = bytes(numString);
        for (uint256 i = 0; i < stringBytes.length; i++) {
            uint256 exp = stringBytes.length - i;
            bytes1 ival = stringBytes[i];
            uint8 uval = uint8(ival);
            uint256 jval = uval - uint256(0x30);

            val += (uint256(jval) * (10**(exp - 1)));
        }
        return val;
    }

    function stringMemoryToUint256(string memory numString)
        internal
        pure
        returns (uint256)
    {
        uint256 val = 0;
        bytes memory stringBytes = bytes(numString);
        for (uint256 i = 0; i < stringBytes.length; i++) {
            uint256 exp = stringBytes.length - i;
            bytes1 ival = stringBytes[i];
            uint8 uval = uint8(ival);
            uint256 jval = uval - uint256(0x30);

            val += (uint256(jval) * (10**(exp - 1)));
        }
        return val;
    }
}
