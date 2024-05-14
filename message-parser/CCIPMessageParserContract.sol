// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "./CCIPMessageParser.sol";

contract CCIPMessageParserContract {
    function parseCCIPData(uint256 ccipData)
        public
        pure
        returns (CCIPMessageParser.CCIPData memory data)
    {
        return CCIPMessageParser._parseCCIPData(ccipData);
    }

    function packCCIPData(CCIPMessageParser.CCIPData memory data)
        public
        pure
        returns (uint256)
    {
        return CCIPMessageParser._packCCIPData(data);
    }

    function parseCCIPDataAsString(string memory ccipData)
        public
        pure
        returns (CCIPMessageParser.CCIPData memory data)
    {
        return CCIPMessageParser._parseCCIPDataAsStringMemory(ccipData);
    }

    function packCCIPDataAsString(CCIPMessageParser.CCIPData memory data)
        public
        pure
        returns (string memory)
    {
        return CCIPMessageParser._packCCIPDataAsString(data);
    }
}
